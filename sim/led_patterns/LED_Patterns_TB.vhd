library ieee;
use ieee.std_logic_1164.all;
use ieee.NUMERIC_STD.all;
use work.print_pkg.all;
use work.assert_pkg.all;
use work.tb_pkg.all;

entity LED_Patterns_TB is
end entity;

architecture testbench of LED_Patterns_TB is
    
signal clk_tb               : std_ulogic := '0';
signal rst_tb               : std_ulogic := '0';
signal push_button_tb       : std_ulogic := '0';
signal switches_tb          : std_ulogic_vector(3 downto 0);
signal hps_led_control_tb   : boolean := true;
signal base_period_tb       : unsigned(7 downto 0) := "00000001";
signal led_reg_tb           : STD_ULOGIC_VECTOR(7 downto 0) := "00000000";
signal led_tb               : STD_ULOGIC_VECTOR(7 downto 0);

constant CLK_PERIOD :  time := 20 ns;
constant HALF_PERIOD_WIDTH_TB : natural := 30;

component LED_patterns is
    generic (
        system_clock_period : time := 1 ms
    );
    port (
        clk             : in std_ulogic;
        rst             : in std_ulogic;
        push_button     : in std_ulogic;
        switches        : in std_ulogic_vector(3 downto 0);
        hps_led_control : in boolean;
        base_period     : in unsigned(7 downto 0);
        led_reg         : in std_ulogic_vector(7 downto 0);
        led             : out std_ulogic_vector(7 downto 0) 
    );
end component led_patterns;

begin
    dut: LED_patterns
        port map(
            clk             => clk_tb,
            rst             => rst_tb,
            push_button     => push_button_tb,
            switches        => switches_tb,
            hps_led_control => hps_led_control_tb,
            base_period     => base_period_tb,
            led_reg         => led_reg_tb,
            led             => led_tb
        );
   clk_tb <= not clk_tb after CLK_PERIOD /2;

   stimuli_and_checker : process is 
   begin
        rst_tb <= '1';
        wait_for_clock_edges(clk_tb, 10);
        rst_tb <= '0';
        wait_for_clock_edges(clk_tb, 300);

        switches_tb <= "0001";
        wait_for_clock_edges(clk_tb,10);
        push_button_tb <= '1';
        wait_for_clock_edges(clk_tb,10);
        push_button_tb <= '0';
        wait_for_clock_edges(clk_tb, 300);

        switches_tb <= "0010";
        wait_for_clock_edges(clk_tb,10);
        push_button_tb <= '1';
        wait_for_clock_edges(clk_tb,10);
        push_button_tb <= '0';
        wait_for_clock_edges(clk_tb, 300);

        switches_tb <= "0011";
        wait_for_clock_edges(clk_tb,10);
        push_button_tb <= '1';
        wait_for_clock_edges(clk_tb,10);
        push_button_tb <= '0';
        wait_for_clock_edges(clk_tb, 300); 

        switches_tb <= "0100";
        wait_for_clock_edges(clk_tb,10);
        push_button_tb <= '1';
        wait_for_clock_edges(clk_tb,10);
        push_button_tb <= '0';
        wait_for_clock_edges(clk_tb, 300);
        
        std.env.finish;

   end process stimuli_and_checker;
end architecture;