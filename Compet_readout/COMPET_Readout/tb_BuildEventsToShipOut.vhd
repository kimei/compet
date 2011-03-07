--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:34:57 10/19/2010
-- Design Name:   
-- Module Name:   D:/avnet_50LXT/COMPET_readout/COMPET_Readout/COMPET_Readout/tb_BuildEventsToShipOut.vhd
-- Project Name:  COMPET_Readout
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: BuildEventsToShipOut
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 library work;
use work.constants.all;       --! Global constants
use work.types.all;           --! Global types
use work.functions.all;       --! Global functions
ENTITY tb_BuildEventsToShipOut IS
END tb_BuildEventsToShipOut;
 
ARCHITECTURE behavior OF tb_BuildEventsToShipOut IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT BuildEventsToShipOut
    PORT(
         mclk : IN  std_logic;
         fe_rst_b : IN  std_logic;
         send_trigger : IN  std_logic;
         fe_event_ready : IN  std_logic;
         fe_event_data         : in fe_ch_event_data_type;
         fe_EventRateArray     : in fe_EventRateArray_atype;   

         fe_data               : out fe_ch_event_data_type;
         
         fe_data_ready : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal mclk : std_logic := '0';
   signal fe_rst_b : std_logic := '0';
   signal send_trigger : std_logic := '0';
   signal fe_event_ready : std_logic := '0';
   
   
signal fe_event_data         :  fe_ch_event_data_type;
      signal   fe_EventRateArray     :  fe_EventRateArray_atype;   

  signal       fe_data               : fe_ch_event_data_type;
 	--Outputs
  
   signal fe_data_ready : std_logic;

   -- Clock period definitions
   constant mclk_period : time := 10ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: BuildEventsToShipOut PORT MAP (
          mclk => mclk,
          fe_rst_b => fe_rst_b,
          send_trigger => send_trigger,
          fe_event_ready => fe_event_ready,
          fe_event_data => fe_event_data,
          fe_EventRateArray => fe_EventRateArray,
          fe_data => fe_data,
          fe_data_ready => fe_data_ready
        );

   -- Clock process definitions
   mclk_process :process
   begin
		mclk <= '0';
		wait for mclk_period/2;
		mclk <= '1';
		wait for mclk_period/2;
   end process;
 
fe_EventRateArray(0) <= std_logic_vector(to_unsigned(12,11));
fe_EventRateArray(1) <= std_logic_vector(to_unsigned(12,11));
fe_EventRateArray(2) <= std_logic_vector(to_unsigned(12,11));
fe_EventRateArray(3) <= std_logic_vector(to_unsigned(12,11));
fe_EventRateArray(4) <= std_logic_vector(to_unsigned(12,11));
fe_EventRateArray(5) <= std_logic_vector(to_unsigned(12,11));
fe_EventRateArray(6) <= std_logic_vector(to_unsigned(12,11));
   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100ms.
		fe_rst_b <= '0';
      wait for 100ns;	
	   fe_rst_b	<= '1';
      send_trigger<= '0';
		wait for mclk_period*30;
		send_trigger <= '1';
		wait for mclk_period;
		send_trigger<= '0';
		

      -- insert stimulus here 

      wait;
   end process;

END;
