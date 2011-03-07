--! \file
--! \brief Parametrisation stage.

--! Note that this file is tweaked for optimal performance with a 10bit deserialiser.
--! Some logic may be saved by using 8bits, and performance may possibly be the same -
--! or maybe even better -  since the reduced complexity may allow for a higher base
--! clock frequency. But I am unsure as to whether the slight decrease in logic usage
--! is worth the disadvantages an increased clock speed introduces - like extra power
--! consumption and tighter timing requirements.

--! I have been contemplating as to whether increase the abstraction level of this
--! module to make it easier to play with its relevant parameters, but the price to
--! pay in terms of added complexity and constants seems not to be worth it. Will
--! leave it as is for now. I suggest keeping this as a reference anyways, and simply
--! add new configurations if you want to experiment.

--! Standard library
library ieee;
use ieee.std_logic_1164.all;  --! Standard logic
use ieee.numeric_std.all;     --! Numeric/arithmetical logic (IEEE standard)

--! Xilinx Unisim library
library unisim;
use unisim.vcomponents.all;   --! For simulation

--! Work library (self-composed)
library work;
use work.constants.all;       --! Global constants
use work.types.all;           --! Global types
-- use work.components.all;      --! Global component declarations
use work.functions.all;       --! Global functions

--! \brief Entity
entity fe_ch_pargen is
generic(
  ch_no                 :     natural
);
port(
 --ch_no                :   in  std_logic_vector( fe_ch_LOC_SIZE-1 downto 0 );
  mclk                  : in  std_logic; --! Master clock
  fe_rst_b              : in  std_logic; --! Front-end reset (active low)                     
  data                  : in  std_logic_vector( fe_ch_WORD_WIDTH-1 downto 0 );
  data_delay            : in  std_logic_vector( fe_ch_MAX_DELAY-1  downto 0 ); --! # cycles to delay data in order to sync with coincidence trigger window

  coincidence_trigger   : in  std_logic                      ; --! Event validation
  coarse_time           : in  std_logic_vector( fe_CO_TRG_SIZE-log2(fe_ch_WORD_WIDTH)-1 downto 0 ) ;   --! Co. trg. length
  event_no              : in  std_logic_vector( fe_EVENT_NO_SIZE-1 downto 0 ) ; --! Co.trg cnt
  event_trigger         : out std_logic                      ; --! Sent to the Trigger Unit

  event_data            : out fe_ch_event_data_type          ; --! Event #, time, ch. #, tot
  event_ready           : out std_logic                        --! Fresh event_data present? 
);
end entity;

---------------------------------------------------------------------------------------------------
--! \brief Architecture
architecture rtl of fe_ch_pargen is
---------------------------------------------------------------------------------------------------

type   state_type is (reset_st, wait_st, hold_st);
signal state, next_state  : state_type;

--! \todo Both may not be needed. 
signal data_or              : std_logic := '0';
signal data_or_next         : std_logic := '0';
signal data_or_delayed      : std_logic := '0';
signal data_and             : std_logic := '0';
signal data_and_next        : std_logic := '0';
signal data_and_z1          : std_logic := '0';
signal data_and_delayed     : std_logic := '0';
signal pargen_busy          : std_logic := '0';

-- These signals have sizes to fit with a 10-bit deserialisation configuration
signal fine_time_start      : integer range 0 to   fe_ch_WORD_WIDTH := 0;
signal data_sum_delayed     : integer range 0 to   fe_ch_WORD_WIDTH := 0;
signal fine_width_tot       : integer range 0 to 2*fe_ch_WORD_WIDTH := 0; --! The sum of two fine_widths
signal fine_width_start     : integer range 0 to   fe_ch_WORD_WIDTH := 0;
-- signal fine_width             : std_logic_vector(  3 downto 0 );

signal coarse_width         : natural range 0 to 2**(fe_ch_TOT_SIZE-log2(fe_ch_WORD_WIDTH)+1)-1 := 0;
--signal coarse_width    : integer;

signal total_width          : natural range 0 to 2**(fe_ch_TOT_SIZE+1)-1 := 0;
signal total_width_i        : natural range 0 to 2**(fe_ch_TOT_SIZE+1)-1 := 0;
signal total_time           : natural range 0 to 2**(fe_CO_TRG_SIZE+1)-1 := 0;

--! Why?
--! The coarse counter will be multiplied with 10, added together with the fine-counter
--! (which may have a carry), and this must fit within fe_ch_TOT_SIZE bits...
--! \todo I suspect '/' to floor the constant, but check this out...

