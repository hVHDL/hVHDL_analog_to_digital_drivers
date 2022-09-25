echo off

ghdl -a --ieee=synopsys --std=08 sigma_delta/sigma_delta_simulation_model_pkg.vhd
ghdl -a --ieee=synopsys --std=08 sigma_delta/sigma_delta_cic_filter_pkg.vhd

ghdl -a --ieee=synopsys --std=08 spi_adc/clock_divider_pkg.vhd
ghdl -a --ieee=synopsys --std=08 spi_adc/ads7056_pkg.vhd
ghdl -a --ieee=synopsys --std=08 spi_adc/ad_mux_driver_pkg.vhd
ghdl -a --ieee=synopsys --std=08 spi_adc/muxed_adc_pkg.vhd
