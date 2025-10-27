library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_i2c_master is
end tb_i2c_master;

architecture sim of tb_i2c_master is

    -- Компонент, який ми тестуємо (Master)
    component i2c_master_tx
        Port (
            clk        : in  std_logic;
            rst_n      : in  std_logic;
            start_tx   : in  std_logic;
            slave_addr : in  std_logic_vector(6 downto 0);
            data_in    : in  std_logic_vector(7 downto 0);
            busy       : out std_logic;
            sda        : inout std_logic;
            scl        : out std_logic
        );
    end component;

    signal clk        : std_logic := '0';
    signal rst_n      : std_logic := '0';
    signal start_tx   : std_logic := '0';
    signal slave_addr : std_logic_vector(6 downto 0) := "1010000"; -- приклад адреси
    signal data_in    : std_logic_vector(7 downto 0) := "01010101";
    signal sda_line   : std_logic := 'H';  -- I2C лінія SDA (H = high-impedance)
    signal scl_line   : std_logic;
    signal busy       : std_logic;

    constant CLK_PERIOD : time := 20 ns; -- 50 MHz

begin

    -- Генерація тактового сигналу
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Генерація сигналу RESET (активний low)
    reset_process : process
    begin
        rst_n <= '0';
        wait for 200 ns;
        rst_n <= '1';
        wait;
    end process;

    -- Інстанція I2C Master
    uut_master : i2c_master_tx
        port map (
            clk        => clk,
            rst_n      => rst_n,
            start_tx   => start_tx,
            slave_addr => slave_addr,
            data_in    => data_in,
            busy       => busy,
            sda        => sda_line,
            scl        => scl_line
        );

    -- Імітація роботи Slave (імітація ACK)
    slave_process : process
    begin
        wait until rst_n = '1';
        wait until start_tx = '1';
        wait for 100 us;

        -- ACK від Slave (SDA тягнеться до 0)
        sda_line <= '0';
        wait for 5 us;
        sda_line <= 'H';
        wait;
    end process;

    -- Вхідні сигнали для Master
    stim_proc : process
    begin
        wait for 500 ns;
        start_tx <= '1';
        wait for 20 ns;
        start_tx <= '0';

        wait for 2 ms;

        data_in <= "10101010";
        start_tx <= '1';
        wait for 20 ns;
        start_tx <= '0';
        wait;
    end process;

end sim;