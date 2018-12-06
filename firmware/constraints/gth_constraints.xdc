# Configuration
# F - front, B - back
# 0 - CPLL, 1 - QPLL

# TODO


####################### GT reference clock constraints #########################

create_clock -period 4.000 [get_ports {refclk_F_0_p_i[0]}]
create_clock -period 4.000 [get_ports {refclk_F_0_p_i[1]}]
create_clock -period 4.000 [get_ports {refclk_F_0_p_i[2]}]
create_clock -period 4.000 [get_ports {refclk_F_0_p_i[3]}]

create_clock -period 4.000 [get_ports {refclk_F_1_p_i[0]}]
create_clock -period 4.000 [get_ports {refclk_F_1_p_i[1]}]
create_clock -period 4.000 [get_ports {refclk_F_1_p_i[2]}]
create_clock -period 4.000 [get_ports {refclk_F_1_p_i[3]}]

create_clock -period 4.000 [get_ports {refclk_B_0_p_i[0]}]
create_clock -period 4.000 [get_ports {refclk_B_0_p_i[1]}]
create_clock -period 4.000 [get_ports {refclk_B_0_p_i[2]}]
create_clock -period 4.000 [get_ports {refclk_B_0_p_i[3]}]

create_clock -period 4.000 [get_ports {refclk_B_1_p_i[0]}]
create_clock -period 4.000 [get_ports {refclk_B_1_p_i[1]}]
create_clock -period 4.000 [get_ports {refclk_B_1_p_i[2]}]
create_clock -period 4.000 [get_ports {refclk_B_1_p_i[3]}]

################################ RefClk Location constraints #####################

set_property PACKAGE_PIN E10 [get_ports {refclk_F_0_p_i[0]}]
set_property PACKAGE_PIN N10 [get_ports {refclk_F_0_p_i[1]}]
set_property PACKAGE_PIN AF8 [get_ports {refclk_F_0_p_i[2]}]
set_property PACKAGE_PIN AR10 [get_ports {refclk_F_0_p_i[3]}]

set_property PACKAGE_PIN G10 [get_ports {refclk_F_1_p_i[0]}]
set_property PACKAGE_PIN R10 [get_ports {refclk_F_1_p_i[1]}]
set_property PACKAGE_PIN AH8 [get_ports {refclk_F_1_p_i[2]}]
set_property PACKAGE_PIN AT8 [get_ports {refclk_F_1_p_i[3]}]

set_property PACKAGE_PIN AR35 [get_ports {refclk_B_0_p_i[0]}]
set_property PACKAGE_PIN AF37 [get_ports {refclk_B_0_p_i[1]}]
set_property PACKAGE_PIN N35 [get_ports {refclk_B_0_p_i[2]}]
set_property PACKAGE_PIN E35 [get_ports {refclk_B_0_p_i[3]}]

set_property PACKAGE_PIN AT37 [get_ports {refclk_B_1_p_i[0]}]
set_property PACKAGE_PIN AH37 [get_ports {refclk_B_1_p_i[1]}]
set_property PACKAGE_PIN R35 [get_ports {refclk_B_1_p_i[2]}]
set_property PACKAGE_PIN G35 [get_ports {refclk_B_1_p_i[3]}]


