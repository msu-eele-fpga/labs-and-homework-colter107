library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity pattern3 is
    port (
        clk_in      : in std_ulogic;
        rst         : in std_ulogic;
        pattern3_out : out std_ulogic_vector(6 downto 0)
    );
end entity pattern3;


architecture pattern3_arch of pattern3 is
    signal pattern3_unsigned : unsigned(6 downto 0);
begin
    update_pattern : process(clk_in, rst)
    begin
        if(rst = '1') then
            pattern3_out <= "1111111"; 
            pattern3_unsigned <= "1111111";
        else
            if(rising_edge(clk_in))then
                if(pattern3_unsigned = 0) then
                    pattern3_unsigned <= (others => '1');
                end if; 
                pattern3_unsigned <= pattern3_unsigned - 1;
                pattern3_out <= std_ulogic_vector(pattern3_unsigned); 
            end if;
        end if;
    end process update_pattern;
end architecture pattern3_arch;