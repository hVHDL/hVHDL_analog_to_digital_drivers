LIBRARY ieee  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    use ieee.math_real.all;

library vunit_lib;
context vunit_lib.vunit_context;

    use work.sigma_delta_simulation_model_pkg.all;

entity delta_sigma_filtering_tb is
  generic (runner_cfg : string);
end;

architecture vunit_simulation of delta_sigma_filtering_tb is

    constant clock_period      : time    := 1 ns;
    constant simtime_in_clocks : integer := 50000;
    
    signal simulator_clock     : std_logic := '0';
    signal simulation_counter  : natural   := 0;
    -----------------------------------
    -- simulation specific signals ----

    signal sdm_model : sdm_model_record := init_sdm_model;
    signal sdm_io : std_logic := '0';
    signal sini : real := 0.0;

    type filter_array is array (integer range 0 to 3) of real;
    signal filters : filter_array := (0.0,0.0,0.0,0.0);

    constant filter_gain : real := 0.2;
    signal maximum_error : real := 0.0;
    signal demodulation_error : real := 0.0;

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

            create_sdm_model(sdm_model, sini);
            request_sdm_model_calculation(sdm_model);
            sdm_io <= sdm_model.output;

            sini <= 0.9 * sin((real(simulation_counter)/6000.0*math_pi) mod (2.0*math_pi));

            if sdm_model_is_ready(sdm_model) then
                filters(0) <= filters(0)-(filters(0) - sdm_io)*filter_gain;
                filters(1) <= filters(1) +(filters(0) - filters(1))*filter_gain;
                filters(2) <= filters(2) +(filters(1) - filters(2))*filter_gain;
                filters(3) <= filters(3) +(filters(2) - filters(3))*filter_gain;
            end if;

            demodulation_error <= (sini - filters(3));

            -- allow initial model start to have larger error
            if simulation_counter > 100 then
                check( abs(demodulation_error) < 0.1, "maximum filter error should be less than 0.1");
                if maximum_error < abs(demodulation_error) then
                    maximum_error <= abs(demodulation_error);
                end if;
            end if;


        end if; -- rising_edge
    end process stimulus;	
------------------------------------------------------------------------
end vunit_simulation;
