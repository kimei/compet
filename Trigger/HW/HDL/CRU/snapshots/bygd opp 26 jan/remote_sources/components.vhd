--! \file
--! \brief Component declarations.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
--use work.constants.all;   --! Global constants


package components is

-- PLL from Xilinx ip
	COMPONENT PLL_ALL
	PORT(
		CLKIN1_IN : IN std_logic;
		RST_IN : IN std_logic;          
		CLKOUT0_OUT : OUT std_logic;
		CLKOUT1_OUT : OUT std_logic;
		LOCKED_OUT : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT a2s
	generic(
		depth :      positive := 2 ); --! FIFO depth
	port(
		arst_b : in  std_logic      ; --! Asynchronous reset	
		srst_b : in  std_logic      ; --! Synchronous reset
		clk    : in  std_logic      ; --! Synchronisation clock
		i      : in  std_logic      ; --! Input
		o      : out std_logic )    ; --! Output
	end COMPONENT;
	
end package components;