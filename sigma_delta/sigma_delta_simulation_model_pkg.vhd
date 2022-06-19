library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.all;

package sigma_delta_simulation_model_pkg is

    -- equation obtained from ti white paper How delta-sigma ADCs work, Part 1
    -- https://www.ti.com/lit/an/slyt423a/slyt423a.pdf

    type sdm_model_record is record
        calculation_requested : boolean;
        calculation_is_ready : boolean;
        integral1 : real;
        integral2 : real;
        output    : std_logic;
    end record;

    constant init_sdm_model : sdm_model_record := (false, false, 0.0,0.0,'0');
------------------------------------------------------------------------
    procedure create_sdm_model (
        signal sdm_model_object : inout sdm_model_record;
        input_to_sdm : in real);
------------------------------------------------------------------------
    function get_1bit_sdm_output ( sdm_model_object : sdm_model_record)
        return std_logic;
------------------------------------------------------------------------
    function "-" ( left : real; right : std_logic )
        return real;
------------------------------------------------------------------------
    procedure request_sdm_model_calculation (
        signal sdm_model_object : out sdm_model_record);
------------------------------------------------------------------------
    function sdm_model_is_ready ( sdm_model_object : sdm_model_record)
        return boolean;
------------------------------------------------------------------------

end package sigma_delta_simulation_model_pkg;



package body sigma_delta_simulation_model_pkg is
------------------------------------------------------------------------
------------------------------------------------------------------------
    function "-"
    (
        left : real; right : std_logic 
    )
    return real
    is
        variable returned_value : real;
    begin
        if right = '1' then
            returned_value := left - 1.0;
        else
            returned_value := left + 1.0;
        end if;
        return returned_value;
    end "-";
------------------------------------------------------------------------
    procedure create_sdm_model
    (
        signal sdm_model_object : inout sdm_model_record;
        input_to_sdm : in real
    ) is
        alias m is sdm_model_object;

    --------------------------------------------------
        function ">"
        (
            left, right : real
        )
        return std_logic 
        is
            variable return_value : std_logic;
        begin
            if left > right then
                return '1';
            else
                return '0';
            end if;
            
        end ">";
    --------------------------------------------------

        variable x1 : real;
        variable x2 : real;
        variable y  : std_logic;

    begin


        m.calculation_requested <= false;
        m.calculation_is_ready <= false;

        if m.calculation_requested then
            m.calculation_is_ready <= true;
            x1 := m.integral1 + input_to_sdm - m.output;
            x2 := m.integral2 + x1 - m.output;
            if x2 > 0.0 then
                y := '1';
            else
                y := '0';
            end if;

            m.integral1 <= x1;
            m.integral2 <= x2;
            m.output <= y;
        end if;
        
    end create_sdm_model;
------------------------------------------------------------------------
    function get_1bit_sdm_output
    (
        sdm_model_object : sdm_model_record
    )
    return std_logic 
    is
    begin
        return sdm_model_object.output;
    end get_1bit_sdm_output;
------------------------------------------------------------------------
    procedure request_sdm_model_calculation
    (
        signal sdm_model_object : out sdm_model_record
    ) is
    begin
        sdm_model_object.calculation_requested <= true;
        
    end request_sdm_model_calculation;
------------------------------------------------------------------------
    function sdm_model_is_ready
    (
        sdm_model_object : sdm_model_record
    )
    return boolean
    is
    begin
        return sdm_model_object.calculation_is_ready;
        
    end sdm_model_is_ready;
------------------------------------------------------------------------

end package body sigma_delta_simulation_model_pkg;

