library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity pattern1 is
    port (
        clk_in      : in std_ulogic;
        rst         : in std_ulogic;
        pattern1_out : out std_ulogic_vector(6 downto 0)
    );
end entity pattern1;


architecture pattern1_arch of pattern1 is
    signal pattern1_unsigned : unsigned(6 downto 0);
begin
    update_pattern : process(clk_in, rst)
    begin
        if(rst = '1') then
            pattern1_unsigned <= to_unsigned(3,7); 
        else
            pattern1_unsigned <= pattern1_unsigned sll 1;
            if(pattern1_unsigned = "1100000") then
                pattern1_unsigned(0) <= '1';
            elsif (pattern1_unsigned = "1000001") then
                pattern1_unsigned(0) <= '1';
            end if;  
        end if;
        pattern1_out <= std_ulogic_vector(pattern1_unsigned);
    end process update_pattern;
end architecture pattern1_arch;