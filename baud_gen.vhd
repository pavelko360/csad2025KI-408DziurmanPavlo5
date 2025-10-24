-- uart_baud_gen.vhd
-- �����������: ������� ���������� ����� ��� ��������� strobe (baud_tick)
-- ���������:
--   CLK_FREQ_HZ  - ������� ���������� ����� � ������
--   BAUD_RATE    - ������� ���� (��������� 115200)
-- �����:
--   baud_tick    - ��������� �������� ���� ��� ������� ������� ��������� UART

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_baud_gen is
  generic (
    CLK_FREQ_HZ : integer := 50_000_000;
    BAUD_RATE   : integer := 115200
  );
  port (
    clk       : in  std_logic;    -- ��������� ����
    rst_n     : in  std_logic;    -- ����������� �������� low reset
    baud_tick : out std_logic     -- �������� �������� ������� ��� UART (����� � 1 clk)
  );
end entity;

architecture rtl of uart_baud_gen is
  constant DIVIDE_COUNT : integer := integer(CLK_FREQ_HZ / BAUD_RATE);
  signal cnt : integer range 0 to DIVIDE_COUNT := 0;
  signal tick_reg : std_logic := '0';
begin
  -- ������� ������: ����� �������� ������� ���� ��� �� DIVIDE_COUNT �����
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
