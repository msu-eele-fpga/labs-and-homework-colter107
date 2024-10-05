library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity pattern4 is
    port (
        clk_in      : in std_ulogic;
        rst         : in std_ulogic;
        pattern4_out : out std_ulogic_vector(6 downto 0)
    );
end entity pattern4;


architecture pattern1_arch of pattern4 is
    signal pattern4_unsigned : unsigned(6 downto 0);
    signal pattern4_counter : natural := 0;
begin
    update_pattern : process(clk_in, rst)
    begin
        if(rst = '1') then
            pattern4_unsigned <= "1111110"; 
        else
            pattern4_unsigned(pattern4_counter) <= not (pattern4_unsigned(pattern4_counter));
            pattern4_counter <= pattern4_counter + 1;
            if (pattern4_counter = 6) then
                pattern4_counter <= 0;
            end if;
        end if;
        pattern4_out <= std_ulogic_vector(pattern4_unsigned);
    end process update_pattern;
end architecture pattern1_arch;