library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.ads7056_pkg.all;
    use work.ad_mux_pkg.all;

package muxed_adc_pkg is

    type measurements_array is array (integer range 0 to 7) of integer;

    type muxed_adc_record is record
        ads7056 : ads7056_record;
        ad_mux : ad_mux_record;
        triggered_adc_channel : integer range 0 to 7;
        measurements : measurements_array;
    end record;

end package muxed_adc_pkg;

package body muxed_adc_pkg is

------------------------------------------------------------------------
    procedure create_muxed_adc
    (
        signal muxed_adc_object : inout muxed_adc_record;
        adc_io : in std_logic
    ) is
        alias m is muxed_adc_object;
    begin
        create_ads7056(m.ads7056, adc_io);
        create_ad_mux(m.ad_mux, ads7056_is_ready(m.ads7056));

        if ads7056_is_ready(m.ads7056) then
            m.measurements(m.triggered_adc_channel) <= get_ad_measurement(m.ads7056);
        end if;
    end create_muxed_adc;
------------------------------------------------------------------------
    function measurement_is_ready
    (
        muxed_adc_object : muxed_adc_record;
        channel : integer range 0 to 7
    )
    return boolean
    is
        alias m is muxed_adc_object;
    begin
        return ads7056_is_ready(m.ads7056) and m.triggered_adc_channel = channel;
        
    end measurement_is_ready;
------------------------------------------------------------------------
    function get_muxed_ad_measurement
    (
        muxed_adc_object : muxed_adc_record;
        channel : integer range 0 to 7;
        requested_measurement : integer
    )
    return integer
    is
    begin
        report "no implementatino for get_muxed_ad_measurement" severity failure;
        return 0;
        
    end get_muxed_ad_measurement;
------------------------------------------------------------------------

end package body muxed_adc_pkg;
