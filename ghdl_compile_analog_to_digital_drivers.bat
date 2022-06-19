echo off

ghdl -a --ieee=synopsys --std=08 sigma_delta/sigma_delta_simulation_model_pkg.vhd
ghdl -a --ieee=synopsys --std=08 sigma_delta/sigma_delta_cic_filter_pkg.vhd
