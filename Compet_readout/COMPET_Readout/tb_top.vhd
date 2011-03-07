--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:20:53 10/12/2010
-- Design Name:   
-- Module Name:   D:/avnet_50LXT/COMPET_readout/COMPET_Readout/COMPET_Readout/tb_top.vhd
-- Project Name:  COMPET_Readout
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: top
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
 
ENTITY tb_top IS
END tb_top;
 
ARCHITECTURE behavior OF tb_top IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT top
    PORT(
         Switch : IN  std_logic_vector(3 downto 0);
         LEDs : OUT  std_logic_vector(7 downto 0);
         fe_data_p : IN  std_logic_vector(7 downto 0);
         fe_data_n : IN  std_logic_vector(7 downto 0);
         EMAC0CLIENTRXDVLD : OUT  std_logic;
         EMAC0CLIENTRXFRAMEDROP : OUT  std_logic;
         EMAC0CLIENTRXSTATS : OUT  std_logic_vector(6 downto 0);
         EMAC0CLIENTRXSTATSVLD : OUT  std_logic;
         EMAC0CLIENTRXSTATSBYTEVLD : OUT  std_logic;
         CLIENTEMAC0TXIFGDELAY : IN  std_logic_vector(7 downto 0);
         EMAC0CLIENTTXSTATS : OUT  std_logic;
         EMAC0CLIENTTXSTATSVLD : OUT  std_logic;
         EMAC0CLIENTTXSTATSBYTEVLD : OUT  std_logic;
         CLIENTEMAC0PAUSEREQ : IN  std_logic;
         CLIENTEMAC0PAUSEVAL : IN  std_logic_vector(15 downto 0);
         GTX_CLK_0 : IN  std_logic;
         GMII_TXD_0 : OUT  std_logic_vector(7 downto 0);
         GMII_TX_EN_0 : OUT  std_logic;
         GMII_TX_ER_0 : OUT  std_logic;
         GMII_TX_CLK_0 : OUT  std_logic;
         GMII_RXD_0 : IN  std_logic_vector(7 downto 0);
         GMII_RX_DV_0 : IN  std_logic;
         GMII_RX_ER_0 : IN  std_logic;
         GMII_RX_CLK_0 : IN  std_logic;
         REFCLK_100MHz : IN  std_logic;
         PHY_RESET_0 : OUT  std_logic;
			 MII_TX_CLK_0                    : in  std_logic;
      GMII_COL_0                      : in  std_logic;
      GMII_CRS_0                      : in  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal Switch : std_logic_vector(3 downto 0) := (others => '0');
   signal fe_data_p : std_logic_vector(7 downto 0) := (others => '0');
   signal fe_data_n : std_logic_vector(7 downto 0) := (others => '0');
   signal CLIENTEMAC0TXIFGDELAY : std_logic_vector(7 downto 0) := (others => '0');
   signal CLIENTEMAC0PAUSEREQ : std_logic := '0';
   signal CLIENTEMAC0PAUSEVAL : std_logic_vector(15 downto 0) := (others => '0');
   signal GTX_CLK_0 : std_logic := '0';
   signal GMII_RXD_0 : std_logic_vector(7 downto 0) := (others => '0');
   signal GMII_RX_DV_0 : std_logic := '0';
   signal GMII_RX_ER_0 : std_logic := '0';
   signal GMII_RX_CLK_0 : std_logic := '0';
   signal REFCLK_100MHz : std_logic := '0';

 	--Outputs
   signal LEDs : std_logic_vector(7 downto 0);
   signal EMAC0CLIENTRXDVLD : std_logic;
   signal EMAC0CLIENTRXFRAMEDROP : std_logic;
   signal EMAC0CLIENTRXSTATS : std_logic_vector(6 downto 0);
   signal EMAC0CLIENTRXSTATSVLD : std_logic;
   signal EMAC0CLIENTRXSTATSBYTEVLD : std_logic;
   signal EMAC0CLIENTTXSTATS : std_logic;
   signal EMAC0CLIENTTXSTATSVLD : std_logic;
   signal EMAC0CLIENTTXSTATSBYTEVLD : std_logic;
   signal GMII_TXD_0 : std_logic_vector(7 downto 0);
   signal GMII_TX_EN_0 : std_logic;
   signal GMII_TX_ER_0 : std_logic;
   signal GMII_TX_CLK_0 : std_logic;
   signal PHY_RESET_0 : std_logic;
	signal  MII_TX_CLK_0 : std_logic;
   signal GMII_COL_0 : std_logic;
   signal GMII_CRS_0  :std_logic;
  
  constant REFCLK_100MHz_period : Time:= 10ns;
	 --GTX_CLK_0
 constant GTX_CLK_0_period:Time := 8ns;
	
BEGIN
 fe_data_p <= not fe_data_n;
	-- Instantiate the Unit Under Test (UUT)
   uut: top PORT MAP (
          Switch => Switch,
          LEDs => LEDs,
          fe_data_p => fe_data_p,
          fe_data_n => fe_data_n,
          EMAC0CLIENTRXDVLD => EMAC0CLIENTRXDVLD,
          EMAC0CLIENTRXFRAMEDROP => EMAC0CLIENTRXFRAMEDROP,
          EMAC0CLIENTRXSTATS => EMAC0CLIENTRXSTATS,
          EMAC0CLIENTRXSTATSVLD => EMAC0CLIENTRXSTATSVLD,
          EMAC0CLIENTRXSTATSBYTEVLD => EMAC0CLIENTRXSTATSBYTEVLD,
          CLIENTEMAC0TXIFGDELAY => CLIENTEMAC0TXIFGDELAY,
          EMAC0CLIENTTXSTATS => EMAC0CLIENTTXSTATS,
          EMAC0CLIENTTXSTATSVLD => EMAC0CLIENTTXSTATSVLD,
          EMAC0CLIENTTXSTATSBYTEVLD => EMAC0CLIENTTXSTATSBYTEVLD,
          CLIENTEMAC0PAUSEREQ => CLIENTEMAC0PAUSEREQ,
          CLIENTEMAC0PAUSEVAL => CLIENTEMAC0PAUSEVAL,
          GTX_CLK_0 => GTX_CLK_0,
          GMII_TXD_0 => GMII_TXD_0,
          GMII_TX_EN_0 => GMII_TX_EN_0,
          GMII_TX_ER_0 => GMII_TX_ER_0,
          GMII_TX_CLK_0 => GMII_TX_CLK_0,
          GMII_RXD_0 => GMII_RXD_0,
          GMII_RX_DV_0 => GMII_RX_DV_0,
          GMII_RX_ER_0 => GMII_RX_ER_0,
          GMII_RX_CLK_0 => GMII_RX_CLK_0,
          REFCLK_100MHz => REFCLK_100MHz,
          PHY_RESET_0 => PHY_RESET_0,
			 MII_TX_CLK_0                    => MII_TX_CLK_0,
      GMII_COL_0                      => GMII_COL_0,
      GMII_CRS_0                      => GMII_CRS_0
        );
 
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 

 
  REFCLK_100MHz_process :process
   begin
		REFCLK_100MHz <= '0';
		wait for REFCLK_100MHz_period/2;
		REFCLK_100MHz <= '1';
		wait for REFCLK_100MHz_period/2;
   end process;
-- 
-- 
--gmii_crs_0 <= '0';
--gmii_col_0 <= '0';
--mii_tx_clk_0 <= '0';
-- 
  GTX_CLK_0_process :process
   begin
		GTX_CLK_0 <= '0';
		wait for GTX_CLK_0_period/2;
		GTX_CLK_0 <= '1';
		wait for GTX_CLK_0_period/2;
   end process;
   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100ms.
		Switch(0) <= '1';
		fe_data_n <= (OTHERS=>'0');
      wait for 100ns;	
	   Switch(0) <= '0';
      wait for 500ns;
		fe_data_n <= (Others=>'1');
		wait for 312ns;
		fe_data_n <= (OTHERS=>'0');
		wait for 50ns;
       for i in 0 to 150 loop
         fe_data_n <= (OTHERS=>'1');
         wait for 55ns;
			fe_data_n <= (OTHERS=>'0');
			wait for 5us;
		end loop;

--
--
--		fe_data_n <= (OTHERS=>'0');
--      wait for 100ns;	
--	   Switch(0) <= '0';
--      wait for 500ns;
--		fe_data_n(0) <= '1';
--		wait for 312ns;
--		fe_data_n(0) <= '0';
--		wait for 50ns;
--       for i in 0 to 5 loop
--         fe_data_n(0) <= '1';
--         wait for 55ns;
--			fe_data_n(0) <= '0';
--			wait for 5us;
--		end loop;

      -- insert stimulus here 

      wait;
   end process;

END;
