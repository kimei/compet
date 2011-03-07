--! \file
--! \brief Synchronisation FIFO.

--! This module synchronises an asynchronous signal by shifting it through a "depth" deep FIFO
--! comprised of registers (hence the name s2s). In most cases a depth of 2 should provide 
--! decent metastability protection, as explained in this document: 
--! http://www.xilinx.com/support/documentation/application_notes/xapp094.pdf
--! or in "Advanced FPGA Design" by Steve Kilts (ISBN 978-0-470-05437-6) .

--! \warning Do NOT use both arst_b and srst_b at the same time. One of these two should be
--! set to a static value to make sure it disappears in synthesis.


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
entity a2s is
generic(
  depth :      positive := 2 ); --! FIFO depth
port(
  arst_b : in  std_logic      ; --! Asynchronous reset
  srst_b : in  std_logic      ; --! Synchronous reset
  clk    : in  std_logic      ; --! Synchronisation clock
  i      : in  std_logic      ; --! Input
  o      : out std_logic )    ; --! Output
end entity;
-- 

---------------------------------------------------------------------------------------------------
--! \brief Standard architecture
architecture rtl of a2s is
---------------------------------------------------------------------------------------------------

  signal d      : std_logic_vector(depth-1 downto 0);
  signal d_next : std_logic_vector(depth-1 downto 0);

begin

d0_next: if( depth = 1 ) generate  d_next(0) <= i;                         end generate;
dn_next: if( depth > 1 ) generate  d_next    <= (d(depth-2 downto 0) & i); end generate;

process (clk,arst_b) begin
  if( arst_b = '0' ) then
    d <= (others => '0');
  elsif( rising_edge(clk) ) then
    if( srst_b = '0' ) then
      d <= (others => '0');
    else
      d <= d_next;
    end if;
  end if;
end process;


o <= d(depth-1);


end architecture;
