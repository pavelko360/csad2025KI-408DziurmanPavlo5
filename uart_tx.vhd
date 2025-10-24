--  uart_tx.vhd
-- Призначення: послідовна передача байта по UART (8N1)
-- Порти:
--   tx_start  - вхід: почати передачу (один такт)
--   tx_data   - 8-бітні дані для передачі
--   busy      - сигнал, що передача йде
--   tx_serial - фізичний TX вихід (idle = '1' для UART)


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is
  port (
    clk       : in  std_logic;
    rst_n     : in  std_logic;
    baud_tick : in  std_logic;        -- синхронний імпульс для кожного бітового інтервалу
    tx_start  : in  std_logic;        -- 1 такт старту передачі (фіксація байта)
    tx_data   : in  std_logic_vector(7 downto 0);
    busy      : out std_logic;
    tx_serial : out std_logic         -- лінія TX (idle = '1')
  );
end entity;

architecture rtl of uart_tx is
  type state_t is (IDLE, START_BIT, DATA_BITS, STOP_BIT);
  signal state     : state_t := IDLE;
  signal bit_cnt   : integer range 0 to 7 := 0;
  signal sr        : std_logic_vector(7 downto 0) := (others => '0');
  signal tx_reg    : std_logic := '1'; -- idle high
begin
  -- Передача синхронно з baud_tick: на кожному baud_tick зсуваємо стан
  process(clk, rst_n)
  begin
    if rst_n = '0' then
      state <= IDLE;
      bit_cnt <= 0;
      sr <= (others => '0');
      tx_reg <= '1';
    elsif rising_edge(clk) then
      if baud_tick = '1' then
        case state is
          when IDLE =>
            tx_reg <= '1';                -- idle
            if tx_start = '1' then
              sr <= tx_data;
              state <= START_BIT;
            end if;

          when START_BIT =>
            tx_reg <= '0';                -- стартовий біт (0)
            bit_cnt <= 0;
            state <= DATA_BITS;

          when DATA_BITS =>
            tx_reg <= sr(bit_cnt);
            if bit_cnt = 7 then
              state <= STOP_BIT;
            else
              bit_cnt <= bit_cnt + 1;
            end if;

          when STOP_BIT =>
            tx_reg <= '1';               -- стоп біт (1)
            state <= IDLE;
        end case;
      end if;
    end if;
  end process;

  busy <= '1' when state /= IDLE else '0';
  tx_serial <= tx_reg;
end architecture;
