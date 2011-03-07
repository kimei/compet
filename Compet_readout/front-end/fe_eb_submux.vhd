--! \file
--! \brief The Event Builder sub-multiplexer block.

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

--! \brief Event Builder
--! \details Stitches data with the same event number together.
entity fe_ch_submux is
generic(
  no_inputs      : positive; --! The number of input data-lines left
  fan_in         : positive  --! The fan-in of this level
);
port(
  mclk           : in  std_logic; --! Master clock
  fe_rst_b       : in  std_logic; --! Front-end reset (active low)

  -- These are constant sized signals - used by last level instantiation
  fifo_data      : in  fe_ch_event_data_reduced_atype( no_inputs-1 downto 0 );
  fifo_en        : in  std_logic_vector           ( no_inputs-1 downto 0 );
  fifo_rd        : out std_logic_vector           ( no_inputs-1 downto 0 );

  --! Assigns priority to enable signals. Only 0 when no submux' with higher priorities have data.
  priority_in    : in  std_logic; 
  priority_out   : out std_logic;

  -- Data output from a mux in the pipe. These vary for each instance.
  mux_en         : out std_logic;
  mux_data       : out fe_ch_event_data_reduced_type --! Data output

);
end entity;

architecture rtl of fe_ch_submux is
  signal mux_data_i     : fe_ch_event_data_reduced_type;
begin


-- Less inputs left than fan-in = last level. Use FIFO data in this case.
if_last_level: if (no_inputs <= fan_in) generate
  signal priority_tmp : std_logic;
begin

  --! Handle the case where there is only one channel left. No need for a MUX then.
  if_one_ch: if (no_inputs = 1) generate begin
    fifo_rd(0)  <= fifo_en(0) and ( not priority_in );
    priority_out <= priority_tmp;

    mux_data <= fifo_data(0); --! Data output

    priority_tmp <= priority_in or fifo_en(0);
    process (mclk) begin
      if( fe_rst_b = '0' ) then
        mux_en <= '0';
      elsif( rising_edge( mclk ) ) then
        mux_en <= priority_tmp and ( not priority_in );
      end if;
    end process;
  end generate if_one_ch;

  -- Describing a multiplexer with priority encoded inputs.
  process(fifo_en, priority_in, fifo_data)
    variable en          : std_logic; --Temporary
    variable fifo_rd_tmp : std_logic_vector( fifo_rd'range );
  begin
    en          := '1';
    fifo_rd_tmp := ( others => '0' );

    -- Assign priorities from data channel 0 (highest) to 'no_inputs' (lowest)
    for i in 0 to no_inputs-1 loop
      if( fifo_en(i) = '1' and priority_in = '0' ) then 
        mux_data_i  <= fifo_data(i);
        fifo_rd_tmp(i) := '1' ; --! "Clear"/read signal sent to the channel FIFO being read
        en             := '0' ;
      else
--         mux_data_i <= ( others => ( others => '0') );
        mux_data_i.tot_start <=( others => '0');
        mux_data_i.tot_width <=( others => '0');
        mux_data_i.ch_no     <=( others => '0');
      end if;
        exit when en = '0';
    end loop;
  
    fifo_rd <= fifo_rd_tmp;
  end process;

  priority_tmp <= priority_in or bitwise_or( fifo_en );
  priority_out  <= priority_tmp;


  --! Generate the pipeline registers.
  pipe_buf: process (mclk,fe_rst_b)
  begin
    if( fe_rst_b = '0' ) then
      mux_data.tot_start <=( others => '0');
      mux_data.tot_width <=( others => '0');
      mux_data.ch_no     <=( others => '0');
      mux_en   <= '0' ;
    elsif( rising_edge(mclk) ) then
      mux_data <= mux_data_i;
      mux_en   <= priority_tmp and ( not priority_in );
    end if;
  end process;

end generate;

-- Decend recursively when there are less inputs left than fan-in
if_mid_level: if (no_inputs > fan_in) generate
  signal priority_tmp   : std_logic_vector( fan_in downto 0 );
  signal mux_en_in      : std_logic_vector( fan_in-1 downto 0 );
  signal mux_data_in    : fe_ch_event_data_reduced_atype( fan_in-1 downto 0 );
begin

  -- Describing a multiplexer with priority encoded inputs.
  process( mux_data_in, mux_en_in )
    variable en  : std_logic;
  begin
    en := '1';

    -- Assign priorities from data channel 0 (highest) to 'fan_in-1' (lowest)
    for i in 0 to fan_in-1 loop
      if( mux_en_in(i) = '1' ) then --! Start 
        mux_data_i  <= mux_data_in(i);
        en := '0';
      else
--         mux_data_i <= ( others => ( others => '0' ) );
        mux_data_i.tot_start <=( others => '0');
        mux_data_i.tot_width <=( others => '0');
        mux_data_i.ch_no     <=( others => '0');
      end if;
        exit when en = '0';
    end loop;
  end process;

  --! The priority lines are not used here. Passing them along to last level.
  priority_tmp(0) <= priority_in;
  priority_out    <= priority_tmp(fan_in);

  --! Now, continue down the hierarchy
  rep: for i in 0 to fan_in-1 generate begin
  rep_inst: entity work.fe_ch_submux
  generic map(
    no_inputs     => (no_inputs/fan_in) , --! The number of inputs
    fan_in        => fan_in    
  )
  port map(
    mclk          => mclk               , --! Master clock
    fe_rst_b      => fe_rst_b           , --! Front-end reset (active low)

    -- These are constant sized signals - used by last level instantiation
    --!\todo Make this more robust to *any* value of no_inputs and fanout
    fifo_data    => fifo_data( (no_inputs/fan_in)*(i+1)-1 downto (no_inputs/fan_in)*i ),
    fifo_en      => fifo_en  ( (no_inputs/fan_in)*(i+1)-1 downto (no_inputs/fan_in)*i ),
    fifo_rd      => fifo_rd  ( (no_inputs/fan_in)*(i+1)-1 downto (no_inputs/fan_in)*i ),

    priority_in  => priority_tmp(i  )   ,
    priority_out => priority_tmp(i+1)   ,

    -- Data outputs from the next MUX is 'inputs' to this one.
    mux_en       => mux_en_in(i)        , -- The enable line
    mux_data     => mux_data_in(i)        -- Assign each fanout to 'inputs' of this module.
  );
  end generate;

  --! Generate the pipeline registers.
  pipe_buf: process (mclk,fe_rst_b)
  begin
    if( fe_rst_b = '0' ) then
--       mux_data <= ( others => ( others => '0' ) );
      mux_data.tot_start <= ( others => '0');
      mux_data.tot_width <= ( others => '0');
      mux_data.ch_no     <= ( others => '0');
      mux_en             <= '0' ;
    elsif( rising_edge(mclk) ) then
      mux_data <= mux_data_i;
      mux_en   <= bitwise_or( mux_en_in );
    end if;
  end process;

end generate if_mid_level;

end architecture;