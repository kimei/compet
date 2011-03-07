-------------------------------------------------------------------------------
-- Title      : Virtex-5 Ethernet MAC Example Design Wrapper
-- Project    : Virtex-5 Ethernet MAC Wrappers
-------------------------------------------------------------------------------
-- File       : v5_emac_v1_5_example_design.vhd
-------------------------------------------------------------------------------
-- Copyright (c) 2004-2008 by Xilinx, Inc. All rights reserved.
-- This text/file contains proprietary, confidential
-- information of Xilinx, Inc., is distributed under license
-- from Xilinx, Inc., and may be used, copied and/or
-- disclosed only pursuant to the terms of a valid license
-- agreement with Xilinx, Inc. Xilinx hereby grants you
-- a license to use this text/file solely for design, simulation,
-- implementation and creation of design files limited
-- to Xilinx devices or technologies. Use with non-Xilinx
-- devices or technologies is expressly prohibited and
-- immediately terminates your license unless covered by
-- a separate agreement.
--
-- Xilinx is providing this design, code, or information
-- "as is" solely for use in developing programs and
-- solutions for Xilinx devices. By providing this design,
-- code, or information as one possible implementation of
-- this feature, application or standard, Xilinx is making no
-- representation that this implementation is free from any
-- claims of infringement. You are responsible for
-- obtaining any rights you may require for your implementation.
-- Xilinx expressly disclaims any warranty whatsoever with
-- respect to the adequacy of the implementation, including
-- but not limited to any warranties or representations that this
-- implementation is free from claims of infringement, implied
-- warranties of merchantability or fitness for a particular
-- purpose.
--
-- Xilinx products are not intended for use in life support
-- appliances, devices, or systems. Use in such applications are
-- expressly prohibited.
--
-- This copyright and support notice must be retained as part
-- of this text at all times. (c) Copyright 2004-2008 Xilinx, Inc.
-- All rights reserved.

-------------------------------------------------------------------------------
-- Description:  This is the VHDL example design for the Virtex-5 
--               Embedded Ethernet MAC.  It is intended that
--               this example design can be quickly adapted and downloaded onto
--               an FPGA to provide a real hardware test environment.
--
--               This level:
--
--               * instantiates the TEMAC local link file that instantiates 
--                 the TEMAC top level together with a RX and TX FIFO with a 
--                 local link interface;
--
--               * instantiates a simple client I/F side example design,
--                 providing an address swap and a simple
--                 loopback function;
--
--               * Instantiates IBUFs on the GTX_CLK, REFCLK and HOSTCLK inputs 
--                 if required;
--
--               Please refer to the Datasheet, Getting Started Guide, and
--               the Virtex-5 Embedded Tri-Mode Ethernet MAC User Gude for
--               further information.
--
--
--
--    ---------------------------------------------------------------------
--    | EXAMPLE DESIGN WRAPPER                                            |
--    |           --------------------------------------------------------|
--    |           |LOCAL LINK WRAPPER                                     |
--    |           |              -----------------------------------------|
--    |           |              |BLOCK LEVEL WRAPPER                     |
--    |           |              |    ---------------------               |
--    | --------  |  ----------  |    | ETHERNET MAC      |               |
--    | |      |  |  |        |  |    | WRAPPER           |  ---------    |
--    | |      |->|->|        |--|--->| Tx            Tx  |--|       |--->|
--    | |      |  |  |        |  |    | client        PHY |  |       |    |
--    | | ADDR |  |  | LOCAL  |  |    | I/F           I/F |  |       |    |  
--    | | SWAP |  |  |  LINK  |  |    |                   |  | PHY   |    |
--    | |      |  |  |  FIFO  |  |    |                   |  | I/F   |    |
--    | |      |  |  |        |  |    |                   |  |       |    |
--    | |      |  |  |        |  |    | Rx            Rx  |  |       |    |
--    | |      |  |  |        |  |    | client        PHY |  |       |    |
--    | |      |<-|<-|        |<-|----| I/F           I/F |<-|       |<---|
--    | |      |  |  |        |  |    |                   |  ---------    |
--    | --------  |  ----------  |    ---------------------               |
--    |           |              -----------------------------------------|
--    |           --------------------------------------------------------|
--    ---------------------------------------------------------------------
--
-------------------------------------------------------------------------------


library unisim;
use unisim.vcomponents.all;

library ieee;
use ieee.std_logic_1164.all;



