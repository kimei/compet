-------------------------------------------------------------------------------
-- Title      : Sync Trigger
-- Project    : Source files in two directories, custom library name, VHDL'87
-------------------------------------------------------------------------------
-- File       : Sync_trigger.vhd
-- Author     :   <kimei@fyspc-epf02>
-- Company    : 
-- Created    : 2011-03-08
-- Last update: 2011-03-17
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Synchronous trigger part of the CTU in COMPET
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-03-08  1.0      kimei   Created
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.components.all;
use work.constants.all;
use work.functions.all;

entity sync_trigger is
  port (
    rst_b         : in  std_logic;
    mclk          : in  std_logic;
    trigger_in    : in  std_logic_vector(NUMBER_OF_ROCS-1 downto 0);
    trigger_in_b  : in  std_logic_vector(NUMBER_OF_ROCS-1 downto 0);
    trigger_out   : out std_logic_vector(NUMBER_OF_MODULES-1 downto 0);
    trigger_out_b : out std_logic_vector(NUMBER_OF_MODULES-1 downto 0)
    );

end sync_trigger;


architecture Behavioral of sync_trigger is
  
  
 signal trig_in_as : std_logic_vector(NUMBER_OF_ROCS - 1 downto 0);

  signal trig_out     : std_logic_vector(NUMBER_OF_MODULES - 1 downto 0);
  signal leading_edge_as_b : std_logic_vector(NUMBER_OF_MODULES-1 downto 0);
  signal leading_edge_b : std_logic_vector(NUMBER_OF_MODULES-1 downto 0);
                                         
begin


  -- Not the slickest solution, but i doubt there will be more than four
  -- modules, and therefore this solution is sufficient..
  N : for n in 0 to NUMBER_OF_MODULES-1 generate
    N1 : if n = 0 generate
      leading_edge_as_b(n) <= '1' when all_zeros(trig_in_as(ROCS_IN_M1-1 downto 0)) = '1' else '0';
    end generate N1;
    
    N2 : if n = 1 generate
      leading_edge_as_b(n) <= '1' when all_zeros(trig_in_as(ROCS_IN_M1+ROCS_IN_M2-1 downto ROCS_IN_M1)) = '1' else '0';
    end generate N2;

    N3 : if n = 2 generate
      leading_edge_as_b(n) <= '1' when all_zeros(trig_in_as(ROCS_IN_M1+ROCS_IN_M2+ROCS_IN_M3-1 downto ROCS_IN_M1+ROCS_IN_M2)) = '1' else '0';
    end generate N3;

    N4 : if n = 3 generate
      leading_edge_as_b(n) <= '1' when all_zeros(trig_in_as(ROCS_IN_M1+ROCS_IN_M2+ROCS_IN_M3+ROCS_IN_M4-1 downto ROCS_IN_M1+ROCS_IN_M2+ROCS_IN_M3)) = '1' else '0';
    end generate N4;
  end generate N;

-- legg merke til bytta om pos og neg for aa lage omvendt signal
  G1 : for I in 0 to (NUMBER_OF_ROCS-1) generate
 diff_in : work.components.IBUFDS port map (
	-- diff_in : IBUFDS port map (
      I  => trigger_in(I),
      IB => trigger_in_b(I),
      O  => trig_in_as(I));
  end generate G1;
  
    G2 : for I in 0 to (NUMBER_OF_MODULES-1) generate
    diff_out : work.components.OBUFDS port map (
--	 diff_out : OBUFDS port map (
      O  => trigger_out(I),
      OB => trigger_out_b(I),
      I  => trig_out(I));
	  end generate G2;

  -- To synchronize the trigger input
  -- async assert and sync deasset
  G3 : for I in 0 to (NUMBER_OF_MODULES-1) generate
    trigger_sync : entity work.a2s port map(
	 
      srst_b => '1' ,                   --! Synchronous  reset
      arst_b => leading_edge_as_b(I),        --! Asynchronous reset
      clk    => mclk,                   --! Synchronisation clock
      i      => '1',                    --! Asynchronous input
      o      => leading_edge_b(I)            --! Synchronous  output (metafiltered)
      );
  end generate G3;

  st_fsm_1: st_fsm
    generic map (
      NO_OF_MODULES => NUMBER_OF_MODULES)
    port map (
      leading_edge_b => leading_edge_b,
      mclk           => mclk,
      rst_b         => rst_b,
      trigger_out    => trig_out);

end Behavioral;
