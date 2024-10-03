library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity pattern3 is
    port (
        clk_in      : in std_ulogic;
        rst         : in std_ulogic;
        pattern3_out : out unsigned(6 downto 0)
    );
end entity pattern3;


architecture pattern3_arch of pattern3 is
begin
    update_pattern : process(clk_in, rst)
    begin
        if(rst = '1') then
            pattern3_out <= (others => '1'); 
        else
            if(pattern3_out = "0000000") then
                pattern3_out <= (others => '1');
            end if; 
            pattern3_out <= pattern3_out - 1; 
        end if;
    end process update_pattern;
end architecture pattern3_arch;