-------------------------------------------------------------------------------
-- Title      : Testbench for design "CRU"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : CRU_tb.vhd
-- Author     :   <kimei@fyspc-epf02>
-- Company    : 
-- Created    : 2011-01-25
-- Last update: 2011-01-27
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-01-25  1.0      kimei	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity CRU_tb is

end CRU_tb;

-------------------------------------------------------------------------------

architecture TB of CRU_tb is

  component CRU
    port (
      fpga_100m_clk    : in  STD_LOGIC;
      fpga_cpu_reset   : in  STD_LOGIC;
      mclk             : out STD_LOGIC;
      mclk_b           : out STD_LOGIC;
      gclk             : out STD_LOGIC;
      mrst             : out STD_LOGIC;
      lrst             : out STD_LOGIC);
  end component;

  -- component ports
  signal fpga_100m_clk    : STD_LOGIC;
  signal fpga_cpu_reset   : STD_LOGIC;
  signal mclk             : STD_LOGIC;

  signal mclk_b           : STD_LOGIC;
  signal gclk             : STD_LOGIC;
  signal mrst             : STD_LOGIC;
  signal lrst             : STD_LOGIC;

  -- clock
  signal klokka : std_logic := '1';
  signal Clk : std_logic := '1';

begin  -- TB

  -- component instantiation
  DUT: CRU
    port map (
      fpga_100m_clk    => fpga_100m_clk,
      fpga_cpu_reset => fpga_cpu_reset,
      mclk             => mclk,
      mclk_b           => mclk_b,      
      gclk             => gclk,
      mrst             => mrst,
      lrst             => lrst);

  -- clock generation
  Clk <= not Clk after 10 ns;
	fpga_100m_clk <= Clk when klokka = '1' else '0';
  -- waveform generation
  WaveGen_Proc: process
  begin
	 wait for 3.5 ms;
	 klokka <= '0';
	 wait for 40 ns;
	 klokka <= '1';
    wait;
  end process WaveGen_Proc;


end TB;
