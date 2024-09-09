-- Copyright 2016 Ricardo Jasinski
-- from the book Effective Coding with VHDL by Ricardo Jasinski
-- Copyright 2024 Trevor Vannoy
-- SPDX-License-Identifier: CC0-1.0
-- CC0 1.0 Universal (CC0 1.0) Public Domain Dedication 
--  Summary: https://creativecommons.org/publicdomain/zero/1.0/ 
--  Full text: https://creativecommons.org/publicdomain/zero/1.0/legalcode

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.float_pkg.all;

-- Routines to help write testbenches at a higher level of abstraction
package assert_pkg is
    constant REAL_DELTA_MAX: real := 0.001;
    constant FLOAT_DELTA_MAX: real := 0.001;

    procedure assert_true(expr: boolean; msg: string);
    procedure assert_false(expr: boolean; msg: string);
    procedure assert_eq(actual, expected: std_logic; msg: string);
    procedure assert_eq(actual, expected: integer; msg: string);
    procedure assert_eq(actual, expected: std_logic_vector; msg: string);
    procedure assert_eq(actual, expected: unsigned; msg: string);
    procedure assert_that(msg: string; expr: boolean);
    procedure assert_that(msg: string; expr: std_logic);
    procedure assert_that(msg: string; actual, expected: std_logic);
    procedure assert_that(msg: string; actual, expected: std_logic_vector);
    procedure assert_that(msg: string; actual, expected: unsigned);
    procedure assert_that(msg: string; actual, expected: integer);
    procedure assert_that(msg: string; actual, expected, tolerance: real := REAL_DELTA_MAX);
    procedure assert_that(msg: string; actual, expected: float; tolerance: real := FLOAT_DELTA_MAX);

end;

package body assert_pkg is

    procedure assert_true(expr: boolean; msg: string) is begin
        assert_that(msg, expr);
    end;

    procedure assert_false(expr: boolean; msg: string) is begin
        assert_that(msg, not expr);
    end;

    procedure assert_eq(actual, expected: integer; msg: string) is begin
        assert_that(msg, actual, expected);
    end;

    procedure assert_eq(actual, expected: std_logic; msg: string) is begin
        assert_that(msg, actual, expected);
    end;

    procedure assert_eq(actual, expected: std_logic_vector; msg: string) is begin
        assert_that(msg, actual, expected);
    end;

    procedure assert_eq(actual, expected: unsigned; msg: string) is begin
        assert_that(msg, actual, expected);
    end;

    procedure assert_that(msg: string; expr: boolean) is begin
        assert expr report "error in test case '" & msg & "'" severity failure;
        if expr then
        end if;
    end;

    procedure assert_that(msg: string; expr: std_logic) is begin
        assert_that(msg, ?? expr);
    end;

    function character_from_std_ulogic(value: std_ulogic) return character is
        type conversion_array_type is array (std_ulogic) of character;
        constant CONVERSION_ARRAY: conversion_array_type := (
            'U' => 'U', 'X' => 'X', '0' => '0', '1' => '1',
            'Z' => 'Z', 'W' => 'W', 'L' => 'L', 'H' => 'H', '-' => '-'
        );
    begin
        return CONVERSION_ARRAY(value);
    end;

    function string_from_std_logic_vector(vector : std_logic_vector) return string is
        variable vector_string : string(1 to vector'length);
    begin
        for i in vector'range loop
            vector_string(i + 1) := character_from_std_ulogic(vector(i));
        end loop;
        return vector_string;
    end;

    procedure assert_that(msg : string; actual, expected: std_logic) is
    begin
        if (actual /= expected) then
            report "error in test case '" & msg & "'" & LF & "     " &
            "actual: " & to_string(actual) & ", " &
            "expected: " & to_string(expected)
            severity failure;
        end if;
    end;

    procedure assert_that(msg : string; actual, expected: std_logic_vector) is
    begin
        if (actual /= expected) then
            report "error in test case '" & msg & "'" & LF & "     " &
            "actual: " & string_from_std_logic_vector(actual) & ", " &
            "expected: " & string_from_std_logic_vector(expected)
            severity failure;
        end if;
    end;

    procedure assert_that(msg : string; actual, expected: unsigned) is
    begin
        if (actual /= expected) then
            report "error in test case '" & msg & "'" & LF & "     " &
            "actual: " & to_string(actual) & ", " &
            "expected: " & to_string(expected)
            severity failure;
        end if;
    end;

    procedure assert_that(msg : string; actual, expected: integer) is
    begin
        if (actual /= expected) then
            report "error in test case '" & msg & "'" & LF & "     " &
            "actual: " & to_string(actual) & ", " &
            "expected: " & to_string(expected)
            severity failure;
        end if;
    end;

    procedure assert_that(msg : string; actual, expected, tolerance: real := REAL_DELTA_MAX) is begin

        -- we need to check with "<=" because the default comparison result for
        -- metavalues is 'false'; otherwise, whenever a value were 'X' the test would pass
        if (abs(actual - expected) <= tolerance) then
            return;
        end if;

        report "error in test case '" & msg & "'" & LF & "     " &
            "actual: " & to_string(actual) & ", " &
            "expected: " & to_string(expected)
            severity failure;
    end;

    procedure assert_that(msg: string; actual, expected: float; tolerance: real := FLOAT_DELTA_MAX) is begin

        -- we need to check with "<=" because the default comparison result for
        -- metavalues is 'false'; otherwise, whenever a value were 'X' the test would pass
        if (abs(actual - expected) <= tolerance) then
            return;
        end if;

        report "error in test case '" & msg & "'" & LF & "     " &
            "actual: " & to_string(to_real(actual)) & ", " &
            "expected: " & to_string(to_real(expected))
            severity failure;
    end;

end;
