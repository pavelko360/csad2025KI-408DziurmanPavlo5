-- uart_baud_gen.vhd
-- Призначення: ділитель системного такту для генерації strobe (baud_tick)
-- Параметри:
--   CLK_FREQ_HZ  - частота системного такту в герцах
--   BAUD_RATE    - бажаний бауд (наприклад 115200)
-- Вихід:
--   baud_tick    - одиночний тактовий такт для кожного бітового інтервалу UART

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_baud_gen is
  generic (
    CLK_FREQ_HZ : integer := 50_000_000;
    BAUD_RATE   : integer := 115200
  );
  port (
    clk       : in  std_logic;    -- системний такт
    rst_n     : in  std_logic;    -- асинхронний активний low reset
    baud_tick : out std_logic     -- вихідний тактовий імпульс для UART (пульс у 1 clk)
  );
end entity;

architecture rtl of uart_baud_gen is
  constant DIVIDE_COUNT : integer := integer(CLK_FREQ_HZ / BAUD_RATE);
  signal cnt : integer range 0 to DIVIDE_COUNT := 0;
  signal tick_reg : std_logic := '0';
begin
  -- Простий дільник: формує короткий імпульс один раз на DIVIDE_COUNT циклів
  process(clk, rst_n)
  begin
    if rst_n = '0' then
      cnt <= 0;
      tick_reg <= '0';
    elsif rising_edge(clk) then
      if cnt = DIVIDE_COUNT - 1 then
        cnt <= 0;
        tick_reg <= '1';
      else
        cnt <= cnt + 1;
        tick_reg <= '0';
      end if;
    end if;
  end process;

  baud_tick <= tick_reg;
end architecture;
