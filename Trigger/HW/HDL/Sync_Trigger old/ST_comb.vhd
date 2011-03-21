-------------------------------------------------------------------------------
-- Title      : Sync Trigger
-- Project    : Source files in two directories, custom library name, VHDL'87
-------------------------------------------------------------------------------
-- File       : st_comb.vhd
-- Author     :   <kimei@fyspc-epf02>
-- Company    : 
-- Created    : 2011-03-15
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

entity st_comb is
  generic (
    NO_OF_MODULES : positive := 4);
  port (
    leading_edge_b : in  std_logic_vector(NO_OF_MODULES-1 downto 0);
    mclk           : in  std_logic;
    rst_b          : in  std_logic;
    trigger_out    : out std_logic_vector(NO_OF_MODULES-1 downto 0));
end st_comb;

architecture comb of st_comb is
  
  signal counter : integer range 15 downto 0;

  signal trig_hold   : std_logic_vector(trigger_out'length-1 downto 0);
  signal coincidence : std_logic;

  signal trigger_output_shift : std_logic_vector(TRIGGER_WINDOW_LENGTH + TRIGGER_DELAY -1 downto 0);
  signal test : std_logic;
  signal trigger_output : std_logic;

  component trigger_hold
    port (
      edge_in_b : in  std_logic;
      mclk      : in  std_logic;
      rst_b     : in  std_logic;
      trig_hold : out std_logic);
  end component;

  
begin
  trigger_output <= trigger_output_shift(0);
  
  G1 : for I in 0 to (NUMBER_OF_MODULES-1) generate
    inst_trig : trigger_hold
      port map (
        edge_in_b => leading_edge_b(I),
        mclk      => mclk,
        rst_b     => rst_b,
        trig_hold => trig_hold(I));     
  end generate G1;

  test <= '1' when all_zeros(trig_hold) = '0' else '0';
  coincidence <= '1' when count_ones(trig_hold) > 1 else '0';
  find_delay : process (mclk, rst_b)
  begin  -- process find_delay
    if rst_b = '0' then                   -- asynchronous reset (active low)
      counter <= 0;
      trigger_output_shift <= (others => '0');
      --counter_m1 <= 0;
      -- counter_m2 <= 0;
      -- counter_m3 <= 0;
      -- counter_m4 <= 0;
    elsif mclk'event and mclk = '1' then  -- falling clock edge
      trigger_output_shift <= zshr(trigger_output_shift);
      trigger_output_shift(TRIGGER_DELAY) <= test;
      
--      if coincidence = '1' then
        
      
--      elsif (all_zeros(trig_hold) /= '1') and (coincidence = '0') then
--        counter <= counter + 1;
--        if counter = 2 then
--          counter <= 0;
--        end if;
--      else
--        counter <= 0;
--      end if;
      
    end if;
  end process find_delay;

  
end comb;
