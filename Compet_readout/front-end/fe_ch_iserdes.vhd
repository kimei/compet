--! \file
--! \brief Deserialiser

--! Standard library
library ieee;
use ieee.std_logic_1164.all;  --! Standard logic

--! Xilinx Unisim library
library unisim;
use unisim.vcomponents.all;   --! For simulation

--! Work library (self-composed)
library work;
use work.constants.all;       --! Global constants
use work.types.all;           --! Global types
-- use work.components.all;      --! Global component declarations

--! \brief This is the Top entity
--! \details And this is some more details
entity fe_ch_iserdes is
port(
    mclk              : in  std_logic;       --! Master clock
    fe_clk            : in  std_logic;       --! Front-end clock
--     fe_rst_b          : in  std_logic;       --! Front-end reset (active low)

--     mask_input        : in  std_logic; --! Mask this channel completely?
                        
    --! XGI Expansion Headers
    serial_data      : in  std_logic;                              --! Serial input data
    parallel_data    : out std_logic_vector(fe_ch_WORD_WIDTH-1 downto 0) --! Deserialised output data
  );
end entity;

---------------------------------------------------------------------------------------------------
--! \brief Architecture
architecture rtl of fe_ch_iserdes is
---------------------------------------------------------------------------------------------------

signal shift_link1 : std_logic;
signal shift_link2 : std_logic;
signal BITSLIP     : std_logic;
signal CE1, CE2    : std_logic;
-- signal CLK         : std_logic;
-- signal CLKDIV      : std_logic;
-- signal D           : std_logic;
signal DLYCE       : std_logic;
signal DLYINC      : std_logic;
signal DLYRST      : std_logic;
signal OCLK        : std_logic;
signal SHIFTIN1    : std_logic;
signal SHIFTIN2    : std_logic;
signal SR          : std_logic;

-- signal O   : std_logic;
-- signal Q1  : std_logic;
-- signal Q2  : std_logic;
-- signal Q3  : std_logic;
-- signal Q4  : std_logic;
-- signal Q5  : std_logic;
-- signal Q6  : std_logic;

-- parallel_data    : out std_logic_vector(fe_ch_WORD_WIDTH-1 downto 0)

signal REV : std_logic;

-- signal data : std_logic_vector(9 downto 0);

begin

BITSLIP     <= '0'; --! Disabled
DLYCE       <= '0'; --! Delay chain disabled
DLYINC      <= '0'; --! Delay chain increment/decrement. Just holding it fixed..
DLYRST      <= '0'; --! Delay chain reset. Active high.
OCLK        <= '0'; --! Clock for memory applications. Not used.
REV         <= '0'; --! Inverses state of asserted SR. Not used.
SHIFTIN1    <= '0'; --! Not to be used, but errors produced unless connected.
SHIFTIN2    <= '0'; --! Not to be used, but errors produced unless connected.
SR          <= '0'; --! Set/reset. Disabled.

CE1 <= '1';
CE2 <= '1';
-- CE1 <= not mask_input; --! Enable clock when input is not masked
-- CE2 <= not mask_input; --! Enable clock when input is not masked

ISERDES_1 : ISERDES
generic map (
  BITSLIP_ENABLE  => TRUE            , --! Required for "NETWORKING" mode
  DATA_RATE       => "DDR"           , --! Yep, we want DDR
  DATA_WIDTH      => fe_ch_WORD_WIDTH, --! Data width, 10 is max
  INIT_Q1         => '0'             , --! INIT for Q1 register - '1' or '0'
  INIT_Q2         => '0'             , --! INIT for Q2 register - '1' or '0'
  INIT_Q3         => '0'             , --! INIT for Q3 register - '1' or '0'
  INIT_Q4         => '0'             , --! INIT for Q4 register - '1' or '0'
  INTERFACE_TYPE  => "NETWORKING"    , --! "NETWORKING" required for width expansion (alt. is "MEMORY")
  IOBDELAY        => "NONE"          , --! Specify outputs where delay chain is applied
                                       --! "NONE", "IBUF", "IFD", or "BOTH"
  IOBDELAY_TYPE   => "DEFAULT"       , --! Set tap delay "DEFAULT", "FIXED", or "VARIABLE"
  IOBDELAY_VALUE  => 0               , --! Set initial tap delay to an integer from 0 to 63
  NUM_CE          => 1               , --! Define number or clock enables to an integer of 1 or 2
  SERDES_MODE     => "MASTER"        ) --! This is the "MASTER" of the expansion setup
