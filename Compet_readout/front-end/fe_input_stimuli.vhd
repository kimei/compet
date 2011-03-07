--! \file
--! \brief A module for creating test TOT pulses.

--! It simply utilises a counter and some AND gates to do this. You can use these pulses to test
--! the front-end basic operation by substituting the output from the deserialiser with 'tot_test'

--! Standard library
library ieee;
use ieee.std_logic_1164.all;  --! Standard logic
use ieee.numeric_std.all;     --! Numeric/arithmetical logic (IEEE standard)

--! Work library (self-composed)
library work;
use work.constants.all;       --! Global constants
use work.types.all;           --! Global types
-- use work.components.all;      --! Global component declarations

--! \brief Entity
entity fe_input_stimuli is
port(
  gcnt              : in  std_logic_vector(                35 downto 0); --Yep, huge.
  tot_test          : out std_logic_vector(fe_ch_WORD_WIDTH-1 downto 0)
);
end entity;

--! \brief Architecture
architecture rtl of fe_input_stimuli is
 signal tot_test_i : std_logic_vector(fe_ch_WORD_WIDTH-1 downto 0);
begin


  generate_pattern : process(gcnt)
    variable temp_and    : std_logic;
    variable pulse_width : positive; 
    variable rep_rate    : positive;
  begin
    temp_and    := '1' ;
    rep_rate    := 15  ; --! 50MHz/2^26 = 0.75Hz
    pulse_width :=  6  ; --! 2^5/50MHz = 640ns

  --! Not much can go wrong here. :) Good for testing.
  for i in pulse_width to rep_rate loop
    temp_and := temp_and and gcnt(i);
  end loop;

    tot_test_i <= ( others => temp_and );
  end process;

  tot_test <= tot_test_i;
end architecture;

