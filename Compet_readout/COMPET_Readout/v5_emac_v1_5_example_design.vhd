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



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;     --! Numeric/arithmetical logic (IEEE standard)


--library work;
use work.constants.all;       --! Global constants
use work.types.all;           --! Global types
use work.functions.all;       --! Global functions


library unisim;
use unisim.vcomponents.all;

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

      MII_TX_CLK_0                    : in  std_logic;
      GMII_COL_0                      : in  std_logic;
      GMII_CRS_0                      : in  std_logic;

      -- Reference clock for RGMII IODELAYs
      REFCLK_200MHz                          : in  std_logic; 
        
        
      -- Asynchronous Reset
      reset_i                           : in  std_logic;
		PHY_RESET_0                     : out std_logic;
		
		--data to be sent out:
		fe_event_ready       : in std_logic; 
     fe_event_data_packed    : in std_logic_vector(31 downto 0);
	  mclk : in std_logic;
	  fe_rst_b: in std_logic;
	  LEDs:  out std_logic_vector(7 downto 0);
	  cs_ila_trig0    : out std_logic_vector( cs_ILA_SIZE-1 downto 0 );
	  coincidence_trigger: in std_logic;
	  	temac_clk_out                  : out std_logic

   );
end v5_emac_v1_5_example_design;


architecture TOP_LEVEL of v5_emac_v1_5_example_design is

signal temac_clk_out_i : std_logic;
signal cs_ila_trig0_i    : std_logic_vector( cs_ILA_SIZE-1 downto 0 );

signal LEDs_bf : std_logic_vector(7 downto 0);
 --signal RefClk_200MHz: std_logic;


signal ReceivedData: std_logic_vector(7 downto 0);
signal ReceivedDataRdy: std_logic;
-------------------------------------------------------------------------------
-- Component Declarations for lower hierarchial level entities
-------------------------------------------------------------------------------

--component cs_control
--  PORT (
--    CONTROL0 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0));
--
--end component;
--
--
--component cs_ila
--  PORT (
--    CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
--    CLK : IN STD_LOGIC;
--    TRIG0 : IN STD_LOGIC_VECTOR(63 DOWNTO 0));
--
--end component;
--






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

      MII_TX_CLK_0                    : in  std_logic;
      GMII_COL_0                      : in  std_logic;
      GMII_CRS_0                      : in  std_logic;

        
        
      -- Asynchronous Reset
      RESET                           : in  std_logic
   );
  end component;
 
   ---------------------------------------------------------------------
   --  Component Declaration for 8-bit address swapping module
   ---------------------------------------------------------------------
