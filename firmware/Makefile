# Define target output
target: bit
#
# # Define Firmware Version Number
export PRJ_VERSION = 0x00000001
#
export PROJECT = ctp7_top
export VIVADO_PROJECT_SIM = tb_ctp7_top
export VIVADO_PROJECT_SIM_TIME = 1100 ns # Simulation time with unit
#
# # Define target part
export PRJ_PART = xc7vx690tffg1927-2

export PARALLEL_SYNTH = 16

#  # Using a non-standard target directory structure,
# which requires me to define the TOP_DIR path
export TOP_DIR = $(abspath $(PWD)/..)
 
export IP_REPO = $(abspath $(PWD)/ip_repo)

# # Use top level makefile
include $(TOP_DIR)/submodules/ruckus/system_vivado.mk

