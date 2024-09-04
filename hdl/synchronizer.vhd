library IEEE;
use IEEE.std_logic_1164.all;

entity synchronizer is
    port (
      clk   : in    std_logic;
      async : in    std_ulogic;
      sync  : out   std_ulogic
    );
  end entity synchronizer;

architecture synchronizer_arch of synchronizer is

	signal q1 : std_logic;
begin
	

	synchronize : process (clk)
	begin
		if(rising_edge(clk)) then
			sync <= q1;
			q1 <= async;
		end if;
	end process synchronize;
end architecture;
			