-------------------------------------------------------------------------------
-- The entity declaration for the example design.
-------------------------------------------------------------------------------
entity v5_emac_v1_5_example_design is
   port(
	   
      -- Client Receiver Interface - EMAC0
      EMAC0CLIENTRXDVLD               : out std_logic;
      EMAC0CLIENTRXFRAMEDROP          : out std_logic;
      EMAC0CLIENTRXSTATS              : out std_logic_vector(6 downto 0);
      EMAC0CLIENTRXSTATSVLD           : out std_logic;
      EMAC0CLIENTRXSTATSBYTEVLD       : out std_logic;

      -- Client Transmitter Interface - EMAC0
      CLIENTEMAC0TXIFGDELAY           : in  std_logic_vector(7 downto 0);
      EMAC0CLIENTTXSTATS              : out std_logic;
      EMAC0CLIENTTXSTATSVLD           : out std_logic;
      EMAC0CLIENTTXSTATSBYTEVLD       : out std_logic;

      -- MAC Control Interface - EMAC0
      CLIENTEMAC0PAUSEREQ             : in  std_logic;
      CLIENTEMAC0PAUSEVAL             : in  std_logic_vector(15 downto 0);

 
      -- Clock Signals - EMAC0
      GTX_CLK_0                       : in  std_logic;

      -- GMII Interface - EMAC0
      GMII_TXD_0                      : out std_logic_vector(7 downto 0);
      GMII_TX_EN_0                    : out std_logic;
      GMII_TX_ER_0                    : out std_logic;
      GMII_TX_CLK_0                   : out std_logic;
      GMII_RXD_0                      : in  std_logic_vector(7 downto 0);
      GMII_RX_DV_0                    : in  std_logic;
      GMII_RX_ER_0                    : in  std_logic;
      GMII_RX_CLK_0                   : in  std_logic;

    --  MII_TX_CLK_0                    : in  std_logic;
   --   GMII_COL_0                      : in  std_logic;
   --   GMII_CRS_0                      : in  std_logic;

      -- Reference clock for RGMII IODELAYs
      REFCLK_200MHz                          : in  std_logic; 
        
        
      -- Asynchronous Reset
      reset_i                           : in  std_logic;
		PHY_RESET_0                     : out std_logic

   );
end v5_emac_v1_5_example_design;


architecture TOP_LEVEL of v5_emac_v1_5_example_design is
 --signal RefClk_200MHz: std_logic;

-------------------------------------------------------------------------------
-- Component Declarations for lower hierarchial level entities
-------------------------------------------------------------------------------

component cs_control
  PORT (
    CONTROL0 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0));

end component;


component cs_ila
  PORT (
    CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
    CLK : IN STD_LOGIC;
    TRIG0 : IN STD_LOGIC_VECTOR(63 DOWNTO 0));

end component;