--   component address_swap_module_8
--   port (
--      rx_ll_clock         : in  std_logic;                     -- Input CLK from MAC Reciever
--      rx_ll_reset         : in  std_logic;                     -- Synchronous reset signal
--      rx_ll_data_in       : in  std_logic_vector(7 downto 0);  -- Input data
--      rx_ll_sof_in_n      : in  std_logic;                     -- Input start of frame
--      rx_ll_eof_in_n      : in  std_logic;                     -- Input end of frame
--      rx_ll_src_rdy_in_n  : in  std_logic;                     -- Input source ready
--      rx_ll_data_out      : out std_logic_vector(7 downto 0);  -- Modified output data
--      rx_ll_sof_out_n     : out std_logic;                     -- Output start of frame
--      rx_ll_eof_out_n     : out std_logic;                     -- Output end of frame
--      rx_ll_src_rdy_out_n : out std_logic;                     -- Output source ready
--      rx_ll_dst_rdy_in_n  : in  std_logic                      -- Input destination ready
--      );
--   end component;


	COMPONENT UDP_IP_Core
	PORT(
		rst : IN std_logic;
		clk_125MHz : IN std_logic;
		transmit_start_enable : IN std_logic;
		transmit_data_length : IN std_logic_vector(15 downto 0);
		transmit_data_input_bus : IN std_logic_vector(7 downto 0);
		rx_sof : IN std_logic;
		rx_eof : IN std_logic;
		input_bus : IN std_logic_vector(7 downto 0);          
		usr_data_trans_phase_on : OUT std_logic;
		start_of_frame_O : OUT std_logic;
		end_of_frame_O : OUT std_logic;
		source_ready : OUT std_logic;
		transmit_data_output_bus : OUT std_logic_vector(7 downto 0);
		valid_out_usr_data : OUT std_logic;
		usr_data_output_bus : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

	component fe_FIFO_toUDP
	port (
	din: IN std_logic_VECTOR(31 downto 0);
	rd_clk: IN std_logic;
	rd_en: IN std_logic;
	rst: IN std_logic;
	wr_clk: IN std_logic;
	wr_en: IN std_logic;
	dout: OUT std_logic_VECTOR(31 downto 0);
	empty: OUT std_logic;
	full: OUT std_logic;
	rd_data_count: OUT std_logic_VECTOR(7 downto 0));
end component;

component GlobalEventTrigger_FIFO
	port (
	din: IN std_logic_VECTOR(63 downto 0);
	rd_clk: IN std_logic;
	rd_en: IN std_logic;
	rst: IN std_logic;
	wr_clk: IN std_logic;
	wr_en: IN std_logic;
	dout: OUT std_logic_VECTOR(63 downto 0);
	empty: OUT std_logic;
	full: OUT std_logic);
end component;

-- Synplicity black box declaration
attribute syn_black_box : boolean;
attribute syn_black_box of GlobalEventTrigger_FIFO: component is true;


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

--UDP stuff:


signal transmit_data_output_bus: std_logic_vector(7 downto 0);
	signal transmit_data_output_bus_reg: std_logic_vector(7 downto 0);	
	signal source_ready : std_logic;


	signal end_of_frame_O :  std_logic;
	signal start_of_frame_O : std_logic;    
	signal input_bus : std_logic_vector(7 downto 0);
	signal rx_eof :  std_logic;
	
	signal rx_sof :  std_logic;
	--signal ll_clk_0_i: std_logic;
	--signal ll_reset_0_i: std_logic;
	signal transmit_start_enable: std_logic;
	signal transmit_data_length:std_logic_vector(15 downto 0);
	signal usr_data_trans_phase_on: std_logic;
	signal usr_data_trans_phase_on_reg1: std_logic;
	signal usr_data_trans_phase_on_reg2: std_logic;
	signal usr_data_trans_phase_on_tmp: std_logic;
	signal transmit_data_input_bus: std_logic_vector(7 downto 0);
	signal valid_out_usr_data: std_logic;
	signal usr_data_output_bus:     std_logic_vector(7 downto 0);
	signal usr_data_output_bus_tmp: std_logic_vector(7 downto 0);
	signal usr_data_output_bus_reg: std_logic_vector(7 downto 0);

-- UDP fifos etc:
   signal read_fifo : std_logic;
	signal fifo_toUDP_data: std_logic_vector(31 downto 0);
	signal fifo_toUDP_empty: std_logic;
   signal fifo_toUDP_full: std_logic;
	signal rd_data_count: std_logic_VECTOR(7 downto 0);
	
	-- UDP sending FSM:
	type state_type is ( S_reset,S_wait, S_wait0,S_send0, S_send1, S_send2, S_send3, S_start0,S_start1, S_footer,S_footer_1);
	signal next_state: state_type := S_reset;
	signal current_state : state_type := S_wait;
   signal state_counter : unsigned(7 downto 0);
	signal footer_counter: integer range 0 to 7;
   signal UDP_sending_now: std_logic;
	signal fe_FIFO_out  : std_logic_vector(31 downto 0);
-- cs:
    
	 
	 signal counter : unsigned(31 downto 0);
	 
	 
	 signal PackageCounter: unsigned(63 downto 0);
--signal CONTROL0: STD_LOGIC_VECTOR(35 DOWNTO 0);
--signal cs_trig: STD_LOGIC_VECTOR(63 DOWNTO 0);
-------------------------------------------------------------------------------
-- Main Body of Code
-------------------------------------------------------------------------------
signal GlobalEventCounter : unsigned(63 downto 0);
signal coincidence_trigger_i : std_logic;
signal WriteGlobalEventCounterToFifo : std_logic;
signal readGlobalEventCounter: std_logic;
signal GlobalEventCounter_out: std_logic_vector(63 downto 0);
signal GlobalEventCounter_out_i: std_logic_vector(63 downto 0);
signal GlobalEventTriggerEmpty: std_logic;
begin


-- count the global trigger number:



LEDs<=LEDs_bf;
cs_ila_trig0 <= cs_ila_trig0_i;
--inst_cs_control : cs_control
--  port map (
--    CONTROL0 => CONTROL0);
--
--inst_cs_ila : cs_ila
--  port map (
--    CONTROL => CONTROL0,
--    CLK => RefClk_200MHz,
--    TRIG0 => cs_trig);

	


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

      MII_TX_CLK_0                    => MII_TX_CLK_0,
      GMII_COL_0                      => GMII_COL_0,
      GMII_CRS_0                      => GMII_CRS_0,

        
        
      -- Asynchronous Reset
      RESET                           => reset_i
    );
