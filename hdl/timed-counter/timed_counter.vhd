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
	constant COUNTER_LIMIT : integer := count_time / clk_period;
	signal count_iter : integer range 0 to 10000000 := 0;

	begin

	timer_logic: process(clk, enable)
		
	begin
		if enable then
			if(rising_edge(clk)) then
				count_iter <= count_iter + 1;
				if (count_iter = COUNTER_LIMIT) then
					done <= true;
					count_iter <= 0;
				else
					done <= false;
				end if;
			end if;
		else
			count_iter <= 0;
		end if;
	end process timer_logic;

end architecture counter_arch;
