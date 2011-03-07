-- A dummy core.vhd used for simulation...

--! Standard library
library ieee;
use ieee.std_logic_1164.all;  --! Standard logic
use ieee.numeric_std.all;     --! Numeric/arithmetical logic (IEEE standard)

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

--! Work library (self-composed)
library work;
use work.constants.all;       --! Global constants
use work.types.all;           --! Global types
use work.functions.all;       --! Global functions

entity chipscope is
port(
  cs_clk          : in  std_logic;
  cs_ila_trig0    : in  std_logic_vector( cs_ILA_SIZE-1 downto 0 );
  cs_vio_out      : inout std_logic_vector( cs_VIO_SIZE-1 downto 0 )
);
end entity;

architecture rtl of chipscope is
  signal cs_vio : cs_vio_type;
begin

  cs_vio.test_en       <= '1' ;
  cs_vio.readout_en    <= '1' ;
  cs_vio.fe_soft_rst_b <= '1' ;
  cs_vio.cotrg_en      <= '1' ;
  cs_vio.data_delay    <= std_logic_vector(to_unsigned(5,fe_ch_MAX_DELAY));--std_logic_vector(to_unsigned(4,fe_ch_MAX_DELAY));
  cs_vio.negate_inputs <= ( others => '0' );
  cs_vio.mask_inputs   <= (OTHERS => '0');-- x"0000";--std_logic_vector(to_unsigned(,fe_NUM_CHANNELS));
  cs_vio.other         <= ( others => '0' );

  cs_vio_out          <= pack( cs_vio );

-- cs_vio_out( 2 downto 0) <= "110"; -- [fe_soft_rst_b, trigger_en, test_en]

end architecture;

