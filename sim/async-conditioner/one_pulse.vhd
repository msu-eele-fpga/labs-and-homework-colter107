library ieee;
use ieee.std_logic_1164.all;

entity one_pulse is
    port (
        clk     : in std_ulogic;
        rst     : in std_ulogic;
        input   : in std_ulogic;
        pulse   : out std_ulogic
    );
end entity one_pulse;

architecture one_pulse_arch of one_pulse is
signal pulseFlag : std_ulogic := '0';
begin
    pulse_logic : process(clk, rst)
    begin
        if(rst = '0') then
		if(rising_edge(clk)) then
            		if(input = '1' and pulseFlag = '0') then
                		pulse <= '1';
				pulseFlag <= '1';
            		else
               			pulse <= '0';
            		end if;
			if (input = '0') then
				pulseFlag <= '0';
			end if;
		end if;
        else
            pulseFlag <= '0';
            pulse <= '0';
        end if;
    end process pulse_logic;
    

end architecture one_pulse_arch;