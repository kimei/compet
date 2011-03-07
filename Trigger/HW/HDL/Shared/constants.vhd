-- Constants for the CTU
-- Kim-Eigard Hines

--! Standard library
library ieee;
use ieee.std_logic_1164.all;  --! Standard logic
use ieee.numeric_std.all;     --! Numeric/arithmetical logic (IEEE standard)


--! \brief Constants
package constants is
--Constants associated with the CRU

-- Since each read-out card needs to be reset to accept the new clock coming
-- CTU, and since it is daisy chained, we have to send a reset signal around
-- every 200 us. The pll needs at least 100 us to be a trustworthy source of clk.
  constant NUMBER_OF_ROCS : positive := 2; 

  constant WAIT_PERIODS_1 : positive := 10000;
  constant WAIT_PERIODS_2 : positive := 50000;  -- it will wait twice as many clockcycles

  
end package constants;
