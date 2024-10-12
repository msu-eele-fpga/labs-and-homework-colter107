library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity Clock_generation is
    generic(
        half_period_width : natural
    );
    port (
        clk_in             : in std_ulogic;
        rst                : in std_ulogic;
        half_period_cycles : in unsigned(half_period_width downto 0);
        clk_out            : out std_ulogic 
    );
end entity Clock_generation;

architecture Clock_gen_arch of Clock_Generation is
signal counter : unsigned(half_period_width downto 0) := (others => '0');
signal clk : std_ulogic := '0';
begin
   clock_gen : process(clk_in,rst)
   begin
        if(rst = '1') then
            clk_out <= '0';
            counter <= (others => '0');
        else
            if(rising_edge(clk_in))then
                if(counter = half_period_cycles) then
                    clk <= not clk;
                    counter <= (others => '0');
                else
                    counter <= counter + 1;
                    clk <= clk;
                end if;
                clk_out <= clk;
            end if;
        end if;
	
   end process clock_gen;

end architecture;