library ieee;
use ieee.std_logic_1164.all;
use work.print_pkg.all;
use work.assert_pkg.all;
use work.tb_pkg.all;

entity one_pulse_tb is 
end entity one_pulse_tb;

architecture testbench of one_pulse_tb is 

component one_pulse is
    port (
        clk     : in std_ulogic;
        rst     : in std_ulogic;
        input   : in std_ulogic;
        pulse   : out std_ulogic
    );
end component one_pulse;
signal clk_tb : std_ulogic := '0';
signal rst_tb : std_ulogic := '0';
signal input_tb : std_ulogic := '0';
signal pulse_tb : std_ulogic := '0';

signal THREE_CYCLES : integer := 3;
signal TWENTYFIVE_CYCLES : integer := 25;
signal FIFTY_CYCLES : integer := 50;




begin

    dut_one_pulse : component one_pulse
        port map (
            clk => clk_tb,
            rst => rst_tb,
            input => input_tb,
            pulse => pulse_tb
        );

    clk_tb <= not clk_tb after CLK_PERIOD / 2;
        
    stimuli_and_checker : process is 
    begin
        rst_tb <= '1';
        wait_for_clock_edges(clk_tb, THREE_CYCLES);
        rst_tb <= '0';

        --Test one pulse for 3 clock cycles of switch on (60ns)
        print("Testing one pulse component for 60ns");
        wait_for_clock_edge(clk_tb);
        input_tb <= '1';
        wait_for_clock_edge(clk_tb);
        assert_true((pulse_tb = '1'), "Pulse enables");
        wait_for_clock_edge(clk_tb);
        assert_true((pulse_tb = '0'), "Pulse disables");
        wait_for_clock_edge(clk_tb);
	input_tb <= '0';

         --Test one pulse for 25 clock cycles of switch on (500ns)
         print("Testing one pulse component for 500ns");
         wait_for_clock_edge(clk_tb);
         input_tb <= '1';
         wait_for_clock_edge(clk_tb);
         assert_true((pulse_tb = '1'), "Pulse enables");
         wait_for_clock_edge(clk_tb);
         assert_true((pulse_tb = '0'), "Pulse disables");
         wait_for_clock_edges(clk_tb,TWENTYFIVE_CYCLES - 3); --3 clock cycles were used to test initial pulse
         assert_true((pulse_tb = '0'), "Pulse stays disabled while button is held");
	input_tb <= '0';


         --Test one pulse for 25 clock cycles of switch on (500ns)
         print("Testing one pulse component for 1000ns");
         wait_for_clock_edge(clk_tb);
         input_tb <= '1';
         wait_for_clock_edge(clk_tb);
         assert_true((pulse_tb = '1'), "Pulse enables");
         wait_for_clock_edge(clk_tb);
         assert_true((pulse_tb = '0'), "Pulse disables");
         wait_for_clock_edges(clk_tb,FIFTY_CYCLES - 3); --3 clock cycles were used to test initial pulse
         assert_true((pulse_tb = '0'), "Pulse stays disabled while button is held");
	 input_tb <= '0';




        std.env.finish;





    end process stimuli_and_checker;

end architecture testbench;
