----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:14:44 10/19/2010 
-- Design Name: 
-- Module Name:    BuildEventsToShipOut - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
-- 

-- Interleaves between the Event packages Trigger packages, containing
-- Trigger rates for each channel. Event number for these packages is 000.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;     --! Numeric/arithmetical logic (IEEE standard)
library work;
use work.constants.all;       --! Global constants
use work.types.all;           --! Global types
use work.functions.all;       --! Global functions
---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity BuildEventsToShipOut is
port(
  mclk                  : in  std_logic; --! Master clock
  fe_rst_b              : in  std_logic; --! Front-end reset (active low)
  send_trigger          : in  std_logic;  --! Send out trigger package when this is high
  fe_event_ready        : in std_logic; 
  fe_event_data         : in fe_ch_event_data_type;
  fe_EventRateArray     : in fe_EventRateArray_atype;   

  fe_data               : out fe_ch_event_data_type;
  fe_data_ready         : out std_logic


);


end entity;
architecture Behavioral of BuildEventsToShipOut is

signal ev_fifo_full     : std_logic;
signal ev_fifo_empty    : std_logic;
signal fe_rst           : std_logic;
signal dout_events      : std_logic_vector(31 downto 0);

signal dout_triggers     : std_logic_vector(31 downto 0);
signal TriggerEvent     : fe_ch_event_data_type;
signal counter          : natural range 0 to fe_NUM_CHANNELS-1;
signal wr_trig_fifo     : std_logic;
signal trig_fifo_full   : std_logic;
signal trig_fifo_empty  : std_logic;
signal rd_events        : std_logic;
signal rd_trigger       : std_logic;


signal ev_trig_fifo_empty : std_logic;
signal ev_trig_fifo_full  : std_logic;
signal ev_trig_to_fifo : std_logic_vector(31 downto 0);
signal rd_AllPackages: std_logic;
signal wr_ev_trig_fifo: std_logic;
signal dout_AllPackages: std_logic_vector(31 downto 0);

signal fe_data_packed: std_logic_vector(31 downto 0);




component BuildEventsFifo
	port (
	clk: IN std_logic;
	din: IN std_logic_VECTOR(31 downto 0);
	rd_en: IN std_logic;
	rst: IN std_logic;
	wr_en: IN std_logic;
	dout: OUT std_logic_VECTOR(31 downto 0);
	empty: OUT std_logic;
	almost_empty: OUT std_logic;
	full: OUT std_logic);
end component;

begin
fe_rst <= not fe_rst_b;


Events_BuildEventsFifo : BuildEventsFifo
		port map (
			clk => mclk,
			din => pack(fe_event_data),
			rd_en => rd_events,
			rst => fe_rst,
			wr_en => fe_event_ready,
			dout => dout_events,
			empty => open,
			almost_empty =>ev_fifo_empty,
			full => ev_fifo_full);

Trigger_BuildEventsFifo : BuildEventsFifo
		port map (
			clk => mclk,
			din => pack(TriggerEvent),
			rd_en => rd_trigger,
			rst => fe_rst,
			wr_en => wr_trig_fifo,
			dout => dout_triggers,
			empty => open,
			almost_empty => trig_fifo_empty ,
			full => trig_fifo_full);

AllPackages_BuildEventsFifo : BuildEventsFifo
		port map (
			clk => mclk,
			din => ev_trig_to_fifo,
			rd_en => rd_AllPackages,
			rst => fe_rst,
			wr_en => wr_ev_trig_fifo,
			dout => dout_AllPackages,
			empty => open,
			almost_empty => ev_trig_fifo_empty,
			full => ev_trig_fifo_full);

OutputAllPackages: process(mclk,fe_rst_b)
variable first: std_logic;
 begin 
 if( fe_rst_b = '0' ) then
    fe_data_packed<= (OTHERS => '0');
	 fe_data_ready <= '0';
	 rd_AllPackages<= '0';
	 first:= '0';
	 
	  elsif( rising_edge(mclk) ) then
	    if(first = '1') then
		   fe_data_packed       <= dout_AllPackages;
	      fe_data_ready <= '1';
			if(ev_trig_fifo_empty = '0') then
			 rd_AllPackages<= '1';
			 first := '1';
			else
			 rd_AllPackages<= '0';
			 first := '0';
			end if;
	    elsif(ev_trig_fifo_empty = '0') then
		   fe_data_packed       <= (OTHERS => '0');
	      fe_data_ready <= '0';
	      rd_AllPackages<= '1';
			first := '1';
		 else
		   fe_data_packed      <=  (OTHERS => '0');
	      fe_data_ready <= '0';
	      rd_AllPackages<= '0';
			first := '0';
			
		end if;
	end if;
