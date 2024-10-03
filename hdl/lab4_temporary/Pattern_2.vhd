library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity pattern2 is
    port (
        clk_in      : in std_ulogic;
        rst         : in std_ulogic;
        pattern2_out :out std_ulogic_vector(6 downto 0)
    );
end entity pattern2;


architecture pattern2_arch of pattern2 is
    signal pattern2_unsigned : unsigned(6 downto 0);
begin
    update_pattern : process(clk_in, rst)
    begin
        if(rst = '1') then
            pattern2_unsigned <= (others => '0'); 
        else
            if(pattern2_unsigned = "1111111") then
                pattern2_unsigned <= (others => '0');
            end if; 
            pattern2_unsigned <= pattern2_unsigned + 1; 
        end if;
        pattern2_out <= std_ulogic_vector(pattern2_unsigned);
    end process update_pattern;
end architecture pattern2_arch;