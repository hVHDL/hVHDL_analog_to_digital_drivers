LIBRARY ieee  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    use ieee.math_real.all;

library vunit_lib;
context vunit_lib.vunit_context;

    use work.muxed_adc_pkg.all;

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
    signal muxed_adc : muxed_adc_record := init_muxed_adc(11);
    signal ad_mux_io : std_logic_vector(2 downto 0) := (others => '0');

    signal measurements          : measurements_array := (others => 0);

    type intarray is array (integer range 0 to 7) of integer;
    constant channel_sel : intarray := (5,3,7,4,1,0,6,2);
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
            create_muxed_adc(muxed_adc, '1');
            ad_mux_io <= get_ad_mux_io(muxed_adc);

            if ad_measurement_is_ready(muxed_adc) then
                channel := (channel + 1) mod 8;
                setup_next_channel(muxed_adc, channel_sel(channel));
            end if;

            if simulation_counter mod 100 = 0 then
                request_ad_conversion(muxed_adc);
            end if;

            if ad_measurement_is_ready(muxed_adc) then
                measurements(get_triggered_adc_channel(muxed_adc)) <= get_ad_measurement(muxed_adc);
            end if;


        end if; -- rising_edge
    end process stimulus;	
------------------------------------------------------------------------
end vunit_simulation;
