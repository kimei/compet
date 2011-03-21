library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.components.all;
use work.constants.all;

entity com is
  
  port (
    mclk  : in  std_logic;
    rst_b : in  std_logic;
    rx    : in  std_logic;
    tx    : out std_logic);
end com;

architecture Behavioral of com is
signal rst,rst_uart,tx_req, tx_end, rx_ready, par_en : std_logic;
signal rx_data, tx_data : std_logic_vector(7 downto 0);



type state is (INIT,LOAD,SEND, WAIT_SENT);
signal fsm_state : state;

begin  -- Behavioral
rst <=  not rst_b;

  uart_1: uart
    generic map (
    CLK_FREQ => 100,           -- Main frequency (MHz)
    SER_FREQ => 9600)

    port map (
      clk      => mclk,
      rst      => rst_uart,
      rx       => rx,
      tx       => tx,
      par_en   => '0',
      tx_req   => tx_req,
      tx_end   => tx_end,
      tx_data  => tx_data,
      rx_ready => rx_ready,
      rx_data  => rx_data);


send_shit : process(mclk,rst)
begin
  if rst = '1' then 
    rst_uart <=  '1';
    fsm_state <= INIT;
  elsif mclk'event and mclk = '1' then
    rst_uart <= '0';
    tx_req <= '0';
    case fsm_state is
      when INIT =>
        rst_uart <= '1';
        fsm_state <= LOAD;
 
      when LOAD =>
        tx_data <= x"31";
        fsm_state <= SEND;
      when SEND =>
        tx_req <= '1';
      when WAIT_SENT =>
        if tx_end = '1' then
          fsm_state <= INIT;
       else
         fsm_state <= WAIT_SENT;
		end if;
      when others => null;
    end case;
  end if;
 end process;
end Behavioral;