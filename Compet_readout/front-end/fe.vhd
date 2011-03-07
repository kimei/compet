--! \file
--! \brief The Front-End top-module.

--!--------------------------------------------------------------------------------
--! \par Project {MaPET read-out electronics}
--! The MaPET read-out electronics
--! \author : Jo Inge Buskenes
--!           mapet@joinge.net
--! -------------------------------------------------------------------------------
--! RELEASE HISTORY
--! VERSION  DATE   AUTHOR  DESCRIPTION
--! \version <a date>
--! \todo Add git dynamics..

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

--! \brief This is the Top entity
--! \details And this is some more details
entity fe is
port(
  mclk                  : in  std_logic; --! Master clock
  fe_clk                : in  std_logic; --! Front-end clock
  fe_rst_b              : in  std_logic; --! Front-end reset (active low)
                      
  --! XGI Expansion Headers
  fe_data               : in  std_logic_vector(fe_NUM_CHANNELS-1 downto 0);

  coincidence_trigger   : in  std_logic                       ; --! Recieved from Trigger Unit
  fe_event_trigger      : out std_logic                       ; --! Sent to the Trigger Unit

 -- up_bram               : out up_bram_otype                   ; --! The uP BRAM interface

 cs_vio                : in  cs_vio_type;
 cs_fe                 : out std_logic_vector( 127 downto 0 ) ; 
 fe_event_ready_out     : out std_logic; 
 fe_event_data_out      : out fe_ch_event_data_type   ;
 LEDs                    :out std_logic_vector(7 downto 0) 
  
);
end entity;
       
---------------------------------------------------------------------------------------------------
--! \brief Architecture
architecture rtl of fe is
---------------------------------------------------------------------------------------------------

signal write_trigger  : std_logic;
signal LEDs_bf : std_logic_vector(7 downto 0);
---------------------
--Readout controller:

--type   state_type is (reset_st, ready_st, write_st);
--signal state, next_state  : state_type;
--
--signal inc_write_ptr        : std_logic;
--signal write_ptr            : std_logic_vector(8 downto 0); --! Can only reach half of the addresses...
--
--signal up_bram_din_i        : std_logic_vector(0 to 31);
--signal up_bram_a_i          : std_logic_vector(0 to 31);
--signal up_bram_we_i         : std_logic_vector(0 to 3);
-- signal up_bram_com_i  : std_logic_vector(0 to 1);

signal gcnt                 : std_logic_vector(35 downto 0); --Yep, huge.
signal gcnt_u               : unsigned(35 downto 0);
signal fe_event_ready       : std_logic; --! Fresh event_data present? 
signal fe_event_data        : fe_ch_event_data_type           ; --! Event #, time, ch. #, tot
signal event_no             : std_logic_vector( fe_EVENT_NO_SIZE-1 downto 0 ) ; --! Co.trg cnt
signal event_no_max         : std_logic_vector( fe_EVENT_NO_SIZE-1 downto 0);--! Last valid evt.no.
signal coarse_time          : std_logic_vector( fe_CO_TRG_SIZE-log2(fe_ch_WORD_WIDTH)-1 downto 0 ) ;    --! Window length
signal fe_ch_event_trigger  : std_logic_vector( fe_NUM_CHANNELS-1  downto 0 );
signal fe_event_trigger_i   : std_logic;
signal readout_en           : std_logic;
                                       
signal tot_test             : std_logic_vector( fe_ch_WORD_WIDTH-1 downto 0 );

--! Signals shared by event builder and channel fifo's
signal fe_ch_fifo_rd        : std_logic_vector( fe_NUM_CHANNELS-1 downto 0 );
signal fe_ch_fifo_out_array : fe_ch_fifo_out_atype; -- See definition in 'types'vhd'
signal fe_ch_fifo_out0 : fe_ch_fifo_otype;




type fe_parallel_data_atype is array ( fe_NUM_CHANNELS-1 downto 0 ) of std_logic_vector( fe_ch_WORD_WIDTH-1 downto 0 );
signal fe_parallel_data     : fe_parallel_data_atype := ( others => ( others => '0' ) );

