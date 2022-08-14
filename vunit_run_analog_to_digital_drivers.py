#!/usr/bin/env python3

from pathlib import Path
from vunit import VUnit

# ROOT
ROOT = Path(__file__).resolve().parent
VU = VUnit.from_argv()

adc = VU.add_library("analog_to_digital")
adc.add_source_files(ROOT / "sigma_delta" / "*.vhd")
adc.add_source_files(ROOT / "simulation" / "*.vhd")
adc.add_source_files(ROOT / "spi_adc" / "*.vhd")

VU.main()