################################ GTH2_CHANNEL Location constraints  #####################
set_property LOC GTHE2_CHANNEL_X1Y0 [get_cells {i_gth_wrapper/gen_single_gt[0].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y1 [get_cells {i_gth_wrapper/gen_single_gt[1].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y2 [get_cells {i_gth_wrapper/gen_single_gt[2].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y3 [get_cells {i_gth_wrapper/gen_single_gt[3].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y4 [get_cells {i_gth_wrapper/gen_single_gt[4].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y5 [get_cells {i_gth_wrapper/gen_single_gt[5].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y6 [get_cells {i_gth_wrapper/gen_single_gt[6].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y7 [get_cells {i_gth_wrapper/gen_single_gt[7].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y8 [get_cells {i_gth_wrapper/gen_single_gt[8].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y9 [get_cells {i_gth_wrapper/gen_single_gt[9].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]

set_property LOC GTHE2_CHANNEL_X1Y10 [get_cells {i_gth_wrapper/gen_single_gt[10].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y11 [get_cells {i_gth_wrapper/gen_single_gt[11].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y12 [get_cells {i_gth_wrapper/gen_single_gt[12].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y13 [get_cells {i_gth_wrapper/gen_single_gt[13].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y14 [get_cells {i_gth_wrapper/gen_single_gt[14].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y15 [get_cells {i_gth_wrapper/gen_single_gt[15].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y16 [get_cells {i_gth_wrapper/gen_single_gt[16].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y17 [get_cells {i_gth_wrapper/gen_single_gt[17].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y18 [get_cells {i_gth_wrapper/gen_single_gt[18].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y19 [get_cells {i_gth_wrapper/gen_single_gt[19].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]

set_property LOC GTHE2_CHANNEL_X1Y20 [get_cells {i_gth_wrapper/gen_single_gt[20].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y21 [get_cells {i_gth_wrapper/gen_single_gt[21].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y22 [get_cells {i_gth_wrapper/gen_single_gt[22].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y23 [get_cells {i_gth_wrapper/gen_single_gt[23].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y24 [get_cells {i_gth_wrapper/gen_single_gt[24].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y25 [get_cells {i_gth_wrapper/gen_single_gt[25].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y26 [get_cells {i_gth_wrapper/gen_single_gt[26].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y27 [get_cells {i_gth_wrapper/gen_single_gt[27].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y28 [get_cells {i_gth_wrapper/gen_single_gt[28].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y29 [get_cells {i_gth_wrapper/gen_single_gt[29].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]

set_property LOC GTHE2_CHANNEL_X1Y30 [get_cells {i_gth_wrapper/gen_single_gt[30].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y31 [get_cells {i_gth_wrapper/gen_single_gt[31].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y32 [get_cells {i_gth_wrapper/gen_single_gt[32].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y33 [get_cells {i_gth_wrapper/gen_single_gt[33].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y34 [get_cells {i_gth_wrapper/gen_single_gt[34].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y35 [get_cells {i_gth_wrapper/gen_single_gt[35].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y36 [get_cells {i_gth_wrapper/gen_single_gt[36].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y37 [get_cells {i_gth_wrapper/gen_single_gt[37].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y38 [get_cells {i_gth_wrapper/gen_single_gt[38].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X1Y39 [get_cells {i_gth_wrapper/gen_single_gt[39].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]

set_property LOC GTHE2_CHANNEL_X0Y39 [get_cells {i_gth_wrapper/gen_single_gt[40].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X0Y38 [get_cells {i_gth_wrapper/gen_single_gt[41].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X0Y37 [get_cells {i_gth_wrapper/gen_single_gt[42].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X0Y36 [get_cells {i_gth_wrapper/gen_single_gt[43].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X0Y35 [get_cells {i_gth_wrapper/gen_single_gt[44].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X0Y34 [get_cells {i_gth_wrapper/gen_single_gt[45].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X0Y33 [get_cells {i_gth_wrapper/gen_single_gt[46].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X0Y32 [get_cells {i_gth_wrapper/gen_single_gt[47].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X0Y31 [get_cells {i_gth_wrapper/gen_single_gt[48].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X0Y30 [get_cells {i_gth_wrapper/gen_single_gt[49].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]

set_property LOC GTHE2_CHANNEL_X0Y29 [get_cells {i_gth_wrapper/gen_single_gt[50].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X0Y28 [get_cells {i_gth_wrapper/gen_single_gt[51].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X0Y27 [get_cells {i_gth_wrapper/gen_single_gt[52].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X0Y26 [get_cells {i_gth_wrapper/gen_single_gt[53].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X0Y25 [get_cells {i_gth_wrapper/gen_single_gt[54].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X0Y24 [get_cells {i_gth_wrapper/gen_single_gt[55].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X0Y23 [get_cells {i_gth_wrapper/gen_single_gt[56].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X0Y22 [get_cells {i_gth_wrapper/gen_single_gt[57].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X0Y21 [get_cells {i_gth_wrapper/gen_single_gt[58].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X0Y20 [get_cells {i_gth_wrapper/gen_single_gt[59].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]

set_property LOC GTHE2_CHANNEL_X0Y19 [get_cells {i_gth_wrapper/gen_single_gt[60].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X0Y18 [get_cells {i_gth_wrapper/gen_single_gt[61].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X0Y17 [get_cells {i_gth_wrapper/gen_single_gt[62].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]
set_property LOC GTHE2_CHANNEL_X0Y16 [get_cells {i_gth_wrapper/gen_single_gt[63].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2}]




############# Channel [0] - 10 Gbps TX, 10.0 Gbps RX #############

#create_clock -period 4.000 [get_pins -hier -filter {name=~*gen_gth_single[0].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2*TXOUTCLK}]
#create_clock -period 4.000 [get_pins -hier -filter {name=~*gen_gth_single[0].gen_gth_if_enabled.i_gth_10gbps_buf_cc_gt/i_gthe2*RXOUTCLK}]





