-------------------------------------------------------------------------------
-- Title      : Testbench for design "com"
-- Project    : Source files in two directories, custom library name, VHDL'87
-------------------------------------------------------------------------------
-- File       : com_tb.vhd
-- Author     :   <kimei@fyspc-epf02>
-- Company    : 
-- Created    : 2011-03-10
-- Last update: 2011-03-10
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-03-10  1.0      kimei	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity com_tb is

end com_tb;

-------------------------------------------------------------------------------

architecture tb of com_tb is

  component com
    port (
      mclk  : in  std_logic;
      rst_b : in  std_logic;
      rx    : in  std_logic;
      tx    : out std_logic);
  end component;

  -- component ports
  signal mclk  : std_logic;
  signal rst_b : std_logic;
  signal rx    : std_logic;
  signal tx    : std_logic;

  -- clock
  signal Clk : std_logic := '1';

begin  -- tb

  -- component instantiation
  DUT: com
    port map (
      mclk  => mclk,
      rst_b => rst_b,
      rx    => rx,
      tx    => tx);

  -- clock generation
  Clk <= not Clk after 5 ns;
  mclk <= clk;

  -- waveform generation
  WaveGen_Proc: process
  begin
    rst_b <= '1';
    wait for 10 ns;
    rst_b <= '0';
    wait for 20 ns;
    rst_b <= '1';
    wait;
  end process WaveGen_Proc;

  

end tb;

-------------------------------------------------------------------------------

configuration com_tb_tb_cfg of com_tb is
  for tb
  end for;
end com_tb_tb_cfg;

-------------------------------------------------------------------------------
