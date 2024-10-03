library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity pattern2 is
    port (
        clk_in      : in std_ulogic;
        rst         : in std_ulogic;
        pattern2_out : out unsigned(6 downto 0)
    );
end entity pattern2;


architecture pattern2_arch of pattern2 is
begin
    update_pattern : process(clk_in, rst)
    begin
        if(rst = '1') then
            pattern2_out <= (others => '0'); 
        else
            if(pattern2_out = "1111111") then
                pattern2_out <= (others => '0');
            end if; 
            pattern2_out <= pattern2_out + 1; 
        end if;
    end process update_pattern;
end architecture pattern2_arch;