-- Component Declaration for the TEMAC wrapper with 
  -- Local Link FIFO.
  
  
  
  component v5_emac_v1_5_locallink is
   port(
      -- EMAC0 Clocking
      -- TX Client Clock output from EMAC0
      TX_CLIENT_CLK_OUT_0              : out std_logic;
      -- RX Client Clock output from EMAC0
      RX_CLIENT_CLK_OUT_0              : out std_logic;
      -- TX PHY Clock output from EMAC0
      TX_PHY_CLK_OUT_0                 : out std_logic;
      -- EMAC0 TX Client Clock input from BUFG
      TX_CLIENT_CLK_0                  : in  std_logic;
      -- EMAC0 RX Client Clock input from BUFG
      RX_CLIENT_CLK_0                  : in  std_logic;
      -- EMAC0 TX PHY Clock input from BUFG
      TX_PHY_CLK_0                     : in  std_logic;

      -- Local link Receiver Interface - EMAC0
      RX_LL_CLOCK_0                   : in  std_logic; 
      RX_LL_RESET_0                   : in  std_logic;
      RX_LL_DATA_0                    : out std_logic_vector(7 downto 0);
      RX_LL_SOF_N_0                   : out std_logic;
      RX_LL_EOF_N_0                   : out std_logic;
      RX_LL_SRC_RDY_N_0               : out std_logic;
      RX_LL_DST_RDY_N_0               : in  std_logic;
      RX_LL_FIFO_STATUS_0             : out std_logic_vector(3 downto 0);

      -- Local link Transmitter Interface - EMAC0
      TX_LL_CLOCK_0                   : in  std_logic;
      TX_LL_RESET_0                   : in  std_logic;
      TX_LL_DATA_0                    : in  std_logic_vector(7 downto 0);
      TX_LL_SOF_N_0                   : in  std_logic;
      TX_LL_EOF_N_0                   : in  std_logic;
      TX_LL_SRC_RDY_N_0               : in  std_logic;
      TX_LL_DST_RDY_N_0               : out std_logic;

      -- Client Receiver Interface - EMAC0
      EMAC0CLIENTRXDVLD               : out std_logic;
      EMAC0CLIENTRXFRAMEDROP          : out std_logic;
      EMAC0CLIENTRXSTATS              : out std_logic_vector(6 downto 0);
      EMAC0CLIENTRXSTATSVLD           : out std_logic;
      EMAC0CLIENTRXSTATSBYTEVLD       : out std_logic;

      -- Client Transmitter Interface - EMAC0
      CLIENTEMAC0TXIFGDELAY           : in  std_logic_vector(7 downto 0);
      EMAC0CLIENTTXSTATS              : out std_logic;
      EMAC0CLIENTTXSTATSVLD           : out std_logic;
      EMAC0CLIENTTXSTATSBYTEVLD       : out std_logic;

      -- MAC Control Interface - EMAC0
      CLIENTEMAC0PAUSEREQ             : in  std_logic;
      CLIENTEMAC0PAUSEVAL             : in  std_logic_vector(15 downto 0);

 
      -- Clock Signals - EMAC0
      GTX_CLK_0                       : in  std_logic;

      -- GMII Interface - EMAC0
      GMII_TXD_0                      : out std_logic_vector(7 downto 0);
      GMII_TX_EN_0                    : out std_logic;
      GMII_TX_ER_0                    : out std_logic;
      GMII_TX_CLK_0                   : out std_logic;
      GMII_RXD_0                      : in  std_logic_vector(7 downto 0);
      GMII_RX_DV_0                    : in  std_logic;
      GMII_RX_ER_0                    : in  std_logic;
      GMII_RX_CLK_0                   : in  std_logic;

     -- MII_TX_CLK_0                    : in  std_logic;
     -- GMII_COL_0                      : in  std_logic;
     -- GMII_CRS_0                      : in  std_logic;

        
        
      -- Asynchronous Reset
      RESET                           : in  std_logic
   );
  end component;
 
   ---------------------------------------------------------------------
   --  Component Declaration for 8-bit address swapping module
   ---------------------------------------------------------------------
   component address_swap_module_8
   port (
      rx_ll_clock         : in  std_logic;                     -- Input CLK from MAC Reciever
      rx_ll_reset         : in  std_logic;                     -- Synchronous reset signal
      rx_ll_data_in       : in  std_logic_vector(7 downto 0);  -- Input data
      rx_ll_sof_in_n      : in  std_logic;                     -- Input start of frame
      rx_ll_eof_in_n      : in  std_logic;                     -- Input end of frame
      rx_ll_src_rdy_in_n  : in  std_logic;                     -- Input source ready
      rx_ll_data_out      : out std_logic_vector(7 downto 0);  -- Modified output data
      rx_ll_sof_out_n     : out std_logic;                     -- Output start of frame
      rx_ll_eof_out_n     : out std_logic;                     -- Output end of frame
      rx_ll_src_rdy_out_n : out std_logic;                     -- Output source ready
      rx_ll_dst_rdy_in_n  : in  std_logic                      -- Input destination ready
      );
   end component;

-----------------------------------------------------------------------
-- Signal Declarations
-----------------------------------------------------------------------

    -- Global asynchronous reset
    --signal reset_i               : std_logic;
	 signal reset_b : std_logic;
