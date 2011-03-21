-------------------------------------------------------------------------------
-- Title      : Testbench for design "sync_trigger"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : sync_trigger_tb.vhd
-- Author     :   <kimei@fyspc-epf02>
-- Company    : 
-- Created    : 2011-03-11
-- Last update: 2011-03-21
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-03-11  1.0      kimei   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


library work;
use work.components.all;
use work.constants.all;
-------------------------------------------------------------------------------

entity sync_trigger_tb is

end sync_trigger_tb;

-------------------------------------------------------------------------------

architecture tb of sync_trigger_tb is

  component sync_trigger
    port (
      rst_b         : in  std_logic;
      mclk          : in  std_logic;
      trigger_in    : in  std_logic_vector(NUMBER_OF_ROCS-1 downto 0);
      trigger_in_b  : in  std_logic_vector(NUMBER_OF_ROCS-1 downto 0);
      trigger_out   : out std_logic_vector(NUMBER_OF_MODULES-1 downto 0);
      trigger_out_b : out std_logic_vector(NUMBER_OF_MODULES-1 downto 0));
  end component;

  -- component ports
  signal rst_b         : std_logic;
  signal mclk          : std_logic;
  signal trigger_in    : std_logic_vector(NUMBER_OF_ROCS-1 downto 0);
  signal trigger_in_b  : std_logic_vector(NUMBER_OF_ROCS-1 downto 0);
  signal trigger_out   : std_logic_vector(NUMBER_OF_MODULES-1 downto 0);
  signal trigger_out_b : std_logic_vector(NUMBER_OF_MODULES-1 downto 0);

  -- clock
  signal Clk : std_logic := '1';

begin  -- tb

  -- component instantiation
  DUT : sync_trigger
    port map (
      rst_b         => rst_b,
      mclk          => mclk,
      trigger_in    => trigger_in,
      trigger_in_b  => trigger_in_b,
      trigger_out   => trigger_out,
      trigger_out_b => trigger_out_b);

  -- clock generation
  Clk  <= not Clk after 5 ns;
  mclk <= Clk;

  WaveGen_Proc : process
  begin
    rst_b        <= '0';
    trigger_in   <= (others => '0');
    trigger_in_b <= (others => '1');


    wait for 20 ns;
    rst_b <= '1';
    wait for 113 ns;

    trigger_in(1)   <= '1';
    trigger_in_b(1) <= '0';

    wait for 15 ns;
    trigger_in(0)   <= '1';
    trigger_in_b(0) <= '0';
    wait for 30 ns;
    trigger_in(1)   <= '0';
    trigger_in_b(1) <= '1';


    wait for 20 ns;
    trigger_in(0)   <= '0';
    trigger_in_b(0) <= '1';
    wait for 27 ns;

    wait for 23 ns;
    trigger_in(0)   <= '1';
    trigger_in_b(0) <= '0';
    wait for 30 ns;
    trigger_in(0)   <= '0';
    trigger_in_b(0) <= '1';

    wait for 24 ns;
    trigger_in(1)   <= '1';
    trigger_in_b(1) <= '0';
    wait for 23 ns;
     trigger_in(0)   <= '1';
    trigger_in_b(0) <= '0';

    wait for 20 ns;
    trigger_in(1)   <= '0';
    trigger_in_b(1) <= '1';
    wait for 20 ns;
     trigger_in(0)   <= '0';
    trigger_in_b(0) <= '1';
    wait for 20 ns;
    rst_b <= '1';
    wait for 113 ns;

    trigger_in(1)   <= '1';
    trigger_in_b(1) <= '0';

    wait for 15 ns;
    trigger_in(0)   <= '1';
    trigger_in_b(0) <= '0';
    wait for 30 ns;
    trigger_in(1)   <= '0';
    trigger_in_b(1) <= '1';


    wait for 20 ns;
    trigger_in(0)   <= '0';
    trigger_in_b(0) <= '1';
    wait for 27 ns;

    wait for 32 ns;
    trigger_in(0)   <= '1';
    trigger_in_b(0) <= '0';
    wait for 30 ns;
    trigger_in(0)   <= '0';
    trigger_in_b(0) <= '1';

--    wait for 18 ns;
--    trigger_in(9)   <= '1';
--    trigger_in_b(9) <= '0';
--    wait for 10 ns;
--     trigger_in(0)   <= '1';
--    trigger_in_b(0) <= '0';

--    wait for 22 ns;
--    trigger_in(9)   <= '0';
--    trigger_in_b(9) <= '1';
--    wait for 20 ns;
--     trigger_in(0)   <= '0';
--    trigger_in_b(0) <= '1';

--        wait for 15 ns;
--    trigger_in(0)   <= '1';
--    trigger_in_b(0) <= '0';
--    wait for 30 ns;
--    trigger_in(2)   <= '0';
--    trigger_in_b(2) <= '1';


--    wait for 20 ns;
--    trigger_in(0)   <= '0';
--    trigger_in_b(0) <= '1';
--    wait for 27 ns;

--    wait for 23 ns;
--    trigger_in(6)   <= '1';
--    trigger_in_b(6) <= '0';
--    wait for 30 ns;
--    trigger_in(6)   <= '0';
--    trigger_in_b(6) <= '1';

--    wait for 24 ns;
--    trigger_in(9)   <= '1';
--    trigger_in_b(9) <= '0';
--    wait for 23 ns;
--     trigger_in(0)   <= '1';
--    trigger_in_b(0) <= '0';

--    wait for 20 ns;
--    trigger_in(9)   <= '0';
--    trigger_in_b(9) <= '1';
--    wait for 20 ns;
--     trigger_in(0)   <= '0';
--    trigger_in_b(0) <= '1';
--    wait for 20 ns;
--    rst_b <= '1';
--    wait for 113 ns;

--    trigger_in(2)   <= '1';
--    trigger_in_b(2) <= '0';

--    wait for 15 ns;
--    trigger_in(0)   <= '1';
--    trigger_in_b(0) <= '0';
--    wait for 30 ns;
--    trigger_in(2)   <= '0';
--    trigger_in_b(2) <= '1';


--    wait for 20 ns;
--    trigger_in(0)   <= '0';
--    trigger_in_b(0) <= '1';
--    wait for 27 ns;

--    wait for 32 ns;
--    trigger_in(6)   <= '1';
--    trigger_in_b(6) <= '0';
--    wait for 30 ns;
--    trigger_in(6)   <= '0';
--    trigger_in_b(6) <= '1';

--    wait for 18 ns;
--    trigger_in(9)   <= '1';
--    trigger_in_b(9) <= '0';
--    wait for 10 ns;
--     trigger_in(3)   <= '1';
--    trigger_in_b(3) <= '0';

--    wait for 22 ns;
--    trigger_in(9)   <= '0';
--    trigger_in_b(9) <= '1';
--    wait for 20 ns;
--     trigger_in(3)   <= '0';
--    trigger_in_b(3) <= '1';
    
    wait;
  end process WaveGen_Proc;

  

end tb;

-------------------------------------------------------------------------------

configuration sync_trigger_tb_tb_cfg of sync_trigger_tb is
  for tb
  end for;
end sync_trigger_tb_tb_cfg;

-------------------------------------------------------------------------------
