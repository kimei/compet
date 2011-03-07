--! \file
--! \brief Coincidence trigger processing module

--! The coincidence trigger validates the data lines of this card, but but for data
--! identification it is also necessary to keep track of the window length and the
--! number of events that has been recorded. This is what this module if for.

--! Additionally, the EventBuilder needs to know what event number it may request from the
--! channel FIFOs. At minimum it needs to wait 2^fe_ch_TOT_SIZE cycles after 


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

--! \brief This is the Top entity
--! \details And this is some more details
entity fe_cotrg_proc is
port(
  mclk                  : in  std_logic; --! Master clock
  fe_rst_b              : in  std_logic; --! Front-end reset (active low)
                      
  coincidence_trigger   : in  std_logic ; --! Recieved from Trigger Unit
  
  event_no              : out std_logic_vector( fe_EVENT_NO_SIZE-1 downto 0 ); --! Co.trg. counter
  event_no_max          : out std_logic_vector( fe_EVENT_NO_SIZE-1 downto 0); --! Last valid evt.no.
  coarse_time           : out std_logic_vector( fe_CO_TRG_SIZE-log2(fe_ch_WORD_WIDTH)-1 downto 0 ) --try leave -1 away. MR    --! Window length
);
end entity;
       
---------------------------------------------------------------------------------------------------
--! \brief Architecture
architecture rtl of fe_cotrg_proc is
---------------------------------------------------------------------------------------------------

type   state_type is (reset_st, ready_st, cotrg_hold_st);
signal state, next_state  : state_type;

signal event_no_i         : unsigned( fe_EVENT_NO_SIZE-1 downto 0 ) := (others => '0'); --! Co.trg. counter
signal coarse_time_i      : unsigned( fe_CO_TRG_SIZE-log2(fe_ch_WORD_WIDTH)-1 downto 0 ) := ( others => '0' ) ;  -- increase as well!

signal cotrg_end          : std_logic := '0';
signal cotrg_end_delayed  : std_logic; 
signal event_no_max_i     : unsigned( fe_EVENT_NO_SIZE-1 downto 0 ) := ( others => '0' );

signal event_no_inc       : unsigned( 1 downto 0 );
signal event_no_max_inc   : unsigned( 1 downto 0 );
begin

--! \todo May want to synchronise the coincidence trigger when it is external...

--------------------------------------------
-- ASM, event no. and timing calclulation --
--------------------------------------------

--! ASM heart
sync_proc: process (fe_rst_b, mclk) begin
  if( fe_rst_b = '0' ) then
    state <= reset_st;
  elsif( rising_edge(mclk) ) then
    state <= next_state;
  end if;
end process;

--! Next state logic
next_logic: process (state,coincidence_trigger) begin
  case( state ) is
    when reset_st  =>                      next_state <= ready_st       ;
    when ready_st =>                       
      if( coincidence_trigger = '1' ) then next_state <= cotrg_hold_st  ;
      else                                 next_state <= ready_st       ;
      end if;
    when others   =>
      if( coincidence_trigger = '0' ) then next_state <= ready_st       ;
      else                                 next_state <= cotrg_hold_st  ;
      end if;
  end case;
end process;

--! Event number '0' does not exist. Make sure the counters always wraps back to 1.
inc_event_no: process (fe_rst_b, mclk) begin
  if( fe_rst_b = '0' ) then
    event_no_inc <= "01";
  elsif( rising_edge(mclk) ) then
    if( event_no_i = 2**event_no_i'length-1 ) then
      event_no_inc <= "10";
    else
      event_no_inc <= "01";
    end if;
  end if;
end process;

inc_event_no_max: process (fe_rst_b, mclk) begin
  if( fe_rst_b = '0' ) then
    event_no_max_inc <= "01";
  elsif( rising_edge(mclk) ) then
    if( event_no_max_i = 2**event_no_max_i'length-1 ) then
      event_no_max_inc <= "10";
    else
      event_no_max_inc <= "01";
    end if;
  end if;
end process;

--! Output logic synchronous drivers (Mealy)
output_logic: process ( mclk ) begin
  if( rising_edge(mclk) ) then
    cotrg_end <= '0' ;
    case( state ) is
      when reset_st  =>
        event_no_i    <= ( others => '0' );
        coarse_time_i <= ( others => '0' );
      when ready_st =>
        if( coincidence_trigger = '1' ) then
          event_no_i    <= event_no_i + event_no_inc;
          coarse_time_i <= ( others => '0' );
        else
          event_no_i    <= event_no_i;
          coarse_time_i <= ( others => '0' );
        end if;
      when others =>
        if( coincidence_trigger = '0' ) then
          cotrg_end     <= '1' ;
          event_no_i    <= event_no_i;
          coarse_time_i <= coarse_time_i + 1;
        else
          event_no_i    <= event_no_i;
          coarse_time_i <= coarse_time_i + 1;
        end if;
    end case;
  end if;
end process;

-- Find the "highest valued event number" the EventBuilder can read out.
-- We do this by applying a delay of minimum 2^fe_ch_TOT_SIZE clock cycles from the coincidence
-- trigger window end, to ensure that all channels have finished the processing of this event.
-- (this will be inferred in distributed RAM resources, thus requiring little extra logic)

--! Delay the OR to synchronise it with coincidence trigger
shift_cotrg_end: entity work.shift
generic map(
  depth => (2**fe_ch_TOT_SIZE)/fe_ch_WORD_WIDTH )   --! Depth of shift-chain
port map(
  mclk  => mclk                                   , --! Clock
  i     => cotrg_end                              , --! Input
  s     => (2**fe_ch_TOT_SIZE)/fe_ch_WORD_WIDTH-1 , --! Select
  o     => cotrg_end_delayed                     ); --! Output

process( mclk, fe_rst_b ) begin
  if( fe_rst_b = '0' ) then
    event_no_max_i <= ( others => '0' );
  elsif( rising_edge(mclk) ) then
    if( cotrg_end_delayed = '1' ) then
      event_no_max_i <= event_no_max_i + event_no_max_inc;
    end if;
  end if;
end process;

event_no_max <= std_logic_vector(event_no_max_i) ;  --! Highest accessable event no.
event_no     <= std_logic_vector(event_no_i    ) ;  --! Co.trg. counter
coarse_time  <= std_logic_vector(coarse_time_i ) ;  --! Window length

end architecture;

