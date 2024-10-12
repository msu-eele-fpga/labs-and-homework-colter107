library ieee;
use ieee.std_logic_1164.all;

entity timed_counter is
	generic (
		clk_period : time;
		count_time : time
	);
	port (
		clk : in std_ulogic;
		enable : in boolean;
		done : out boolean
	);
end entity timed_counter;

architecture counter_arch of timed_counter is
	constant COUNTER_LIMIT : natural := count_time / clk_period;
	signal count_iter : natural range 0 to COUNTER_LIMIT := 0;

	begin

	timer_logic: process(clk)
		
	begin
		if(rising_edge(clk)) then
			done <= false;
			if enable then
				if (count_iter = COUNTER_LIMIT) then
					done <= true;
					count_iter <= 0;
				else
					count_iter <= count_iter + 1;
				end if;
			else
				count_iter <= 0;
			end if;
		end if;
		
	end process timer_logic;

end architecture counter_arch;
