-- Copyright 2106 Ricardo Jasinski
-- from the book Effective Coding with VHDL by Ricardo Jasinski
-- SPDX-License-Identifier: CC0-1.0
-- CC0 1.0 Universal (CC0 1.0) Public Domain Dedication
--  Summary: https://creativecommons.org/publicdomain/zero/1.0/
--  Full text: https://creativecommons.org/publicdomain/zero/1.0/legalcode
-- Modified by Trevor Vannoy; Copyright 2024
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.assert_pkg.all;
use work.print_pkg.all;
use work.tb_pkg.all;

entity vending_macine_tb is
end entity vending_macine_tb;

architecture testbench of vending_macine_tb is

  signal clk_tb      : std_ulogic := '0';
  signal rst_tb      : std_ulogic := '0';
  signal nickel_tb   : std_ulogic := '0';
  signal dime_tb     : std_ulogic := '0';
  signal dispense_tb : std_ulogic;
  signal amount_tb   : natural range 0 to 15;

  type coins_transaction_type is record
    nickels : std_logic_vector(1 to 5);
    dimes   : std_logic_vector(1 to 5);
  end record coins_transaction_type;

  signal transaction_data : coins_transaction_type;
  signal transaction_done : boolean;

begin

  duv : entity work.vending_machine
    port map (
      clk      => clk_tb,
      rst      => rst_tb,
      nickel   => nickel_tb,
      dime     => dime_tb,
      dispense => dispense_tb,
      amount   => amount_tb
    );

  clk_tb <= not clk_tb after CLK_PERIOD / 2;
  rst_tb <= '1', '0' after 50 ns;

  stimuli_generator : process is

    variable seq : std_logic_vector(1 to 10);

  begin

    wait until not rst_tb;

    -- Generate all possible 10-bit sequences
    for i in 0 to (2 ** 10) - 1 loop
      seq := std_logic_vector(to_unsigned(i, 10));

      -- Break down each 10-bit sequence into sequences of nickels and dimes
      -- A sequence of five coins is enough to cover all state transitions
      transaction_data <= (nickels => seq(1 to 5), dimes => seq(6 to 10));

      -- Wait until the current transaction from the driver process is done
      -- before creating the next input stimuli.
      wait on transaction_done'transaction;
    end loop;

    print("End of testbench.");
    std.env.finish;

  end process stimuli_generator;

  driver : process is
  begin

    -- Wait until a new sequence of coins is ready
    wait on transaction_data'transaction;

    for i in 1 to 5 loop
      -- Assign the coins to the DUV
      nickel_tb <= transaction_data.nickels(i);
      dime_tb   <= transaction_data.dimes(i);

      wait_for_clock_edge(clk_tb);
    end loop;

    -- Signal to the stimuli_generator process that we are done
    -- stimulating the vending machine.
    transaction_done <= true;

  end process driver;

  response_checker : process is

    variable amount_predicted   : natural range 0 to 15;
    variable dispense_predicted : std_logic;

  begin

    -- We want to check the state machine outputs after each clock edge.
    wait_for_clock_edge(clk_tb);

    -- Predictor for the 'amount' output
    if rst_tb = '1' or amount_predicted = 15 then
      amount_predicted := 0;
    elsif dime_tb then
      amount_predicted := minimum(amount_predicted + 10, 15);
    elsif nickel_tb then
      amount_predicted := amount_predicted + 5;
    end if;

    -- Predictor for the 'dispense' output
    dispense_predicted := '1' when amount_tb = 15 else '0';

    -- Comparator - assert that DUV outputs and predictor outputs match
    assert_eq(amount_tb, amount_predicted, "amount is as expected");
    assert_eq(dispense_tb, dispense_predicted, "dispense is as expected");

  end process response_checker;

end architecture testbench;