GMII_TXD_0 <= GMII_TXD_0_bf;
GMII_TX_ER_0 <= GMII_TX_ER_0_bf;
GMII_TX_EN_0 <= GMII_TX_EN_0_bf;
    ---------------------------------------------------------------------
    --  Instatiate the address swapping module
    ---------------------------------------------------------------------
--    client_side_asm_emac0 : address_swap_module_8
--      port map (
--        rx_ll_clock         => ll_clk_0_i,
--        rx_ll_reset         => ll_reset_0_i,
--        rx_ll_data_in       => rx_ll_data_0_i,
--        rx_ll_sof_in_n      => rx_ll_sof_n_0_i,
--        rx_ll_eof_in_n      => rx_ll_eof_n_0_i,
--        rx_ll_src_rdy_in_n  => rx_ll_src_rdy_n_0_i,
--        rx_ll_data_out      => tx_ll_data_0_i,
--        rx_ll_sof_out_n     => tx_ll_sof_n_0_i,
--        rx_ll_eof_out_n     => tx_ll_eof_n_0_i,
--        rx_ll_src_rdy_out_n => tx_ll_src_rdy_n_0_i,
--        rx_ll_dst_rdy_in_n  => tx_ll_dst_rdy_n_0_i
--    );

    rx_ll_dst_rdy_n_0_i     <= tx_ll_dst_rdy_n_0_i;
--from system:
--transmit_data_output_busUDP_pin => transmit_data_output_bus,
--		source_readyUDP_pin => source_ready,
--		end_of_frame_OUDP_pin => end_of_frame_O,
--		start_of_frame_OUDP_pin => start_of_frame_O,
--		input_busUDP_pin => input_bus,
--		rx_eofUDP_pin => rx_eof,
--		rx_sofUDP_pin => rx_sof,
--		ll_clk_0_iUDP_pin => ll_clk_0_i,
--		ll_reset_0_i_pin => ll_reset_0_i

tx_ll_sof_n_0_i <= start_of_frame_O;
tx_ll_eof_n_0_i <= end_of_frame_O;
tx_ll_data_0_i  <= transmit_data_output_bus;
tx_ll_src_rdy_n_0_i   <= source_ready;

temac_clk_out <= temac_clk_out_i;
temac_clk_out_i <= ll_clk_0_i;

