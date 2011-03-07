--! A module for creating test TOT pulses.

--! By utilising a simple counter and LUT this model aims to create
--! TOT pulses to test the operation of the front-end stage.


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fe_input_stimuli is
port(
  gcnt              : in  std_logic_vector(35 downto 0); --Yep, huge.
  tot_test          : out std_logic_vector( 9 downto 0)
);
end entity;

architecture rtl of fe_input_stimuli is

type   state_type is (reset_st, wait_st, hold_st);
signal state, next_state  : state_type;

-- signal tot_i : std_logic_vector( tot'range );


begin


--! Start with something really simple...
-- tot <= ( others => (gcnt( 22 ) and gcnt( 21 ) and gcnt( 20 ) and gcnt( 19 ) and 
--                     gcnt( 18 ) and gcnt( 17 ) and gcnt( 16 ) and gcnt( 15 ) and 
--                     gcnt( 14 ) and gcnt( 13 ) and gcnt( 12 ) and gcnt( 11 ) and
--                     gcnt( 10 ) and gcnt(  9 ) and gcnt(  8 ) and gcnt(  7 ) ) );
   tot_test <= ( others => (gcnt( 6 ) and gcnt( 5 ) ) );
  

end architecture;

