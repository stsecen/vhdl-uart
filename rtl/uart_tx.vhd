library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_tx is
    generic (
        CLK_FREQ    : integer := 115200000;   --> set system clock frequency in Hz
        BAUD_RATE   : integer := 115200;      --> baud rate value
        DATA_WIDTH  : integer := 8;
        STOP_WIDTH : integer := 1;
        TYPE_PARITY  : string  := "NONE"      --> "NONE", "EVEN", "ODD"
    );
    port (
        clk, rst: in std_logic; 
        i_valid : in std_logic;
        i_data  : in std_logic_vector(DATA_WIDTH-1 downto 0);
        o_txd   : out std_logic;
        o_ready : out std_logic
    );
end entity uart_tx;

architecture rtl of uart_tx is
    type state_type is (state_idle, state_start, state_data, state_parity, state_stop);
    signal state : state_type := state_idle;
    signal s_ready : std_logic := '0';
    constant TIMER_TICK : integer := CLK_FREQ/BAUD_RATE;
    signal s_cnt   : integer range 0 to TIMER_TICK := 0;
    signal s_tick  : std_logic := '0';
    signal s_tx_buffer : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal s_bit_cnt   : integer range 0 to DATA_WIDTH-1 := 0;
    signal s_party_bit : std_logic := 'Z';

    component parity is
        generic (
            DATA_WIDTH  : integer := 8;
            TYPE_PARITY : string := "NONE"
        );
        port (
            i_data : std_logic_vector(DATA_WIDTH-1 downto 0);
            o_parity : out std_logic
        );
    end component parity; 
begin
    
    uart_tx_parity: entity work.parity(rtl)
    generic map(
        DATA_WIDTH  => DATA_WIDTH,
        TYPE_PARITY => TYPE_PARITY
    )
    port map(
        i_data => s_tx_buffer,
        o_parity => s_party_bit
    );

    ticker: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                s_tick <= '0';
                s_cnt <= 0;
            else
                if s_cnt = TIMER_TICK-1 then 
                    s_tick <= '1';
                    s_cnt <= 0;
                else
                    s_tick <= '0';
                    s_cnt <= s_cnt+1;
                end if;
            end if;
        end if;
    end process ticker;

    tx: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= state_idle; 
                o_txd <= '1';
                s_ready <= '0';
                s_bit_cnt <= 0;
            else
                o_txd <= '1';
                s_ready <= '0';
                case( state ) is
                    when state_idle =>
                        if i_valid = '1' then 
                            s_ready <= '1';
                            s_tx_buffer <= i_data;
                            state <= state_start;
                        else 
                            state <= state_idle; 
                        end if; 
                    when state_start =>
                        if s_tick = '1' then 
                            o_txd <= '0';
                            state <= state_data;
                            s_ready <= '1';
                        end if;
                    when state_data =>
                        if s_tick = '1' then 
                            s_ready <= '1';
                            o_txd <= s_tx_buffer(s_bit_cnt);
                            if s_bit_cnt = DATA_WIDTH-1 then 
                                s_bit_cnt <= 0;
                                if TYPE_PARITY = "NONE" then  
                                    state <= state_stop; 
                                else 
                                    state <= state_parity;
                                end if;
                            else
                                s_bit_cnt <= s_bit_cnt+1;
                            end if;
                        end if; 
                    when state_parity =>
                        if s_tick = '1' then 
                            s_ready <= '1';
                            o_txd <= s_party_bit; 
                            state <= state_stop; 
                        end if;
                    when state_stop =>
                        if s_tick = '1' then 
                            o_txd <= '1'; 
                            s_ready <= '1';
                            if s_bit_cnt = STOP_WIDTH-1 then 
                                s_bit_cnt <= 0;
                                state <= state_idle; 
                            else 
                                s_bit_cnt <= s_bit_cnt+1; 
                            end if;
                        end if; 
                    when others =>
                        state <= state_idle; 
                        o_txd <= '1';
                        s_ready <= '0';
                        s_bit_cnt <= 0;
                end case ;
            end if;
        end if;
    end process tx;
    o_ready <= s_ready; 
end architecture rtl;