--	 signal RESET : std_logic;
    -- client interface clocking signals - EMAC0
    signal ll_clk_0_i            : std_logic;

    -- address swap transmitter connections - EMAC0
    signal tx_ll_data_0_i      : std_logic_vector(7 downto 0);
    signal tx_ll_sof_n_0_i     : std_logic;
    signal tx_ll_eof_n_0_i     : std_logic;
    signal tx_ll_src_rdy_n_0_i : std_logic;
    signal tx_ll_dst_rdy_n_0_i : std_logic;

   -- address swap receiver connections - EMAC0
    signal rx_ll_data_0_i           : std_logic_vector(7 downto 0);
    signal rx_ll_sof_n_0_i          : std_logic;
    signal rx_ll_eof_n_0_i          : std_logic;
    signal rx_ll_src_rdy_n_0_i      : std_logic;
    signal rx_ll_dst_rdy_n_0_i      : std_logic;

    -- create a synchronous reset in the transmitter clock domain
    signal ll_pre_reset_0_i          : std_logic_vector(5 downto 0);
    signal ll_reset_0_i              : std_logic;

    attribute async_reg : string;
    attribute async_reg of ll_pre_reset_0_i : signal is "true";


    -- Reference clock for RGMII IODELAYs
    signal refclk_ibufg_i            : std_logic;
    signal refclk_bufg_i             : std_logic;

    -- EMAC0 Clocking signals

    -- GMII input clocks to wrappers
    signal tx_clk_0                  : std_logic;
    signal rx_clk_0_i                : std_logic;
    signal gmii_rx_clk_0_delay       : std_logic;

    -- IDELAY controller
    signal idelayctrl_reset_0_r      : std_logic_vector(12 downto 0);
    signal idelayctrl_reset_0_i      : std_logic;

    -- Setting attribute for RGMII/GMII IDELAY
    -- For more information on IDELAYCTRL and IDELAY, please refer to
    -- the Virtex-5 User Guide.
    attribute syn_noprune              : boolean;
    attribute syn_noprune of dlyctrl0  : label is true;

    
    -- GMII client clocks
    signal tx_client_clk_0_o         : std_logic;
    signal tx_client_clk_0           : std_logic;
    signal rx_client_clk_0_o         : std_logic;
    signal rx_client_clk_0           : std_logic;
    -- GMII PHY clocks
    signal tx_phy_clk_0_o            : std_logic;
    signal tx_phy_clk_0              : std_logic;

    attribute buffer_type : string;
    signal gtx_clk_0_i               : std_logic;
    attribute buffer_type of gtx_clk_0_i  : signal is "none";


signal GMII_TXD_0_bf: std_logic_vector(7 downto 0);
signal GMII_TX_ER_0_bf: std_logic;
signal GMII_TX_EN_0_bf: std_logic;
-- cs:

signal CONTROL0: STD_LOGIC_VECTOR(35 DOWNTO 0);
signal cs_trig: STD_LOGIC_VECTOR(63 DOWNTO 0);
-------------------------------------------------------------------------------
-- Main Body of Code
-------------------------------------------------------------------------------


begin


inst_cs_control : cs_control
  port map (
    CONTROL0 => CONTROL0);