signal event_ready_i        : std_logic := '0';
signal event_trigger_i      : std_logic := '0';

signal event_data_i         : fe_ch_event_data_type;
signal event_data_ii        : fe_ch_event_data_type;


signal coarse_time_start    : unsigned( fe_CO_TRG_SIZE-log2(fe_ch_WORD_WIDTH)-1 downto 0 ) := ( others => '0' );

signal data_delay_i         : natural range 0 to 2**fe_ch_MAX_DELAY-2;
signal data_delay_p1        : natural range 0 to 2**fe_ch_MAX_DELAY-1;

signal data_sum             : natural range 0 to fe_ch_WORD_WIDTH := 0;
signal data_sum_i           : std_logic_vector( log2(fe_ch_WORD_WIDTH)-1 downto 0 );

signal data_and_tmp         : std_logic := '0';
signal data_or_tmp          : std_logic := '0';
signal data_sum_tmp         : integer range 0 to fe_ch_WORD_WIDTH;
signal data_sum_tmp_i       : std_logic_vector( log2(fe_ch_WORD_WIDTH)-1 downto 0 );

signal data_and_fixed       : std_logic := '0';
signal data_next_or         : std_logic := '0';
signal record_event         : std_logic := '0';

signal inc                  : natural range 0 to 1 := 0;


begin

  data_delay_i <= to_integer(unsigned(data_delay));--,log2(fe_ch_MAX_DELAY));

  --! Perform bitwise and, or and add (defined in 'functions.vhd'):
  data_or   <= bitwise_or ( data ) ;
  data_and  <= bitwise_and( data ) ;
  data_sum  <= bitwise_sum( data ) ;

  --! We need to record some information of the 'past' to correctly discover all edges.
  process (mclk,fe_rst_b) begin
    if( fe_rst_b = '0' ) then
      data_and_z1 <= '0';
    elsif rising_edge(mclk) then
      data_and_z1 <= data_and;
    end if;
  end process;

  --! Use a driver to ensure a glitch-free event_trigger (note that this adds a cycle delay)
  process (mclk,fe_rst_b)
  begin
    if( fe_rst_b = '0' ) then
      event_trigger_i <= '0';
    elsif( rising_edge(mclk) ) then
      if(  ( data_or = '1' and data_and_z1 = '0' and event_trigger_i = '0' ) ) then
        event_trigger_i <= '1';
      else
        event_trigger_i <= '0';
      end if;
    end if;
  end process;
  event_trigger <= event_trigger_i;


  --! Delay the AND to synchronise it with coincidence trigger
  shift_and: entity work.shift
  generic map(
    depth => 2**fe_ch_MAX_DELAY )   --! Depth of shift-chain
  port map(
    mclk  => mclk              , --! Clock
    i     => data_and          , --! Input
    s     => data_delay_i      , --! Select
    o     => data_and_next    ); --! Output

  --! Delay the OR to synchronise it with coincidence trigger
  shift_or: entity work.shift
  generic map(
    depth => 2**fe_ch_MAX_DELAY )   --! Depth of shift-chain
  port map(
    mclk  => mclk              , --! Clock
    i     => data_or           , --! Input
    s     => data_delay_i      , --! Select
    o     => data_or_next     ); --! Output

  -- 'data_delay' is the "future". These signals are needed to handle a few exception cases
  -- (see thesis for documentation)
  --! Create "present" versions of the AND/OR
  process (mclk, fe_rst_b)
  begin
    if( fe_rst_b = '0' ) then
      data_and_tmp <= '0';
      data_or_tmp <= '0';
    elsif rising_edge(mclk) then
      data_and_tmp <= data_and_next;
      data_or_tmp  <= data_or_next;
    end if;
  end process;

  --! Delay SUM to the "present" aswell
  data_delay_p1  <= data_delay_i+1;
  data_sum_i     <= std_logic_vector(to_unsigned(data_sum,log2(fe_ch_WORD_WIDTH)));
  shift_sum: for i in 0 to log2(fe_ch_WORD_WIDTH)-1 generate
  begin
    shift_sum_i: entity work.shift
    generic map(
      depth => 2**fe_ch_MAX_DELAY )   --! Depth of shift-chain
    port map(
      mclk  => mclk                   , --! Clock
      i     => data_sum_i(i)          , --! Input
      s     => data_delay_p1          , --! Select
      o     => data_sum_tmp_i(i)     ); --! Output
  end generate;
  data_sum_tmp <= to_integer(unsigned(data_sum_tmp_i));


