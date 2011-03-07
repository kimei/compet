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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.components.all;
use work.constants.all;


entity top is
		PORT(
		FPGA100M : IN std_logic;
		RESET : IN std_logic;          
		MCLK100 : OUT std_logic;
		MCLK100_b : OUT std_logic;
		RESET_ROC : OUT std_logic
		);
end top;

architecture Behavioral of top is

signal mclk:std_logic; -- 100
signal rst : std_logic;

	COMPONENT CRU
	PORT(
		fpga_100m_clk : IN std_logic;
		fpga_cpu_reset : IN std_logic;          
		mclk : OUT std_logic;
		mclk_b : OUT std_logic;
		gclk : OUT std_logic;
		mrst : OUT std_logic;
		lrst : OUT std_logic
		);
	END COMPONENT;

	
begin
	Inst_CRU: CRU PORT MAP(
		fpga_100m_clk =>FPGA100M,
		fpga_cpu_reset =>RESET ,
		mclk =>MCLK100,
		mclk_b =>MCLK100_b ,
		gclk => mclk,
		mrst => RESET_ROC,
		lrst => rst
	);

end Behavioral;

