library ieee;
use ieee.std_logic_1164.all;
use ieee.NUMERIC_STD.all;
use work.print_pkg.all;
use work.assert_pkg.all;
use work.tb_pkg.all;

entity Clock_Generation_TB is
end entity;

architecture testbench of Clock_Generation_TB is
    
signal clk_tb               : std_ulogic := '0';
signal rst_tb               : std_ulogic := '0';
signal half_period_width_tb : natural := 7;
signal half_period_cycles_tb : unsigned(half_period_width_tb downto 0) := "00001000";
signal clk_out_tb         : std_ulogic := '0';

component Clock_generation is
    generic(
        half_period_width : natural
    );
    port (
        clk_in             : in std_ulogic;
        rst                : in std_ulogic;
        half_period_cycles : in unsigned(half_period_width downto 0);
        clk_out            : out std_ulogic 
    );
end component Clock_generation;

begin
    dut : Clock_generation 
        generic map(
            half_period_width => half_period_width_tb
        )
        port map (
            clk_in  => clk_tb,
            rst     => rst_tb,
            half_period_cycles => half_period_cycles_tb,
            clk_out => clk_out_tb
        );

   clk_tb <= not clk_tb after CLK_PERIOD /2;

   stimuli_and_checker : process is 
   begin
        rst_tb <= '1';
        wait_for_clock_edges(clk_tb, 10);
        rst_tb <= '0';
        wait_for_clock_edges(clk_tb, 30000);
        
        std.env.finish;

   end process stimuli_and_checker;
end architecture;