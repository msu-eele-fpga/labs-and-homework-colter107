library ieee;
use ieee.std_logic_1164.all;
use ieee.NUMERIC_STD.all;
use work.print_pkg.all;
use work.assert_pkg.all;
use work.tb_pkg.all;

entity pattern_4_TB is
end entity;

architecture testbench of pattern_4_TB is
    
signal clk_tb               : std_ulogic := '0';
signal rst_tb               : std_ulogic := '0';
signal pattern4_tb          : std_ulogic_vector(6 downto 0);

component pattern4 is
    port (
        clk_in      : in std_ulogic;
        rst         : in std_ulogic;
        pattern4_out : out std_ulogic_vector(6 downto 0)
    );
end component pattern4;

begin
    dut : pattern4
        port map (
            clk_in  => clk_tb,
            rst     => rst_tb,
            pattern4_out => pattern4_tb
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