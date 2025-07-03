library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package sigma_delta_cic_filter_pkg is

    -- currently only 32 cycle downsampling is supported
    constant wordlength : integer := 16;
    subtype sdm_integer is integer range -2**15 to 2**15-1;
    type integer_array is array (integer range 0 to 2) of integer range -2**(wordlength-1) to 2**(wordlength-1)-1;
    constant init_integer_array : integer_array := (0,0,0);

    type cic_filter_record is record
        integrator_array   : integer_array;
        derivator_array    : integer_array;
        decimation_counter : integer range 0 to 255;
        output_signal      : sdm_integer;
    end record;

    constant init_cic_filter : cic_filter_record := (init_integer_array, init_integer_array, 0, 0);

    procedure calculate_cic_filter (
        signal self : inout cic_filter_record;
        input_bit : in std_logic);

    function get_cic_filter_output ( cic_filter_object : cic_filter_record)
        return integer;

    procedure calculate_cic_filter (
        signal integrator_array   : inout integer_array;
        signal derivator_array    : inout integer_array;
        signal decimation_counter : inout integer range 0 to 255;
        signal output_signal      : out sdm_integer;
        input_bit                 : in integer);

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
    procedure calculate_cic_filter (
        signal integrator_array   : inout integer_array;
        signal derivator_array    : inout integer_array;
        signal decimation_counter : inout integer range 0 to 255;
        signal output_signal      : out sdm_integer;
        input_bit                 : in integer
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
            output_signal      <= (derivators(0) - derivator_array(0) - derivator_array(1) - derivator_array(2));
        end if;
    end calculate_cic_filter;
------------------------------------------------------------------------
    procedure calculate_cic_filter
    (
        signal self : inout cic_filter_record;
        input_bit : in std_logic
    ) is

        variable input_data : unsigned(0 downto 0);

    begin

        input_data(0) := input_bit;
        calculate_cic_filter(
            self.integrator_array   ,
            self.derivator_array    ,
            self.decimation_counter ,
            self.output_signal      ,
            to_integer(input_data)*2-1);
        
    end calculate_cic_filter;
------------------------------------------------------------------------
    function get_cic_filter_output
    (
        cic_filter_object : cic_filter_record
    )
    return integer
    is
    begin
        return cic_filter_object.output_signal;
    end get_cic_filter_output;
------------------------------------------------------------------------
end package body sigma_delta_cic_filter_pkg;
