LIBRARY ieee  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    use ieee.math_real.all;

library vunit_lib;
context vunit_lib.vunit_context;

    use work.ad_mux_pkg.all;
    use work.ads7056_pkg.all;

entity muxed_adc_tb is
  generic (runner_cfg : string);
end;

architecture vunit_simulation of muxed_adc_tb is

    constant clock_period      : time    := 1 ns;
    constant simtime_in_clocks : integer := 5000;
    
    signal simulator_clock     : std_logic := '0';
    signal simulation_counter  : natural   := 0;
    -----------------------------------
    -- simulation specific signals ----
    signal ad_mux : ad_mux_record := init_ad_mux;


    signal ads7056 : ads7056_record := init_ads7056(2);
    signal ad_mux_io : std_logic_vector(2 downto 0);
    signal clock_counter : integer := 0;
    signal triggered_adc_channel : integer := 0;

    type measurements_array is array (integer range 0 to 7) of integer;
    signal measurements : measurements_array := (others => 0);

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
        variable channel : integer := 0;

    begin
        if rising_edge(simulator_clock) then
            simulation_counter <= simulation_counter + 1;
            create_ads7056(ads7056, '1');
            create_ad_mux(ad_mux, ads7056_is_ready(ads7056));
            ad_mux_io <= get_ad_mux_io(ad_mux);

            if ads7056_is_ready(ads7056) then
                channel := (channel + 1) mod 8;
                setup_next_channel(ad_mux, channel);
            end if;

            if simulation_counter mod 100 = 0 then
                request_ad_conversion(ads7056);
                triggered_adc_channel <= get_ad_mux_io(ad_mux);
            end if;

            if ads7056_is_ready(ads7056) then
                measurements(triggered_adc_channel) <= get_ad_measurement(ads7056);
            end if;

        end if; -- rising_edge
    end process stimulus;	
------------------------------------------------------------------------
end vunit_simulation;
