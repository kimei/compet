--! \file
--! \brief Chipscope stuff

library ieee;
use ieee.std_logic_1164.all;

--! Work library (self-composed)
library work;
use work.constants.all;       --! Global constants

--! \brief Entity
entity chipscope is
port(
  cs_clk          : in  std_logic;
  cs_ila_trig0    : in  std_logic_vector( cs_ILA_SIZE-1 downto 0 );
  cs_vio_out      : out std_logic_vector( cs_VIO_SIZE-1 downto 0 )
);
end entity;

--! \brief Architecture
architecture rtl of chipscope is

  component icon
  port(
    control0   : inout std_logic_vector( 35 downto 0 ); 
    control1   : inout std_logic_vector( 35 downto 0 )
  );
  end component;

  component ila
  port(
    clk       : in    std_logic;
    control   : inout std_logic_vector( 35  downto 0 ); 
    trig0     : in    std_logic_vector( cs_ILA_SIZE-1 downto 0 )
  );
  end component;

  component vio
  port(
    clk       : in    std_logic;
    control   : inout std_logic_vector( 35 downto 0 ); 
    sync_out  : out   std_logic_vector( cs_VIO_SIZE-1 downto 0 )
  );
  end component;

  --! To make XST suppress "black box" messages (AR #9838)
  attribute box_type : string;
  attribute box_type of icon : component is "black_box";
  attribute box_type of ila  : component is "black_box";
  attribute box_type of vio  : component is "black_box";

  signal control0     : std_logic_vector( 35 downto 0 ); 
  signal control1     : std_logic_vector( 35 downto 0 );
  signal cs_vio_out_i : std_logic_vector( cs_VIO_SIZE-1 downto 0 );

begin
 
  icon_i: icon port map(
    control0   => control0 ,
    control1   => control1 
  );

  ila_i: ila port map(
    clk      => cs_clk          , 
    control  => control0        , 
    trig0    => cs_ila_trig0
  );

  vio_i: vio port map(
    clk      => cs_clk        , 
    control  => control1      , 
    sync_out => cs_vio_out_i
  );

cs_vio_out <= cs_vio_out_i;

end architecture;