type fe_ch_no_atype is array (fe_NUM_CHANNELS-1 downto 0 ) of std_logic_vector(fe_ch_LOC_SIZE-1 downto 0 );
signal ch_no_a: fe_ch_no_atype;

signal muxed_parallel_data  : std_logic_vector( fe_ch_WORD_WIDTH-1 downto 0 );
signal muxed_event_trigger  : std_logic;

signal coincidence_trigger_z1 : std_logic; --delayed by one cycle

signal event_trigger_time : unsigned(17 downto 0);
signal event_trigger_ch   : unsigned(7 downto 0);
signal event_trigger_no   : unsigned(7 downto 0);
signal event_trigger_rdy  : std_logic;
--signal trigger_data_i     : fe_ch_event_data_type;


-- counter to derive event rate:
signal TriggerRateCounter: unsigned(fe_TriggerRate_SIZE-1 downto 0); --at 100MHz: 0.33s wrap around time
signal ResetRateCounters : std_logic;

signal fe_EventRateArray :  fe_EventRateArray_atype;
signal TriggerRateCounter_C: unsigned(fe_TriggerRate_SIZE-1 downto 0);

signal sec1: std_logic;
signal sec1_i: std_logic;
signal send_trigger: std_logic;

begin

LEDs <= LEDs_bf;

TriggerRateCounter_C(fe_TriggerRate_SIZE-1) <= '1';
TriggerRateCounter_C(fe_TriggerRate_SIZE-2 downto 0) <= (OTHERS => '0');
--l1: process  begin
--
--       for i in 0 to fe_NUM_CHANNELS-1 loop
--        ch_no_a(i)<= std_logic_vector(to_unsigned(i, (fe_ch_LOC_SIZE)));
--       end loop;

--end process;
--ch_no_a(0) <= std_logic_vector(to_unsigned(0, (fe_ch_LOC_SIZE)));
--ch_no_a(1) <= std_logic_vector(to_unsigned(1, (fe_ch_LOC_SIZE)));
--ch_no_a(2) <= std_logic_vector(to_unsigned(2, (fe_ch_LOC_SIZE)));
--ch_no_a(3) <= std_logic_vector(to_unsigned(3, (fe_ch_LOC_SIZE)));
--ch_no_a(4) <= std_logic_vector(to_unsigned(4, (fe_ch_LOC_SIZE)));
--ch_no_a(5) <= std_logic_vector(to_unsigned(5, (fe_ch_LOC_SIZE)));
--ch_no_a(6) <= std_logic_vector(to_unsigned(6, (fe_ch_LOC_SIZE)));
--ch_no_a(7) <= std_logic_vector(to_unsigned(7, (fe_ch_LOC_SIZE)));
--




 --fe_event_ready_out<=  fe_event_ready;
 --fe_event_data_out <=  fe_event_data;
sec1 <= gcnt(26);
send_trigger_pack: process (mclk,fe_rst_b) begin
  if( fe_rst_b = '0' ) then
   send_trigger <= '0';
	LEDs_bf(7) <= '0';
  elsif( rising_edge(mclk) ) then
     sec1_i <= sec1;
	  if(sec1_i /= sec1) then
	    send_trigger <= '1';
		 LEDs_bf(7) <= not LEDs_bf(7);
	  else
	    send_trigger <= '0';
		 LEDs_bf(7) <= LEDs_bf(7);
	  end if;
	 end if;
end process;
	   
cs_fe(32) <= fe_event_ready;
cs_fe(31 downto 0) <= pack(fe_event_data);
Inst_BuildEventsToShipOut: entity work.BuildEventsToShipOut PORT MAP(
		mclk => mclk,
		fe_rst_b => fe_rst_b,
		send_trigger => send_trigger,
		fe_event_ready => fe_event_ready,
		fe_event_data =>fe_event_data ,
		fe_EventRateArray =>fe_EventRateArray ,
		fe_data =>fe_event_data_out,
		fe_data_ready => fe_event_ready_out
	);