inst_cs_ila : cs_ila
  port map (
    CONTROL => CONTROL0,
    CLK => RefClk_200MHz,
    TRIG0 => cs_trig);

	


    ---------------------------------------------------------------------------
    -- Reset Input Buffer
    ---------------------------------------------------------------------------
  

    
	 --reset_i <= RESET;
	 PHY_RESET_0 <= not reset_i;
	 reset_b     <= not reset_i;
    -- EMAC0 Clocking

    -- Use IDELAY on GMII_RX_CLK_0 to move the clock into
    -- alignment with the data

    -- Instantiate IDELAYCTRL for the IDELAY in Fixed Tap Delay Mode
    dlyctrl0 : IDELAYCTRL port map (
        RDY    => open,
        REFCLK => refclk_bufg_i,
        RST    => idelayctrl_reset_0_i
        );

    delay0rstgen :process (refclk_bufg_i, reset_i)
    begin
      if (reset_i = '1') then
        idelayctrl_reset_0_r(0)           <= '0';
        idelayctrl_reset_0_r(12 downto 1) <= (others => '1');
      elsif refclk_bufg_i'event and refclk_bufg_i = '1' then
        idelayctrl_reset_0_r(0)           <= '0';
        idelayctrl_reset_0_r(12 downto 1) <= idelayctrl_reset_0_r(11 downto 0);
      end if;
    end process delay0rstgen;

    idelayctrl_reset_0_i <= idelayctrl_reset_0_r(12);

    -- Please modify the value of the IOBDELAYs according to your design.
    -- For more information on IDELAYCTRL and IODELAY, please refer to
    -- the Virtex-5 User Guide.
    gmii_rxc0_delay : IODELAY
    generic map (
        IDELAY_TYPE    => "FIXED",
        IDELAY_VALUE   => 0,
        DELAY_SRC      => "I",
        SIGNAL_PATTERN => "CLOCK"
        )
    port map (
        IDATAIN    => GMII_RX_CLK_0,
        ODATAIN    => '0',
        DATAOUT    => gmii_rx_clk_0_delay,
        DATAIN     => '0',
        C          => '0',
        T          => '0',
        CE         => '0',
        INC        => '0',
        RST        => '0'
        );


    -- Put the PHY clocks from the EMAC through BUFGs.
    -- Used to clock the PHY side of the EMAC wrappers.
    bufg_phy_tx_0 : BUFG port map (I => tx_phy_clk_0_o, O => tx_phy_clk_0);
    bufg_phy_rx_0 : BUFG port map (I => gmii_rx_clk_0_delay, O => rx_clk_0_i);

    -- Put the client clocks from the EMAC through BUFGs.
    -- Used to clock the client side of the EMAC wrappers.
    bufg_client_tx_0 : BUFG port map (I => tx_client_clk_0_o, O => tx_client_clk_0);
    bufg_client_rx_0 : BUFG port map (I => rx_client_clk_0_o, O => rx_client_clk_0);

    ll_clk_0_i <= tx_client_clk_0;


    ------------------------------------------------------------------------
    -- Instantiate the EMAC Wrapper with LL FIFO 
    -- (v5_emac_v1_5_locallink.v)
    ------------------------------------------------------------------------
    v5_emac_ll : v5_emac_v1_5_locallink
    port map (
      -- EMAC0 Clocking
      -- TX Client Clock output from EMAC0
      TX_CLIENT_CLK_OUT_0             => tx_client_clk_0_o,
      -- RX Client Clock output from EMAC0
      RX_CLIENT_CLK_OUT_0             => rx_client_clk_0_o,
      -- TX PHY Clock output from EMAC0
      TX_PHY_CLK_OUT_0                => tx_phy_clk_0_o,
      -- EMAC0 TX Client Clock input from BUFG
      TX_CLIENT_CLK_0                 => tx_client_clk_0,
      -- EMAC0 RX Client Clock input from BUFG
      RX_CLIENT_CLK_0                 => rx_client_clk_0,
      -- EMAC0 TX PHY Clock input from BUFG
      TX_PHY_CLK_0                    => tx_phy_clk_0, 
      -- Local link Receiver Interface - EMAC0
      RX_LL_CLOCK_0                   => ll_clk_0_i,
      RX_LL_RESET_0                   => ll_reset_0_i,
      RX_LL_DATA_0                    => rx_ll_data_0_i,
      RX_LL_SOF_N_0                   => rx_ll_sof_n_0_i,
      RX_LL_EOF_N_0                   => rx_ll_eof_n_0_i,
      RX_LL_SRC_RDY_N_0               => rx_ll_src_rdy_n_0_i,
      RX_LL_DST_RDY_N_0               => rx_ll_dst_rdy_n_0_i,
      RX_LL_FIFO_STATUS_0             => open,

      -- Unused Receiver signals - EMAC0
      EMAC0CLIENTRXDVLD               => EMAC0CLIENTRXDVLD,
      EMAC0CLIENTRXFRAMEDROP          => EMAC0CLIENTRXFRAMEDROP,
      EMAC0CLIENTRXSTATS              => EMAC0CLIENTRXSTATS,
      EMAC0CLIENTRXSTATSVLD           => EMAC0CLIENTRXSTATSVLD,
      EMAC0CLIENTRXSTATSBYTEVLD       => EMAC0CLIENTRXSTATSBYTEVLD,

      -- Local link Transmitter Interface - EMAC0
      TX_LL_CLOCK_0                   => ll_clk_0_i,
      TX_LL_RESET_0                   => ll_reset_0_i,
      TX_LL_DATA_0                    => tx_ll_data_0_i,
      TX_LL_SOF_N_0                   => tx_ll_sof_n_0_i,
      TX_LL_EOF_N_0                   => tx_ll_eof_n_0_i,
      TX_LL_SRC_RDY_N_0               => tx_ll_src_rdy_n_0_i,
      TX_LL_DST_RDY_N_0               => tx_ll_dst_rdy_n_0_i,

      -- Unused Transmitter signals - EMAC0
      CLIENTEMAC0TXIFGDELAY           => CLIENTEMAC0TXIFGDELAY,
      EMAC0CLIENTTXSTATS              => EMAC0CLIENTTXSTATS,
      EMAC0CLIENTTXSTATSVLD           => EMAC0CLIENTTXSTATSVLD,
      EMAC0CLIENTTXSTATSBYTEVLD       => EMAC0CLIENTTXSTATSBYTEVLD,

      -- MAC Control Interface - EMAC0
      CLIENTEMAC0PAUSEREQ             => CLIENTEMAC0PAUSEREQ,
      CLIENTEMAC0PAUSEVAL             => CLIENTEMAC0PAUSEVAL,

 
      -- Clock Signals - EMAC0
      GTX_CLK_0                       => gtx_clk_0_i,
      -- GMII Interface - EMAC0
      GMII_TXD_0                      =>GMII_TXD_0_bf,
      GMII_TX_EN_0                    => GMII_TX_EN_0_bf,
      GMII_TX_ER_0                    => GMII_TX_ER_0_bf,
      GMII_TX_CLK_0                   => GMII_TX_CLK_0,
      GMII_RXD_0                      => GMII_RXD_0,
      GMII_RX_DV_0                    => GMII_RX_DV_0,
      GMII_RX_ER_0                    => GMII_RX_ER_0,
      GMII_RX_CLK_0                   => rx_clk_0_i,

     -- MII_TX_CLK_0                    => MII_TX_CLK_0,
--      GMII_COL_0                      => GMII_COL_0,
--      GMII_CRS_0                      => GMII_CRS_0,

        
        
      -- Asynchronous Reset
      RESET                           => reset_i
    );
