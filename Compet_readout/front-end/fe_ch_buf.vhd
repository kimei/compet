--! \file
--! \brief Per-channel event buffer.

--! Standard library
library ieee;
use ieee.std_logic_1164.all;  --! Standard logic
use ieee.numeric_std.all;     --! Numeric/arithmetical logic (IEEE standard)

--! Xilinx Unisim library
library unisim;
use unisim.vcomponents.all;   --! For simulation

--! Work library (self-composed)
library work;
use work.constants.all;       --! Global constants
use work.types.all;           --! Global types
use work.functions.all;       --! Global functions
--use work.components.all;
--! \brief Entity
entity fe_ch_buf is
port(
  mclk              : in  std_logic; --! Master clock
  fe_rst_b          : in  std_logic; --! Front-end reset (active low)
                        
  event_data        : in fe_ch_event_data_type           ; --! Event #, time, ch. #, tot
  event_ready       : in std_logic;

  fe_ch_fifo_rd     : in std_logic; --! Input to FIFO
  fe_ch_fifo_out    : out fe_ch_fifo_otype; --! Outputs from FIFO
  ResetRateCounters : in std_logic;
  EventRate         : out std_logic_vector(fe_EventRate_SIZE-1 downto 0)
);   
end entity;

----------------------------------------------------------------------------------
--! \brief Architecture
architecture rtl of fe_ch_buf is
----------------------------------------------------------------------------------
  component fe_ch_fifo
  port (
    clk               : in  std_logic                     ; --! Common clock for read/write
    din               : in  std_logic_vector(31 downto 0) ; --! Data input
    rd_en             : in  std_logic                     ; --! Read enable
    rst               : in  std_logic                     ; --! Async reset
    wr_en             : in  std_logic                     ; --! Write enable
    almost_full       : out std_logic                     ; --! Only 1 data space left
    dout              : out std_logic_vector(31 downto 0) ; --! Data output
    empty             : out std_logic                     ; --! No data
    full              : out std_logic                     ; --! No room for more data
    overflow          : out std_logic                     ; --! Write on full fifo = overflow
    valid             : out std_logic                     ; --! Dout valid (read-ack)
    wr_ack            : out std_logic                       --! Din valid (write-ack)
  );
  end component;
-- signal parallel_data  : std_logic_vector(fe_ch_WORD_WIDTH-1 downto 0);
-- signal data           : std_logic_vector(fe_ch_WORD_WIDTH-1 downto 0);
-- signal test_en        : std_logic;
-- signal event_i          : std_logic_vector(63 downto 0);
-- signal event_trigger_i  : std_logic;

-- type   state_type is (reset_st, ready_st, write_st);
-- signal state, next_state  : state_type;

--! The "write-side" of the FIFO only accessed in this module:
-- signal wr_en          : std_logic;
-- signal wr_ack         : std_logic;

-- signal almost_full_i  : std_logic;
-- signal valid          : std_logic;


  
  
  signal oports : fe_ch_fifo_otype;

--   signal delay_line_read_en : std_logic_vector(9 downto 0);
--   signal rd_en : std_logic;
  signal almost_full : std_logic;
  signal empty       : std_logic;
  signal event_ready_to_write : std_logic;
  
  signal dout        : std_logic_vector(31 downto 0);
  signal dout_masked : std_logic_vector(31 downto 0);
  signal fe_rst      : std_logic;
  
  
  signal EventRate_i:  unsigned(fe_EventRate_SIZE+fe_EventRate_LowerBound-1 downto 0); -- contains also the non transmitted LSBs
  signal EventRate_ii: std_logic_vector(fe_EventRate_SIZE-1 downto 0);
  
  --signal LowerBound:   unsigned(fe_EventRate_LowerBound-1 downto 0);
begin

  --! \todo Let us first just see what happens when there is no handling of "overflow".

 EventRate <= EventRate_ii;
 
event_rate_cnt: process (mclk,fe_rst_b) begin
  if( fe_rst_b = '0' ) then
    EventRate_i <=  ( others => '0' );
	 EventRate_ii<=  ( others => '0' );
  elsif( rising_edge(mclk) ) then       
   if(ResetRateCounters = '1') then
      EventRate_ii <= std_logic_vector(EventRate_i(fe_EventRate_SIZE+fe_EventRate_LowerBound-1 downto fe_EventRate_LowerBound));
		EventRate_i <= ( others => '0' );
	elsif(event_ready_to_write = '1') then
	   EventRate_ii <= EventRate_ii;
		EventRate_i <= EventRate_i +1;
   else
	   EventRate_ii <= EventRate_ii;
		EventRate_i  <= EventRate_i;
	end if;
	
  end if;
end process;



 
  
  event_ready_to_write <= event_ready AND empty;  -- want only one event in the FIFO^!
    fe_rst <= not fe_rst_b;
  fifo: fe_ch_fifo
  port map(
    clk             => mclk                     , --! Common clock for read/write
    rst             => fe_rst                   , --! Async reset
    din             => pack(event_data)         , --! Data input
    wr_en           => event_ready_to_write     , --! Write enable
    rd_en           => fe_ch_fifo_rd            , --! Read enable
    almost_full     => oports.almost_full       , --! Only 1 data space left
    dout            => dout                     , --! Data output
    empty           => empty                    , --! No data
    full            => oports.full              , --! No room for more data
    overflow        => oports.overflow          , --! Write on full fifo = overflow
    valid           => oports.valid             , --! Dout valid (read-ack)
    wr_ack          => open                       --! Din valid (write-ack)
  );

dout_masked <= dout when ( empty = '0' ) else ( others => '0' );
oports.dout <= unpack_event( dout_masked );

fe_ch_fifo_out <= oports;

end architecture;