trigger_rate_cnt: process (mclk,fe_rst_b) begin
  if( fe_rst_b = '0' ) then
    TriggerRateCounter <=  ( others => '0' );
	 ResetRateCounters  <= '0';
  elsif( rising_edge(mclk) ) then
    TriggerRateCounter <=TriggerRateCounter + 1;
	 if(TriggerRateCounter = TriggerRateCounter_C) then -- send out the reset counter at wrap around
	    ResetRateCounters <= '1';
	 else
	    ResetRateCounters <= '0';
	 end if;
  end if;
end process;



  --readout_en    <= cs_vio.readout_en;

-- A global counter (to keep track of coarse time).
-- Seems to automatically wrap... No need for extra statements..
global_cnt: process (mclk,fe_rst_b) begin
  if( fe_rst_b = '0' ) then
    gcnt_u <=  ( others => '0' );
  elsif( rising_edge(mclk) ) then
    gcnt_u <= gcnt_u +1;
  end if;
end process;
gcnt <= std_logic_vector(gcnt_u);


-- create a trigger event (which is the same as a event, but contains instead of
-- rel. event time and TOT the event_trigger_time)

--process(mclk,fe_rst_b)
--if( fe_rst_b = '0' ) then
--    event_trigger_no   <=  ( others => '0' );
--	 event_trigger_time <=  ( others => '0' );
--	 event_trigger_rdy  <=  '0';
-- elsif( rising_edge(mclk) ) then
--    if(coincidence_trigger = '0' and coincidence_trigger_z1 = '1') then -- end of trigger signal
--	    event_trigger_rdy  <=  '1';
--	 else
--       event_trigger_rdy  <=  '0';
--    end if;
--    if(coincidence_trigger = '1') then
--	   event_trigger_no <= event_no;
--		event_trigger_time <= gcnt(17 downto 0);
--
--	else
--		event_trigger_no <= event_no;
--      event_trigger_time <= event_trigger_time;
--	end if;
-- end if;
--end process;
 
-- event_trigger_ch <= TO_UNSIGNED(7,11);
--trigger_data_i.event_no <= event_trigger_no;
--trigger_data_i.tot_start <= 
--trigger_data_i.tot_width <= 
--
--
--trigger_fifo: entity work.fe_ch_buf
--port map(
--  mclk              => mclk           , --! Master clock
--  fe_rst_b          => fe_rst_b       , --! Front-end reset (active low)
--
--  event_data        => trigger_data_i   , --! Event #, time, ch. #, tot
--  event_ready       => event_trigger_rdy  ,
--
--  fe_ch_fifo_rd     => fe_ch_fifo_rd  , --! Input to FIFO
--  fe_ch_fifo_out    => fe_ch_fifo_out   --! Outputs from FIFO
--);






--! Pass the coincidence window to the coincidence processing unit one clock before
--! parametrisation block receives it. This way the event number will be synchronised
--! with the coincidence window rising edge.
cotrg_delay: process (mclk,fe_rst_b) begin
  if( fe_rst_b = '0' ) then
    coincidence_trigger_z1 <= '0';
  elsif( rising_edge(mclk) ) then
    coincidence_trigger_z1 <= coincidence_trigger;
  end if;
end process;

input_stimuli: entity work.fe_input_stimuli
port map(
  gcnt             => gcnt     , --Yep, huge.
  tot_test         => tot_test   --! TOT test signal
);
-- tot_test <= ( others => '0' );

cotrg_proc: entity work.fe_cotrg_proc
port map(
  mclk                  => mclk                 , --! Master clock
  fe_rst_b              => fe_rst_b             , --! Front-end reset (active low)
                      
  coincidence_trigger   => coincidence_trigger  , --! Recieved from Trigger Unit

  event_no              => event_no             , --! Co.trg. counter
  event_no_max          => event_no_max         , --! Last valid evt.no.
  coarse_time           => coarse_time            --! Window length
);




