library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity pattern1 is
    port (
        clk_in      : in std_ulogic;
        rst         : in std_ulogic;
        pattern1_out : out unsigned(6 downto 0)
    );
end entity pattern1;


architecture pattern1_arch of pattern1 is
begin
    update_pattern : process(clk_in, rst)
    begin
        if(rst = '1') then
            pattern1_out <= (others => '0') + 3; 
        else
            pattern1_out <= pattern1_out sll 1;
            if(pattern1_out = "1000000") then
                pattern1_out(0) <= '1';
            elsif (pattern1_out = "0000010") then
                pattern1_out(0) <= '1';
            end if;  
        end if;
    end process update_pattern;
end architecture pattern1_arch;