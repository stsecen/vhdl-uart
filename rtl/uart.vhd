library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is
    generic(
        CLK_FREQ    : integer := 115200000;   --> set system clock frequency in Hz
        BAUD_RATE   : integer := 115200;      --> baud rate value
        DATA_WIDTH  : integer := 8;
        STOP_WIDTH  : integer := 1;
        TYPE_PARITY : string  := "NONE"      --> "NONE", "EVEN", "ODD"
    );
    port (
        clk, rst      :  in std_logic;
        i_rxd         :  in std_logic; 
        i_valid       :  in std_logic;
        i_data        :  in std_logic_vector(DATA_WIDTH-1 downto 0);
        i_data_ready  :  in std_logic;

        o_txd         : out std_logic;
        o_data        : out std_logic_vector(DATA_WIDTH-1 downto 0);
        o_data_valid  : out std_logic;
        o_data_ready  : out std_logic
    );
end uart;

architecture rtl of uart is
    component uart_tx is
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
    end component;
    
    component uart_rx is
        generic (
            CLK_FREQ    : integer := 115200000;   --> set system clock frequency in Hz
            BAUD_RATE   : integer := 115200;      --> baud rate value
            DATA_WIDTH  : integer := 8;
            STOP_WIDTH  : integer := 1;
            TYPE_PARITY  : string  := "NONE"      --> "NONE", "EVEN", "ODD"
        );
        port (
            clk, rst : in std_logic; 
            i_ready  : in std_logic;
            i_rxd    : in std_logic;
            o_data   : out std_logic_vector(DATA_WIDTH-1 downto 0);
            o_valid  : out std_logic
        );
    end component;
    
begin
    rx: uart_rx 
        generic map(
            CLK_FREQ     => CLK_FREQ,
            BAUD_RATE    => BAUD_RATE,
            DATA_WIDTH   => DATA_WIDTH,
            STOP_WIDTH   => STOP_WIDTH,
            TYPE_PARITY  => TYPE_PARITY
        )
        port map(
            clk          => clk, 
            rst          => rst,
            i_ready      => i_data_ready,
            i_rxd        => i_rxd, 
            o_data       => o_data,
            o_valid      => o_data_valid 

        );
    tx: uart_tx
        generic map(
            CLK_FREQ     => CLK_FREQ,
            BAUD_RATE    => BAUD_RATE,
            DATA_WIDTH   => DATA_WIDTH,
            STOP_WIDTH   => STOP_WIDTH,
            TYPE_PARITY  => TYPE_PARITY
        )
        port map(
            clk          => clk, 
            rst          => rst, 
            i_valid      => i_valid,
            i_data       => i_data,
            o_txd        => o_txd,
            o_ready      => o_data_ready
        );
    
    
end architecture rtl;