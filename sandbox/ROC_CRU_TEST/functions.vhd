--! \file
--! \brief Type declarations.

--! Standard library
library ieee;
use ieee.std_logic_1164.all;  --! Standard logic
use ieee.numeric_std.all;     --! Numeric/arithmetical logic (IEEE standard)

--! Work library (self-composed)
library work;
use work.constants.all;       --! Global constants
use work.types.all;           --! Global types'

package functions is
  function pack          (this : fe_ch_event_data_type ) return std_logic_vector;
  function pack          (this : cs_vio_type           ) return std_logic_vector;
  function unpack_event  (this : std_logic_vector      ) return fe_ch_event_data_type;
  function unpack_cs_vio (this : std_logic_vector      ) return cs_vio_type;
  function strip_event_no(this : fe_ch_event_data_type ) return fe_ch_event_data_reduced_type;
  function get_event_no  (this : fe_ch_event_data_type ) return std_logic_vector;
  function bitwise_and   (this : std_logic_vector      ) return std_logic;
  function bitwise_or    (this : std_logic_vector      ) return std_logic;
  function bitwise_sum   (this : std_logic_vector      ) return natural;
--   function dynamic_shift (this : std_logic_vector      ) return std_logic;
  function log2          (N    : natural               ) return positive;
  function find_L        (N    : positive; F: positive ) return natural;
end package functions;

--! \brief Types
package body functions is
  --! Functions to pack those records up...
