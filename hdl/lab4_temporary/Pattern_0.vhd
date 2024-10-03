library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity pattern0 is
    port (
        clk_in      : in std_ulogic;
        rst         : in std_ulogic;
        pattern0_out : out std_ulogic_vector(6 downto 0)
    );
end entity pattern0;


architecture pattern0_arch of pattern0 is
    signal pattern0_unsigned : unsigned(6 downto 0);
begin
    update_pattern : process(clk_in, rst)
    begin
        if(rst = '1') then
            pattern0_unsigned <= (others => '0') + 1; 
        else
            pattern0_unsigned <= pattern0_unsigned srl 1;
            if(pattern0_unsigned = "0000000") then
                pattern0_unsigned(6) <= '1';
            end if;  
        end if;
        pattern0_out <= std_ulogic_vector(pattern0_unsigned);
    end process update_pattern;
end architecture pattern0_arch;