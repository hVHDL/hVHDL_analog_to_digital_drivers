LIBRARY ieee  ; 
    USE ieee.NUMERIC_STD.all  ; 
    USE ieee.std_logic_1164.all  ; 
    use ieee.math_real.all;

library vunit_lib;
context vunit_lib.vunit_context;

entity spi_adc_tb is
  generic (runner_cfg : string);
end;

architecture vunit_simulation of spi_adc_tb is

    constant clock_period      : time    := 1 ns;
    constant simtime_in_clocks : integer := 500;
    
    signal simulator_clock     : std_logic := '0';
    signal simulation_counter  : natural   := 0;
    -----------------------------------
    -- simulation specific signals ----
    signal sine_angle : real := 0.0;
    signal sine : real := 0.0;

    signal sample : std_logic_vector(13 downto 0) := (others => '0');

    function get_sample
    (
        sampled_signal : real
    )
    return std_logic_vector 
    is
        variable int_sampled_signal : integer;
        variable unsigned_sampled_signal : unsigned(13 downto 0);
    begin
        int_sampled_signal := integer(sampled_signal*2.0**13) + 2**13;
        if int_sampled_signal < 2**14 then
            unsigned_sampled_signal := to_unsigned(int_sampled_signal, 14);
        else
            unsigned_sampled_signal := to_unsigned(2**14-1,14);
        end if;
        return std_logic_vector(unsigned_sampled_signal);
        
    end get_sample;

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

            sine_angle <= (sine_angle + math_pi*2.0/220.0) mod (2.0*math_pi);
            sine <= sin(sine_angle);
            sample(13 downto 0) <= get_sample(sine);


        end if; -- rising_edge
    end process stimulus;	
------------------------------------------------------------------------
end vunit_simulation;
