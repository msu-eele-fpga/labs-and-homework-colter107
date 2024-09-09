-- Copyright 2016 Ricardo Jasinski
-- from the book Effective Coding with VHDL by Ricardo Jasinski
-- SPDX-License-Identifier: CC0-1.0
-- CC0 1.0 Universal (CC0 1.0) Public Domain Dedication 
--  Summary: https://creativecommons.org/publicdomain/zero/1.0/ 
--  Full text: https://creativecommons.org/publicdomain/zero/1.0/legalcode
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

-- Routines to help output text at a higher level of abstraction.
package print_pkg is
    procedure print(value: string);
    procedure print(value: boolean);
    procedure print(value: real);
    procedure print(value: integer);
    procedure print_vector(vector: integer_vector);
    procedure print_vector(vector: real_vector);
    procedure print_vector(vector: std_logic_vector);
    procedure print_vector(vector: bit_vector);
    procedure print_vector(vector: signed);
    procedure print_vector(vector: unsigned);
end;

package body print_pkg is

    procedure print(value: string) is
        variable s: line;
    begin
        write(s, value);
        writeline(output,s);
    end;

    procedure print(value: boolean) is begin
        -- synthesis translate_off
        print(to_string(value));
        -- synthesis translate_on
    end;

    procedure print(value: real) is begin
        -- synthesis translate_off
        print(to_string(value));
        -- synthesis translate_on
    end;

    procedure print(value: integer) is begin
        -- synthesis translate_off
        print(to_string(value));
        -- synthesis translate_on
    end;

    procedure print_vector(vector: integer_vector) is
        variable current_line: line;
    begin
        -- synthesis translate_off
        for i in vector'range loop
            write(current_line, to_string(vector(i)) & " ");
        end loop;
        print("");
        -- synthesis translate_on
    end;

    procedure print_vector(vector: real_vector) is
        variable current_line: line;
    begin
        -- synthesis translate_off
        for i in vector'range loop
            write(current_line, to_string(vector(i)) & " ");
        end loop;
        print("");
        -- synthesis translate_on
    end;

    procedure print_vector(vector: std_logic_vector) is
        variable current_line: line;
    begin
        -- synthesis translate_off
        for i in vector'range loop
            write(current_line, to_string(vector(i)) & " ");
        end loop;
        print("");
        -- synthesis translate_on
    end;

    procedure print_vector(vector: bit_vector) is
        variable current_line: line;
    begin
        -- synthesis translate_off
        for i in vector'range loop
            write(current_line, to_string(vector(i)) & " ");
        end loop;
        print("");
        -- synthesis translate_on
    end;

    procedure print_vector(vector: unsigned) is
        variable current_line: line;
    begin
        -- synthesis translate_off
        for i in vector'range loop
            write(current_line, to_string(vector(i)) & " ");
        end loop;
        print("");
        -- synthesis translate_on
    end;

    procedure print_vector(vector: signed) is
        variable current_line: line;
    begin
        -- synthesis translate_off
        for i in vector'range loop
            write(current_line, to_string(vector(i)) & " ");
        end loop;
        print("");
        -- synthesis translate_on
    end;

end;
