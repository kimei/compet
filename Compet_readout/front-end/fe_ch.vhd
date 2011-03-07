--! \file 
--! \brief All per-channel front-end functionality.
--! 
--! This module contains the per-channel front-end electronics. 

--! Standard library
library ieee;
use ieee.std_logic_1164.all;  --! Standard logic
use ieee.numeric_std.all;     --! Numeric/arithmetical logic (IEEE standard)

-- --! Xilinx Unisim library
-- library unisim;
-- use unisim.vcomponents.all;   --! For simulation

--! Work library (self-composed)
library work;
use work.constants.all;       --! Global constants
use work.types.all;           --! Global types
-- use work.components.all;      --! Global component declarations
use work.functions.all;       --! Global functions

--! \brief Entity
entity fe_ch is
generic(
  ch_no                 :     natural := 0--! The channel number
);
port(
--  ch_no                 : in  std_logic_vector( fe_ch_LOC_SIZE-1 downto 0 );
  mclk                  : in  std_logic           ; --! Master clock
  fe_clk                : in  std_logic           ; --! Front-end clock
  fe_rst_b              : in  std_logic           ; --! Front-end reset (active low)
                      
  fe_data               : in  std_logic           ; --! TOT signal from the analog electronics
  tot_test              : in  std_logic_vector(fe_ch_WORD_WIDTH-1 downto 0);--! TOT test signal
  neg_input             : in  std_logic; --! Negate polarity of the input?
  mask_input            : in  std_logic; --! Mask this channel completely?

  event_no              : in  std_logic_vector( fe_EVENT_NO_SIZE-1 downto 0 ) ; --! Co.trg cnt
  event_trigger         : out std_logic                       ; --! Sent to the Trigger Unit
  coincidence_trigger   : in  std_logic                       ; --! Event validation
  coarse_time           : in  std_logic_vector( fe_CO_TRG_SIZE-log2(fe_ch_WORD_WIDTH)-1 downto 0 ) ;   --! Co.trg. length

--   event_ready           : out std_logic                       ; --! Fresh event_data present? 
--   event_data            : out fe_ch_event_data_type           ; --! Event #, time, ch. #, tot
  fe_ch_fifo_rd          : in std_logic           ; --! Input to FIFO
  fe_ch_fifo_out         : out fe_ch_fifo_otype   ; --! Outputs from FIFO

--   up_bram               : out up_bram_otype                   ; --! The uP BRAM interface

  -- Data to be viewed with ILA:
  fe_parallel_data       : out std_logic_vector( fe_ch_WORD_WIDTH-1 downto 0 );
  cs_vio                 : in cs_vio_type;
  --cs_fe                 : out std_logic_vector( 31 downto 0 );
  ResetRateCounters     : in std_logic;
  EventRate             : out std_logic_vector(fe_EventRate_SIZE-1 downto 0)
 
);   
end entity;

---------------------------------------------------------------------------------------------------
--! \brief Architecture
architecture rtl of fe_ch is
---------------------------------------------------------------------------------------------------

signal parallel_data    : std_logic_vector(fe_ch_WORD_WIDTH-1 downto 0);
signal parallel_data_i  : std_logic_vector(fe_ch_WORD_WIDTH-1 downto 0);
signal parallel_data_ii : std_logic_vector(fe_ch_WORD_WIDTH-1 downto 0);
signal data             : std_logic_vector(fe_ch_WORD_WIDTH-1 downto 0);
signal event_trigger_i  : std_logic;
signal event_ready_i    : std_logic                       ; --! Fresh event_data present? 
signal event_data_i     : fe_ch_event_data_type           ; --! Event #, time, ch. #, tot
begin


deser: entity work.fe_ch_iserdes
port map(
  mclk              => mclk           , --! Master clock
  fe_clk            => fe_clk         , --! Front-end clock
--   fe_rst_b          => fe_rst_b       , --! Front-end reset (active low)

--   mask_input        => mask_input     , --! Disable the input?
                                    
  serial_data       => fe_data        , --! Serial input data
  parallel_data     => parallel_data    --! Deserialised output data
);

--! Negate the input lines where polarity is not the standard one.
parallel_data_i  <= parallel_data   when (neg_input = '0')  else (not parallel_data);

--! Mask the channels we do not need.
parallel_data_ii <= parallel_data_i when (mask_input = '0') else ( others => '0' );

--! Note the renaming: data=parallel_data
data <= tot_test when (cs_vio.test_en = '1') else parallel_data_ii; 

pg: entity work.fe_ch_pargen
generic map(
ch_no               => ch_no                  --! The channel number
)
port map(
  --
  mclk                => mclk                 , --! Master clock
  fe_rst_b            => fe_rst_b             , --! Front-end reset (active low)                     
  data                => data                 ,
  data_delay          => cs_vio.data_delay    , --! # cycles data delay

  coincidence_trigger => coincidence_trigger  , --! Event validation
  coarse_time         => coarse_time          , --! Coincidence window length
  event_no            => event_no             , --! Co.trg cnt
  event_trigger       => event_trigger_i      , --! Sent to the Trigger Unit

  event_data          => event_data_i         , --! Event #, time, ch. #, tot
  event_ready         => event_ready_i          --! Fresh event_data present? 
);

--! \todo Need more ports!
ch_fifo: entity work.fe_ch_buf
port map(
  mclk              => mclk           , --! Master clock
  fe_rst_b          => fe_rst_b       , --! Front-end reset (active low)

  event_data        => event_data_i   , --! Event #, time, ch. #, tot
  event_ready       => event_ready_i  ,

  fe_ch_fifo_rd     => fe_ch_fifo_rd  , --! Input to FIFO
  fe_ch_fifo_out    => fe_ch_fifo_out ,  --! Outputs from FIFO
  ResetRateCounters => ResetRateCounters,
  EventRate         => EventRate
);


-- event_data    <= event_data_i;
-- event_ready   <= event_ready_i;
event_trigger <= event_trigger_i;-- when (mask_input = '0') else '0';
fe_parallel_data <= data;

end architecture;