--   function pack(this : fe_ch_event_data_type) return std_logic_vector;
  function pack(this : fe_ch_event_data_type) return std_logic_vector is
    variable packed_data : std_logic_vector(31 downto 0);
  begin
    packed_data := this.event_no & this.ch_no & this.tot_start & this.tot_width;
    return packed_data;
  end function;

  function pack(this : cs_vio_type) return std_logic_vector is
    variable packed_data : std_logic_vector(cs_VIO_SIZE-1 downto 0);
  begin
    packed_data := this.other &
                   this.mask_inputs &
                   this.negate_inputs &
                   this.ch_select &
                   this.data_delay &
                   this.cotrg_en &
                   this.fe_soft_rst_b & 
                   this.readout_en &
                   this.test_en;
    return packed_data;
  end function;


  --These can not be overloaded, so I use different names instead. Alternative 
  --would be procedures
  function unpack_event(this : std_logic_vector) return fe_ch_event_data_type is
    variable tmp : fe_ch_event_data_type;
    variable L1 : natural := tmp.tot_width'length ;
    variable L2 : natural := tmp.tot_start'length ;
    variable L3 : natural := tmp.ch_no'length     ;
    variable L4 : natural := tmp.event_no'length  ;
 
  begin
    tmp.event_no  := this(L4+L3+L2+L1-1 downto L3+L2+L1);
    tmp.ch_no     := this(   L3+L2+L1-1 downto    L2+L1);
    tmp.tot_start := this(      L2+L1-1 downto       L1);
    tmp.tot_width := this(         L1-1 downto        0);
    return tmp;
  end function;

  function unpack_cs_vio(this : std_logic_vector) return cs_vio_type is
    variable tmp : cs_vio_type;
    variable L1 : natural := 1                        ; --test_en
    variable L2 : natural := 1                        ; --readout_en
    variable L3 : natural := 1                        ; --fe_soft_rst_b
    variable L4 : natural := 1                        ; --cotrg_en
    variable L5 : natural := tmp.data_delay'length    ;
    variable L6 : natural := tmp.ch_select'length     ;
    variable L7 : natural := tmp.negate_inputs'length ;
    variable L8 : natural := tmp.mask_inputs'length   ;
    variable L9 : natural := tmp.other'length         ;
 
  begin
    tmp.other         := this(L9+L8+L7+L6+L5+L4+L3+L2+L1-1 downto L8+L7+L6+L5+L4+L3+L2+L1);
    tmp.mask_inputs   := this(   L8+L7+L6+L5+L4+L3+L2+L1-1 downto    L7+L6+L5+L4+L3+L2+L1);
    tmp.negate_inputs := this(      L7+L6+L5+L4+L3+L2+L1-1 downto       L6+L5+L4+L3+L2+L1);
    tmp.ch_select     := this(         L6+L5+L4+L3+L2+L1-1 downto          L5+L4+L3+L2+L1);
    tmp.data_delay    := this(            L5+L4+L3+L2+L1-1 downto             L4+L3+L2+L1);
    tmp.cotrg_en      := this(                                                   L3+L2+L1);
    tmp.fe_soft_rst_b := this(                                                      L2+L1);
    tmp.readout_en    := this(                                                         L1);
    tmp.test_en       := this(                                                          0);
    return tmp;
  end function;

  -- The event builder will multiplex data with _known_ event number, so we strip it from the data
  function strip_event_no ( this : fe_ch_event_data_type ) return fe_ch_event_data_reduced_type is
    variable tmp : fe_ch_event_data_reduced_type;
  begin
      tmp.ch_no     := this.ch_no     ;
      tmp.tot_start := this.tot_start ;
      tmp.tot_width := this.tot_width ;
    return tmp;
  end function;

  -- Complements the above function. Returns only the event number
  function get_event_no ( this : fe_ch_event_data_type ) return std_logic_vector is
  begin
    return this.event_no;
  end function;


  --! Bitwise and - implemented with recursive functions (to 'ensure' the synthesis of and-tree)
  function bitwise_and(this : std_logic_vector) return std_logic is
    variable temp_and : std_logic ;
    variable this_tmp : std_logic_vector( this'length-1 downto 0 );

  begin
    this_tmp := this;
    if this_tmp'length >= 2 then --! Split into adder tree
      temp_and :=  bitwise_and(this_tmp(this_tmp'length  -1 downto this_tmp'length/2 ))
               and bitwise_and(this_tmp(this_tmp'length/2-1 downto                 0 ));
    else
      if this_tmp(0) = '1' then temp_and := '1';
      else                      temp_and := '0';
      end if;
    end if;
    return temp_and;
  end function;

  --! Bitwise or - implemented with recursive functions (to 'ensure' the synthesis of or-tree)
  function bitwise_or(this : std_logic_vector) return std_logic is
    variable temp_or  : std_logic ;
    variable this_tmp : std_logic_vector( this'length-1 downto 0 );
  begin
    this_tmp := this;
    if this_tmp'length >= 2 then --! Split into adder tree
      temp_or :=  bitwise_or(this_tmp(this_tmp'length  -1 downto this_tmp'length/2 ))
               or bitwise_or(this_tmp(this_tmp'length/2-1 downto                 0 ));
    else
      if this_tmp(0) = '1' then temp_or := '1';
      else                      temp_or := '0';
      end if;
    end if;
    return temp_or;
  end function;

  --! Bitwise sum - implemented with recursive functions (to 'ensure' the synthesis of adder tree)
  --! Usage note: Since this returns an integer - say 'a' - you have to use to_unsigned(a,<size>)
  --!             (or something similar), and set the number of bits (size) yourself.
  function bitwise_sum(this : std_logic_vector) return natural is
    --! Use integer to store result with the least amount of bits possible
    variable temp_sum : natural range 0 to this'length;
    variable this_tmp : std_logic_vector( this'length-1 downto 0 );

  begin
    this_tmp := this;
    if this_tmp'length >= 2 then --! Split into adder tree
      temp_sum := bitwise_sum(this_tmp(this_tmp'length  -1 downto this_tmp'length/2 ))
                + bitwise_sum(this_tmp(this_tmp'length/2-1 downto                 0 ));
    else
      if this_tmp(0) = '1' then temp_sum := 1;
      else                      temp_sum := 0;
      end if;
    end if;
    return temp_sum;
  end function;

  -- ceil(log2(N)) - handy to find the number of bits necessary to represent
  -- some number...
  function log2(N: natural) return positive is
  begin
    if N < 2 then
      return 1;
    else
      return 1 + log2(N/2);
    end if;
  end function;

  --! Right, this requires explaination. Consider the submux structure in a case where each 
  --! MUX has a fan-in F=2, a depth L=3, and number of channels is N=8. This satisfies the
  --! relation
  --!             N = F^L       (all being positive integers)
  --!
  --! But given N and F, how can we find L? How about
  --!             L = ln N / ln F   ?
  --!
  --! Naturally, doing this without floats sucks, and even if these were available to us we'd
  --! have to evaluate potential floating-point approximation issues. However, instead of
  --! calculating it, let us just start a while-loop to see how many levels are needed to
  --! reach N channels with a fan-in of F...
  function find_L(N: positive; F: positive) return natural is
    variable N_tmp : positive;
    variable L     : natural;
  begin
    N_tmp := 1; --! Start off with one channel,
    L     := 0; --! and zero levels (which would be true in the case of only one channel).
    while( N_tmp < N ) loop
      N_tmp := N_tmp * F;
      L     := L + 1;
    end loop;
    return L;
  end function;

end package body functions;

