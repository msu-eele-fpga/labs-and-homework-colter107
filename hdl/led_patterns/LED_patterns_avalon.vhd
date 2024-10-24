library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity led_patterns_avalon is
port(
    clk : in std_logic;
    rst : in std_logic;
    avs_read        : in std_logic;
    avs_write       : in std_logic;
    avs_address     : in std_logic_vector(1 downto 0);
    avs_readdata    : out std_logic_vector(31 downto 0);
    avs_writedata   : in std_logic_vector(31 downto 0);
    push_button     : in std_logic;
    switches        : in std_logic_vector(3 downto 0);
    led             : out std_logic_vector(7 downto 0)
);
end entity led_patterns_avalon;

architecture led_patterns_avalon_arch of led_patterns_avalon is 

    signal hps_led_control  : boolean := false;
    signal hps_led_control_bit : std_logic := '0';
    signal base_period_avalon      : unsigned(7 downto 0) := "00010000";
    signal led_reg          : std_logic_vector(7 downto 0) := (others => '0');
    constant SPACER_8BIT    : std_logic_vector(31 downto 8) := (others => '0');
    constant SPACER_1BIT    : std_logic_vector(31 downto 1) := (others => '0');

    component LED_patterns is
        generic (
            system_clock_period : time := 20 ns
        );
        port (
            clk             : in std_logic;
            rst             : in std_logic;
            push_button     : in std_logic;
            switches        : in std_logic_vector(3 downto 0);
            hps_led_control : in boolean;
            base_period     : in unsigned(7 downto 0);
            led_reg         : in std_logic_vector(7 downto 0);
            led             : out std_logic_vector(7 downto 0) 
        );
    end component led_patterns;

begin

    avalon_register_read : process(clk, avs_read)
    begin
        if(rising_edge(clk) and avs_read = '1') then
            case avs_address is 
                when "00"   => avs_readdata <= SPACER_1BIT & hps_led_control_bit;
                when "01"   => avs_readdata <= SPACER_8BIT & std_logic_vector(base_period_avalon);
                when "10"   => avs_readdata <= SPACER_8BIT & led_reg;
                when others => avs_readdata <= (others => '0');
            end case;
        end if;
    end process avalon_register_read;

    avalon_register_write : process(clk, rst, avs_write)
    begin
        if (rst = '1') then
            hps_led_control <= false;
            base_period_avalon <= "00010000";
            led_reg <= (others => '0');
        elsif(rising_edge(clk) and avs_write = '1') then
            case avs_address is 
                when "00"   =>  if(avs_writedata(0) = '1') then
                                    hps_led_control <= true;
                                else
                                    hps_led_control <= false;
                                end if;
                when "01"   => base_period_avalon  <= unsigned(avs_writedata(7 downto 0));
                when "10"   => led_reg      <= avs_writedata(7 downto 0);
                when others => null;
            end case;
        end if;
    end process avalon_register_write;

    hps_control_to_bit : process(clk)
    begin
		 
        if(rising_edge(clk)) then
            if(hps_led_control) then
                hps_led_control_bit <= '1';
            else
                hps_led_control_bit <= '0';
            end if;

        end if;
    end process hps_control_to_bit;

    pattern_Gen : LED_patterns 
    port map(
        clk             => clk,
        rst             => rst,
        push_button     => push_button,
        switches        => switches,
        hps_led_control => hps_led_control,
        base_period     => base_period_avalon,
        led_reg         => led_reg,
        led             => led
    );


end architecture;