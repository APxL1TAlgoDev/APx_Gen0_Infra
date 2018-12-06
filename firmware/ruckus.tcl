#
#Load RUCKUS environment and library
 source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

set_property ip_repo_paths $::env(IP_REPO) [current_project]
update_ip_catalog
set_property STEPS.SYNTH_DESIGN.ARGS.KEEP_EQUIVALENT_REGISTERS true [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.RETIMING true [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY rebuilt [get_runs synth_1]

set_property file_type {VHDL 2008} [get_files "$::DIR_PATH/hdl/*.vhd"]

# # Load common and sub-module ruckus.tcl files
#loadRuckusTcl $::env(PROJ_DIR)/../../../
#loadRuckusTcl $::env(PROJ_DIR)
#
# # Load local source Code and constraints
loadSource      -dir "$::DIR_PATH/hdl/"
loadConstraints -dir "$::DIR_PATH/constraints/"

loadIpCore      -dir "$::DIR_PATH/ip_repo/"
#loadSource      -dir "$::DIR_PATH/ip_repo/"

loadBlockDesign -path "$::DIR_PATH/bd/2017.3/v7_bd.bd"

# Load HLS algo
loadRuckusTcl  "$::DIR_PATH/../../APx_Gen0_Algo/VivadoHls/null_algo"
