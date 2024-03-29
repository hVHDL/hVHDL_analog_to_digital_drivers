LIBRARY ieee  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    use ieee.math_real.all;

library vunit_lib;
context vunit_lib.vunit_context;

    use work.ad_mux_pkg.all;

entity ad_mux_tb is
  generic (runner_cfg : string);
end;

architecture vunit_simulation of ad_mux_tb is

    constant clock_period      : time    := 1 ns;
    constant simtime_in_clocks : integer := 50;
    
    signal simulator_clock     : std_logic := '0';
    signal simulation_counter  : natural   := 0;
    -----------------------------------
    -- simulation specific signals ----
    signal ad_mux : ad_mux_record := init_ad_mux;

    signal ad_mux_io : std_logic_vector(2 downto 0);

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
        variable trigger : boolean := false;
        variable channel : integer := 0;

    begin
        if rising_edge(simulator_clock) then
            simulation_counter <= simulation_counter + 1;
            create_ad_mux(ad_mux, trigger);
            ad_mux_io <= get_ad_mux_io(ad_mux);

            trigger := false;
            if simulation_counter mod 5 = 0 then
                trigger := true;
            end if;

            if simulation_counter mod 5 = 1 then
                channel := (channel + 1) mod 8;
                setup_next_channel(ad_mux, channel);
            end if;

        end if; -- rising_edge
    end process stimulus;	
------------------------------------------------------------------------
end vunit_simulation;
