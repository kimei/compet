----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:05:11 02/15/2011 
-- Design Name: 
-- Module Name:    top - Behavioral 
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
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.components.all;
use work.constants.all;


entity top is
  port(
    -- Inputs from the board
    FPGA100M : in std_logic;
    RESET    : in std_logic;

    -- output to the ROCs

    --clocks and resets
    MCLK100   : out std_logic;
    MCLK100_b : out std_logic;
    RESET_ROC : out std_logic;

    --Sync Trigger trigger part
    -- outputs to SATAs
    SYNC_TRIGGER_OUT   : out std_logic_vector(NUMBER_OF_MODULES-1 downto 0);
    SYNC_TRIGGER_OUT_b : out std_logic_vector(NUMBER_OF_MODULES-1 downto 0);
    SYNC_TRIGGER_IN    : in  std_logic_vector(NUMBER_OF_ROCS-1 downto 0);
    SYNC_TRIGGER_IN_b  : in  std_logic_vector(NUMBER_OF_ROCS-1 downto 0);

    --Communication
    --uart
	 test_led : out std_logic;
	 test_led2 : out std_logic;
    tx : out std_logic;
    rx : in  std_logic
    );
end top;

architecture Behavioral of top is

  signal mclk  : std_logic;             -- 100
  signal rst_b : std_logic;
signal tx_s : std_logic;

  
begin
	tx <= tx_s;
	test_led <= not tx_s;
	test_led2 <= not rst_b;

  Inst_CRU : CRU port map(
    fpga_100m_clk  => FPGA100M,
    fpga_cpu_reset => RESET ,
    mclk           => MCLK100,
    mclk_b         => MCLK100_b ,
    gclk           => mclk,
    mrst_b         => RESET_ROC,
    lrst_b         => rst_b
    );


  sync_trigger_1 : sync_trigger
    port map (
      rst_b =>  rst_b,
      mclk          => mclk,
      trigger_in    => SYNC_TRIGGER_IN,
      trigger_in_b  => SYNC_TRIGGER_IN_b,
      trigger_out   => SYNC_TRIGGER_OUT,
      trigger_out_b => SYNC_TRIGGER_OUT_b);


  -----------------------------------------------------------------------------
  -- UART TESTING GROUNDS!
  com_1: com
    port map (
      mclk  => mclk,
      rst_b => rst_b,
      rx    => rx,
      tx    => tx_s);
end Behavioral;

