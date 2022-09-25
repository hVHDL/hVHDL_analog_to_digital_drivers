library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;

package ad_mux_driver_pkg is

    type ad_mux_record is record
        channel      : integer range 0 to 7;
        next_channel : integer range 0 to 7;
        is_triggered : boolean;
    end record;

------------------------------------------------------------------------
    function init_ad_mux return ad_mux_record;

    function init_ad_mux ( initial_channel : integer)
        return ad_mux_record;

------------------------------------------------------------------------
    procedure create_ad_mux (
        signal ad_mux_object : inout ad_mux_record);
------------------------------------------------------------------------
    procedure setup_next_channel (
        signal ad_mux_object : out ad_mux_record;
        next_channel : in integer);
------------------------------------------------------------------------
    function get_ad_mux_io ( ad_mux_object : ad_mux_record)
        return std_logic_vector;
------------------------------------------------------------------------

end package ad_mux_driver_pkg;

package body ad_mux_driver_pkg is

------------------------------------------------------------------------
    constant initial_value_for_ad_mux : ad_mux_record  := (0,0,false);

--------------------
    function init_ad_mux return ad_mux_record
    is
    begin
        return initial_value_for_ad_mux;
    end init_ad_mux;

--------------------
    function init_ad_mux
    (
        initial_channel : integer
    )
    return ad_mux_record
    is
        variable return_value : ad_mux_record;
    begin

        return_value := (initial_channel, 0, false);
        return return_value;
    end init_ad_mux;

------------------------------------------------------------------------
    procedure create_ad_mux
    (
        signal ad_mux_object : inout ad_mux_record
    ) is
        alias m is ad_mux_object;
    begin

        m.is_triggered <= false;
        if m.is_triggered then
            m.channel <= m.next_channel;
        end if;
        
    end create_ad_mux;
------------------------------------------------------------------------
    procedure setup_next_channel
    (
        signal ad_mux_object : out ad_mux_record;
        next_channel : in integer
    ) is
    begin
        ad_mux_object.next_channel <= next_channel;
    end setup_next_channel;
------------------------------------------------------------------------
    function get_ad_mux_io
    (
        ad_mux_object : ad_mux_record
    )
    return std_logic_vector 
    is
    begin
        return std_logic_vector(to_unsigned(ad_mux_object.channel, 3));
        
    end get_ad_mux_io;
------------------------------------------------------------------------
end package body ad_mux_driver_pkg;
