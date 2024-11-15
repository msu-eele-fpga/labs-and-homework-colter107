library ieee;
use ieee.std_logic_1164.all;
use ieee.NUMERIC_STD.all;
use work.print_pkg.all;
use work.assert_pkg.all;
use work.tb_pkg.all;

entity PWM_controller_TB is
end entity;

architecture testbench of PWM_controller_TB is
    signal clk_tb               : std_ulogic := '0';
    signal rst_tb               : std_ulogic := '0';
--                                                           wwwwwwfffffffffffffffffffff
    signal period_tb            : unsigned (26 downto 0) := "000000100000000000000000000"; --500 us
--                                                           wffffffffffffff
    signal duty_cycle_tb        : unsigned (14 downto 0) := "001000000000000"; --1/4
    signal out_tb               : std_ulogic;

component pwm_controller is
        generic (
        CLK_PERIOD : time := 20 ns
        );
        port (
            clk : in std_logic;
            rst : in std_logic;
            -- PWM repetition period in milliseconds;
            -- datatype (W.F) is individually assigned
            period : in unsigned(27 - 1 downto 0);
            -- PWM duty cycle between [0 1]; out-of-range values are hard-limited
            -- datatype (W.F) is individually assigned
            duty_cycle : in unsigned(15 - 1 downto 0);
            output : out std_logic
        );
end component pwm_controller;
begin

DUT1: pwm_controller
        port map (
            clk => clk_tb,
            rst => rst_tb,
            period => period_tb,
            duty_cycle => duty_cycle_tb,
            output => out_tb
        );

clk_tb <= not clk_tb after CLK_PERIOD /2;

stimuli_and_checker : process is 
begin
    rst_tb <= '1';
    wait_for_clock_edges(clk_tb, 10);
    rst_tb <= '0';
    wait_for_clock_edges(clk_tb, 30000000);

end process stimuli_and_checker;
end architecture; 