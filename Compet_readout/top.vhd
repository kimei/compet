----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:04:03 10/08/2010 
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

library unisim;
use unisim.vcomponents.all;


---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
 port(
	   --switches:
		Switch   : in std_logic_vector(3 downto 0);
		LEDs     : out std_logic_vector(3 downto 0);
	
      EMAC0CLIENTRXDVLD               : out std_logic;
      EMAC0CLIENTRXFRAMEDROP          : out std_logic;
      EMAC0CLIENTRXSTATS              : out std_logic_vector(6 downto 0);
      EMAC0CLIENTRXSTATSVLD           : out std_logic;
      EMAC0CLIENTRXSTATSBYTEVLD       : out std_logic;
      CLIENTEMAC0TXIFGDELAY           : in  std_logic_vector(7 downto 0);
      EMAC0CLIENTTXSTATS              : out std_logic;
      EMAC0CLIENTTXSTATSVLD           : out std_logic;
      EMAC0CLIENTTXSTATSBYTEVLD       : out std_logic;
      CLIENTEMAC0PAUSEREQ             : in  std_logic;
      CLIENTEMAC0PAUSEVAL             : in  std_logic_vector(15 downto 0);
      GTX_CLK_0                       : in  std_logic;
      GMII_TXD_0                      : out std_logic_vector(7 downto 0);
      GMII_TX_EN_0                    : out std_logic;
      GMII_TX_ER_0                    : out std_logic;
      GMII_TX_CLK_0                   : out std_logic;
      GMII_RXD_0                      : in  std_logic_vector(7 downto 0);
      GMII_RX_DV_0                    : in  std_logic;
      GMII_RX_ER_0                    : in  std_logic;
      GMII_RX_CLK_0                   : in  std_logic;
      REFCLK_100MHz                   : in  std_logic; 
    --  RESET                           : in  std_logic;
		PHY_RESET_0                     : out std_logic

   );

end top;

architecture Behavioral of top is

	COMPONENT UDP_dcm
	PORT(
		CLKIN_IN : IN std_logic;
		RST_IN : IN std_logic;          
		CLKFX_OUT : OUT std_logic;
		CLKIN_IBUFG_OUT : OUT std_logic;
		CLK0_OUT : OUT std_logic;
		CLK2X_OUT : OUT std_logic;
		LOCKED_OUT : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT v5_emac_v1_5_example_design
	PORT(
	
		CLIENTEMAC0TXIFGDELAY : IN std_logic_vector(7 downto 0);
		CLIENTEMAC0PAUSEREQ : IN std_logic;
		CLIENTEMAC0PAUSEVAL : IN std_logic_vector(15 downto 0);
		GTX_CLK_0 : IN std_logic;
		GMII_RXD_0 : IN std_logic_vector(7 downto 0);
		GMII_RX_DV_0 : IN std_logic;
		GMII_RX_ER_0 : IN std_logic;
		GMII_RX_CLK_0 : IN std_logic;
		REFCLK_200MHz : IN std_logic;
		reset_i : IN std_logic;          
	
		EMAC0CLIENTRXDVLD : OUT std_logic;
		EMAC0CLIENTRXFRAMEDROP : OUT std_logic;
		EMAC0CLIENTRXSTATS : OUT std_logic_vector(6 downto 0);
		EMAC0CLIENTRXSTATSVLD : OUT std_logic;
		EMAC0CLIENTRXSTATSBYTEVLD : OUT std_logic;
		EMAC0CLIENTTXSTATS : OUT std_logic;
		EMAC0CLIENTTXSTATSVLD : OUT std_logic;
		EMAC0CLIENTTXSTATSBYTEVLD : OUT std_logic;
		GMII_TXD_0 : OUT std_logic_vector(7 downto 0);
		GMII_TX_EN_0 : OUT std_logic;
		GMII_TX_ER_0 : OUT std_logic;
		GMII_TX_CLK_0 : OUT std_logic;
		PHY_RESET_0 : OUT std_logic
		);
	END COMPONENT;
	
signal reset_i               : std_logic;
signal REFCLK_200MHz         : std_logic;
signal RESET : std_logic;
begin
RESET <= Switch(0);
LEDs(3 downto 0) <= Switch(3 downto 0);
reset_ibuf : BUFG port map (I => RESET, O => reset_i);


Inst_dcm: UDP_dcm PORT MAP(
		CLKIN_IN => REFCLK_100MHz ,
		RST_IN => reset_i,
		CLKFX_OUT => open,
		CLKIN_IBUFG_OUT => open,
		CLK0_OUT => open,
		CLK2X_OUT => RefClk_200MHz,
		LOCKED_OUT => open
	);

Inst_v5_emac_v1_5_example_design: v5_emac_v1_5_example_design PORT MAP(
		
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
		GMII_RXD_0 => GMII_RXD_0 ,
		GMII_RX_DV_0 => GMII_RX_DV_0,
		GMII_RX_ER_0 => GMII_RX_ER_0,
		GMII_RX_CLK_0 => GMII_RX_CLK_0,
		REFCLK_200MHz => REFCLK_200MHz,
		reset_i => reset_i,
		PHY_RESET_0 => PHY_RESET_0
	);




end Behavioral;

