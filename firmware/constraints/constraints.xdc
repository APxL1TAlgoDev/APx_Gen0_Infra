#---------------
set_property PACKAGE_PIN H29 [get_ports clk_200_diff_in_clk_n]

set_property IOSTANDARD LVDS [get_ports clk_200_diff_in_clk_p]
set_property IOSTANDARD LVDS [get_ports clk_200_diff_in_clk_n]

create_clock -period 5.000 -name clk_200_diff_in_clk_p [get_ports clk_200_diff_in_clk_p]

#---------------
#green LED (PCB)
set_property PACKAGE_PIN A20 [get_ports {LEDs[0]}]
#orange
set_property PACKAGE_PIN B20 [get_ports {LEDs[1]}]

set_property IOSTANDARD LVCMOS18 [get_ports {LEDs[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {LEDs[1]}]


set_property PACKAGE_PIN H19 [get_ports LED_GREEN_o]
set_property IOSTANDARD LVCMOS18 [get_ports LED_GREEN_o]

set_property PACKAGE_PIN D20 [get_ports LED_RED_o]
set_property IOSTANDARD LVCMOS18 [get_ports LED_RED_o]

set_property PACKAGE_PIN C20 [get_ports LED_BLUE_o]
set_property IOSTANDARD LVCMOS18 [get_ports LED_BLUE_o]

# ==========================================================================
# TTC data stream
set_property PACKAGE_PIN AV30 [get_ports clk_40_ttc_n_i]
set_property IOSTANDARD LVDS [get_ports clk_40_ttc_p_i]
set_property IOSTANDARD LVDS [get_ports clk_40_ttc_n_i]

set_property PACKAGE_PIN J26 [get_ports ttc_data_n_i]
set_property IOSTANDARD LVDS [get_ports ttc_data_p_i]
set_property IOSTANDARD LVDS [get_ports ttc_data_n_i]

## ~40.5 MHz (over-constrained)
create_clock -period 24.691 -name clk_40_ttc_p_i [get_ports clk_40_ttc_p_i]

# ==========================================================================

# ==========================================================================
# AXI Chip2Chip

set_property INTERNAL_VREF 0.9 [get_iobanks 16]

# AXI Chip2Chip - RX section
set_property PACKAGE_PIN BD31 [get_ports axi_c2c_v7_to_zynq_clk]
set_property PACKAGE_PIN AY32 [get_ports {axi_c2c_v7_to_zynq_data[0]}]
set_property PACKAGE_PIN BA33 [get_ports {axi_c2c_v7_to_zynq_data[1]}]
set_property PACKAGE_PIN AR31 [get_ports {axi_c2c_v7_to_zynq_data[2]}]
set_property PACKAGE_PIN AR32 [get_ports {axi_c2c_v7_to_zynq_data[3]}]
set_property PACKAGE_PIN AV32 [get_ports {axi_c2c_v7_to_zynq_data[4]}]
set_property PACKAGE_PIN AW32 [get_ports {axi_c2c_v7_to_zynq_data[5]}]
set_property PACKAGE_PIN AJ30 [get_ports {axi_c2c_v7_to_zynq_data[6]}]
set_property PACKAGE_PIN AJ31 [get_ports {axi_c2c_v7_to_zynq_data[7]}]
set_property PACKAGE_PIN AM32 [get_ports {axi_c2c_v7_to_zynq_data[8]}]
set_property PACKAGE_PIN AM33 [get_ports {axi_c2c_v7_to_zynq_data[9]}]
set_property PACKAGE_PIN BB33 [get_ports {axi_c2c_v7_to_zynq_data[10]}]
set_property PACKAGE_PIN AV33 [get_ports {axi_c2c_v7_to_zynq_data[11]}]
set_property PACKAGE_PIN AP32 [get_ports {axi_c2c_v7_to_zynq_data[12]}]
set_property PACKAGE_PIN AN32 [get_ports {axi_c2c_v7_to_zynq_data[13]}]
set_property PACKAGE_PIN BC34 [get_ports {axi_c2c_v7_to_zynq_data[14]}]
set_property PACKAGE_PIN AR33 [get_ports {axi_c2c_v7_to_zynq_data[15]}]
set_property PACKAGE_PIN AT33 [get_ports {axi_c2c_v7_to_zynq_data[16]}]

set_property IOSTANDARD HSTL_I_DCI_18 [get_ports axi_c2c_v7_to_zynq_clk]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {axi_c2c_v7_to_zynq_data[0]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {axi_c2c_v7_to_zynq_data[1]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {axi_c2c_v7_to_zynq_data[2]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {axi_c2c_v7_to_zynq_data[3]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {axi_c2c_v7_to_zynq_data[4]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {axi_c2c_v7_to_zynq_data[5]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {axi_c2c_v7_to_zynq_data[6]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {axi_c2c_v7_to_zynq_data[7]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {axi_c2c_v7_to_zynq_data[8]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {axi_c2c_v7_to_zynq_data[9]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {axi_c2c_v7_to_zynq_data[10]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {axi_c2c_v7_to_zynq_data[11]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {axi_c2c_v7_to_zynq_data[12]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {axi_c2c_v7_to_zynq_data[13]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {axi_c2c_v7_to_zynq_data[14]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {axi_c2c_v7_to_zynq_data[15]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {axi_c2c_v7_to_zynq_data[16]}]

# AXI Chip2Chip - TX section
set_property PACKAGE_PIN AU33 [get_ports axi_c2c_zynq_to_v7_clk]
set_property PACKAGE_PIN AV34 [get_ports {axi_c2c_zynq_to_v7_data[0]}]
set_property PACKAGE_PIN AV35 [get_ports {axi_c2c_zynq_to_v7_data[1]}]
set_property PACKAGE_PIN AW34 [get_ports {axi_c2c_zynq_to_v7_data[2]}]
set_property PACKAGE_PIN AW35 [get_ports {axi_c2c_zynq_to_v7_data[3]}]
set_property PACKAGE_PIN AY33 [get_ports {axi_c2c_zynq_to_v7_data[4]}]
set_property PACKAGE_PIN AY34 [get_ports {axi_c2c_zynq_to_v7_data[5]}]
set_property PACKAGE_PIN BA34 [get_ports {axi_c2c_zynq_to_v7_data[6]}]
set_property PACKAGE_PIN BA35 [get_ports {axi_c2c_zynq_to_v7_data[7]}]
set_property PACKAGE_PIN BD34 [get_ports {axi_c2c_zynq_to_v7_data[8]}]
set_property PACKAGE_PIN BD35 [get_ports {axi_c2c_zynq_to_v7_data[9]}]
set_property PACKAGE_PIN BB35 [get_ports {axi_c2c_zynq_to_v7_data[10]}]
set_property PACKAGE_PIN BC35 [get_ports {axi_c2c_zynq_to_v7_data[11]}]
set_property PACKAGE_PIN BC32 [get_ports {axi_c2c_zynq_to_v7_data[12]}]
set_property PACKAGE_PIN BC33 [get_ports {axi_c2c_zynq_to_v7_data[13]}]
set_property PACKAGE_PIN BD32 [get_ports {axi_c2c_zynq_to_v7_data[14]}]
set_property PACKAGE_PIN AJ32 [get_ports {axi_c2c_zynq_to_v7_data[15]}]
set_property PACKAGE_PIN AK32 [get_ports {axi_c2c_zynq_to_v7_data[16]}]

set_property IOSTANDARD HSTL_I_DCI_18 [get_ports axi_c2c_zynq_to_v7_clk]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {axi_c2c_zynq_to_v7_data[0]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {axi_c2c_zynq_to_v7_data[1]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {axi_c2c_zynq_to_v7_data[2]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {axi_c2c_zynq_to_v7_data[3]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {axi_c2c_zynq_to_v7_data[4]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {axi_c2c_zynq_to_v7_data[5]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {axi_c2c_zynq_to_v7_data[6]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {axi_c2c_zynq_to_v7_data[7]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {axi_c2c_zynq_to_v7_data[8]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {axi_c2c_zynq_to_v7_data[9]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {axi_c2c_zynq_to_v7_data[10]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {axi_c2c_zynq_to_v7_data[11]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {axi_c2c_zynq_to_v7_data[12]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {axi_c2c_zynq_to_v7_data[13]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {axi_c2c_zynq_to_v7_data[14]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {axi_c2c_zynq_to_v7_data[15]}]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports {axi_c2c_zynq_to_v7_data[16]}]

# AXI Chip2Chip - Status/Control section
set_property PACKAGE_PIN BB31 [get_ports axi_c2c_zynq_to_v7_reset]
set_property PACKAGE_PIN BB32 [get_ports axi_c2c_v7_to_zynq_link_status]

set_property IOSTANDARD HSTL_I_DCI_18 [get_ports axi_c2c_zynq_to_v7_reset]
set_property IOSTANDARD HSTL_I_DCI_18 [get_ports axi_c2c_v7_to_zynq_link_status]
# ==========================================================================

set_property LOC XADC_X0Y0 [get_cells i_v7_bd/xadc_wiz_0/U0/AXI_XADC_CORE_I/XADC_INST]

#set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
#set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
#set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
#connect_debug_port dbg_hub/clk [get_nets s_clk_usrclk_250]

create_clock -period 4.000 -name {i_gth_wrapper/gen_single_gt[0].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2/TXOUTCLK} -waveform {0.000 2.000} [get_pins {i_gth_wrapper/gen_single_gt[0].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2/TXOUTCLK}]


set_false_path -from [get_clocks -of_objects [get_pins i_v7_bd/clk_wiz_0/inst/mmcm_adv_inst/CLKOUT2]] -to [get_clocks -of_objects [get_pins i_v7_bd/clk_wiz_0/inst/mmcm_adv_inst/CLKOUT3]]

set_false_path -from [get_clocks -of_objects [get_pins i_ctp7_ttc/i_ctp7_ttc_clocks/inst/mmcm_adv_inst/CLKOUT1]] -to [get_clocks -of_objects [get_pins i_v7_bd/clk_wiz_0/inst/mmcm_adv_inst/CLKOUT2]]


#set_clock_groups -name v7_clk_to_ttc40 -asynchronous -group [get_clocks -of_objects [get_pins i_ctp7_ttc/i_ctp7_ttc_clocks/inst/mmcm_adv_inst/CLKOUT0]] -group [get_clocks -of_objects [get_pins i_v7_bd/clk_wiz_0/inst/mmcm_adv_inst/CLKOUT2]]
#set_clock_groups -name v7_clk_to_ttc40 -asynchronous -group [get_clocks -of_objects [get_pins i_ctp7_ttc/i_ctp7_ttc_clocks/inst/mmcm_adv_inst/CLKOUT2]] -group [get_clocks -of_objects [get_pins i_v7_bd/clk_wiz_0/inst/mmcm_adv_inst/CLKOUT2]]

#set_clock_groups -name v7_clk_to_ttc40 -asynchronous -group [get_clocks -of_objects [get_pins i_v7_bd/clk_wiz_0/inst/mmcm_adv_inst/CLKOUT2]] -group [get_clocks -of_objects [get_pins i_ctp7_ttc/i_ctp7_ttc_clocks/inst/mmcm_adv_inst/CLKOUT2]]

#set_clock_groups -name v7_clk_to_ttc40 -asynchronous -group [get_clocks -of_objects [get_pins i_v7_bd/clk_wiz_0/inst/mmcm_adv_inst/CLKOUT2]] -group [get_clocks -of_objects [get_pins i_ctp7_ttc/i_ctp7_ttc_clocks/inst/mmcm_adv_inst/CLKOUT0]]


set_false_path -from [get_clocks {i_gth_wrapper/gen_single_gt[0].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2/TXOUTCLK}] -to [get_clocks -of_objects [get_pins i_v7_bd/clk_wiz_0/inst/mmcm_adv_inst/CLKOUT2]]
set_false_path -from [get_clocks -of_objects [get_pins i_ctp7_ttc/i_ctp7_ttc_clocks/inst/mmcm_adv_inst/CLKOUT2]] -to [get_clocks -of_objects [get_pins i_v7_bd/clk_wiz_0/inst/mmcm_adv_inst/CLKOUT2]]
set_false_path -from [get_clocks {i_gth_wrapper/gen_single_gt[0].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2/TXOUTCLK}] -to [get_clocks -of_objects [get_pins i_ctp7_ttc/i_ctp7_ttc_clocks/inst/mmcm_adv_inst/CLKOUT2]]
set_false_path -from [get_clocks -of_objects [get_pins i_v7_bd/clk_wiz_0/inst/mmcm_adv_inst/CLKOUT2]] -to [get_clocks -of_objects [get_pins i_ctp7_ttc/i_ctp7_ttc_clocks/inst/mmcm_adv_inst/CLKOUT2]]
set_false_path -from [get_clocks -of_objects [get_pins i_ctp7_ttc/i_ctp7_ttc_clocks/inst/mmcm_adv_inst/CLKOUT2]] -to [get_clocks {i_gth_wrapper/gen_single_gt[0].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2/TXOUTCLK}]
set_false_path -from [get_clocks -of_objects [get_pins i_v7_bd/clk_wiz_0/inst/mmcm_adv_inst/CLKOUT2]] -to [get_clocks {i_gth_wrapper/gen_single_gt[0].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2/TXOUTCLK}]


set_false_path -from [get_clocks -of_objects [get_pins i_ctp7_ttc/i_ctp7_ttc_clocks/inst/mmcm_adv_inst/CLKOUT0]] -to [get_clocks -of_objects [get_pins i_v7_bd/clk_wiz_0/inst/mmcm_adv_inst/CLKOUT2]]
set_false_path -from [get_clocks -of_objects [get_pins i_v7_bd/clk_wiz_0/inst/mmcm_adv_inst/CLKOUT2]] -to [get_clocks -of_objects [get_pins i_ctp7_ttc/i_ctp7_ttc_clocks/inst/mmcm_adv_inst/CLKOUT0]]



