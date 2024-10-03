library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity pattern0 is
    port (
        clk_in      : in std_ulogic;
        rst         : in std_ulogic;
        pattern0_out : out unsigned(6 downto 0)
    );
end entity pattern0;


architecture pattern0_arch of pattern0 is
begin
    update_pattern : process(clk_in, rst)
    begin
        if(rst = '1') then
            pattern0_out <= (others => '0') + 1; 
        else
            pattern0_out <= pattern0_out srl 1;
            if(pattern0_out = "0000000") then
                pattern0_out(6) <= '1';
            end if;  
        end if;
    end process update_pattern;
end architecture pattern0_arch;