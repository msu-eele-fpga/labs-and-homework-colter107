# Common files and packages for simulations

This folder contains packages that are used in most testbenches.

- `assert_pkg.vhd`: Package that makes writing test assertions easier. This package follows the conventions of many unit-testing frameworks.
- `print_pkg.vhd`: Package that makes priting messages and values easier.

To use any of the packages contained here
1. add them to your Questa project (referencing the files from their current location, not copying them to the project)
2. include them with a `use` clause, e.g.
    ```vhdl
    use work.assert_pkg.all;
    ```