-- (Less code, but does not synthesise with SRLs):
--   process (mclk, fe_rst_b)
--   begin
--     if( fe_rst_b = '0' ) then
--       delay_line_and <= ( others => '0' ) ;
--       delay_line_or  <= ( others => '0' ) ;
--       delay_line_sum <= ( others => (others => '0') );
--     elsif rising_edge(mclk) then
--       delay_line_and <= delay_line_and(delay_line_and'length-2 downto 0) & data_and;
--       delay_line_or  <= delay_line_or( delay_line_and'length-2 downto 0) & data_or;
--       delay_line_sum(2**fe_ch_MAX_DELAY-1 downto 1) <= delay_line_sum(2**fe_ch_MAX_DELAY-2 downto 0);
--       delay_line_sum(0) <= std_logic_vector(to_unsigned(data_sum,log2(fe_ch_WORD_WIDTH)));
--     end if;
--   end process;

  --! Shift output: ()
--   data_and_next      <=  delay_line_and(data_delay_i  );
--   data_or_next       <=  delay_line_or( data_delay_i  );

  --! Create "fixed" versions of the OR and AND signals to handle exceptions (see thesis)
  data_next_or   <= data_and_next    or  data_or_next; --! \todo uhm, redundant...
  data_and_fixed <= data_and_delayed and pargen_busy;--data_next_or;

  --! The data frames are verified by the coincidence window, but the pargen module must also
  --! be able to finish the processing of an event even if the coincidence trigger is deasserted
  process( coincidence_trigger, pargen_busy, data_sum_tmp, data_and_tmp, data_or_tmp)
  begin
    if( coincidence_trigger = '1' or pargen_busy = '1' ) then
      data_and_delayed <= data_and_tmp;
      data_or_delayed  <= data_or_tmp;
      data_sum_delayed <= data_sum_tmp;
    else
      data_and_delayed <= '0';
      data_or_delayed  <= '0';
      data_sum_delayed <=  0;
    end if;
  end process;

  -- Cast rules:
  -- integer_signal <= to_integer(signed(slv_signal))
  -- integer_signal <= to_integer(unsigned(slv_signal))
  -- slv_signal <= std_logic_vector(to_signed(integer_signal,<# of bits>)
  -- slv_signal <= std_logic_vector(to_unsigned(integer_signal,<# of bits>)


  --! Ideas for fine timetag:
  --  - Use 10 MUX for reverting data on rising edge, 1 common 10-4 decoder, and 1 10bit adder (realtime).
  --  - Use 2 10-1 decoders (one with data reversed), and 1 10bit adder (realtime).
  --  - Use a shift chain and 1 10bit adder (just count number of 1's) More latency, less logic.
  --  - Use a bunch of 2bit adders in a tree to sum 1's on-the-fly (realtime) - CURRENT.

  --! ASM Synchronisation aka. "the heart" :)
  sync_proc: process (fe_rst_b, mclk) begin
    if( fe_rst_b = '0' ) then
      state <= reset_st;
    elsif( rising_edge(mclk) ) then
      state <= next_state;
    end if;
  end process;

  --! Next state logic
  next_and_output: process (state,data_or_delayed,data_and_fixed )
  begin
    case( state ) is
      when reset_st  =>                                   next_state <= wait_st ;
      when wait_st   => if( data_or_delayed  = '1' ) then next_state <= hold_st ;
                        else                              next_state <= wait_st ;
                        end if;
      when others   =>  if( data_and_fixed = '0' ) then   next_state <= wait_st ;
                        else                              next_state <= hold_st ;
                        end if;
    end case;
  end process;
    
  --! At a leading edge, record coarse and fine time information.
  start_drv: process ( mclk,fe_rst_b )
  begin
    if( fe_rst_b = '0' ) then
      pargen_busy            <= '0';
      event_data_ii.event_no <= ( others => '0' );
      coarse_time_start      <= ( others => '0' );
      fine_width_start       <= 0;
    elsif( rising_edge(mclk) ) then
      if( state = wait_st ) then --CE
        if( data_or_delayed = '1' ) then --load
          pargen_busy <= '1';
          event_data_ii.event_no <= event_no;
          coarse_time_start      <= unsigned(coarse_time);
          fine_width_start       <= data_sum_delayed;
        else
          pargen_busy <= '0';
          event_data_ii.event_no <= event_data_ii.event_no;
          coarse_time_start      <= coarse_time_start;
          fine_width_start       <= fine_width_start;
        end if;
      end if;
    end if;
  end process;

  --! 'fine_width_start' is the number of '1's, the start timetag is really the number of '0's
  fine_time_start <= fe_ch_WORD_WIDTH-fine_width_start;

  --! To handle exception - see thesis
  inc <= 1 when (data_and_fixed = '1') else 0; 

  --! Count up the 'coarse_width' variable as long as 'data_and' is high.
  coarse_width_count: process ( mclk,fe_rst_b )
  begin

    if( fe_rst_b = '0' ) then
      coarse_width <= 0;
    elsif( rising_edge(mclk) ) then
      if( data_and_delayed = '1' ) then
        coarse_width <= coarse_width + inc;
		  --coarse_width <= coarse_width + 1; --mr
      else
        coarse_width <= 0;
      end if;
    end if;
  end process;

  --! If the TOT is too long and coarse_width max out, we assert 'tot_overflow'
  --! \todo Check logic usage on this one. Should be near 0, else add a MSB to counter as overflow-bit.
--   coarse_width_overflow_test: process ( coarse_width )
--   begin
--     if( coarse_width = 2**(coarse_width'length)-1 ) then
--       coarse_width_overflow <= '1';
--     else
--       coarse_width_overflow <= '0';
--     end if;
--   end process;

  --! The total "fine width" is the sum of the (stored) fine width in start frame,
  --! plus the current fine width. At trailing edge, the total "fine width" are recorded.
  fine_width_tot  <= data_sum_delayed + fine_width_start;-- +1;-- MR
  --! The +1 is to make width match the expectation value, see thesis.

  --! Note. This only works because we currently use 10-bits deserialisation; the basesystem for
  --! coarse- and finetime must match to be able to simply add them up. However, if e.g. 8-bits
  --! deserialisation is chosen you may simply add the MSB from fine_width to coarse_width, and
  --! simply concatenate the result with the remaining bits of fine_width. Even better really.
  --! Edit: Using integers may possibly lead to correct synthesis in any case...

  --! Infer a few MACs to compute the total width and time from coarse and fine time information.
  
  total_width_i<= coarse_width                 *fe_ch_WORD_WIDTH + fine_width_tot;
  total_time  <= to_integer(coarse_time_start)*fe_ch_WORD_WIDTH + fine_time_start;  
  
  total_width <= total_width_i when(total_width_i < 2**(fe_ch_TOT_SIZE)) else 2**(fe_ch_TOT_SIZE)-1;
  
  
  

  --! Wrap the parameters in an event package.
  event_data_ii.tot_width <= std_logic_vector(to_unsigned(total_width, fe_ch_TOT_SIZE));
  event_data_ii.tot_start <= std_logic_vector(to_unsigned(total_time,  fe_CO_TRG_SIZE));
  event_data_ii.ch_no     <= std_logic_vector(to_unsigned(ch_no, fe_ch_LOC_SIZE));

  --! Exception handling: 'record_event' is asserted when the TOT tracking must be terminated
  --! one clock earlier.
  process (mclk,fe_rst_b)
  begin
    if( fe_rst_b = '0' ) then
      record_event   <= '0' ;
    elsif( rising_edge(mclk) ) then
      if( state = hold_st and data_next_or = '0' and data_and_delayed = '1' ) then
        record_event <= '1'; --! Exception case. See thesis.
      else
        record_event <= '0';
      end if;
    end if;
  end process;

  --! Buffer the event data and mark it as ready
  event_drv: process ( fe_rst_b, mclk )
  begin
    if( fe_rst_b = '0' ) then
      event_data_i.event_no   <= ( others => '0' );
      event_data_i.tot_start  <= ( others => '0' );
      event_data_i.tot_width  <= ( others => '0' );
      event_data_i.ch_no      <= ( others => '0' );
      event_ready_i <= '0';
    elsif( rising_edge(mclk) ) then
      if( ((data_and_delayed = '0') and (state = hold_st)) or record_event = '1' ) then
        event_data_i <= event_data_ii; --! Necessary; Event data gets sampled
        event_ready_i <= '1';          --!            1cycle after event_ready..
      else
        event_data_i <= event_data_i;
        event_ready_i <= '0';
      end if;
    end if;
  end process;

event_data  <= event_data_i;
event_ready <= event_ready_i;


end architecture;

