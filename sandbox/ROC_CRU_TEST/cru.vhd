
--! \file
--! \brief The Clock Reset Unit


--! Standard library
library ieee;
use ieee.std_logic_1164.all;            --! Standard logic

--! Xilinx Unisim library
library unisim;
use unisim.vcomponents.all;             --! For simulation

--! Work library (self-composed)
library work;
use work.constants.all;                 --! Global constants
use work.types.all;                     --! Global types
use work.components.all;                --! Global component declarations


--! \brief Entity
entity cru is
  port(
    fpga_100m_clk : in std_logic;       --! 100Mhz single-ended board clock



    clk100m_ctu   : in std_logic;       -- differential clk input from CTU
    clk100m_ctu_b : in std_logic;
    cru_reset     : in std_logic;

    using_ext_clock_led  : out std_logic;


    clk100m_ctu_out   : out std_logic;  -- differential clk output to next ROC
    clk100m_ctu_out_b : out std_logic;


    fpga_cpu_reset : in std_logic;  --! Active low system reset (only connected to the IO pad)

    up_clk        : out std_logic;      --! 100MHz Microblaze clock
    fe_clk        : out std_logic;      --! Front-end clock
    mclk          : out std_logic;      --! 50 MHz master (global) clock
    REFCLK_200MHz : out std_logic;
    REFCLK_125MHz : out std_logic;

    up_rst_b     : out std_logic;  --! Microblaze reset (synchronous assert/deassert)
    fe_rst_b     : out std_logic;  --! Front-end reset (async. assert, sync. deassert)
    mrst_b       : out std_logic;  --! Master (global) reset (async. assert, sync. deassert)
    UDPRst_200_b : out std_logic;  --! The reset for the UDP, TEMAC and PHY 
    UDPRst_125_b : out std_logic;   --! The reset for the UDP, TEMAC and PHY 
    --cs_vio            : cs_vio_type    --! ChipScope input/output

    --Debug code!!!
    ----------------------------------------------------------------------------
    clk100m_ctu_out_test   : out std_logic;  -- differential clk input from CTU
    clk100m_ctu_out_b_test : out std_logic

    ----------------------------------------------------------------------
    );
end entity;


---------------------------------------------------------------------------------------------------
--! \brief Architecture
architecture rtl of cru is
---------------------------------------------------------------------------------------------------


  component pll_all
    port(
      CLKIN1_IN   : in  std_logic;
      RST_IN      : in  std_logic;
      CLKOUT0_OUT : out std_logic;
      CLKOUT1_OUT : out std_logic;
      CLKOUT2_OUT : out std_logic;
      CLKOUT3_OUT : out std_logic;
      CLKOUT4_OUT : out std_logic;
      LOCKED_OUT  : out std_logic
      );
  end component;

  component DCM2PLL
    port(
      CLKIN_N_IN        : in  std_logic;
      CLKIN_P_IN        : in  std_logic;
      USER_RST_IN       : in  std_logic;
      CLKIN_IBUFGDS_OUT : out std_logic;
      CLKOUT0_OUT       : out std_logic;
      CLKOUT1_OUT       : out std_logic;
      CLKOUT2_OUT       : out std_logic;
      CLKOUT3_OUT       : out std_logic;
      CLKOUT4_OUT       : out std_logic;
      LOCKED_OUT        : out std_logic
      );
  end component;

  component BUFGMUX_CTRL
    port (
      O  : out std_ulogic;
      I0 : in  std_ulogic;
      I1 : in  std_ulogic;
      S  : in  std_ulogic
      );
  end component;




  signal clk_stable : std_logic;

  signal clk100m_ctu_out_se : std_logic;
signal clk100m_ctu_out_se_test : std_logic;

  
  signal mclk_i          : std_logic;
  signal fe_clk_i        : std_logic;
  signal up_clk_i        : std_logic;
  signal REFCLK_200MHz_i : std_logic;
  signal REFCLK_125MHz_i : std_logic;

  signal mclk_i_0          : std_logic;
  signal fe_clk_i_0        : std_logic;
  signal up_clk_i_0        : std_logic;
  signal REFCLK_200MHz_i_0 : std_logic;
  signal REFCLK_125MHz_i_0 : std_logic;

  signal mclk_i_1          : std_logic;
  signal fe_clk_i_1        : std_logic;
  signal up_clk_i_1        : std_logic;
  signal REFCLK_200MHz_i_1 : std_logic;
  signal REFCLK_125MHz_i_1 : std_logic;

  signal mrst_b_i       : std_logic;
  signal fe_rst_b_i     : std_logic;
  signal up_rst_b_i     : std_logic;
  signal UDPRst_200_b_i : std_logic;
  signal UDPRst_125_b_i : std_logic;


  signal cru_OR_fpga_rst   : std_logic;  -- simple OR of reset on board and from CTU
  signal cru_OR_fpga_rst_b : std_logic;
  signal rst_DCM2PLL       : std_logic;
  signal DCM2PLL_lock      : std_logic;
  signal DCM2PLL_lock_b    : std_logic;
  signal DCM2PLL_lock_uf   : std_logic;

  signal fpga_cpu_reset_b : std_logic;

  signal locked_counter : integer range 0 to 16300;  -- approx 14 bit
