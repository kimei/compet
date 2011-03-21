-------------------------------------------------------------------------------
-- Title      : Testbench for design "st_comb"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : st_comb_tb.vhd
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

architecture trigger_hold_tb of st_comb_tb is

  component st_comb
    port (
      edge_in_b : in  std_logic;
      mclk      : in  std_logic;
      rst_b     : in  std_logic;
      trig_hold : out std_logic);
  end component;

  -- component ports
  signal edge_in_b : std_logic := '1';
  signal mclk      : std_logic;
  signal rst_b     : std_logic;
  signal trig_hold : std_logic;

  -- clock
  signal Clk : std_logic := '1';

begin  -- trigger_hold_tb
  mclk <= clk;
  -- component instantiation
  DUT: st_comb
    port map (
      edge_in_b => edge_in_b,
      mclk      => mclk,
      rst_b     => rst_b,
      trig_hold => trig_hold);

  -- clock generation
  Clk <= not Clk after 5 ns;

  -- waveform generation
  WaveGen_Proc: process
  begin
    
    rst_b <= '0';
    wait for 20 ns;
    rst_b <= '1';
    wait for 9 ns;
    edge_in_b <= '0';
    wait for 7 ns;
    edge_in_b <= '1';
     wait for 30 ns;
    edge_in_b <= '0';
    wait for 20 ns;
    edge_in_b <= '1';
    wait;
  end process WaveGen_Proc;

  

end trigger_hold_tb;

-------------------------------------------------------------------------------

configuration st_comb_tb_trigger_hold_tb_cfg of st_comb_tb is
  for trigger_hold_tb
  end for;
end st_comb_tb_trigger_hold_tb_cfg;

-------------------------------------------------------------------------------
