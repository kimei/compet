--! \file
--! \brief Component deptclarations.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;   --! Global constants


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

        -- a2s from Jo-Inge
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

        -- OBUFDS is a single output buffer that supports low-voltage, differential
        --signaling (1.8v CMOS). OBUFDS isolates the internal circuit and provides
        --drive current for signals leaving the chip. Its output is represented as
        --two distinct ports (O and OB), one deemed the "master" and the other the
        --"slave." The master and the slave are opposite phases of the same logical
        -- signal (for example, MYNET and MYNETB).
        component OBUFDS
          port (O : out STD_ULOGIC;
                OB : out STD_ULOGIC;
                I : in STD_ULOGIC);
        end component;
	
end package components;
