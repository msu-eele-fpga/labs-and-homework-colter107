library ieee;
use ieee.std_logic_1164.all;
use work.print_pkg.all;
use work.assert_pkg.all;
use work.tb_pkg.all;

entity async_conditioner_tb is 
end entity async_conditioner_tb;

architecture testbench of async_conditioner_tb is 

component async_conditioner is
    port (
        clk     : in std_ulogic;
        rst     : in std_ulogic;
        async   : in std_ulogic;
        sync   : out std_ulogic
    );
end component async_conditioner;

signal clk_tb : std_ulogic := '0';
signal rst_tb : std_ulogic := '0';
signal async_tb : std_ulogic := '0';
signal sync_tb : std_ulogic := '0';

signal CLK_PERIOD : time := 20 ns;
signal PULSE_DELAY : integer := 4;
signal DEBOUNCE_DELAY : integer := 50;




begin

    dut_async_conditioner : component async_conditioner 
        port map(
            clk => clk_tb,
            rst => rst_tb,
            async => async_tb,
            sync => sync_tb
        );

    clk_tb <= not clk_tb after CLK_PERIOD / 2;
        
    stimuli_and_checker : process is 
    begin
        
        rst_tb <= '1';
        wait_for_clock_edges(clk_tb, DEBOUNCE_DELAY);
        rst_tb <= '0';

        --Test one pulse for 55 clock cycles of switch on (1100 ns)
        --this is enough time for the debouncing condition to stop, assuring the one-pulse is working properly
        print("Testing async conditioner on 1100ns synchronous pulse");
        wait_for_clock_edge(clk_tb);
        async_tb <= '1';
        wait_for_clock_edges(clk_tb, PULSE_DELAY);
        assert_true((sync_tb = '1'), "Pulse enables");
        wait_for_clock_edge(clk_tb);
        assert_true((sync_tb = '0'), "Pulse disables");
        wait_for_clock_edges(clk_tb,DEBOUNCE_DELAY + 5); 
        assert_true((sync_tb = '0'), "Pulse stays disabled while button is held");
        async_tb <= '0';
        wait_for_clock_edges(clk_tb, DEBOUNCE_DELAY * 2); --Need to wait 2 debounce cycles here, one for the rising edge and one for the falling edge

         --Test debouncer with bouncing signal
         print("Testing async conditioner on bouncing pulse");
         wait_for_clock_edge(clk_tb);
         --Bouncing rising edge
         async_tb <= '1';
         wait_for_clock_edges(clk_tb, PULSE_DELAY);
         assert_true((sync_tb = '1'), "Pulse enables");
         wait_for_clock_edge(clk_tb);
         assert_true((sync_tb = '0'), "Pulse disables");
         wait_for_clock_edges(clk_tb, 3);
         async_tb <= '1';
         assert_true((sync_tb = '0'), "Pulse stays disabled while button is held");
         wait_for_clock_edges(clk_tb, 3);
         async_tb <= '0';
         wait_for_clock_edges(clk_tb,5);
         async_tb <= '1';
         wait_for_clock_edges(clk_tb, PULSE_DELAY);
         assert_true((sync_tb = '0'), "Pulse does not fire on rising edge bounce 1");
         async_tb <= '0';
         wait_for_clock_edges(clk_tb, 2);
         async_tb <= '1';
         wait_for_clock_edges(clk_tb, PULSE_DELAY);
         assert_true((sync_tb = '0'), "Pulse does not fire on rising edge bounce 2");
         wait_for_clock_edges(clk_tb,DEBOUNCE_DELAY);
         --Bouncing falling edge
         async_tb <= '0';
         wait_for_clock_edge(clk_tb);
         async_tb <='1';
         wait_for_clock_edges(clk_tb,PULSE_DELAY);
         assert_true((sync_tb = '0'), "Pulse doesn not fire on falling edge bounce");
         async_tb <= '0';
         wait_for_clock_edges(clk_tb,DEBOUNCE_DELAY + 5);
         



         --Test synchronizer with asynchronous pulse
         print("Testing async conditioner on asyncrhonous pulse");
         wait_for_clock_edge(clk_tb);
         wait for CLK_PERIOD /2;
         async_tb <= '1';
         wait_for_clock_edges(clk_tb, PULSE_DELAY);
         assert_true((sync_tb = '1'), "Pulse enables");
         wait_for_clock_edge(clk_tb);
         assert_true((sync_tb = '0'), "Pulse disables");
         wait_for_clock_edges(clk_tb, PULSE_DELAY);
         assert_true((sync_tb = '0'), "Pulse stays disabled while button is held");

        std.env.finish;

    end process stimuli_and_checker;

end architecture testbench;
