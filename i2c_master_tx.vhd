-- ============================================================================
-- Модуль: i2c_master_tx
-- Реалізація логіки I2C Master для передачі одного байта
-- Автор: <твоє ім’я>
--   Генерує сигнали START, адресу slave-пристрою, біт R/W=0 (запис),
--   передає байт даних і сигнал STOP.
-- ============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity i2c_master_tx is
  generic (
    CLK_FREQ_HZ : integer := 50_000_000; -- Частота системного такту
    I2C_FREQ_HZ : integer := 100_000     -- Швидкість I2C (100 кГц)
  );
  port (
    clk      : in  std_logic;  
    rst_n    : in  std_logic;   
    start_tx : in  std_logic;  
    slave_addr : in  std_logic_vector(6 downto 0);
    data_in  : in  std_logic_vector(7 downto 0);  
    busy     : out std_logic;  
    sda      : inout std_logic;
    scl      : out std_logic  
  );
end entity;

architecture rtl of i2c_master_tx is

  constant DIVIDER : integer := CLK_FREQ_HZ / (I2C_FREQ_HZ * 4);
  signal clk_cnt   : integer range 0 to DIVIDER := 0;
  signal scl_int   : std_logic := '1';
  signal tick      : std_logic := '0'; 

  type state_t is (IDLE, START, ADDR, DATA, STOP);
  signal state : state_t := IDLE;
  signal bit_cnt : integer range 0 to 7 := 0;
  signal sda_reg : std_logic := '1';
  signal shift_reg : std_logic_vector(7 downto 0) := (others => '0');
  signal addr_reg  : std_logic_vector(7 downto 0) := (others => '0');

begin
  -- Генерація внутрішнього тактового сигналу SCL ~ I2C_FREQ_HZ
  process(clk, rst_n)
  begin
    if rst_n = '0' then
      clk_cnt <= 0;
      scl_int <= '1';
      tick <= '0';
    elsif rising_edge(clk) then
      if clk_cnt = DIVIDER then
        clk_cnt <= 0;
        scl_int <= not scl_int;
        tick <= '1';
      else
        clk_cnt <= clk_cnt + 1;
        tick <= '0';
      end if;
    end if;
  end process;

  scl <= scl_int;  -- вихід тактового сигналу

  -- Основний процес керування станами
  process(clk, rst_n)
  begin
    if rst_n = '0' then
      state <= IDLE;
      bit_cnt <= 0;
      sda_reg <= '1';
      busy <= '0';
    elsif rising_edge(clk) then
      if tick = '1' then
        case state is
          when IDLE =>
            sda_reg <= '1';
            busy <= '0';
            if start_tx = '1' then
              busy <= '1';
              addr_reg <= slave_addr & '0';  -- R/W = 0 
              state <= START;
            end if;

          when START =>
            sda_reg <= '0';  -- START: SDA падає при високому SCL
            state <= ADDR;
            bit_cnt <= 7;

          when ADDR =>
            sda_reg <= addr_reg(bit_cnt);
            if bit_cnt = 0 then
              state <= DATA;
              shift_reg <= data_in;
              bit_cnt <= 7;
            else
              bit_cnt <= bit_cnt - 1;
            end if;

          when DATA =>
            sda_reg <= shift_reg(bit_cnt);
            if bit_cnt = 0 then
              state <= STOP;
            else
              bit_cnt <= bit_cnt - 1;
            end if;

          when STOP =>
            sda_reg <= '0';
            state <= IDLE;
            busy <= '0';
        end case;
      end if;
    end if;
  end process;

  -- Вихід SDA (open-drain): або '0', або high-impedance
  sda <= '0' when sda_reg = '0' else 'Z';

end architecture;
