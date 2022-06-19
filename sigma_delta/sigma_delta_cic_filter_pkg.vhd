library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package sigma_delta_cic_filter_pkg is

    constant wordlength : integer := 23;
    type integer_array is array (integer range 0 to 2) of integer range -2**(wordlength-1) to 2**(wordlength-1)-1;

    procedure calculate_cic_filter (
        signal integrator_array : inout integer_array;
        signal derivator_array : inout integer_array;
        signal decimation_counter : inout integer;
        signal output_signal : out integer;
        input_bit : in integer);

end package sigma_delta_cic_filter_pkg;

package body sigma_delta_cic_filter_pkg is
------------------------------------------------------------------------
    function "+"
    (
        left, right : integer
    )
    return integer
    is
    begin
        return to_integer(to_signed(left,wordlength) + to_signed(right,wordlength));
    end "+";
------------------------------------------------------------------------
    function "-"
    (
        left, right : integer
    )
    return integer
    is
    begin
        return to_integer(to_signed(left,wordlength) - to_signed(right,wordlength));
    end "-";
------------------------------------------------------------------------
    procedure calculate_cic_filter
    (
        signal integrator_array : inout integer_array;
        signal derivator_array : inout integer_array;
        signal decimation_counter : inout integer;
        signal output_signal : out integer;
        input_bit : in integer
    ) is
        variable integrators : integer_array;
        variable derivators : integer_array;

    begin
        integrators(0) := integrator_array(0) + input_bit;
        integrators(1) := integrator_array(1) + integrators(0);
        integrators(2) := integrator_array(2) + integrators(1);

        integrator_array(0) <= integrators(0);
        integrator_array(1) <= integrators(1);
        integrator_array(2) <= integrators(2);

        if decimation_counter > 0 then
            decimation_counter <= decimation_counter - 1;
        else
            decimation_counter <= 31;
            derivators(0) := integrators(2);
            derivators(1) := derivators(0) - derivator_array(0);
            derivators(2) := derivators(1) - derivator_array(1);

            derivator_array(0) <= derivators(0);
            derivator_array(1) <= derivators(1);
            derivator_array(2) <= derivators(2);
            output_signal <= (derivators(0) - derivator_array(0) - derivator_array(1) - derivator_array(2));
        end if;
    end calculate_cic_filter;
------------------------------------------------------------------------


end package body sigma_delta_cic_filter_pkg;