end process;
	 fe_data <= unpack_event(fe_data_packed);





Poller: process(mclk,fe_rst_b) 
variable first_ev: std_logic;
variable first_tr: std_logic;

begin -- reads the trigger and the event fifo with a priority chain

 if( fe_rst_b = '0' ) then
    wr_ev_trig_fifo <= '0';
	 rd_trigger      <= '0';
	 rd_events       <= '0';
	 ev_trig_to_fifo <= (OTHERS => '0');
	 first_ev := '0';
	 first_tr := '0';
	 elsif( rising_edge(mclk) ) then
	  if(first_ev = '1') then
	     wr_ev_trig_fifo <= '1';
		  rd_trigger      <= '0';
	     ev_trig_to_fifo <= dout_events;
		  first_tr := '0';
		  if(ev_fifo_empty = '0') then
		    first_ev       := '1';
	       rd_events      <= '1';
		  else
		    first_ev        := '0';
	       rd_events       <= '0';
		  end if;
		  
	 elsif(first_tr = '1')        then
	     wr_ev_trig_fifo <= '1';
		  rd_events      <=  '0';
	     ev_trig_to_fifo <= dout_triggers;
		  first_ev := '0';
		  if(trig_fifo_empty = '0') then
		    first_tr       := '1';
	       rd_trigger     <= '1';
		  else
		    first_tr        := '0';
	       rd_trigger      <= '0';
		  end if;
	   
	  elsif (ev_fifo_empty = '0') then
	     wr_ev_trig_fifo <= '0';
		  rd_trigger      <= '0';
	     rd_events       <= '1';		  
	     ev_trig_to_fifo <= (OTHERS => '0');
		  first_ev := '1';
		  first_tr := '0';
		  
	
	  
	  elsif (trig_fifo_empty ='0') then
	     wr_ev_trig_fifo <= '0';
		  rd_trigger      <= '1';
	     rd_events       <= '0';
	     ev_trig_to_fifo <= (OTHERS => '0');
		  first_ev := '0';
		  first_tr := '1';
		  
	  else
	     wr_ev_trig_fifo <= '0';
	     rd_trigger      <= '0';
	     rd_events       <= '0';
	     ev_trig_to_fifo <= (OTHERS => '0');
		  first_ev := '0';
		  first_tr := '0';
	  end if;
 end if;
end process;



BuildTriggerEvents: process(mclk,fe_rst_b) begin
 if( fe_rst_b = '0' ) then
    counter <= 0;
	 TriggerEvent.event_no <= (OTHERS => '0');
	 TriggerEvent.tot_start<= (OTHERS => '0');
	 TriggerEvent.tot_width<= (OTHERS => '0');
	 TriggerEvent.ch_no    <= (OTHERS => '0');
	 wr_trig_fifo          <= '0';
  elsif( rising_edge(mclk) ) then
     if((send_trigger='1' and counter = 0) OR (send_trigger='0' AND counter > 0 AND counter <fe_NUM_CHANNELS)) then
			if(counter = fe_NUM_CHANNELS-1) then
			   counter <= 0;
			else 
			   counter <= counter+1;
			end if;
			TriggerEvent.event_no <= (OTHERS => '0');
			TriggerEvent.tot_start<= (OTHERS => '0');
			TriggerEvent.tot_width<= std_logic_vector(fe_EventRateArray(counter)); --MR
			TriggerEvent.ch_no    <= std_logic_vector(to_unsigned(counter,fe_ch_LOC_SIZE));
			wr_trig_fifo          <= '1';

		else
		   counter <= 0;
			TriggerEvent.event_no <= (OTHERS => '0');
			TriggerEvent.tot_start<= (OTHERS => '0');
			TriggerEvent.tot_width<= (OTHERS => '0');
			TriggerEvent.ch_no    <= (OTHERS => '0');
			wr_trig_fifo          <= '0';
			
		end if;
	end if;
end process;
  




end Behavioral;

