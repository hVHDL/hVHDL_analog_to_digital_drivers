library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

    use work.ads7056_pkg.all;
    use work.ad_mux_pkg.all;

package muxed_adc_pkg is

    type measurements_array is array (integer range 0 to 7) of integer;

    type muxed_adc_record is record
        ads7056               : ads7056_record;
        ad_mux                : ad_mux_record;
        triggered_adc_channel : integer range 0 to 7;
        measurements          : measurements_array;
    end record;

------------------------------------------------------------------------
    procedure create_muxed_adc (
        signal muxed_adc_object : inout muxed_adc_record;
        adc_io : in std_logic);
------------------------------------------------------------------------
    function init_muxed_adc ( clock_divider : integer)
        return muxed_adc_record;
------------------------------------------------------------------------
    function get_ad_mux_io ( muxed_adc_object : muxed_adc_record)
        return integer;
------------------------------------------------------------------------
    function ad_measurement_is_ready ( muxed_adc_object : muxed_adc_record)
        return boolean;
------------------------------------------------------------------------
    procedure setup_next_channel (
        signal muxed_adc_object : out muxed_adc_record;
        next_channel_is : integer);
------------------------------------------------------------------------
    procedure request_ad_conversion (
        signal muxed_adc_object : inout muxed_adc_record);
------------------------------------------------------------------------
    function get_triggered_adc_channel ( muxed_adc_object : muxed_adc_record)
        return integer;
------------------------------------------------------------------------
    function get_ad_measurement ( muxed_adc_object : muxed_adc_record)
        return integer;
------------------------------------------------------------------------

end package muxed_adc_pkg;

package body muxed_adc_pkg is

------------------------------------------------------------------------
    function init_muxed_adc
    (
        clock_divider : integer
    )
    return muxed_adc_record
    is
        variable return_value : muxed_adc_record;
    begin
        return_value := (init_ads7056(clock_divider), init_ad_mux, 0, (others => 0));
        
    end init_muxed_adc;
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
    function get_ad_mux_io
    (
        muxed_adc_object : muxed_adc_record
    )
    return integer
    is
    begin
        return get_ad_mux_io(muxed_adc_object.ad_mux);
    end get_ad_mux_io;
------------------------------------------------------------------------
    function ad_measurement_is_ready
    (
        muxed_adc_object : muxed_adc_record
    )
    return boolean
    is
    begin
        return ads7056_is_ready(muxed_adc_object.ads7056);
    end ad_measurement_is_ready;
------------------------------------------------------------------------
    procedure setup_next_channel
    (
        signal muxed_adc_object : out muxed_adc_record;
        next_channel_is : integer
    ) is
    begin
        setup_next_channel(muxed_adc_object.ad_mux, next_channel_is);
    end setup_next_channel; 
------------------------------------------------------------------------
    procedure request_ad_conversion
    (
        signal muxed_adc_object : inout muxed_adc_record
    ) is
        alias m is muxed_adc_object;
    begin
        request_ad_conversion(m.ads7056);
        m.triggered_adc_channel <= get_ad_mux_io(m.ad_mux);

    end request_ad_conversion;
------------------------------------------------------------------------
    function get_triggered_adc_channel
    (
        muxed_adc_object : muxed_adc_record
    )
    return integer
    is
    begin
        return muxed_adc_object.triggered_adc_channel;
    end get_triggered_adc_channel;
------------------------------------------------------------------------
    function get_ad_measurement
    (
        muxed_adc_object : muxed_adc_record
    )
    return integer
    is
    begin
        return get_ad_measurement(muxed_adc_object.ads7056);
    end get_ad_measurement;
------------------------------------------------------------------------

end package body muxed_adc_pkg;