port map (
  --! Inputs
  SHIFTOUT1       => shift_link1     , --! 1-bit output
  SHIFTOUT2       => shift_link2     , --! 1-bit output
  BITSLIP         => BITSLIP         , --! Bitslip enable
  CE1             => CE1             , --! Clock enable
  CE2             => CE2             , --! Not used, but get errors unless connected.
  CLK             => fe_clk          , --! Front-end clock
  CLKDIV          => mclk            , --! Master clock
  D               => serial_data    , --! Serial input
  DLYCE           => DLYCE           , --! 1-bit input
  DLYINC          => DLYINC          , --! 1-bit input
  DLYRST          => DLYRST          , --! 1-bit input
  OCLK            => OCLK            , --! 1-bit input
  SHIFTIN1        => SHIFTIN1        , --! 1-bit input
  SHIFTIN2        => SHIFTIN2        , --! 1-bit input
  SR              => SR              , --! Set/reset

  --! Outputs
--   O               => O               , --! Unregistered bypass output. Not used.
  Q1              => parallel_data(0)         , --! 1-bit output
  Q2              => parallel_data(1)         , --! 1-bit output
  Q3              => parallel_data(2)         , --! 1-bit output
  Q4              => parallel_data(3)         , --! 1-bit output
  Q5              => parallel_data(4)         , --! 1-bit output
  Q6              => parallel_data(5)         , --! 1-bit output

  REV             => REV              --! Not used, but get errors unless connected.
);

--ISERDES_2 : ISERDES
--generic map (   
--  BITSLIP_ENABLE  => TRUE            , --! Required for "NETWORKING" mode
--  DATA_RATE       => "DDR"           , --! Yep, we want DDR
--  DATA_WIDTH      => 10              , --! Data width, 10 is max
--  INIT_Q1         => '0'             , --! INIT for Q1 register - '
--  INIT_Q2         => '0'             , --! INIT for Q2 register - '
--  INIT_Q3         => '0'             , --! INIT for Q3 register - '
--  INIT_Q4         => '0'             , --! INIT for Q4 register - '
--  INTERFACE_TYPE  => "NETWORKING"    , --! "NETWORKING" required for width expansion (alt. is "MEMORY")
--  IOBDELAY        => "NONE"          , --! Specify outputs where de
--                                       --! "NONE", "IBUF", "IFD", o
--  IOBDELAY_TYPE   => "DEFAULT"       , --! Set tap delay "DEFAULT",
--  IOBDELAY_VALUE  => 0               , --! Set initial tap delay to
--  NUM_CE          => 1               , --! Define number or clock e
--  SERDES_MODE     => "SLAVE"         ) --! This is the "SLAVE" of the expansion setup
--port map (
--  --! Inputs
----   SHIFTOUT1       => SHIFTOUT1, --! 1-bit output
----   SHIFTOUT2       => SHIFTOUT2, --! 1-bit output
--  BITSLIP         => BITSLIP      , --! Bitslip enable
--  CE1             => CE1          , --! Clock enable
--  CE2             => CE2          , --! Not used, but get errors unless connected.
--  CLK             => fe_clk       , --! Front-end clock
--  CLKDIV          => mclk         , --! Master clock
--  D               => '0'          , --! Serial input
--  DLYCE           => DLYCE        , --! 1-bit input
--  DLYINC          => DLYINC       , --! 1-bit input
--  DLYRST          => DLYRST       , --! 1-bit input
--  OCLK            => OCLK         , --! 1-bit input
--  SHIFTIN1        => shift_link1  , --! 1-bit input
--  SHIFTIN2        => shift_link2  , --! 1-bit input
--  SR              => '0'          , --! 1-bit input
--
--  --! Outputs
----   O               => O            , --! Unregistered bypass output. Not used.
--  Q1              => open           , --! Not used in expanded mode.
--  Q2              => open           , --! Not used in expanded mode.
--  Q3              => parallel_data(6)      , --! 1-bit output
--  Q4              => parallel_data(7)      , --! 1-bit output
--  Q5              => parallel_data(8)      , --! 1-bit output
--  Q6              => parallel_data(9)      , --! 1-bit output
--
--  REV             => REV            --! Not used, but get errors unless connected.
--);
--

end architecture;