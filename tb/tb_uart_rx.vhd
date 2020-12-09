library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_uart_rx is
end entity tb_uart_rx;

architecture rtl of tb_uart_rx is
    constant CLK_FREQ    : integer := 115200000;   --> set system clock frequency in Hz
    constant BAUD_RATE   : integer := 115200;      --> baud rate value
    constant DATA_WIDTH  : integer := 8;
    constant STOP_WIDTH  : integer := 1;
    constant TYPE_PARITY  : string  := "EVEN";
    constant TIMER_TICK   : integer := CLK_FREQ/BAUD_RATE;
    signal clk, rst, i_ready, i_rxd, o_valid : std_logic := '0';
    signal o_data : std_logic_vector(DATA_WIDTH-1  downto 0) := (others => '0');
    constant clk_period : time := 86 ns;
    constant bit_time   : time := TIMER_TICK * clk_period;
    constant data       : std_logic_vector(DATA_WIDTH-1 downto 0) := x"D3";
begin
    
    uut_rx: entity work.uart_rx(rtl)
            generic map(
                CLK_FREQ    => CLK_FREQ,
                BAUD_RATE   => BAUD_RATE,
                DATA_WIDTH  => DATA_WIDTH,
                STOP_WIDTH  => STOP_WIDTH,
                TYPE_PARITY => TYPE_PARITY
            )
            port map(
                clk      => clk, 
                rst      => rst,
                i_ready  => i_ready,
                i_rxd    => i_rxd,
                o_data   => o_data,
                o_valid  => o_valid
            );

    clk_gen: process
    begin
        for i in 0 to 20 * TIMER_TICK loop
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
            clk <= '0';
        end loop;
        wait;
    end process clk_gen;

    stimulus:process
    begin
        i_ready <= '0';
        i_rxd <= '1';
        wait for 2000 ns;
        i_rxd <= '0'; -- start bit
        wait for bit_time;

        for i in 0 to DATA_WIDTH-1 loop
            i_rxd <= data(i); -- data bits
            wait for bit_time;
        end loop;
        i_rxd <= '0'; -- parity bit
        wait for bit_time;
        i_rxd <= '1'; -- stop bit
        wait for bit_time;

        wait until o_valid = '1';
        i_ready <= '1';

        assert o_data = data
            report "data does not match" severity error;

        -- complete the simulation
        assert false report "completed test" severity note;

        wait;
    end process;

end architecture rtl;