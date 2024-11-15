library ieee;
use ieee.std_logic_1164.all;
use ieee.NUMERIC_STD.all;
use work.print_pkg.all;
use work.assert_pkg.all;
use work.tb_pkg.all;

entity PWM_controller_TB is
end entity;

architecture testbench of PWM_controller_TB is
    signal clk_tb               : std_ulogic := '0';
    signal rst_tb               : std_ulogic := '0';
    signal period_tb            : std_ulogic_vector (26 downto 0) := "00000000000000000000000000";
    signal duty_cycle_tb        : std_ulogic_vector (14 downto 0) := "000000000000000";
    
begin

end architecture; 