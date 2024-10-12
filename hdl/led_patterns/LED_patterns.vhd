library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity LED_patterns is
    generic (
        system_clock_period : time := 20 ns
    );
    port (
        clk             : in std_ulogic;
        rst             : in std_ulogic;
        push_button     : in std_ulogic;
        switches        : in std_ulogic_vector(3 downto 0);
        hps_led_control : in boolean;
        base_period     : in unsigned(7 downto 0);
        led_reg         : in std_ulogic_vector(7 downto 0);
        led             : out std_ulogic_vector(7 downto 0) 
    );
end entity led_patterns;

architecture LED_patterns_arch of LED_patterns is

    --Number of bits used to store the system clock frequency as unsinged int
    constant system_clock_freq_num_bits : natural := natural(ceil(log2(real(1 sec / system_clock_period))));

    --System clock frequency
    constant system_clock_freq : unsigned(system_clock_freq_num_bits - 1 downto 0) := TO_UNSIGNED((1 sec / system_clock_period), system_clock_freq_num_bits);

    --Number of bits needed to represent system clock frequency * base period
    --This has fractional bits, but we can't have fractional clock cycles
    constant clock_cycles_num_bits_total : natural := system_clock_freq_num_bits + 8;

    --Number of bits needed to represent system clock frequency * base period
    --No fractional bits :D
    constant clock_cycles_num_bits_whole : natural := system_clock_freq_num_bits + 4;

    --Number of clock cycles in one base period
    --This has fractional bits, but we can't have fractional clock cycles
    signal base_period_clk_cycles_full : unsigned(clock_cycles_num_bits_total - 1 downto 0);

    --Number of whole clock cycles in one base period
    --No fractional bits :D
    signal base_period_clk_cycles : unsigned(clock_cycles_num_bits_whole - 1 downto 0);

    --Number of whole clock cycles in 1/8, 1/4, 1/2, and 2x clock period
    --Since we are only dealing with whole clock cycles, fractional bits are ignored and thus don't need to be updated
    signal clk_cycles_sixteenth : unsigned(base_period_clk_cycles'length - 1 downto 0);
    signal clk_cycles_eighth : unsigned(base_period_clk_cycles'length - 1 downto 0);
    signal clk_cycles_fourth : unsigned(base_period_clk_cycles'length - 1 downto 0);
    signal clk_cycles_half : unsigned(base_period_clk_cycles'length - 1 downto 0);
    signal clk_cycles_double : unsigned(base_period_clk_cycles'length - 1 downto 0);

    --Number of clock cycles in one second (equal to the clock frequency) 
    constant one_second : time := 1 sec;
    signal one_sec_en : boolean := false;


    --State machine states
    type state_type is 
        (SWITCH_IN, S_PATTERN0, S_PATTERN1, S_PATTERN2, S_PATTERN3, S_PATTERN4); 
    signal previous_state, current_state, next_state : state_type;
    
    --LED FSM outputs
    signal led_fsm_out : std_ulogic_vector (7 downto 0);
    signal led7 : std_ulogic;
    signal pattern0_LEDS : STD_ULOGIC_VECTOR(6 downto 0) := "0000000";
    signal pattern1_LEDS : STD_ULOGIC_VECTOR(6 downto 0) := "0000000";
    signal pattern2_LEDS : STD_ULOGIC_VECTOR(6 downto 0) := "0000000";
    signal pattern3_LEDS : STD_ULOGIC_VECTOR(6 downto 0) := "0000000";
    signal pattern4_LEDS : STD_ULOGIC_VECTOR(6 downto 0) := "0000000";

    --Timer for transition from switch in state to led pattern
    signal timer_flag_1sec : boolean;
    
    signal push_button_conditioned : STD_ULOGIC;

    
    constant half_period_length   	: natural := base_period_clk_cycles'length - 1;
    signal half_period              : unsigned(half_period_length downto 0);
    signal half_period_sixteenth    : unsigned(half_period_length downto 0);
    signal half_period_eighth 		: unsigned(half_period_length downto 0);
    signal half_period_fourth   	: unsigned(half_period_length downto 0);
    signal half_period_half     	: unsigned(half_period_length downto 0);
    signal half_period_double    	: unsigned(half_period_length downto 0);

    signal clk_base     : STD_ULOGIC := '0';
    signal clk_pattern0 : STD_ULOGIC := '0';
    signal clk_pattern1 : STD_ULOGIC := '0';
    signal clk_pattern2 : STD_ULOGIC := '0';
    signal clk_pattern3 : STD_ULOGIC := '0';
    signal clk_pattern4 : STD_ULOGIC := '0';

    --Timed counter for switch in state
    component timed_counter is
        generic (
            clk_period : time;
            count_time : time
        );
        port (
            clk : in std_ulogic;
            enable : in boolean;
            done : out boolean
        );
    end component timed_counter;

    --Clock generator for LED patterns
    component Clock_Generation is 
        generic(
            half_period_width : natural
        );
        port (
            clk_in             : in std_ulogic;
            rst                : in std_ulogic;
            half_period_cycles : in unsigned(half_period_width downto 0);
            clk_out            : out std_ulogic 
        );
    end component Clock_generation;
    
   --LED Pattern 0 generator
   component pattern0 is
    port (
        clk_in      : in std_ulogic;
        rst         : in std_ulogic;
        pattern0_out : out std_ulogic_vector(6 downto 0)
    );
    end component pattern0;

    --LED Pattern 1 generator
    component pattern1 is
        port (
            clk_in      : in std_ulogic;
            rst         : in std_ulogic;
            pattern1_out : out std_ulogic_vector(6 downto 0)
        );
    end component pattern1;

    --LED Pattern 2 generator
    component pattern2 is
        port (
            clk_in      : in std_ulogic;
            rst         : in std_ulogic;
            pattern2_out : out std_ulogic_vector(6 downto 0)
        );
    end component pattern2;

    --LED Pattern 3 generator
    component pattern3 is
        port (
            clk_in      : in std_ulogic;
            rst         : in std_ulogic;
            pattern3_out : out std_ulogic_vector(6 downto 0)
        );
    end component pattern3;

    --LED Pattern 4 generator
    component pattern4 is
       port (
            clk_in      : in std_ulogic;
            rst         : in std_ulogic;
            pattern4_out : out std_ulogic_vector(6 downto 0)
        );
    end component pattern4;

    component async_conditioner is
        port (
            clk     : in std_ulogic;
            rst     : in std_ulogic;
            async   : in std_ulogic;
            sync   : out std_ulogic
        );
    end component async_conditioner;

    --signal tap keep signals
    signal one_sec_en_bit : std_ulogic;
    attribute keep : boolean;
	 attribute keep of push_button_conditioned: signal is true;
    attribute keep of current_state: signal is true;
    attribute keep of led_fsm_out  : signal is true;
    attribute keep of pattern0_LEDS: signal is true;
    attribute keep of pattern1_LEDS: signal is true;
    attribute keep of pattern2_LEDS: signal is true;
    attribute keep of pattern3_LEDS: signal is true;
    attribute keep of pattern4_LEDS: signal is true;
    attribute keep of clk_pattern4 : signal is true;

begin

    
    --Assign number of clock cycles in base period
    base_period_clk_cycles_full <= system_clock_freq * base_period;

    --Remove fractional component
    base_period_clk_cycles <= base_period_clk_cycles_full(clock_cycles_num_bits_total - 1 downto 4);
    clk_cycles_sixteenth <= base_period_clk_cycles srl 4;
    clk_cycles_eighth <= base_period_clk_cycles srl 3;
    clk_cycles_fourth <= base_period_clk_cycles srl 2;
    clk_cycles_half <= base_period_clk_cycles srl 1;
    clk_cycles_double <= base_period_clk_cycles sll 1;

    half_period <= base_period_clk_cycles srl 1;
    half_period_sixteenth <= clk_cycles_sixteenth srl 1;
    half_period_eighth <= clk_cycles_eighth srl 1;
    half_period_fourth <= clk_cycles_fourth srl 1;
    half_period_half <= clk_cycles_half srl 1;
    half_period_double <= clk_cycles_double srl 1;

    base_clk : Clock_Generation
    generic map(
        half_period_width => half_period_length
    ) port map (
        clk_in => clk,
        rst => rst,
        half_period_cycles => half_period,
        clk_out => clk_base
    );

    pattern0_clk : Clock_Generation
    generic map(
       half_period_width => half_period_length
    )
    port map(
       clk_in => clk,
       rst => rst,
       half_period_cycles => half_period_half,
       clk_out => clk_pattern0
   );

   pattern1_clk : Clock_Generation
    generic map(
       half_period_width => half_period_length
    )
    port map(
       clk_in => clk,
       rst => rst,
       half_period_cycles => half_period_fourth,
       clk_out => clk_pattern1
   );

   pattern2_clk : Clock_Generation
    generic map(
       half_period_width => half_period_length
    )
    port map(
       clk_in => clk,
       rst => rst,
       half_period_cycles => half_period_double,
       clk_out => clk_pattern2
   );

   pattern3_clk : Clock_Generation
    generic map(
       half_period_width => half_period_length
    )
    port map(
       clk_in => clk,
       rst => rst,
       half_period_cycles => half_period_eighth,
       clk_out => clk_pattern3
   );

   pattern4_clk : Clock_Generation
    generic map(
       half_period_width => half_period_length
    )
    port map(
       clk_in => clk,
       rst => rst,
       half_period_cycles => half_period_sixteenth,
       clk_out => clk_pattern4
   );

   switch_in_timer : timed_counter
    generic map(
        clk_period => system_clock_period,
        count_time => one_second
    )
    port map (
        clk => clk,
        enable => one_sec_en,
        done => timer_flag_1sec
    );


    --LED Pattern 0 generator
   pattern0_gen : pattern0 
    port map(
        clk_in          => clk_pattern0,
        rst             => rst,
        pattern0_out    => pattern0_LEDS
    );

   --LED Pattern 1 generator
   pattern1_gen : pattern1 
   port map(
       clk_in          => clk_pattern1,
       rst             => rst,
       pattern1_out    => pattern1_LEDS
   );

    --LED Pattern 2 generator
    pattern2_gen : pattern2 
    port map(
        clk_in          => clk_pattern2,
        rst             => rst,
        pattern2_out    => pattern2_LEDS
    );

     --LED Pattern 3 generator
   pattern3_gen : pattern3 
   port map(
       clk_in          => clk_pattern3,
       rst             => rst,
       pattern3_out    => pattern3_LEDS
   );

    --LED Pattern 4 generator
    pattern4_gen : pattern4 
    port map(
        clk_in          => clk_pattern4,
        rst             => rst,
        pattern4_out    => pattern4_LEDS
    );

    pb_conditioner: async_conditioner
        port map(
            clk     => clk,
            rst     => rst,
            async   => push_button,
            sync    => push_button_conditioned
        );



    state_memory : process (clk, rst)
    begin
        if (rst = '1') then
            current_state <= S_PATTERN0;
        elsif (rising_edge(Clk)) then
            current_state <= next_state;
        end if;
    end process;

    next_state_logic : process (clk, rst)
    begin
        if(rst = '0') then
            if(rising_edge(clk)) then
                if(push_button_conditioned = '1') then
                    next_state <= SWITCH_IN;
                elsif(timer_flag_1sec) then 
                    case (switches) is 
                        when "0000" => next_state <= S_PATTERN0;
                        when "0001" => next_state <= S_PATTERN1;
                        when "0010" => next_state <= S_PATTERN2;
                        when "0011" => next_state <= S_PATTERN3;
                        when "0100" => next_state <= S_PATTERN4;
                        when others => next_state <= previous_state;
                    end case;      
                end if;
            end if;
        else
            next_state <= S_PATTERN0;
        end if;
    
    end process;

    output_logic : process (clk,rst)
    begin
        if(rst = '0') then
            if(rising_edge(clk)) then
                case(current_state) is 
                    when(SWITCH_IN) =>
                        led_fsm_out(6 downto 0) <= "000" & switches;
                        one_sec_en <= true;
                    when(S_PATTERN0) =>
                        led_fsm_out(6 downto 0) <= pattern0_LEDS;
                        one_sec_en <= false;
                        previous_state <= S_PATTERN0;
                    when(S_PATTERN1) =>
                        led_fsm_out(6 downto 0) <= pattern1_LEDS;
                        one_sec_en <= false;
                        previous_state <= S_PATTERN1;
                    when(S_PATTERN2) =>
                        led_fsm_out(6 downto 0) <= pattern2_LEDS;
                        one_sec_en <= false;
                        previous_state <= S_PATTERN2;
                    when(S_PATTERN3) =>
                        led_fsm_out(6 downto 0) <= pattern3_LEDS;
                        one_sec_en <= false;
                        previous_state <= S_PATTERN3;
                    when(S_PATTERN4) =>
                        led_fsm_out(6 downto 0) <= pattern4_LEDS;
                        one_sec_en <= false;
                        previous_state <= S_PATTERN4;
                    when others =>
                        led_fsm_out(6 downto 0) <= "0101010";
                        one_sec_en <= false;
                end case;
            end if;
        else
            led_fsm_out(6 downto 0) <= "0000000";
            one_sec_en <= false;
            previous_state <= S_PATTERN0;
        end if;

    end process output_logic;

    control_decision : process(clk, rst)
    begin
        if(rst = '0' ) then 
            if(rising_edge(clk)) then
                if hps_led_control then
                    LED <= led_fsm_out;
                else
                    LED <= led_reg;
                end if;
            end if;
        else
            LED <= "00000000";
        end if;
    end process control_decision;

    update_LED7 : process(clk_base, rst)
    begin
        if(rst = '0') then
            if(rising_edge(clk_base)) then
                LED7 <= not LED7;
            end if;
        else
            LED7 <= '0';
        end if;
        if(rising_edge(clk_base))then
            led_fsm_out(7) <= led7;
        end if;
    end process update_LED7;

    update_bool_logic : process(clk)
    begin
        if(rising_edge(clk)) then
            if(one_sec_en) then
                one_sec_en_bit <= '1';
            else
                one_sec_en_bit <= '0';
            end if;
        end if;
    end process update_bool_logic;

end architecture;