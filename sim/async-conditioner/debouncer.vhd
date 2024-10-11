library IEEE;
use ieee.std_logic_1164.all;

entity debouncer is
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
end entity debouncer;

architecture debouncer_arch of debouncer is
   signal hold : std_ulogic := '0';
   signal busy: std_ulogic := '0';
   signal iter : integer range 0 to 100000 := 0;
   constant HOLD_ITER : integer range 0 to 100000 := debounce_time / clk_period;
   begin
   
   debounce :process (clk, rst)
	begin
	if(rst = '0') then 
		if(rising_edge(clk)) then
			if (busy = '1') then
				if (iter < (HOLD_ITER - 2)) then
					iter <= iter + 1;
					busy <= '1';
					hold <= hold;
					debounced <= hold;
				else
					iter <= 0;
					busy <= '0';
					hold <= hold;
					debounced <= hold;
				end if;
			
			else
				if (not (hold = input)) then
					iter <= 0;
					hold <= input;
					debounced <= input;
					busy <= '1';
				end if;
			end if;
		end if;
	else
		iter <= 0;
		busy <= '0';
		hold <= '0';
		debounced <= '0';
	end if;

    end process;

end architecture debouncer_arch;