GMII_TXD_0 <= GMII_TXD_0_bf;
GMII_TX_ER_0 <= GMII_TX_ER_0_bf;
GMII_TX_EN_0 <= GMII_TX_EN_0_bf;
    ---------------------------------------------------------------------
    --  Instatiate the address swapping module
    ---------------------------------------------------------------------
    client_side_asm_emac0 : address_swap_module_8
      port map (
        rx_ll_clock         => ll_clk_0_i,
        rx_ll_reset         => ll_reset_0_i,
        rx_ll_data_in       => rx_ll_data_0_i,
        rx_ll_sof_in_n      => rx_ll_sof_n_0_i,
        rx_ll_eof_in_n      => rx_ll_eof_n_0_i,
        rx_ll_src_rdy_in_n  => rx_ll_src_rdy_n_0_i,
        rx_ll_data_out      => tx_ll_data_0_i,
        rx_ll_sof_out_n     => tx_ll_sof_n_0_i,
        rx_ll_eof_out_n     => tx_ll_eof_n_0_i,
        rx_ll_src_rdy_out_n => tx_ll_src_rdy_n_0_i,
        rx_ll_dst_rdy_in_n  => tx_ll_dst_rdy_n_0_i
    );

    rx_ll_dst_rdy_n_0_i     <= tx_ll_dst_rdy_n_0_i;


cs_trig(0) <= rx_ll_sof_n_0_i;
cs_trig(1) <= rx_ll_eof_n_0_i;
cs_trig(9 downto 2) <= rx_ll_data_0_i;
cs_trig(10) <= rx_clk_0_i;
cs_trig(19 downto 12) <= GMII_RXD_0;


cs_trig(20) <= tx_ll_sof_n_0_i;
cs_trig(21) <= tx_ll_eof_n_0_i;
cs_trig(29 downto 22) <= tx_ll_data_0_i;
cs_trig(30) <=GMII_TX_EN_0_bf;
cs_trig(31) <=GMII_TX_ER_0_bf;
cs_trig(39 downto 32) <= GMII_TXD_0_bf;


    -- Create synchronous reset in the transmitter clock domain.
    gen_ll_reset_emac0 : process (ll_clk_0_i, reset_i)
    begin
      if reset_i = '1' then
        ll_pre_reset_0_i <= (others => '1');
        ll_reset_0_i     <= '1';
      elsif ll_clk_0_i'event and ll_clk_0_i = '1' then
        ll_pre_reset_0_i(0)          <= '0';
        ll_pre_reset_0_i(5 downto 1) <= ll_pre_reset_0_i(4 downto 0);
        ll_reset_0_i                 <= ll_pre_reset_0_i(5);
      end if;
    end process gen_ll_reset_emac0;
 
    ------------------------------------------------------------------------
    -- REFCLK used for RGMII IODELAYCTRL primitive - Need to supply a 200MHz clock
    ------------------------------------------------------------------------
    --refclk_ibufg : IBUFG port map(I => REFCLK, O => refclk_ibufg_i);
    refclk_bufg  : BUFG  port map(I => RefClk_200MHz, O => refclk_bufg_i);

	

    ----------------------------------------------------------------------
    -- Stop the tools from automatically adding in a BUFG on the
    -- GTX_CLK_0 line.
    ----------------------------------------------------------------------
    gtx_clk0_ibuf : IBUF port map (I => GTX_CLK_0, O => gtx_clk_0_i);

--PHY_RESET_0 <=  '1';--RESET;


 
end TOP_LEVEL;