chs: for i in 0 to fe_NUM_CHANNELS-1 generate --fe_data'upper generate
begin
  ch: entity work.fe_ch
  generic map (
   ch_no               => i                   --! Channel number -- MR dont know why yet...
  )
  port map (
   -- ch_no               => std_logic_vector(to_unsigned(i,fe_EVENT_NO_SIZE))  ,  --! channel number
    mclk                => mclk                 , --! Master clock
    fe_clk              => fe_clk               , --! Front-end clock
    fe_rst_b            => fe_rst_b             , --! Front-end reset (active low)
                        
    --! XGI Expansion Headers
    fe_data             => fe_data(i)           , --! TOT signal from the analog electronics
    tot_test            => tot_test             , --! TOT test signal (parallel)
    neg_input           => cs_vio.negate_inputs(i)     ,
    mask_input          => cs_vio.mask_inputs(i)       ,

    event_no            => event_no             , --! Coincidence trigger counter
    event_trigger       => fe_ch_event_trigger(i),--! @TOT rising edge - sent to Trigger Unit
    coincidence_trigger => coincidence_trigger_z1  , --! Received from the Trigger Unit
    coarse_time         => coarse_time          , --! A count of the coincidence window length

--     event_ready         => event_ready          , --! Fresh event_data present? 
--     event_data          => event_data           , --! Event #, time, ch. #, tot
    fe_ch_fifo_rd       => fe_ch_fifo_rd(i)       , --! Input to FIFO
    fe_ch_fifo_out      => fe_ch_fifo_out_array(i), --! Outputs from FIFO

    fe_parallel_data    => fe_parallel_data(i),
    cs_vio              => cs_vio,
  -- cs_fe               => cs_fe;
	ResetRateCounters   => ResetRateCounters,
	EventRate           => fe_EventRateArray(i)
  );
end generate;
--cs_fe(0) <= ResetRateCounters;
--cs_fe(11 downto  1) <= fe_EventRateArray(0);
--cs_fe(22 downto  12) <= fe_EventRateArray(1);
--cs_fe(33 downto  23) <= fe_EventRateArray(2);
--cs_fe(44 downto  34) <= fe_EventRateArray(3);
--cs_fe(55 downto  45) <= fe_EventRateArray(4);
--cs_fe(66 downto  56) <= fe_EventRateArray(5);
--cs_fe(77 downto  67) <= fe_EventRateArray(6);
--cs_fe(88 downto  78) <= fe_EventRateArray(7);
--fe_ch_fifo_out0 <= fe_ch_fifo_out_array(0);
--cs_fe(31 downto  0) <= pack(fe_ch_fifo_out_array(0).dout);
--cs_fe(63 downto 32) <= pack(fe_ch_fifo_out_array(1).dout);
--cs_fe(71 downto 64) <=  fe_ch_event_trigger;
--cs_fe(10 downto 0) <= fe_EventRateArray(0);
--cs_fe(11) <= ResetRateCounters;

fe_event_trigger_i <= bitwise_or(fe_ch_event_trigger);
fe_event_trigger  <= fe_event_trigger_i;
eb: entity work.fe_eb port map (
  mclk                  => mclk                 , --! Master clock
  fe_rst_b              => fe_rst_b             , --! Front-end reset (active low)

  -- Signals between going to the channel fifo.
  fe_ch_fifo_rd         => fe_ch_fifo_rd        , --! Channel FIFO read enable
  fe_ch_fifo_out_array  => fe_ch_fifo_out_array , --! See definition in 'types'vhd'

  event_no_max          => event_no_max         , --! Last valid evt.no.

  -- Data output from the event builder.
  fe_event_ready        => fe_event_ready        , --! Fresh event_data present? 
  fe_event_data         => fe_event_data         , --! Event #, time, ch. #, tot

  cs_vio                => cs_vio
);


--  -- ASM Synchronisation aka. "the heart" :)
--  sync_proc: process (fe_rst_b, mclk) begin
--    if( fe_rst_b = '0' ) then
--      state <= reset_st;
--    elsif( rising_edge(mclk) ) then
--      state <= next_state;
--    end if;
--  end process;


  --! Next state & output logic
  --! \note The write pointer will never point at the first address. This is intentional.
  --! I wish to use the first address for various flags that may be read by Microblaze
  --! without any collision hazard.

--  write_trigger <= fe_event_ready when (readout_en = '1') else '0';
--
--  next_logic: process (state,write_trigger) begin
--    case( state ) is
--      when reset_st  =>                next_state <= ready_st ;
--      when ready_st =>                       
--        if( write_trigger = '1' ) then next_state <= write_st ;
--        else                           next_state <= ready_st ;
--        end if;
--      when others =>
--        if( write_trigger = '1' ) then next_state <= write_st ;
--        else                           next_state <= ready_st;
--        end if;
--    end case;
--  end process;


