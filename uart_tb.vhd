library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_uart_tx is
end tb_uart_tx;

architecture Behavioral of tb_uart_tx is
    component uart_baud_gen
        generic (
            CLK_FREQ_HZ : integer := 50_000_000;
            BAUD_RATE   : integer := 115200
        );
        port (
            clk       : in  std_logic;
            rst_n     : in  std_logic;
            baud_tick : out std_logic
        );
    end component;

    component uart_tx
        port (
            clk       : in  std_logic;
            rst_n     : in  std_logic;
            baud_tick : in  std_logic;
            tx_start  : in  std_logic;
            tx_data   : in  std_logic_vector(7 downto 0);
            busy      : out std_logic;
            tx_serial : out std_logic
        );
    end component;

    signal clk       : std_logic := '0';
    signal rst_n     : std_logic := '0';
    signal tx_start  : std_logic := '0';
    signal tx_data   : std_logic_vector(7 downto 0) := "10101010";
    signal baud_tick : std_logic;
    signal busy      : std_logic;
    signal tx_serial : std_logic;

    constant CLK_PERIOD : time := 20 ns; -- 50 MHz
begin
    -- Генератор тактового сигналу
    clk_process : process
    begin
        clk <= '0'; wait for CLK_PERIOD / 2;
        clk <= '1'; wait for CLK_PERIOD / 2;
    end process;

    uut_baud : uart_baud_gen
        generic map (
            CLK_FREQ_HZ => 50_000_000,
            BAUD_RATE   => 115200
        )
        port map (
            clk       => clk,
            rst_n     => rst_n,
            baud_tick => baud_tick
        );

    -- UART TX
    uut_tx : uart_tx
        port map (
            clk       => clk,
            rst_n     => rst_n,
            baud_tick => baud_tick,
            tx_start  => tx_start,
            tx_data   => tx_data,
            busy      => busy,
            tx_serial => tx_serial
        );

    stim_proc : process
    begin
        rst_n <= '0';
        wait for 200 ns;
        rst_n <= '1'; 

        wait for 200 ns;
        tx_start <= '1';
        wait for 20 ns;
        tx_start <= '0';

        wait for 2 ms; 
        wait;
    end process;
end Behavioral;
