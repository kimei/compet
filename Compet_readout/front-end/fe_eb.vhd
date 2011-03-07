--! \file
--! \brief The Event Builder (fe_eb) block.

--! This module continuously reads any data that may have have been buffered on
--! each channel, taking one event number at a time. Its occupacy should be near 1,
--! so unless there are timing failures or event rate approaches the system clock
--! there should be no errors...


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
use work.functions.all;       --! Global functions

--! \brief Event Builder
--! \details Stitches data with the same event number together.
entity fe_eb is
port(
  mclk                  : in  std_logic; --! Master clock
  fe_rst_b              : in  std_logic; --! Front-end reset (active low)

  -- Signals between going to the channel fifo.
  fe_ch_fifo_rd         : out std_logic_vector( fe_NUM_CHANNELS-1 downto 0 );
  fe_ch_fifo_out_array  : in  fe_ch_fifo_out_atype; -- See definition in 'types'vhd'

  event_no_max          : in  std_logic_vector( fe_EVENT_NO_SIZE-1 downto 0);--! Last valid evt.no.

  -- Data output from the event builder.
  fe_event_ready        : out std_logic;
  fe_event_data         : out fe_ch_event_data_type; --! Data output

  cs_vio                : in  cs_vio_type
);
end entity;

architecture rtl of fe_eb is

  signal event_data_reduced_array  : fe_ch_event_data_reduced_atype ( fe_NUM_CHANNELS-1 downto 0 );
  signal event_no_array            : fe_ch_event_no_atype ( fe_NUM_CHANNELS-1 downto 0 );

  signal event_ready_flags         : std_logic_vector( fe_NUM_CHANNELS-1 downto 0 );
  signal event_ready_flags_i       : std_logic_vector( fe_NUM_CHANNELS-1 downto 0 );

  signal dstb                      : std_logic := '0' ; --! Data strobe

  signal fe_event_data_reduced     :  fe_ch_event_data_reduced_type;

  signal event_no                  : std_logic_vector( fe_EVENT_NO_SIZE-1 downto 0);

  signal event_no_not_zero         : std_logic;

begin

  -- Split event number off the event data package
split_data: for i in 0 to fe_NUM_CHANNELS-1 generate
begin
  process( fe_ch_fifo_out_array(i).dout ) begin
    event_no_array(i)           <= get_event_no  ( fe_ch_fifo_out_array(i).dout );
    event_data_reduced_array(i) <= strip_event_no( fe_ch_fifo_out_array(i).dout );
  end process;
end generate;


-- Add comparators to each channel.
--! \todo XNOR between event no. on fifos and desired?
process(event_no_array, event_no)
begin
  for i in 0 to fe_NUM_CHANNELS-1 loop
    if( event_no_array(i) = event_no and cs_vio.mask_inputs(i) = '0' ) then 
      event_ready_flags_i(i) <= '1' ;
    else
      event_ready_flags_i(i) <= '0' ;
    end if;
  end loop;
end process;
--! Event number equal to zero is not interesting. Just mask the flags in this case.
event_no_not_zero <= bitwise_or( event_no );
event_ready_flags <= event_ready_flags_i when (event_no_not_zero = '1') else ( others => '0' );


-- Generate the event number that we wish to read out.
-- Note that this must be delayed minimum 2^fe_ch_TOT_SIZE clock cycles to ensure that all
-- channels have finished the processing of this event...
process( mclk, fe_rst_b )
  variable one : std_logic_vector( event_no_max'range );
  variable max : std_logic_vector( event_no'range );
begin
  one := std_logic_vector(to_unsigned(1,event_no_max'length));
  max := std_logic_vector(to_unsigned(2**event_no'length-1, event_no'length));
  if( fe_rst_b = '0' ) then
    event_no <= ( others => '0' ) ;
  elsif( rising_edge(mclk) ) then
    if( event_no_max = one and event_no = max ) then
      event_no <= std_logic_vector(unsigned(event_no) + 2) ;
    elsif( dstb = '0' and event_no_max > event_no ) then --or
--                        ( event_no_max = one and event_no = max ) ) ) then
      event_no <= std_logic_vector(unsigned(event_no) + 1) ;
    else
      event_no <= event_no;
    end if;
  end if;
end process;


--! Delay the requested event number to synchronise it with the data output from the
--! SubMux-pipe
shift_event_no: for i in 0 to fe_EVENT_NO_SIZE-1 generate
begin
  shift_event_no_i: entity work.shift
  generic map(
    depth => find_L(fe_NUM_CHANNELS, fe_eb_FANIN) )     --! Depth of shift-chain
  port map(
    mclk  => mclk                                     , --! Clock
    i     => event_no(i)                              , --! Input
    s     => find_L(fe_NUM_CHANNELS, fe_eb_FANIN)-1   , --! Select
    o     => fe_event_data.event_no(i)               ); --! Output
end generate;

fe_event_data.tot_start <= fe_event_data_reduced.tot_start;
fe_event_data.tot_width <= fe_event_data_reduced.tot_width;
fe_event_data.ch_no     <= fe_event_data_reduced.ch_no;


  --! Instantiate the base SubMux (will create the rest of the MUX pipe)
  rep_inst: entity work.fe_ch_submux
  generic map(
    no_inputs     => fe_NUM_CHANNELS         , --! The number of inputs
    fan_in        => fe_eb_FANIN    
  )
  port map(
    mclk          => mclk                    , --! Master clock
    fe_rst_b      => fe_rst_b                , --! Front-end reset (active low)

    -- These are constant sized signals - used by last level instantiation
    --!\todo Make this more robust to *any* value of no_inputs and fanout
    fifo_data    => event_data_reduced_array ,
    fifo_en      => event_ready_flags        ,
    fifo_rd      => fe_ch_fifo_rd            ,

    priority_in  => '0'                      ,
    priority_out => dstb                     , --Inverted below..

    -- Data outputs from the next MUX is 'inputs' to this one.
    mux_en       => fe_event_ready           , -- The enable line
    mux_data     => fe_event_data_reduced      -- Assign each fanout to 'inputs' of this module.
  );


end architecture;