-- end added kim

begin
-- The embedded project contains its own DCM, letting this handle the clock.


--! Use a PLL to create internal clocks based on the same 100MHz board clock source.
--! This should ease adaption to dynamic switch of source clock..
  fpga_cpu_reset_b  <= not fpga_cpu_reset;
  cru_OR_fpga_rst   <= fpga_cpu_reset or cru_reset;
  rst_DCM2PLL       <= cru_OR_fpga_rst and (not DCM2PLL_lock_uf);
  cru_OR_fpga_rst_b <= not cru_OR_fpga_rst;
  DCM2PLL_lock_b    <= not DCM2PLL_lock;


  using_ext_clock_led <= not DCM2PLL_lock;

  clk_gen_pll : pll_all port map(
    CLKIN1_IN   => fpga_100m_clk ,      --! 100MHz board clock
    RST_IN      => fpga_cpu_reset ,     --! Board reset
    CLKOUT0_OUT => up_clk_i_0 ,         --! Microblaze clock (100 MHz)
    CLKOUT1_OUT => fe_clk_i_0 ,         --! Front-end clock
    CLKOUT2_OUT => mclk_i_0 ,           --! Master clock (50 MHz)
    CLKOUT3_OUT => REFCLK_125MHz_i_0 ,  --! 125MHz clk for UDP
    CLKOUT4_OUT => REFCLK_200MHz_i_0 ,  --! 200MHz reference clock for UDP
    LOCKED_OUT  => clk_stable  --! Indicates whether the PLL has a clock lock
    );


-- Using LOCKED_OUT for anything requires it to be 'filtered'
-- The signal can not be trusted 100us after  reset is deasserted.
-- See function lock_filter
  Inst_DCM2PLL : DCM2PLL port map(
    CLKIN_N_IN        => clk100m_ctu_b ,
    CLKIN_P_IN        => clk100m_ctu ,
    USER_RST_IN       => rst_DCM2PLL,
    CLKIN_IBUFGDS_OUT => open,
    CLKOUT0_OUT       => up_clk_i_1,
    CLKOUT1_OUT       => fe_clk_i_1,
    CLKOUT2_OUT       => mclk_i_1,
    CLKOUT3_OUT       => REFCLK_125MHz_i_1,
    CLKOUT4_OUT       => REFCLK_200MHz_i_1,
    LOCKED_OUT        => DCM2PLL_lock_uf
    );

  up_clk_mux : BUFGMUX
    port map (O  => up_clk_i,
              I0 => up_clk_i_0,
              I1 => up_clk_i_1,
              S  => DCM2PLL_lock);
  fe_clk_mux : BUFGMUX
    port map (O  => fe_clk_i,
              I0 => fe_clk_i_0,
              I1 => fe_clk_i_1,
              S  => DCM2PLL_lock);
  mclk_mux : BUFGMUX
    port map (O  => mclk_i,
              I0 => mclk_i_0,
              I1 => mclk_i_1,
              S  => DCM2PLL_lock);
  REFCLK_125MHz_mux : BUFGMUX
    port map (O  => REFCLK_125MHz_i,
              I0 => REFCLK_125MHz_i_0,
              I1 => REFCLK_125MHz_i_1,
              S  => DCM2PLL_lock);
  REFCLK_200MHz_mux : BUFGMUX
    port map (O  => REFCLK_200MHz_i,
              I0 => REFCLK_200MHz_i_0,
              I1 => REFCLK_200MHz_i_1,
              S  => DCM2PLL_lock);

  MCLK_ODDR_OUT : ODDR port map(
    Q  => clk100m_ctu_out_se,
    S  => '0',
    R  => DCM2PLL_lock_b,
    D1 => '1',
    D2 => '0',
    CE => '1',
    C  => up_clk_i);

  MCLK_DIFF_OUT : OBUFDS port map(
    O  => clk100m_ctu_out,
    OB => clk100m_ctu_out_b,
    I  => clk100m_ctu_out_se);

  MCLK_ODDR_OUT_t : ODDR port map(
    Q  => clk100m_ctu_out_se_test,
    S  => '0',
    R  => DCM2PLL_lock_b,
    D1 => '1',
    D2 => '0',
    CE => '1',
    C  => up_clk_i);

  MCLK_DIFF_OUT_t : OBUFDS port map(
    O  => clk100m_ctu_out_test,
    OB => clk100m_ctu_out_b_test,
    I  => clk100m_ctu_out_se_test);
  
