--! \file
--! \brief Component deptclarations.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.constants.all;                 --! Global constants


package components is
-- PLL from Xilinx ip
  component PLL_ALL
    port(
      CLKIN1_IN   : in  std_logic;
      RST_IN      : in  std_logic;
      CLKOUT0_OUT : out std_logic;
      CLKOUT1_OUT : out std_logic;
      LOCKED_OUT  : out std_logic
      );
  end component;

  component CRU
    port(
      fpga_100m_clk  : in  std_logic;
      fpga_cpu_reset : in  std_logic;
      mclk           : out std_logic;
      mclk_b         : out std_logic;
      gclk           : out std_logic;
      mrst_b         : out std_logic;
      lrst_b         : out std_logic
      );
  end component;

  -- a2s from Jo-Inge
  component a2s
    generic(
      depth : positive := 2);           --! FIFO depth
    port(
      arst_b : in  std_logic;           --! Asynchronous reset      
      srst_b : in  std_logic;           --! Synchronous reset
      clk    : in  std_logic;           --! Synchronisation clock
      i      : in  std_logic;           --! Input
      o      : out std_logic);          --! Output
  end component;

  component sync_trigger
    port (
      rst_b        : in  std_logic;
      mclk          : in  std_logic;
      trigger_in    : in  std_logic_vector(NUMBER_OF_ROCS-1 downto 0);
      trigger_in_b  : in  std_logic_vector(NUMBER_OF_ROCS-1 downto 0);
      trigger_out   : out std_logic_vector(NUMBER_OF_MODULES-1 downto 0);
      trigger_out_b : out std_logic_vector(NUMBER_OF_MODULES-1 downto 0));
  end component;

  component uart
    generic (
      CLK_FREQ : integer;
      SER_FREQ : integer);
    port (
      clk      : in  std_logic;
      rst      : in  std_logic;
      rx       : in  std_logic;
      tx       : out std_logic;
      par_en   : in  std_logic;
      tx_req   : in  std_logic;
      tx_end   : out std_logic;
      tx_data  : in  std_logic_vector(7 downto 0);
      rx_ready : out std_logic;
      rx_data  : out std_logic_vector(7 downto 0));
  end component;

  component com
    port (
      mclk  : in  std_logic;
      rst_b : in  std_logic;
      rx    : in  std_logic;
      tx    : out std_logic);
  end component;

  component st_fsm
    generic (
      NO_OF_MODULES : positive);
    port (
      leading_edge_b : in  std_logic_vector(NO_OF_MODULES-1 downto 0);
      mclk           : in  std_logic;
      rst_b         : in  std_logic;
      trigger_out    : out std_logic_vector(NO_OF_MODULES-1 downto 0));
  end component;

  -- OBUFDS is a single output buffer that supports low-voltage, differential
  --signaling (1.8v CMOS). OBUFDS isolates the internal circuit and provides
  --drive current for signals leaving the chip. Its output is represented as
  --two distinct ports (O and OB), one deemed the "master" and the other the
  --"slave." The master and the slave are opposite phases of the same logical
  -- signal (for example, MYNET and MYNETB).
  component OBUFDS
    port (O  : out std_ulogic;
          OB : out std_ulogic;
          I  : in  std_ulogic);
  end component;

    component IBUFDS
    port (I  : in std_ulogic;
          IB : in std_ulogic;
          O  : out  std_ulogic);
  end component;
  
end package components;