Inst_UDP_IP_Core:  UDP_IP_Core PORT MAP( --MyUDP PORT MAP (--
		rst =>ll_reset_0_i ,
		clk_125MHz => ll_clk_0_i,
		transmit_start_enable => transmit_start_enable,
		transmit_data_length => transmit_data_length,
		usr_data_trans_phase_on =>usr_data_trans_phase_on ,
		transmit_data_input_bus => transmit_data_input_bus,
		start_of_frame_O =>start_of_frame_O ,
		end_of_frame_O => end_of_frame_O,
		source_ready => source_ready,
		transmit_data_output_bus => transmit_data_output_bus,
		rx_sof => rx_sof,
		rx_eof => rx_eof,
		input_bus => input_bus,
		valid_out_usr_data => valid_out_usr_data,
		usr_data_output_bus => usr_data_output_bus
	);

cs_ila_trig0_i(7 downto 0) <= usr_data_output_bus;
cs_ila_trig0_i(8)          <= valid_out_usr_data;
--- now the Event FIFO:
--cs_ila_trig0_i(32)<=fe_event_ready ;
--cs_ila_trig0_i(31 downto 0)<= fe_event_data_packed;
inst_FIFO_toUDP :  fe_FIFO_toUDP
		port map (
			din => fe_event_data_packed,
			rd_clk => ll_clk_0_i,
			rd_en => read_fifo,
			rst => ll_reset_0_i,
			wr_clk => mclk,
			wr_en => fe_event_ready,
			dout => fifo_toUDP_data,
			empty => fifo_toUDP_empty,
			full => fifo_toUDP_full,
			rd_data_count => rd_data_count);


--sending state machine:
state_reg_transmit: process(ll_clk_0_i,ll_reset_0_i)
begin
if ll_reset_0_i ='1' then
  current_state <= S_reset;
 
elsif rising_edge(ll_clk_0_i) then
  current_state <= next_state;
	
 end if;
end process;

PackageRdyToSend: process(ll_clk_0_i,ll_reset_0_i) --
begin
if(ll_reset_0_i= '1') then
	counter <= (OTHERS=>'0');
elsif(rising_edge(ll_clk_0_i)) then
	counter <= counter +1;
end if;
end process;

LEDs_bf(1) <= ll_reset_0_i;
LEDs_bf(2) <= counter(27);

--cs_ila_trig0_i(0) <= read_fifo;
--cs_ila_trig0_i(7 downto 0) <= transmit_data_input_bus;
--cs_ila_trig0_i(8)<=usr_data_trans_phase_on;
--cs_ila_trig0_i(17 downto 10)<=transmit_data_output_bus;
--cs_ila_trig0_i(18) <= tx_ll_sof_n_0_i;
--cs_ila_trig0_i(19) <= tx_ll_eof_n_0_i;
--cs_ila_trig0_i(20) <= source_ready;

output_logic_transmit: process(ll_clk_0_i,ll_reset_0_i)
begin
if ll_reset_0_i ='1' then
		transmit_start_enable <= '0';
		transmit_data_length  <= (OTHERS =>'0');
		transmit_data_input_bus <= (OTHERS =>'0');
		read_fifo <= '0';
		state_counter <= (OTHERS => '0');
		UDP_sending_now <='0';
		fe_FIFO_out <= (OTHERS => '0');
		footer_counter <= 0;
		GlobalEventCounter_out_i <= (OTHERS => '0');
		LEDs_bf(0) <= '0';
		
		
elsif rising_edge(ll_clk_0_i) then
case current_state is
   when S_reset=> 
	   transmit_start_enable <= '0';
		transmit_data_length  <= (OTHERS =>'0');
		transmit_data_input_bus <= (OTHERS =>'0');
		read_fifo <= '0';
		state_counter <= (OTHERS => '0');
		UDP_sending_now <='0';
		fe_FIFO_out <= (OTHERS => '0');
		footer_counter <= 0;
		GlobalEventCounter_out_i <= (OTHERS => '0');
		LEDs_bf(0) <=  LEDs_bf(0);
		PackageCounter <= (OTHERS => '0');

	when S_wait0 =>
		 transmit_start_enable <= '0';
		transmit_data_length  <= (OTHERS =>'0');
		transmit_data_input_bus <= (OTHERS =>'0');
		read_fifo <= '0';
		state_counter <= (OTHERS => '0');
		UDP_sending_now <='0';
		fe_FIFO_out <= (OTHERS => '0');
		footer_counter <= 0;
		GlobalEventCounter_out_i <= (OTHERS => '0');
		LEDs_bf(0) <=  LEDs_bf(0);
		PackageCounter <= PackageCounter;
		
	when S_wait => 
	   transmit_start_enable <= '0';
		transmit_data_length  <= (OTHERS =>'0');
		transmit_data_input_bus <= (OTHERS =>'0');
		read_fifo <= '0';
		state_counter <= (OTHERS => '0');
		UDP_sending_now <='0';
		fe_FIFO_out <= (OTHERS => '0');
		footer_counter <= 0;
		GlobalEventCounter_out_i <= (OTHERS => '0');
		PackageCounter <= PackageCounter;
		
		LEDs_bf(0) <=  LEDs_bf(0);
	when S_start0 =>
	   transmit_start_enable <= '1';
		--transmit_data_length  <= std_logic_vector(to_unsigned(4*127+8+1,16)); -- 127 data packages, 8 bytes of event counter, 1 package counter
	   transmit_data_length  <= std_logic_vector(to_unsigned(4*127+8+1,16)); -- 127 data packages, 4 bytes of event counter, 1 package counter
		--transmit_data_length  <= x"01FC";
		transmit_data_input_bus <= (OTHERS => '0');
		read_fifo <= '0'; --mr do again...
		state_counter <= (OTHERS => '0');--mr send one less
		UDP_sending_now <='1';
		fe_FIFO_out <= fifo_toUDP_data;
		GlobalEventCounter_out_i <= GlobalEventCounter_out;
		footer_counter <= 0;
		PackageCounter <= PackageCounter +1;
		LEDs_bf(0) <= not LEDs_bf(0);
	
	when S_start1 =>
	   transmit_start_enable <= '0';
		transmit_data_length  <= (OTHERS => '0');
		transmit_data_input_bus <= fe_FIFO_out(7 downto 0);
		read_fifo <= '0';
		state_counter <= state_counter;
		UDP_sending_now <='1';
		fe_FIFO_out <= fe_FIFO_out;
		footer_counter <= 0;
		GlobalEventCounter_out_i <= GlobalEventCounter_out_i;
		PackageCounter <= PackageCounter;
		LEDs_bf(0) <= LEDs_bf(0);
	
	when S_send0 =>
      transmit_start_enable <= '0';
		transmit_data_length  <= (OTHERS =>'0');
		transmit_data_input_bus <=fe_FIFO_out(15 downto 8);
		read_fifo <= '1';
		state_counter <= state_counter+1;
		UDP_sending_now <='1';
		fe_FIFO_out <= fe_FIFO_out;
		LEDs_bf(0) <= LEDs_bf(0);
		footer_counter <= 0;
		PackageCounter <= PackageCounter;
		GlobalEventCounter_out_i <= GlobalEventCounter_out_i;
	
	when S_send1 =>
      transmit_start_enable <= '0';
		transmit_data_length  <= (OTHERS =>'0');
		transmit_data_input_bus <= fe_FIFO_out(23 downto 16);
		read_fifo <= '0';
		state_counter <= state_counter;
		UDP_sending_now <='1';
		fe_FIFO_out <= fe_FIFO_out;
		footer_counter <= 0;
		GlobalEventCounter_out_i <= GlobalEventCounter_out_i;
		PackageCounter <= PackageCounter;
		LEDs_bf(0) <= LEDs_bf(0);
	
	when S_send2 =>
      transmit_start_enable <= '0';
		transmit_data_length  <= (OTHERS =>'0');
		transmit_data_input_bus <= fe_FIFO_out(31 downto 24);
		read_fifo <= '0'; -- read the next event
		state_counter <= state_counter;
		UDP_sending_now <='1';
		fe_FIFO_out <= fifo_toUDP_data;
		footer_counter <= 0;
		GlobalEventCounter_out_i <= GlobalEventCounter_out_i;
		PackageCounter <= PackageCounter;
		LEDs_bf(0) <= LEDs_bf(0);
	
	when S_footer =>
	   transmit_start_enable <= '0';
		transmit_data_length  <= (OTHERS =>'0');
		transmit_data_input_bus <= GlobalEventCounter_out_i((footer_counter+1)*8-1 downto footer_counter*8);
		read_fifo <= '0'; -- read the next event
		state_counter <= state_counter;
		UDP_sending_now <='1';
		fe_FIFO_out <= fifo_toUDP_data;
		footer_counter <= footer_counter +1;
		GlobalEventCounter_out_i <= GlobalEventCounter_out_i;
		PackageCounter <= PackageCounter;
		LEDs_bf(0) <= LEDs_bf(0);
	
	when S_footer_1 =>
	   transmit_start_enable <= '0';
		transmit_data_length  <= (OTHERS =>'0');
		transmit_data_input_bus <= std_logic_vector(PackageCounter(7 downto 0));
		read_fifo <= '0'; -- read the next event
		state_counter <= state_counter;
		UDP_sending_now <='1';
		fe_FIFO_out <= fifo_toUDP_data;
		footer_counter <= 0;--(OTHERS => '0');
		GlobalEventCounter_out_i <= GlobalEventCounter_out_i;
		PackageCounter <= PackageCounter;
		LEDs_bf(0) <= LEDs_bf(0);
	when others =>
	   transmit_start_enable <= '0';
		transmit_data_length  <= (OTHERS =>'0');
		transmit_data_input_bus <= (OTHERS =>'0');
		read_fifo <= '0';
		UDP_sending_now <='0';
		fe_FIFO_out <= (OTHERS => '0');
		state_counter <= (OTHERS => '0');
		footer_counter <= 0;
		GlobalEventCounter_out_i <= GlobalEventCounter_out_i;
		PackageCounter <= PackageCounter;
		LEDs_bf(0) <= LEDs_bf(0);
end case;
end if;
end process;





comb_logic_transmit: process(current_state,state_counter,   usr_data_trans_phase_on, rd_data_count(7), footer_counter)
begin
case current_state is
   when S_reset => next_state <= S_wait0;
	
   when S_wait0 => next_state <= S_wait;
	
	when S_wait =>  -- wait state
		  	if  rd_data_count(7) = '1' then --start sending when more than 127 events are in the FIFO
			      next_state <= S_start0;
         else
				next_state <= S_wait;
			end if;
			
when S_start0 =>
	       next_state <= S_start1;
			
	when S_start1 =>
	     if usr_data_trans_phase_on = '1' or state_counter /= 0 then
					next_state <= S_send0;	
			else
	         next_state <= S_start1;
			end if;
   
	when S_send0 =>
	      next_state <= S_send1;
			
	when S_send1 =>
	      next_state <= S_send2;
			
	when S_send2 =>
	     if state_counter = 127 then
	      next_state <= S_footer;
		  else
			next_state <= S_start1;
		  end if;
		  
   when S_footer =>
		 if footer_counter = 7 then
	    --if footer_counter = 3 then
		   next_state <= S_footer_1;
		 else
		   next_state <= S_footer;
		 end if;
	when S_footer_1 =>
	    next_state <= S_wait0;
		 
	
	when others =>
	      next_state <= S_reset;
	
end case;
end process;




global_event_cnt: process (mclk,fe_rst_b) begin
  if( fe_rst_b = '0' ) then
   GlobalEventCounter <= (OTHERS => '0');
   coincidence_trigger_i <= '1';
	WriteGlobalEventCounterToFifo <= '0';
  elsif( rising_edge(mclk) ) then
   coincidence_trigger_i <= coincidence_trigger;
   if(coincidence_trigger_i = '0' and coincidence_trigger = '1') then --rising edge
		WriteGlobalEventCounterToFifo <= '1';
		if(GlobalEventCounter(6 downto 0) = "1111111") then --wrapping
			GlobalEventCounter <= GlobalEventCounter + 2;
		else
			GlobalEventCounter <= GlobalEventCounter + 1;
		end if;
	else 
	  GlobalEventCounter <= GlobalEventCounter;
	  WriteGlobalEventCounterToFifo <= '0';
	end if;
  end if;
end process;

inst_GlobalEventTrigger_FIFO : GlobalEventTrigger_FIFO
		port map (
			din => std_logic_vector(GlobalEventCounter),
			rd_clk => ll_clk_0_i,
			rd_en => readGlobalEventCounter,
			rst => ll_reset_0_i,
			wr_clk => mclk,
			wr_en => WriteGlobalEventCounterToFifo,
			dout =>GlobalEventCounter_out,
			empty => GlobalEventTriggerEmpty,
			full => open);


--now pop as many of the GlobalEventTriggers out of the fifo until the first element
-- of the event fifo has the same event trigger number  (last 7 bits)
-- maybe should do it blocking with UDP_sending_now and a signal popping_now?
GlobalEventCounterPopper: process (ll_clk_0_i,ll_reset_0_i) 
variable zeros: std_logic_vector(fe_EVENT_NO_SIZE-1 downto 0);
begin
   zeros := (OTHERS => '0');
  if(ll_reset_0_i = '1' ) then
     readGlobalEventCounter <= '0';
	 
	  elsif(rising_edge(ll_clk_0_i)) then
		if(GlobalEventTriggerEmpty = '0' and fifo_toUDP_empty = '0' ) then
			if(unpack_event(fifo_toUDP_data).event_no = zeros) then
				readGlobalEventCounter <= '0';
			elsif(unpack_event(fifo_toUDP_data).event_no
				/= GlobalEventCounter_out(fe_EVENT_NO_SIZE-1 downto 0) 	) then
				 readGlobalEventCounter <= '1';
			else
			    readGlobalEventCounter <= '0';
			 end if;
		else
			readGlobalEventCounter <= '0';
		end if;
	end if;
end process;
  
--UDP_sending_now







--cs_trig(0) <= rx_ll_sof_n_0_i;
--cs_trig(1) <= rx_ll_eof_n_0_i;
--cs_trig(9 downto 2) <= rx_ll_data_0_i;
--cs_trig(10) <= rx_clk_0_i;
--cs_trig(19 downto 12) <= GMII_RXD_0;
--
--
--cs_trig(20) <= tx_ll_sof_n_0_i;
--cs_trig(21) <= tx_ll_eof_n_0_i;
--cs_trig(29 downto 22) <= tx_ll_data_0_i;
--cs_trig(30) <=GMII_TX_EN_0_bf;
--cs_trig(31) <=GMII_TX_ER_0_bf;
--cs_trig(39 downto 32) <= GMII_TXD_0_bf;
--

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
