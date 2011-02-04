----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Kim-Eigard Hines 
-- 
-- Create Date:    13:59:59 01/18/2011 
-- Design Name: 
-- Module Name:    CRU - Behavioral 
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

entity CRU is
    Port ( fpga_100m_clk : in  STD_LOGIC;
           fpga_cpu_reset_b : in  STD_LOGIC;
           mclk : out	STD_LOGIC;
           gclk : out	STD_LOGIC;
           mrst : out	STD_LOGIC; 	-- Global master reset
			  lrst : out	STD_LOGIC);	-- Local reset
end CRU;


architecture Behavioral of CRU is
signal clk_lock : std_logic;

begin
	Inst_PLL_ALL: PLL_ALL PORT MAP(
		CLKIN1_IN => fpga_100m_clk,
		RST_IN => fpga_cpu_reset_b,
		CLKOUT0_OUT => mclk,
		CLKOUT1_OUT => gclk,
		LOCKED_OUT => clk_lock
	);

a2s1: a2s PORT MAP();
a2s1: a2s PORT MAP();

end Behavioral;

