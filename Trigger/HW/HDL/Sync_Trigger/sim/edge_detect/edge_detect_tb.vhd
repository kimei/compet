-------------------------------------------------------------------------------
-- Title      : Testbench for design "edge_detect"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : edge_detect_tb.vhd
-- Author     :   <kimei@fyspc-epf02>
-- Company    : 
-- Created    : 2011-03-18
-- Last update: 2011-03-18
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-03-18  1.0      kimei	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity edge_detect_tb is

end edge_detect_tb;

-------------------------------------------------------------------------------

architecture tb of edge_detect_tb is

  component edge_detect
    port (
      rst_b : in  std_logic;
      mclk  : in  std_logic;
      inp   : in  std_logic;
      outp  : out std_logic);
  end component;

  -- component ports
  signal rst_b : std_logic;
  signal mclk  : std_logic;
  signal inp   : std_logic;
  signal outp  : std_logic;

  -- clock
  signal Clk : std_logic := '1';

begin  -- tb

  -- component instantiation
  DUT: edge_detect
    port map (
      rst_b => rst_b,
      mclk  => mclk,
      inp   => inp,
      outp  => outp);

  -- clock generation
  Clk <= not Clk after 10 ns;
  mclk <= Clk;
  -- waveform generation
  WaveGen_Proc: process
  begin
    inp <=  '0';
    rst_b <= '0';
    wait for 20 ns;
    rst_b <= '1';
    wait for 25 ns;
    inp <= '1';
    wait for 31 ns;
    inp <= '0';
    wait for 40 ns;
    inp <= '1';
    wait for 29 ns;
    inp <= '0';
     wait for 32  ns;
    inp <= '1';
    wait for 25 ns;
    inp <= '0';
    wait for 26 ns;
    inp <= '1';
    wait for 13 ns;
    inp <= '0';
    wait;
    -- insert signal assignments here
    
    
  end process WaveGen_Proc;

  

end tb;

-------------------------------------------------------------------------------

configuration edge_detect_tb_tb_cfg of edge_detect_tb is
  for tb
  end for;
end edge_detect_tb_tb_cfg;

-------------------------------------------------------------------------------
