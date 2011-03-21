-------------------------------------------------------------------------------
-- Title      : Testbench for design "st_comb"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : st_comb_tb.vhd<2>
-- Author     :   <kimei@fyspc-epf02>
-- Company    : 
-- Created    : 2011-03-17
-- Last update: 2011-03-17
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-03-17  1.0      kimei	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity st_comb_tb is

end st_comb_tb;

-------------------------------------------------------------------------------

architecture st_comb_tb of st_comb_tb is

  component st_comb
    generic (
      NO_OF_MODULES : positive);
    port (
      leading_edge_b : in  std_logic_vector(NO_OF_MODULES-1 downto 0);
      mclk           : in  std_logic;
      rst_b          : in  std_logic;
      trigger_out    : out std_logic_vector(NO_OF_MODULES-1 downto 0));
  end component;

  -- component generics
  constant NO_OF_MODULES : positive := 4;

  -- component ports
  signal leading_edge_b : std_logic_vector(NO_OF_MODULES-1 downto 0);
  signal mclk           : std_logic;
  signal rst_b          : std_logic;
  signal trigger_out    : std_logic_vector(NO_OF_MODULES-1 downto 0);

  -- clock
  signal Clk : std_logic := '1';

begin  -- st_comb_tb
  mclk <=  clk;
  -- component instantiation
  DUT: st_comb
    generic map (
      NO_OF_MODULES => NO_OF_MODULES)
    port map (
      leading_edge_b => leading_edge_b,
      mclk           => mclk,
      rst_b          => rst_b,
      trigger_out    => trigger_out);

  -- clock generation
  Clk <= not Clk after 10 ns;

  -- waveform generation
  WaveGen_Proc: process
  begin
    -- insert signal assignments here
    rst_b <= '0';
    wait for 20 ns;
    rst_b <= '1';
    wait for 9 ns;
    leading_edge_b(1) <= '0';
    wait for 10 ns;
    leading_edge_b(1) <= '1';
     wait for 10 ns;
    leading_edge_b(2) <= '0';
    wait for 10 ns;
    leading_edge_b(2) <= '1';
    wait;
  end process WaveGen_Proc;

  

end st_comb_tb;

-------------------------------------------------------------------------------

configuration st_comb_tb_st_comb_tb_cfg of st_comb_tb is
  for st_comb_tb
  end for;
end st_comb_tb_st_comb_tb_cfg;

-------------------------------------------------------------------------------
