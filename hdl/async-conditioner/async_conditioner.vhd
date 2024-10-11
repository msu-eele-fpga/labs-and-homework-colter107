library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity async_conditioner is
    port (
        clk     : in std_ulogic;
        rst     : in std_ulogic;
        async   : in std_ulogic;
        sync   : out std_ulogic
    );
end entity async_conditioner;

architecture async_conditioner_arch of async_conditioner is

component synchronizer is
    port (
        clk   : in    std_logic;
        async : in    std_ulogic;
        sync  : out   std_ulogic
    );
end component synchronizer;

component debouncer is
    generic (
        clk_period  : time := 20 ns;
        debounce_time : time
    );
    port(
        clk     : in std_ulogic;
        rst     : in std_ulogic;
        input   : in std_ulogic;
        debounced : out std_ulogic
    );
end component debouncer;

component one_pulse is
    port (
        clk     : in std_ulogic;
        rst     : in std_ulogic;
        input   : in std_ulogic;
        pulse   : out std_ulogic
    );
end component one_pulse;

signal sync_dirty : std_ulogic;
signal debounced_dirty : std_ulogic;

constant CLK_PERIOD : time := 20 ns;
constant DEBOUNCE_TIME : time := 1 ms;

begin

    sync1 : synchronizer
        port map(
          clk   => clk,
          async => async,
          sync  => sync_dirty
        );
      
    debouncer1 : debouncer
        generic map(
            clk_period  => CLK_PERIOD,
            debounce_time => DEBOUNCE_TIME
        )
        port map(
            clk => clk,
            rst => rst,
            input => sync_dirty,
            debounced => debounced_dirty
        );

    pulse1 : one_pulse
        port map (
            clk => clk,
            rst  => rst,
            input => debounced_dirty,
            pulse => sync
        );
    


end architecture;