--  write_ptr_drv: process ( fe_rst_b, mclk ) begin
--    if( fe_rst_b = '0' ) then
--      write_ptr(write_ptr'high downto 1) <= ( others => '0' );
--      write_ptr(                      0) <= '1';
--    elsif( rising_edge(mclk) ) then
--      if( write_ptr = "111111111" ) then
--        write_ptr(write_ptr'high downto 1) <= ( others => '0' );
--        write_ptr(                      0) <= '1';
--      elsif( inc_write_ptr = '1' ) then
--        write_ptr <= std_logic_vector(unsigned(write_ptr) + 1);
--      else
--        write_ptr <= write_ptr;
--      end if;
--    end if;
--  end process;
--
--  --! Mealy to ensure 100% occupancy
--  output_logic: process ( state,write_ptr,write_trigger,fe_event_data )
--  begin
--    up_bram_we_i  <= ( others => '0' );
--    up_bram_a_i   <= ( others => '0' );
--    up_bram_din_i <= ( others => '0' );
--    inc_write_ptr <= '0';
--    case( state ) is
--      when reset_st  =>
--        up_bram_we_i  <= ( others => '1' );
--        up_bram_a_i   <= ( others => '0' );
--        up_bram_din_i <= ( others => '0' );
--      when ready_st =>
--        if( write_trigger = '1' ) then
--          up_bram_we_i  <= ( others => '1' );
--          up_bram_a_i   <= x"00000" & '0' & write_ptr & "00";
--          up_bram_din_i <= pack(fe_event_data);
--          inc_write_ptr <= '1';
--        end if;
--      when write_st =>
--        if( write_trigger = '1' ) then
--          up_bram_we_i  <= ( others => '1' );
--          up_bram_a_i   <= x"00000" & '0' & write_ptr & "00";
--          up_bram_din_i <= pack(fe_event_data);
--          inc_write_ptr <= '1';
--        else
--          up_bram_we_i  <= ( others => '1' );
--          up_bram_a_i   <= x"00000000";
--          up_bram_din_i <= x"00000" & "000" & write_ptr;
--        end if;
--    end case;
--  end process;
--
--  --! Using output drivers to provide a more "clean" BRAM interface
--  output_drv: process ( mclk,fe_rst_b ) begin
--    if( fe_rst_b = '0' ) then
--      up_bram.din       <= ( others => '0' );
--      up_bram.a         <= ( others => '0' );
--      up_bram.we        <= ( others => '0' );
--    elsif( rising_edge(mclk) ) then
--      up_bram.din       <= up_bram_din_i;
--      up_bram.a         <= up_bram_a_i;  
--      up_bram.we        <= up_bram_we_i; 
--    end if;
--  end process;
--
--  up_bram.en        <= '1';
--  up_bram.clk       <= mclk;
--  up_bram.com       <= ( others => '0' );
 
--
--  cs_fe( 31 downto 28 ) <= ( others => '0' );
--  cs_fe(           27 ) <= fe_event_trigger_i;
--  cs_fe( 26 downto 11 ) <= ("00000" & write_ptr & "00" );
--  cs_fe( 10           ) <= muxed_event_trigger;
--  cs_fe(  9 downto  0 ) <= muxed_parallel_data;
--
----! A generic multiplexer for the parallel_data going to ILA
--mux_parallel_data: process (fe_parallel_data, fe_ch_event_trigger, cs_vio.ch_select)
--  variable i : natural;
--  variable r1 : fe_parallel_data_atype;
--  variable r2 : std_logic_vector( fe_NUM_CHANNELS-1 downto 0 );
--begin
--  r1 := fe_parallel_data;
--  r2 := fe_ch_event_trigger;
--  i := 0;
--  i := to_integer( unsigned( cs_vio.ch_select ) );
--
--  muxed_parallel_data <= r1(i);
--  muxed_event_trigger <= r2(i);
--end process;


end architecture;

