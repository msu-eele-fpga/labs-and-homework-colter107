library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vending_machine is
	port (
		clk : in std_ulogic;
		rst : in std_ulogic;
		nickel : in std_ulogic;
		dime : in std_ulogic;
		dispense : out std_ulogic;
		amount : out natural range 0 to 15
	);
end entity vending_machine;

architecture vending_arch of vending_machine is
	
	type State_Type is (zero, five, ten, fifteen);
	signal current_state, next_state : State_Type;

	begin

		state_memory : process (clk,rst)
		begin
			if (rst = '1') then
				current_state <= zero;
			elsif (rising_edge(clk)) then
				current_state <= next_state;
			end if;
		end process;

		next_state_logic : process (current_state, nickel, dime)
		begin
			case (current_state) is
				when(zero) => 	if(nickel = '0' and dime = '0') then
									next_state <= zero;
								elsif(dime = '1') then
									next_state <= ten;
								elsif(nickel = '1') then
									next_state <= five;
								end if;
				when(five) => 	if(nickel = '0' and dime = '0') then
									next_state <= five;
								elsif(dime = '1') then
									next_state <= fifteen;
								elsif(nickel = '1') then
									next_state <= ten;
								end if;
				when(ten) => 	if(nickel = '0' and dime = '0') then
									next_state <= ten;
								elsif(dime = '1') then
									next_state <= fifteen;
								elsif(nickel = '1') then
									next_state <= fifteen;
								end if;
				when(fifteen) => next_state <= zero;
				when others => next_state <= zero;

			end case;
		end process;

		output_logic : process(current_state, nickel, dime)
		begin
			case (current_state) is
				when(zero) => 	dispense <= '0';
					        amount <= 0;
				when(five) => 	dispense <= '0';
						amount <= 5;
				when(ten) => 	dispense <= '0';
						amount <= 10;
				when(fifteen) =>dispense <= '1';
						amount <= 15;
				when others =>  dispense <= '0';
						amount <= 0;
			end case;
		end process;

end architecture vending_arch;
