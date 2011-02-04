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
-- The CRU on the trigger unit shall handle the global clock, local clock and
-- system reset. The system reset, following jo-inges practice will be
-- asynchronous assert, and synchronous deassert. The reset will not deassert
-- until clk_lock goes high.
------------------------------------------------------------------------------
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
-- TODO: - connect mclk & mclk_b
--      - fix reset
--      - test..

entity CRU is
    Port ( fpga_100m_clk : in  STD_LOGIC;
           fpga_cpu_reset_b : in  STD_LOGIC;

           -- Clock outputs
           mclk            : out std_logic;
           mclk_b          : out STD_LOGIC;   -- Master clock
           gclk            : out STD_LOGIC;   -- single ended clock used on 'this fpga.
           
           -- Reset outputs
           mrst            : out STD_LOGIC;      -- Global master reset
			  lrst            : out STD_LOGIC);	-- Local reset
end CRU;


architecture Behavioral of CRU is
signal clk_lock : std_logic;
signal clk_lock_b : std_logic;
signal mclk_s : std_logic;              -- Master clock, single ended to go into differential port
signal mclk_o_ddr : std_logic; 			-- Out from ODDR
signal gclk_s : std_logic;              -- Signal of gclksignal mclk_s : std_logic;
--signal oddr_ce : std_logic;

signal rst_counter : integer range 65535 downto 0; -- To delay the reset signal (16 bit int)

signal mrst_s : std_logic;              -- signal of mrst
signal lrst_s : std_logic;              -- signal of lrst


-- TODO: Bytt til OBUFDST, og flytt komponenten til components.vhd
component OBUFDS
          port (O : out STD_ULOGIC;
                OB : out STD_ULOGIC;
                I : in STD_ULOGIC);
end component;

component ODDR
	generic(
		DDR_CLK_EDGE : string := "OPPOSITE_EDGE";
		INIT : bit := '0';
		SRTYPE : string := "SYNC");
	port(
		Q :out STD_ULOGIC;
		S : in STD_ULOGIC;
		R : in STD_ULOGIC;
		D1 : in STD_ULOGIC;
		D2 : in STD_ULOGIC;
		CE : in STD_ULOGIC;
		C: in STD_ULOGIC);
end component;
	
begin
	Inst_PLL_ALL: PLL_ALL PORT MAP(
		CLKIN1_IN => fpga_100m_clk,
		RST_IN => fpga_cpu_reset_b,
		CLKOUT0_OUT => mclk_s,
		CLKOUT1_OUT => gclk_s,
		LOCKED_OUT => clk_lock
	);

   MCLK_DIFF_OUT : OBUFDS port map (
		O => mclk,
      OB => mclk_b,
      I => mclk_o_ddr);

	MCLK_ODDR_OUT : ODDR PORT MAP(
		Q => mclk_o_ddr,
		S => '0', 
		R => clk_lock_b,
		D1 => '1',
		D2 => '0',
		CE => '1',
		C => mclk_s);



--mrst <= gclk_s xor mclk_o_ddr;
clk_lock_b <= not clk_lock;
mrst <= mrst_s;
lrst <= lrst_s;
gclk <= gclk_s;


-- purpose: Sends reset signal. async assert, deassert when the clock is stable
-- type   : sequential
send_reset: process (gclk_s, fpga_cpu_reset_b)
begin
  if fpga_cpu_reset_b = '1' then        -- Set reset high
    mrst_s <= '1';
    lrst_s <= '1';
    rst_counter <= 0;
elsif gclk_s'event and gclk_s = '1' then  -- rising clock edge
  if clk_lock = '1' then
    if mrst_s = '1' or lrst_s = '1' then
      rst_counter <= rst_counter + 1;
    end if;
    if rst_counter = 10 then
       mrst_s <= '0';
       lrst_s <= '0';
       rst_counter <= 0;
    end if;
  end if;
end if;
end process send_reset;


--set_ce_oddr : process (gclk_s, fpga_cpu_reset_b)
--begin
--if fpga_cpu_reset_b = '1' then 
--	oddr_ce <= '0';
--elsif gclk_s'event and gclk_s = '1' then
--	if clk_lock = '1' then
--		oddr_ce <= '1';
--	else
--		oddr_ce <= '0'; -- Denne er jeg litt usikker paa
--	end if;
--end if;
--end process set_ce_oddr;

end Behavioral;