-- purpose: Connect LOCKED_OUT from DCM2PLL to multiplexer 100 us after reset on DCM2PLL is deasserted
-- type   : sequential
-- inputs : mclk_i_1, rst_DCM2PLL
  lock_filter : process (mclk_i_1, rst_DCM2PLL)
  begin  -- process lock_filter
    if rst_DCM2PLL = '1' then           -- asynchronous reset (active low)
      DCM2PLL_lock   <= '0';
      locked_counter <= 0;
    elsif mclk_i_1'event and mclk_i_1 = '1' then  -- rising clock edge
      if locked_counter < 10000 then
        locked_counter <= locked_counter + 1;
      else
        DCM2PLL_lock <= DCM2PLL_lock_uf;          -- and its filtered..
      end if;
    end if;
  end process lock_filter;


  up_clk <= up_clk_i;
  fe_clk <= fe_clk_i;
  mclk   <= mclk_i;

  REFCLK_125MHz <= REFCLK_125MHz_i;
  REFCLK_200MHz <= REFCLK_200MHz_i;



--! For the Microblaze, use synchronous assertion and deassertion of reset
--! \todo Add soft resets etc. when available
--! \todo Fix the async hack when reset mux is done
  up_rst_sync : entity work.a2s port map(
    srst_b => '1' ,                     --! Synchronous  reset
    arst_b => cru_OR_fpga_rst_b ,       --! Asynchronous reset
    clk    => up_clk_i ,                --! Synchronisation clock
    i      => '1' ,                     --! Asynchronous input
    o      => up_rst_b_i                --! Synchronous  output (metafiltered)
    );
  up_rst_b <= up_rst_b_i;


  fe_rst_sync : entity work.a2s port map(
    srst_b => '1' ,                     --! Synchronous  reset
    arst_b => cru_OR_fpga_rst_b ,       --! Asynchronous reset
    clk    => fe_clk_i ,                --! Synchronisation clock
    i      => '1' ,                     --! Asynchronous input
    o      => fe_rst_b_i                --! Synchronous  output (metafiltered)
    );
  fe_rst_b <= fe_rst_b_i;  -- and cs_vio.fe_soft_rst_b; --! Ok since the soft reset is synchronous


  mrst_sync : entity work.a2s port map(
    srst_b => '1' ,                     --! Synchronous  reset
    arst_b => cru_OR_fpga_rst_b ,       --! Asynchronous reset
    clk    => mclk_i ,                  --! Synchronisation clock
    i      => '1' ,                     --! Asynchronous input
    o      => mrst_b_i                  --! Synchronous  output (metafiltered)
    );
  mrst_b <= mrst_b_i;


--UDP / TEMAC etc.
  UDP_125_Rst_sync : entity work.a2s port map(
    srst_b => '1' ,                     --! Synchronous  reset
    arst_b => cru_OR_fpga_rst_b ,       --! Asynchronous reset
    clk    => REFCLK_125MHz_i ,         --! Synchronisation clock
    i      => '1' ,                     --! Asynchronous input
    o      => UDPRst_125_b_i            --! Synchronous  output (metafiltered)
    );

  UDPRst_125_b <= UDPRst_125_b_i;

  UDP_200_Rst_sync : entity work.a2s port map(
    srst_b => '1' ,                     --! Synchronous  reset
    arst_b => cru_OR_fpga_rst_b ,       --! Asynchronous reset
    clk    => REFCLK_200MHz_i ,         --! Synchronisation clock
    i      => '1' ,                     --! Asynchronous input
    o      => UDPRst_200_b_i            --! Synchronous  output (metafiltered)
    );

  UDPRst_200_b <= UDPRst_200_b_i;
end architecture;

