library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity Clock_generation is
    generic(
        multipier   : in unsigned(7 downto 0) --fixed point
    );
    port (
        clk_in             : in std_ulogic;
        rst             : in std_ulogic;
        base_period     : in unsigned(7 downto 0);
        led             : out std_ulogic_vector(7 downto 0) 
    );
end entity Clock_generation;