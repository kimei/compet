--! \file
--! \brief LUT shiftregister

--! A decent amount of logic may be saved by implementing shift-registers using the SRLXX primitives.
--! This module describes a shift-register to facilitation the interration of such primitives.

--! Why not just use loop description? XST simply too often fails to recognise and infer SRLs from
--! this type of description.


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
entity shift is
generic(
  depth :      positive      ); --! Depth of shift-chain
port(
  mclk   : in  std_logic                   ; --! Clock
  i      : in  std_logic                   ; --! Input
  s      : in  natural  range 0 to depth-1 ; --! Select
  o      : out std_logic )                 ; --! Output
end entity;
-- 
---------------------------------------------------------------------------------------------------
--! \brief Standard architecture
architecture rtl of shift is
---------------------------------------------------------------------------------------------------

-- dn_next: if( depth > 0 ) generate
-- 
-- end generate;

begin

d0_next: if( depth = 0 ) generate  o <= i; end generate;

dn_next: if( depth > 0 ) generate
  signal d_chain : std_logic_vector(depth-1 downto 0);
begin

  process (mclk) begin
    if( rising_edge(mclk) ) then
      d_chain( depth-1 downto 0 ) <= d_chain( depth-2 downto 0 ) & i;
    end if;
  end process;

  o <= d_chain(s); 

end generate;

end architecture;
