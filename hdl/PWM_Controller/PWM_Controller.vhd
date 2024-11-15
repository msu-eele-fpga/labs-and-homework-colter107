
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
 
entity pwm_controller is
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
end entity pwm_controller;

architecture pwm_controller_arch of pwm_controller is
constant PERIOD_WIDTH : natural := 27;
constant DUTY_CYCLE_WIDTH : natural := 15;
constant PERIOD_FRACTIONAL : natural := 21;
constant DUTY_CYCLE_FRACTIONAL : natural := 14;
constant PERIOD_WHOLE : natural := 6;
constant DUTY_CYCLE_WHOLE : natural := 1;

--Number of bits used to store the system clock frequency as unsinged int
constant system_clock_freq_num_bits : natural := natural(ceil(log2(real(1 sec / (1000 * CLK_PERIOD)))));

 --System clock frequency
constant system_clock_freq : unsigned(system_clock_freq_num_bits - 1 downto 0) := TO_UNSIGNED((1 sec / (1000 * CLK_PERIOD)), system_clock_freq_num_bits);

--System clock frequency (cycles/sec) * (1 sec / 1000 ms) = cycles / ms (no fractional bits)

--Clock frequency * PWM period 
--      cycles/ms * seconds = clock cycles/1000 (good)
--      total bits = system_clock_freq_num_bits + period_width
--      whole bits = system_clock_freq_num_bits + period_whole
--      assign total_bits downto period_fractional
--
--PWM cycles * Duty cycle
--      cycles/1000 * fraction of cycles to switch at (good)
--      total bits = system_clock_freq_num_bits + period_width + duty_cycle_width
--      whole bits = system_clock_freq_num_bits + period_whole + duty_cycle whole
--      assign total_bits downto (period_fractional + duty_cycle_fractional)


--CONSTANTS FOR PWM PERIOD------------------------------------------------------------------------------------------------------------------------
--Number of bits needed to represent system clock frequency * period
--This has fractional bits, but we can't have fractional clock cycles
constant period_clock_cycles_num_bits_total : natural := system_clock_freq_num_bits + PERIOD_WIDTH;

--Number of bits needed to represent system clock frequency * period
--No fractional bits :D
 constant period_clock_cycles_num_bits_whole : natural := system_clock_freq_num_bits + PERIOD_WHOLE;

--Number of clock cycles in one period
--This has fractional bits, but we can't have fractional clock cycles
signal period_clk_cycles_full : unsigned(period_clock_cycles_num_bits_total - 1 downto 0);

--Number of whole clock cycles in one base period
--No fractional bits :D
signal period_clk_cycles : unsigned(period_clock_cycles_num_bits_whole - 1 downto 0);

--CONSTANTS FOR PWM DUTY CYCLE---------------------------------------------------------------------------------------------------------------------
--Number of bits needed to represent system duty_cycle * period
--This has fractional bits, but we can't have fractional clock cycles
constant duty_cycle_clock_cycles_num_bits_total : natural := PERIOD_WIDTH + DUTY_CYCLE_WIDTH + system_clock_freq_num_bits;

--Number of bits needed to represent system duty_cycle * period
--No fractional bits :D
 constant duty_cycle_clock_cycles_num_bits_whole : natural := DUTY_CYCLE_WHOLE + PERIOD_WHOLE + system_clock_freq_num_bits;

--Number of clock cycles in one period
--This has fractional bits, but we can't have fractional clock cycles
signal duty_cycle_clk_cycles_full : unsigned(duty_cycle_clock_cycles_num_bits_total - 1 downto 0);

--Number of whole clock cycles in one base period
--No fractional bits :D
signal duty_cycle_clk_cycles : unsigned(duty_cycle_clock_cycles_num_bits_whole - 1 downto 0);
signal duty_cycle_clk_cycles_constrained : unsigned(duty_cycle_clock_cycles_num_bits_whole - 1 downto 0) := (others => '0');

signal counter : unsigned (PERIOD_WIDTH downto 0) := (others => '0');
signal pwm : STD_ULOGIC := '0';


begin

--Set number of clock cycles in period
period_clk_cycles_full <= system_clock_freq * period;
period_clk_cycles <= period_clk_cycles_full(period_clock_cycles_num_bits_total - 1 downto PERIOD_FRACTIONAL);

--Set number of clock cycles in duty cycle
duty_cycle_clk_cycles_full <= period_clk_cycles_full * duty_cycle;
duty_cycle_clk_cycles <= duty_cycle_clk_cycles_full(duty_cycle_clock_cycles_num_bits_total - 1 downto PERIOD_FRACTIONAL + DUTY_CYCLE_FRACTIONAL);


pulse_width_modulate : process(clk,rst)
begin
    if(rst = '1') then
        counter <= (others => '0');
        if(duty_cycle_clk_cycles > period_clk_cycles) then
            duty_cycle_clk_cycles_constrained <= (others => '0');
            duty_cycle_clk_cycles_constrained(duty_cycle_clock_cycles_num_bits_whole-1) <= '1';
        elsif(to_integer(duty_cycle_clk_cycles) < 0) then
            duty_cycle_clk_cycles_constrained <= (others => '0');
        else
            duty_cycle_clk_cycles_constrained <= duty_cycle_clk_cycles;
        end if;
    elsif(rising_edge(clk))then
        counter <= counter + 1;
        --If counter reaches period, turn on PWM signal, reset timer
        if counter >= period_clk_cycles then
            pwm <= '1';
            counter <= (others => '0');
        --If counter is between end of duty cycle and period, turn off PWM signal
        elsif counter >= duty_cycle_clk_cycles_constrained  then
            pwm <= '0';
        --Otherwise, the counter is between the start of the period and the end of duty cycle, and PWM should be on
        else
            pwm <= '1';
        end if;
        output <= pwm;
    end if;
end process pulse_width_modulate;
end architecture;
