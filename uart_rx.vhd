-- ����: uart_rx.vhd
-- �����������: ������ ����� �� UART (8N1), � ��������� ���������� ���.
-- �����:
--   rx_serial  - ���� RX (�'�������� � �������� ���)
--   new_data   - �������� ����� (1 clk) ��������, �� ������� ����� ����
--   rx_data    - ��������� ����

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_rx is
  port (
    clk        : in  std_logic;
    rst_n      : in  std_logic;
    baud_tick  : in  std_logic;         -- ������� � �������/���� ������� ���������
    rx_serial  : in  std_logic;
    new_data   : out std_logic;
    rx_data    : out std_logic_vector(7 downto 0)
  );
end entity;

architecture rtl of uart_rx is
  type state_t is (IDLE, START_WAIT, DATA_BITS, STOP_WAIT);
  signal state : state_t := IDLE;
  signal sample_cnt : integer range 0 to 1 := 0; 
  signal bit_cnt : integer range 0 to 7 := 0;
  signal shift_reg : std_logic_vector(7 downto 0) := (others => '0');
  signal new_data_reg : std_logic := '0';
  signal rx_sync : std_logic_vector(2 downto 0) := (others => '1'); 
begin
  process(clk)
  begin
    if rising_edge(clk) then
      rx_sync(2 downto 1) <= rx_sync(1 downto 0);
      rx_sync(0) <= rx_serial;
    end if;
  end process;

  -- �������� FSM
  process(clk, rst_n)
  begin
    if rst_n = '0' then
      state <= IDLE;
      bit_cnt <= 0;
      shift_reg <= (others => '0');
      new_data_reg <= '0';
      sample_cnt <= 0;
    elsif rising_edge(clk) then
      new_data_reg <= '0'; -- default, �������� �����
      if baud_tick = '1' then
        case state is
          when IDLE =>
            -- ������ �� �� ���� ������ (idle). ������ �� 0 (start)
            if rx_sync(2 downto 0) = "000" then
              state <= START_WAIT;
            end if;

          when START_WAIT =>
            if rx_sync(2) = '0' then
              bit_cnt <= 0;
              state <= DATA_BITS;
            else
              state <= IDLE;
            end if;

          when DATA_BITS =>
            -- ������� 8 ��� LSB ������
            shift_reg(bit_cnt) <= rx_sync(2);
            if bit_cnt = 7 then
              state <= STOP_WAIT;
            else
              bit_cnt <= bit_cnt + 1;
            end if;

          when STOP_WAIT =>
            -- ������ ����-�� (�� ���� '1')
            if rx_sync(2) = '1' then
              new_data_reg <= '1';
            end if;
            state <= IDLE;
        end case;
      end if;
    end if;
  end process;

  rx_data <= shift_reg;
  new_data <= new_data_reg;
end architecture;
