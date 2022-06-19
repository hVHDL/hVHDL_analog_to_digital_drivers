LIBRARY ieee  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    use ieee.math_real.all;

library vunit_lib;
context vunit_lib.vunit_context;

    use work.sigma_delta_simulation_model_pkg.all;
    use work.sigma_delta_cic_filter_pkg.all;

entity sigma_delta_filter_tb is
  generic (runner_cfg : string);
end;

architecture vunit_simulation of sigma_delta_filter_tb is

    constant clock_period      : time    := 1 ns;
    constant simtime_in_clocks : integer := 15000;
    
    signal simulator_clock     : std_logic := '0';
    signal simulation_counter  : natural   := 0;
    -----------------------------------
    -- simulation specific signals ----

    signal sigma_delta_model : sdm_model_record := init_sdm_model;

------------------------------------------------------------------------
    function "+"
    (
        left, right : integer
    )
    return integer
    is
    begin
        return to_integer(to_signed(left,17) + to_signed(right,17));
    end "+";
------------------------------------------------------------------------
    function "-"
    (
        left, right : integer
    )
    return integer
    is
    begin
        return to_integer(to_signed(left,17) - to_signed(right,17));
    end "-";
------------------------------------------------------------------------
    signal counter : integer := 0;
    signal output : integer := 0;

    type integer_array is array (integer range 0 to 2) of integer range -2**16 to 2**16-1;

    signal integrator : integer_array := (0,0,0);
    signal derivator : integer_array := (0,0,0);

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

    signal filter_output : real := 0.0;
    signal input_to_cic_filter : real := 0.0;

begin

------------------------------------------------------------------------
    simtime : process
    begin
        test_runner_setup(runner, runner_cfg);
        wait for simtime_in_clocks*clock_period;
        test_runner_cleanup(runner); -- Simulation ends here
        wait;
    end process simtime;	

    simulator_clock <= not simulator_clock after clock_period/2.0;
------------------------------------------------------------------------

    stimulus : process(simulator_clock)

    begin
        if rising_edge(simulator_clock) then
            simulation_counter <= simulation_counter + 1;

            create_sdm_model(sigma_delta_model, input_to_cic_filter);
            request_sdm_model_calculation(sigma_delta_model);

            filter_output <= real(output)/32768.0;

            if sdm_model_is_ready(sigma_delta_model) then
                calculate_cic_filter(integrator, derivator, counter, output, get_sdm_output(sigma_delta_model));
            end if;

            input_to_cic_filter <= 0.009 * sin((real(simulation_counter)/5500.0*2.0*math_pi) mod (2.0*math_pi));
            if simulation_counter > 7000 and simulation_counter < 8000 then
                input_to_cic_filter <= -0.9;
            end if;

        end if; -- rising_edge
    end process stimulus;	
------------------------------------------------------------------------
end vunit_simulation;
