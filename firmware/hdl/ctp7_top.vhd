library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

use work.ctp7_utils_pkg.all;
use work.ctp7_v7_build_cfg_pkg.all;

use work.link_align_pkg.all;
use work.link_buffer_pkg.all;

use work.gth_pkg.all;
use work.ttc_pkg.all;
use work.algo_pkg.all;

library UNISIM;
use UNISIM.VCOMPONENTS.all;

entity ctp7_top is
  generic (
    g_algo_include : integer := 1;
    g_ila_include  : integer := 1
    );
  port (

    clk_200_diff_in_clk_p : in std_logic;
    clk_200_diff_in_clk_n : in std_logic;

    clk_40_ttc_p_i : in std_logic;      -- TTC backplane clock signals
    clk_40_ttc_n_i : in std_logic;
    ttc_data_p_i   : in std_logic;
    ttc_data_n_i   : in std_logic;

    LEDs : out std_logic_vector (1 downto 0);

    LED_GREEN_o : out std_logic;
    LED_RED_o   : out std_logic;
    LED_BLUE_o  : out std_logic;

    refclk_F_0_p_i : in std_logic_vector (3 downto 0);
    refclk_F_0_n_i : in std_logic_vector (3 downto 0);

    refclk_F_1_p_i : in std_logic_vector (3 downto 0);
    refclk_F_1_n_i : in std_logic_vector (3 downto 0);

    refclk_B_0_p_i : in std_logic_vector (3 downto 0);
    refclk_B_0_n_i : in std_logic_vector (3 downto 0);

    refclk_B_1_p_i : in std_logic_vector (3 downto 0);
    refclk_B_1_n_i : in std_logic_vector (3 downto 0);


    axi_c2c_v7_to_zynq_data        : out std_logic_vector (16 downto 0);
    axi_c2c_v7_to_zynq_clk         : out std_logic;
    axi_c2c_zynq_to_v7_clk         : in  std_logic;
    axi_c2c_zynq_to_v7_data        : in  std_logic_vector (16 downto 0);
    axi_c2c_v7_to_zynq_link_status : out std_logic;
    axi_c2c_zynq_to_v7_reset       : in  std_logic
    );
end ctp7_top;

architecture ctp7_top_arch of ctp7_top is

  component ila_link_data_1

    port (
      clk    : in std_logic;
      probe0 : in std_logic_vector(31 downto 0);
      probe1 : in std_logic_vector(11 downto 0);
      probe2 : in std_logic_vector(0 downto 0);
      probe3 : in std_logic_vector(0 downto 0);
      probe4 : in std_logic_vector(0 downto 0)
      );
  end component;

  component v7_bd is
    port (

      clk_200_diff_in_clk_n : in std_logic;
      clk_200_diff_in_clk_p : in std_logic;

      axi_c2c_zynq_to_v7_clk         : in  std_logic;
      axi_c2c_zynq_to_v7_data        : in  std_logic_vector (16 downto 0);
      axi_c2c_v7_to_zynq_link_status : out std_logic;
      axi_c2c_v7_to_zynq_clk         : out std_logic;
      axi_c2c_v7_to_zynq_data        : out std_logic_vector (16 downto 0);
      axi_c2c_zynq_to_v7_reset       : in  std_logic;

      BRAM_CTRL_DRP_addr : out std_logic_vector (15 downto 0);
      BRAM_CTRL_DRP_clk  : out std_logic;
      BRAM_CTRL_DRP_din  : out std_logic_vector (31 downto 0);
      BRAM_CTRL_DRP_dout : in  std_logic_vector (31 downto 0);
      BRAM_CTRL_DRP_en   : out std_logic;
      BRAM_CTRL_DRP_rst  : out std_logic;
      BRAM_CTRL_DRP_we   : out std_logic_vector (3 downto 0);

      BRAM_CTRL_REG_FILE_addr : out std_logic_vector (16 downto 0);
      BRAM_CTRL_REG_FILE_clk  : out std_logic;
      BRAM_CTRL_REG_FILE_din  : out std_logic_vector (31 downto 0);
      BRAM_CTRL_REG_FILE_dout : in  std_logic_vector (31 downto 0);
      BRAM_CTRL_REG_FILE_en   : out std_logic;
      BRAM_CTRL_REG_FILE_rst  : out std_logic;
      BRAM_CTRL_REG_FILE_we   : out std_logic_vector (3 downto 0);

      BRAM_CTRL_GTH_REG_FILE_addr : out std_logic_vector (16 downto 0);
      BRAM_CTRL_GTH_REG_FILE_clk  : out std_logic;
      BRAM_CTRL_GTH_REG_FILE_din  : out std_logic_vector (31 downto 0);
      BRAM_CTRL_GTH_REG_FILE_dout : in  std_logic_vector (31 downto 0);
      BRAM_CTRL_GTH_REG_FILE_en   : out std_logic;
      BRAM_CTRL_GTH_REG_FILE_rst  : out std_logic;
      BRAM_CTRL_GTH_REG_FILE_we   : out std_logic_vector (3 downto 0);

      BRAM_CTRL_INPUT_RAM_0_addr : out std_logic_vector (16 downto 0);
      BRAM_CTRL_INPUT_RAM_0_clk  : out std_logic;
      BRAM_CTRL_INPUT_RAM_0_din  : out std_logic_vector (31 downto 0);
      BRAM_CTRL_INPUT_RAM_0_dout : in  std_logic_vector (31 downto 0);
      BRAM_CTRL_INPUT_RAM_0_en   : out std_logic;
      BRAM_CTRL_INPUT_RAM_0_rst  : out std_logic;
      BRAM_CTRL_INPUT_RAM_0_we   : out std_logic_vector (3 downto 0);

      BRAM_CTRL_INPUT_RAM_1_addr : out std_logic_vector (16 downto 0);
      BRAM_CTRL_INPUT_RAM_1_clk  : out std_logic;
      BRAM_CTRL_INPUT_RAM_1_din  : out std_logic_vector (31 downto 0);
      BRAM_CTRL_INPUT_RAM_1_dout : in  std_logic_vector (31 downto 0);
      BRAM_CTRL_INPUT_RAM_1_en   : out std_logic;
      BRAM_CTRL_INPUT_RAM_1_rst  : out std_logic;
      BRAM_CTRL_INPUT_RAM_1_we   : out std_logic_vector (3 downto 0);

      BRAM_CTRL_OUTPUT_RAM_0_addr : out std_logic_vector (16 downto 0);
      BRAM_CTRL_OUTPUT_RAM_0_clk  : out std_logic;
      BRAM_CTRL_OUTPUT_RAM_0_din  : out std_logic_vector (31 downto 0);
      BRAM_CTRL_OUTPUT_RAM_0_dout : in  std_logic_vector (31 downto 0);
      BRAM_CTRL_OUTPUT_RAM_0_en   : out std_logic;
      BRAM_CTRL_OUTPUT_RAM_0_rst  : out std_logic;
      BRAM_CTRL_OUTPUT_RAM_0_we   : out std_logic_vector (3 downto 0);

      BRAM_CTRL_OUTPUT_RAM_1_addr : out std_logic_vector (16 downto 0);
      BRAM_CTRL_OUTPUT_RAM_1_clk  : out std_logic;
      BRAM_CTRL_OUTPUT_RAM_1_din  : out std_logic_vector (31 downto 0);
      BRAM_CTRL_OUTPUT_RAM_1_dout : in  std_logic_vector (31 downto 0);
      BRAM_CTRL_OUTPUT_RAM_1_en   : out std_logic;
      BRAM_CTRL_OUTPUT_RAM_1_rst  : out std_logic;
      BRAM_CTRL_OUTPUT_RAM_1_we   : out std_logic_vector (3 downto 0);

      clk_50mhz : out std_logic
      );
  end component v7_bd;

  component fifo_algo_in
    port (
      wr_rst    : in  std_logic;
      rd_rst    : in  std_logic;
      wr_clk    : in  std_logic;
      rd_clk    : in  std_logic;
      din       : in  std_logic_vector(33 downto 0);
      wr_en     : in  std_logic;
      rd_en     : in  std_logic;
      dout      : out std_logic_vector(67 downto 0);
      full      : out std_logic;
      overflow  : out std_logic;
      empty     : out std_logic;
      underflow : out std_logic
      );
  end component fifo_algo_in;

  component fifo_algo_out
    port (
      wr_rst    : in  std_logic;
      rd_rst    : in  std_logic;
      wr_clk    : in  std_logic;
      rd_clk    : in  std_logic;
      din       : in  std_logic_vector(67 downto 0);
      wr_en     : in  std_logic;
      rd_en     : in  std_logic;
      dout      : out std_logic_vector(33 downto 0);
      full      : out std_logic;
      overflow  : out std_logic;
      empty     : out std_logic;
      underflow : out std_logic
      );
  end component fifo_algo_out;

  signal s_clk_50 : std_logic;

  signal BRAM_CTRL_REG_FILE_en   : std_logic;
  signal BRAM_CTRL_REG_FILE_dout : std_logic_vector (31 downto 0);
  signal BRAM_CTRL_REG_FILE_din  : std_logic_vector (31 downto 0);
  signal BRAM_CTRL_REG_FILE_we   : std_logic_vector (3 downto 0);
  signal BRAM_CTRL_REG_FILE_addr : std_logic_vector (16 downto 0);
  signal BRAM_CTRL_REG_FILE_clk  : std_logic;
  signal BRAM_CTRL_REG_FILE_rst  : std_logic;

  signal BRAM_CTRL_INPUT_RAM_0_addr : std_logic_vector (16 downto 0);
  signal BRAM_CTRL_INPUT_RAM_0_clk  : std_logic;
  signal BRAM_CTRL_INPUT_RAM_0_din  : std_logic_vector (31 downto 0);
  signal BRAM_CTRL_INPUT_RAM_0_dout : std_logic_vector (31 downto 0);
  signal BRAM_CTRL_INPUT_RAM_0_en   : std_logic;
  signal BRAM_CTRL_INPUT_RAM_0_rst  : std_logic;
  signal BRAM_CTRL_INPUT_RAM_0_we   : std_logic_vector (3 downto 0);

  signal BRAM_CTRL_INPUT_RAM_1_addr : std_logic_vector (16 downto 0);
  signal BRAM_CTRL_INPUT_RAM_1_clk  : std_logic;
  signal BRAM_CTRL_INPUT_RAM_1_din  : std_logic_vector (31 downto 0);
  signal BRAM_CTRL_INPUT_RAM_1_dout : std_logic_vector (31 downto 0);
  signal BRAM_CTRL_INPUT_RAM_1_en   : std_logic;
  signal BRAM_CTRL_INPUT_RAM_1_rst  : std_logic;
  signal BRAM_CTRL_INPUT_RAM_1_we   : std_logic_vector (3 downto 0);

  signal BRAM_CTRL_OUTPUT_RAM_0_addr : std_logic_vector (16 downto 0);
  signal BRAM_CTRL_OUTPUT_RAM_0_clk  : std_logic;
  signal BRAM_CTRL_OUTPUT_RAM_0_din  : std_logic_vector (31 downto 0);
  signal BRAM_CTRL_OUTPUT_RAM_0_dout : std_logic_vector (31 downto 0);
  signal BRAM_CTRL_OUTPUT_RAM_0_en   : std_logic;
  signal BRAM_CTRL_OUTPUT_RAM_0_rst  : std_logic;
  signal BRAM_CTRL_OUTPUT_RAM_0_we   : std_logic_vector (3 downto 0);

  signal BRAM_CTRL_OUTPUT_RAM_1_addr : std_logic_vector (16 downto 0);
  signal BRAM_CTRL_OUTPUT_RAM_1_clk  : std_logic;
  signal BRAM_CTRL_OUTPUT_RAM_1_din  : std_logic_vector (31 downto 0);
  signal BRAM_CTRL_OUTPUT_RAM_1_dout : std_logic_vector (31 downto 0);
  signal BRAM_CTRL_OUTPUT_RAM_1_en   : std_logic;
  signal BRAM_CTRL_OUTPUT_RAM_1_rst  : std_logic;
  signal BRAM_CTRL_OUTPUT_RAM_1_we   : std_logic_vector (3 downto 0);

  signal BRAM_CTRL_DRP_addr : std_logic_vector (15 downto 0);
  signal BRAM_CTRL_DRP_clk  : std_logic;
  signal BRAM_CTRL_DRP_din  : std_logic_vector (31 downto 0);
  signal BRAM_CTRL_DRP_dout : std_logic_vector (31 downto 0);
  signal BRAM_CTRL_DRP_en   : std_logic;
  signal BRAM_CTRL_DRP_rst  : std_logic;
  signal BRAM_CTRL_DRP_we   : std_logic_vector (3 downto 0);

  signal BRAM_CTRL_GTH_REG_FILE_en   : std_logic;
  signal BRAM_CTRL_GTH_REG_FILE_dout : std_logic_vector (31 downto 0);
  signal BRAM_CTRL_GTH_REG_FILE_din  : std_logic_vector (31 downto 0);
  signal BRAM_CTRL_GTH_REG_FILE_we   : std_logic_vector (3 downto 0);
  signal BRAM_CTRL_GTH_REG_FILE_addr : std_logic_vector (16 downto 0);
  signal BRAM_CTRL_GTH_REG_FILE_clk  : std_logic;
  signal BRAM_CTRL_GTH_REG_FILE_rst  : std_logic;

  signal s_ttc_clk_40         : std_logic;
  signal s_ttc_clk_120        : std_logic;
  signal s_ttc_clk_240        : std_logic;
  signal s_ttc_mmcm_ps_clk_en : std_logic;
  signal s_ttc_mmcm_ps_clk    : std_logic;
  signal s_ttc_cmd            : std_logic_vector(3 downto 0);  -- TTC b command output
  signal s_ttc_l1a            : std_logic;                     -- L1A output
  signal s_ttc_mmcm_ctrl      : t_ttc_mmcm_ctrl;
  signal s_ttc_mmcm_stat      : t_ttc_mmcm_stat;
  signal s_ttc_ctrl           : t_ttc_ctrl;
  signal s_ttc_stat           : t_ttc_stat;
  signal s_ttc_diag_cntrs_o   : t_ttc_diag_cntrs;
  signal s_ttc_daq_cntrs      : t_ttc_daq_cntrs;
  signal s_ttc_bgo_cmds       : t_ttc_bgo_cmds;

  signal s_local_timing_ref : t_timing_ref;

  signal s_resync : std_logic;
  signal s_l1a    : std_logic;

  signal s_gth_gt_txreset        : std_logic_vector(C_NUM_OF_GTH_GTs-1 downto 0);
  signal s_gth_gt_rxreset        : std_logic_vector(C_NUM_OF_GTH_GTs-1 downto 0);
  signal s_gth_gt_txreset_sticky : std_logic_vector(C_NUM_OF_GTH_GTs-1 downto 0);
  signal s_gth_gt_rxreset_sticky : std_logic_vector(C_NUM_OF_GTH_GTs-1 downto 0);

  signal s_clk_gth_tx_usrclk_arr : std_logic_vector(C_NUM_OF_GTH_GTs-1 downto 0);
  signal s_clk_gth_rx_usrclk_arr : std_logic_vector(C_NUM_OF_GTH_GTs-1 downto 0);

  signal gth_cpll_reset_arr    : std_logic_vector(C_NUM_OF_GTH_GTs-1 downto 0);
  signal s_gth_cpll_status_arr : t_gth_cpll_status_arr(C_NUM_OF_GTH_GTs-1 downto 0);

  signal s_gth_common_ctrl_arr    : t_gth_common_ctrl_arr(C_NUM_OF_GTH_COMMONs-1 downto 0);
  signal s_gth_common_status_arr  : t_gth_common_status_arr(C_NUM_OF_GTH_COMMONs-1 downto 0);
  signal s_gth_common_drp_in_arr  : t_gth_common_drp_in_arr(C_NUM_OF_GTH_COMMONs-1 downto 0);
  signal s_gth_common_drp_out_arr : t_gth_common_drp_out_arr(C_NUM_OF_GTH_COMMONs-1 downto 0);

  signal s_gth_gt_txreset_done  : std_logic_vector(C_NUM_OF_GTH_GTs-1 downto 0);
  signal s_gth_gt_rxreset_done  : std_logic_vector(C_NUM_OF_GTH_GTs-1 downto 0);
  signal s_gth_gt_rxdfelpmreset : std_logic_vector(C_NUM_OF_GTH_GTs-1 downto 0);
  signal s_gth_gt_rxcdrreset    : std_logic_vector(C_NUM_OF_GTH_GTs-1 downto 0);


  signal s_gth_gt_drp_in_arr   : t_gth_gt_drp_in_arr(C_NUM_OF_GTH_GTs-1 downto 0);
  signal s_gth_gt_drp_out_arr  : t_gth_gt_drp_out_arr(C_NUM_OF_GTH_GTs-1 downto 0);
  signal s_gth_tx_ctrl_arr     : t_gth_tx_ctrl_arr(C_NUM_OF_GTH_GTs-1 downto 0);
  signal s_gth_tx_status_arr   : t_gth_tx_status_arr(C_NUM_OF_GTH_GTs-1 downto 0);
  signal s_gth_rx_ctrl_arr     : t_gth_rx_ctrl_arr(C_NUM_OF_GTH_GTs-1 downto 0);
  signal s_gth_rx_status_arr   : t_gth_rx_status_arr(C_NUM_OF_GTH_GTs-1 downto 0);
  signal s_gth_misc_ctrl_arr   : t_gth_misc_ctrl_arr(C_NUM_OF_GTH_GTs-1 downto 0);
  signal s_gth_misc_status_arr : t_gth_misc_status_arr(C_NUM_OF_GTH_GTs-1 downto 0);
  signal s_gth_tx_data_arr     : t_gth_tx_data_arr(C_NUM_OF_GTH_GTs-1 downto 0);
  signal s_gth_rx_data_arr     : t_gth_rx_data_arr(C_NUM_OF_GTH_GTs-1 downto 0);

  signal s_gth_rx_cdr_ctrl_arr          : t_gth_rx_cdr_ctrl_arr(C_NUM_OF_GTH_GTs-1 downto 0);
  signal s_gth_rx_eq_cdr_dfe_status_arr : t_gth_rx_eq_cdr_dfe_status_arr(C_NUM_OF_GTH_GTs-1 downto 0);
  signal s_gth_rx_lpm_ctrl_arr          : t_gth_rx_lpm_ctrl_arr(C_NUM_OF_GTH_GTs-1 downto 0);
  signal s_gth_rx_dfe_agc_ctrl_arr      : t_gth_rx_dfe_agc_ctrl_arr(C_NUM_OF_GTH_GTs-1 downto 0);
  signal s_gth_rx_dfe_1_ctrl_arr        : t_gth_rx_dfe_1_ctrl_arr(C_NUM_OF_GTH_GTs-1 downto 0);
  signal s_gth_rx_dfe_2_ctrl_arr        : t_gth_rx_dfe_2_ctrl_arr(C_NUM_OF_GTH_GTs-1 downto 0);
  signal s_gth_rx_os_ctrl_arr           : t_gth_rx_os_ctrl_arr(C_NUM_OF_GTH_GTs-1 downto 0);

  -------------------------------------------------------

  signal s_txdata    : t_slv_arr_32(C_NUM_OF_GTH_GTs-1 downto 0);
  signal s_txcharisk : t_slv_arr_4(C_NUM_OF_GTH_GTs-1 downto 0);

  signal s_LED_FP : std_logic_vector(31 downto 0);

  signal s_pattern_start_request : std_logic;
  signal s_algo_latency          : std_logic_vector (15 downto 0);


  signal s_capture_arm      : std_logic;
  signal s_capture_done_arr : std_logic_vector(C_NUM_OF_GTH_GTs-1 downto 0);


  signal s_capture_start_bx_id          : std_logic_vector(11 downto 0);
  signal s_link_latency_ctrl            : std_logic_vector(15 downto 0);
  signal s_link_mask_ctrl               : std_logic_vector(C_NUM_OF_GTH_GTs-1 downto 0);
  signal s_link_aligned_diagnostics_arr : t_link_aligned_diagnostics_arr(C_NUM_OF_GTH_GTs-1 downto 0);

  signal s_link_align_req   : std_logic;
  signal s_link_latency_err : std_logic;

  signal s_link_align     : std_logic;
  signal s_link_fifo_read : std_logic;

  signal s_link_8b10b_err_rst : std_logic;

  signal link_aligned_RX_status_arr : t_link_aligned_status_arr(C_NUM_OF_GTH_GTs-1 downto 0);

  signal link_data_RX_arr_i          : t_link_aligned_data_arr(63 downto 0) := (others => C_link_aligned_data_null);
  signal link_data_RX_arr_o          : t_link_aligned_data_arr(63 downto 0) := (others => C_link_aligned_data_null);
  signal link_buffer_ctrl_RX_arr_i   : t_link_buffer_ctrl_arr(63 downto 0)  := (others => C_link_buffer_ctrl_PB);
  signal link_buffer_status_RX_arr_o : t_link_buffer_status_arr(63 downto 0);


  signal link_data_TX_arr_i          : t_link_aligned_data_arr(63 downto 0) := (others => C_link_aligned_data_null);
  signal link_data_TX_arr_o          : t_link_aligned_data_arr(63 downto 0) := (others => C_link_aligned_data_null);
  signal link_buffer_ctrl_TX_arr_i   : t_link_buffer_ctrl_arr(63 downto 0)  := (others => C_link_buffer_ctrl_CAP);
  signal link_buffer_status_TX_arr_o : t_link_buffer_status_arr(63 downto 0);


  signal link_out_TVALID_n  : std_logic;
  signal link_tx_timing_ref : t_timing_ref;

  signal ap_clk : std_logic;
  signal ap_rst : std_logic := '0';

  signal ap_start : std_logic := '1';
  signal ap_done  : std_logic;
  signal ap_idle  : std_logic;
  signal ap_ready : std_logic;

  signal algo_in_fifo_din   : t_slv_arr_34(47 downto 0)     := (others => (others => '0'));
  signal algo_in_fifo_dout  : t_slv_arr_68(47 downto 0)     := (others => (others => '0'));
  signal algo_in_fifo_rst   : std_logic_vector(47 downto 0) := (others => '0');
  signal algo_in_fifo_wr_en : std_logic_vector(47 downto 0) := (others => '0');
  signal algo_in_fifo_rd_en : std_logic_vector(47 downto 0) := (others => '0');
  signal algo_in_fifo_empty : std_logic_vector(47 downto 0) := (others => '0');

  signal algo_out_fifo_din   : t_slv_arr_68(47 downto 0)     := (others => (others => '0'));
  signal algo_out_fifo_dout  : t_slv_arr_34(47 downto 0)     := (others => (others => '0'));
  signal algo_out_fifo_rst   : std_logic_vector(47 downto 0) := (others => '0');
  signal algo_out_fifo_wr_en : std_logic_vector(47 downto 0) := (others => '0');
  signal algo_out_fifo_rd_en : std_logic_vector(47 downto 0) := (others => '0');
  signal algo_out_fifo_empty : std_logic_vector(47 downto 0) := (others => '0');

  signal link_in_master : LinkMasterArrType(47 downto 0);
  signal link_in_slave  : LinkSlaveArrType(47 downto 0);

  signal link_out_master : LinkMasterArrType(47 downto 0);
  signal link_out_slave  : LinkSlaveArrType(47 downto 0);

  signal algo_reset      : std_logic;
  signal algo_reset_sync : std_logic;

  signal algo_reset_edge : std_logic;


  signal tx_link_timing_ref : t_link_timing_ref_arr(63 downto 0);

begin

  LED_GREEN_o <= s_LED_FP(0);
  LED_RED_o   <= s_LED_FP(1);
  LED_BLUE_o  <= s_LED_FP(2);

  i_v7_bd : v7_bd
    port map (

      axi_c2c_v7_to_zynq_clk               => axi_c2c_v7_to_zynq_clk,
      axi_c2c_v7_to_zynq_data(16 downto 0) => axi_c2c_v7_to_zynq_data(16 downto 0),
      axi_c2c_v7_to_zynq_link_status       => axi_c2c_v7_to_zynq_link_status,
      axi_c2c_zynq_to_v7_clk               => axi_c2c_zynq_to_v7_clk,
      axi_c2c_zynq_to_v7_data(16 downto 0) => axi_c2c_zynq_to_v7_data(16 downto 0),
      axi_c2c_zynq_to_v7_reset             => axi_c2c_zynq_to_v7_reset,

      clk_200_diff_in_clk_n => clk_200_diff_in_clk_n,
      clk_200_diff_in_clk_p => clk_200_diff_in_clk_p,

      BRAM_CTRL_DRP_addr => BRAM_CTRL_DRP_addr,
      BRAM_CTRL_DRP_clk  => BRAM_CTRL_DRP_clk,
      BRAM_CTRL_DRP_din  => BRAM_CTRL_DRP_din,
      BRAM_CTRL_DRP_dout => BRAM_CTRL_DRP_dout,
      BRAM_CTRL_DRP_en   => BRAM_CTRL_DRP_en,
      BRAM_CTRL_DRP_rst  => BRAM_CTRL_DRP_rst,
      BRAM_CTRL_DRP_we   => BRAM_CTRL_DRP_we,

      BRAM_CTRL_REG_FILE_addr => BRAM_CTRL_REG_FILE_addr,
      BRAM_CTRL_REG_FILE_clk  => BRAM_CTRL_REG_FILE_clk,
      BRAM_CTRL_REG_FILE_din  => BRAM_CTRL_REG_FILE_din,
      BRAM_CTRL_REG_FILE_dout => BRAM_CTRL_REG_FILE_dout,
      BRAM_CTRL_REG_FILE_en   => BRAM_CTRL_REG_FILE_en,
      BRAM_CTRL_REG_FILE_rst  => BRAM_CTRL_REG_FILE_rst,
      BRAM_CTRL_REG_FILE_we   => BRAM_CTRL_REG_FILE_we,

      BRAM_CTRL_GTH_REG_FILE_addr => BRAM_CTRL_GTH_REG_FILE_addr,
      BRAM_CTRL_GTH_REG_FILE_clk  => BRAM_CTRL_GTH_REG_FILE_clk,
      BRAM_CTRL_GTH_REG_FILE_din  => BRAM_CTRL_GTH_REG_FILE_din,
      BRAM_CTRL_GTH_REG_FILE_dout => BRAM_CTRL_GTH_REG_FILE_dout,
      BRAM_CTRL_GTH_REG_FILE_en   => BRAM_CTRL_GTH_REG_FILE_en,
      BRAM_CTRL_GTH_REG_FILE_rst  => BRAM_CTRL_GTH_REG_FILE_rst,
      BRAM_CTRL_GTH_REG_FILE_we   => BRAM_CTRL_GTH_REG_FILE_we,

      BRAM_CTRL_INPUT_RAM_0_addr => BRAM_CTRL_INPUT_RAM_0_addr,
      BRAM_CTRL_INPUT_RAM_0_clk  => BRAM_CTRL_INPUT_RAM_0_clk,
      BRAM_CTRL_INPUT_RAM_0_din  => BRAM_CTRL_INPUT_RAM_0_din,
      BRAM_CTRL_INPUT_RAM_0_dout => BRAM_CTRL_INPUT_RAM_0_dout,
      BRAM_CTRL_INPUT_RAM_0_en   => BRAM_CTRL_INPUT_RAM_0_en,
      BRAM_CTRL_INPUT_RAM_0_rst  => BRAM_CTRL_INPUT_RAM_0_rst,
      BRAM_CTRL_INPUT_RAM_0_we   => BRAM_CTRL_INPUT_RAM_0_we,

      BRAM_CTRL_INPUT_RAM_1_addr => BRAM_CTRL_INPUT_RAM_1_addr,
      BRAM_CTRL_INPUT_RAM_1_clk  => BRAM_CTRL_INPUT_RAM_1_clk,
      BRAM_CTRL_INPUT_RAM_1_din  => BRAM_CTRL_INPUT_RAM_1_din,
      BRAM_CTRL_INPUT_RAM_1_dout => BRAM_CTRL_INPUT_RAM_1_dout,
      BRAM_CTRL_INPUT_RAM_1_en   => BRAM_CTRL_INPUT_RAM_1_en,
      BRAM_CTRL_INPUT_RAM_1_rst  => BRAM_CTRL_INPUT_RAM_1_rst,
      BRAM_CTRL_INPUT_RAM_1_we   => BRAM_CTRL_INPUT_RAM_1_we,

      BRAM_CTRL_OUTPUT_RAM_0_addr => BRAM_CTRL_OUTPUT_RAM_0_addr,
      BRAM_CTRL_OUTPUT_RAM_0_clk  => BRAM_CTRL_OUTPUT_RAM_0_clk,
      BRAM_CTRL_OUTPUT_RAM_0_din  => BRAM_CTRL_OUTPUT_RAM_0_din,
      BRAM_CTRL_OUTPUT_RAM_0_dout => BRAM_CTRL_OUTPUT_RAM_0_dout,
      BRAM_CTRL_OUTPUT_RAM_0_en   => BRAM_CTRL_OUTPUT_RAM_0_en,
      BRAM_CTRL_OUTPUT_RAM_0_rst  => BRAM_CTRL_OUTPUT_RAM_0_rst,
      BRAM_CTRL_OUTPUT_RAM_0_we   => BRAM_CTRL_OUTPUT_RAM_0_we,

      BRAM_CTRL_OUTPUT_RAM_1_addr => BRAM_CTRL_OUTPUT_RAM_1_addr,
      BRAM_CTRL_OUTPUT_RAM_1_clk  => BRAM_CTRL_OUTPUT_RAM_1_clk,
      BRAM_CTRL_OUTPUT_RAM_1_din  => BRAM_CTRL_OUTPUT_RAM_1_din,
      BRAM_CTRL_OUTPUT_RAM_1_dout => BRAM_CTRL_OUTPUT_RAM_1_dout,
      BRAM_CTRL_OUTPUT_RAM_1_en   => BRAM_CTRL_OUTPUT_RAM_1_en,
      BRAM_CTRL_OUTPUT_RAM_1_rst  => BRAM_CTRL_OUTPUT_RAM_1_rst,
      BRAM_CTRL_OUTPUT_RAM_1_we   => BRAM_CTRL_OUTPUT_RAM_1_we,

      clk_50mhz => s_clk_50
      );

  i_register_file : entity work.register_file
    port map (
      clk40_i  => s_ttc_clk_40,
      clk240_i => s_ttc_clk_240,

      LED_FP_o => s_led_FP,

      BRAM_CTRL_REG_FILE_addr => BRAM_CTRL_REG_FILE_addr,
      BRAM_CTRL_REG_FILE_clk  => BRAM_CTRL_REG_FILE_clk,
      BRAM_CTRL_REG_FILE_din  => BRAM_CTRL_REG_FILE_din,
      BRAM_CTRL_REG_FILE_dout => BRAM_CTRL_REG_FILE_dout,
      BRAM_CTRL_REG_FILE_en   => BRAM_CTRL_REG_FILE_en,
      BRAM_CTRL_REG_FILE_rst  => BRAM_CTRL_REG_FILE_rst,
      BRAM_CTRL_REG_FILE_we   => BRAM_CTRL_REG_FILE_we,

      ttc_mmcm_ctrl_o => s_ttc_mmcm_ctrl,
      ttc_mmcm_stat_i => s_ttc_mmcm_stat,

      ttc_ctrl_o => s_ttc_ctrl,
      ttc_stat_i => s_ttc_stat,

      ttc_diag_cntrs_i => s_ttc_diag_cntrs_o,
      ttc_daq_cntrs_i  => s_ttc_daq_cntrs,

      link_latency_ctrl_o          => s_link_latency_ctrl,
      link_mask_ctrl_o             => s_link_mask_ctrl,
      link_aligned_diagnostics_arr => s_link_aligned_diagnostics_arr,
      link_aligned_status_arr_i    => link_aligned_RX_status_arr,

      link_align_req_o   => s_link_align_req,
      link_latency_err_i => s_link_latency_err,

      algo_reset => algo_reset,

      gth_gt_txreset_done_i => s_gth_gt_txreset_done,
      gth_gt_rxreset_done_i => s_gth_gt_rxreset_done,

      link_buffer_ctrl_RX_arr   => link_buffer_ctrl_RX_arr_i,
      link_buffer_status_RX_arr => link_buffer_status_RX_arr_o,

      link_buffer_ctrl_TX_arr   => link_buffer_ctrl_TX_arr_i,
      link_buffer_status_TX_arr => link_buffer_status_TX_arr_o
      );

  i_gth_register_file : entity work.gth_register_file
    generic map (
      G_NUM_OF_GTH_GTs     => C_NUM_OF_GTH_GTs,
      G_NUM_OF_GTH_COMMONs => C_NUM_OF_GTH_COMMONs
      )
    port map (

      BRAM_CTRL_GTH_REG_FILE_addr => BRAM_CTRL_GTH_REG_FILE_addr,
      BRAM_CTRL_GTH_REG_FILE_clk  => BRAM_CTRL_GTH_REG_FILE_clk,
      BRAM_CTRL_GTH_REG_FILE_din  => BRAM_CTRL_GTH_REG_FILE_din,
      BRAM_CTRL_GTH_REG_FILE_dout => BRAM_CTRL_GTH_REG_FILE_dout,
      BRAM_CTRL_GTH_REG_FILE_en   => BRAM_CTRL_GTH_REG_FILE_en,
      BRAM_CTRL_GTH_REG_FILE_rst  => BRAM_CTRL_GTH_REG_FILE_rst,
      BRAM_CTRL_GTH_REG_FILE_we   => BRAM_CTRL_GTH_REG_FILE_we,

      clk_gth_tx_usrclk_arr_i => s_clk_gth_tx_usrclk_arr,
      clk_gth_rx_usrclk_arr_i => s_clk_gth_rx_usrclk_arr,

      gth_tx_data_arr_i => s_gth_tx_data_arr,
      gth_rx_data_arr_i => s_gth_rx_data_arr,

      gth_common_ctrl_arr_o   => s_gth_common_ctrl_arr,
      gth_common_status_arr_i => s_gth_common_status_arr,

      gth_cpll_reset_arr_o  => gth_cpll_reset_arr,
      gth_cpll_status_arr_i => s_gth_cpll_status_arr,

      gth_gt_txreset_o        => s_gth_gt_txreset,
      gth_gt_txreset_sticky_o => s_gth_gt_txreset_sticky,
      gth_gt_rxreset_o        => s_gth_gt_rxreset,
      gth_gt_rxreset_sticky_o => s_gth_gt_rxreset_sticky,
      gth_gt_rxdfelpmreset_o  => s_gth_gt_rxdfelpmreset,
      gth_gt_rxcdrreset_o     => s_gth_gt_rxcdrreset,

      gth_gt_txreset_done_i => s_gth_gt_txreset_done,
      gth_gt_rxreset_done_i => s_gth_gt_rxreset_done,

      gth_tx_ctrl_arr_o   => s_gth_tx_ctrl_arr,
      gth_tx_status_arr_i => s_gth_tx_status_arr,

      gth_rx_ctrl_arr_o   => s_gth_rx_ctrl_arr,
      gth_rx_status_arr_i => s_gth_rx_status_arr,

      gth_rx_cdr_ctrl_arr_o          => s_gth_rx_cdr_ctrl_arr,
      gth_rx_eq_cdr_dfe_status_arr_i => s_gth_rx_eq_cdr_dfe_status_arr,
      gth_rx_lpm_ctrl_arr_o          => s_gth_rx_lpm_ctrl_arr,
      gth_rx_dfe_agc_ctrl_arr_o      => s_gth_rx_dfe_agc_ctrl_arr,
      gth_rx_dfe_1_ctrl_arr_o        => s_gth_rx_dfe_1_ctrl_arr,
      gth_rx_dfe_2_ctrl_arr_o        => s_gth_rx_dfe_2_ctrl_arr,
      gth_rx_os_ctrl_arr_o           => s_gth_rx_os_ctrl_arr,

      gth_misc_ctrl_arr_o   => s_gth_misc_ctrl_arr,
      gth_misc_status_arr_i => s_gth_misc_status_arr

      );


  i_drp_controller : entity work.drp_controller
    port map (
      BRAM_CTRL_DRP_en   => BRAM_CTRL_DRP_en,
      BRAM_CTRL_DRP_dout => BRAM_CTRL_DRP_dout,
      BRAM_CTRL_DRP_din  => BRAM_CTRL_DRP_din,
      BRAM_CTRL_DRP_we   => BRAM_CTRL_DRP_we,
      BRAM_CTRL_DRP_addr => BRAM_CTRL_DRP_addr,
      BRAM_CTRL_DRP_clk  => BRAM_CTRL_DRP_clk,
      BRAM_CTRL_DRP_rst  => BRAM_CTRL_DRP_rst,

      gth_common_drp_arr_o => s_gth_common_drp_in_arr,
      gth_common_drp_arr_i => s_gth_common_drp_out_arr,

      gth_gt_drp_arr_o => s_gth_gt_drp_in_arr,
      gth_gt_drp_arr_i => s_gth_gt_drp_out_arr

      );

  i_gth_wrapper : entity work.gth_wrapper
    generic map
    (
      g_EXAMPLE_SIMULATION     => 0,
      g_STABLE_CLOCK_PERIOD    => 20,
      G_NUM_OF_GTH_GTs         => C_NUM_OF_GTH_GTs,
      G_NUM_OF_GTH_COMMONs     => C_NUM_OF_GTH_COMMONs,
      g_GT_SIM_GTRESET_SPEEDUP => "TRUE"
      )
    port map (
      clk_stable_i => s_clk_50,

      clk_ttc_120_i => s_ttc_clk_120,
      clk_ttc_240_i => s_ttc_clk_240,

      refclk_F_0_p_i => refclk_F_0_p_i,
      refclk_F_0_n_i => refclk_F_0_n_i,
      refclk_F_1_p_i => refclk_F_1_p_i,
      refclk_F_1_n_i => refclk_F_1_n_i,
      refclk_B_0_p_i => refclk_B_0_p_i,
      refclk_B_0_n_i => refclk_B_0_n_i,
      refclk_B_1_p_i => refclk_B_1_p_i,
      refclk_B_1_n_i => refclk_B_1_n_i,

      clk_gth_tx_usrclk_arr_o => s_clk_gth_tx_usrclk_arr,
      clk_gth_rx_usrclk_arr_o => s_clk_gth_rx_usrclk_arr,

      gth_common_ctrl_arr_i   => s_gth_common_ctrl_arr,
      gth_common_status_arr_o => s_gth_common_status_arr,

      gth_cpll_reset_arr_i  => gth_cpll_reset_arr,
      gth_cpll_status_arr_o => s_gth_cpll_status_arr,

      gth_common_drp_arr_i => s_gth_common_drp_in_arr,
      gth_common_drp_arr_o => s_gth_common_drp_out_arr,

      gth_gt_txreset_i        => s_gth_gt_txreset,
      gth_gt_txreset_sticky_i => s_gth_gt_txreset_sticky,
      gth_gt_rxreset_i        => s_gth_gt_rxreset,
      gth_gt_rxreset_sticky_i => s_gth_gt_rxreset_sticky,
      gth_gt_rxdfelpmreset_i  => s_gth_gt_rxdfelpmreset,
      gth_gt_rxcdrreset_i     => s_gth_gt_rxcdrreset,

      gth_gt_txreset_done_o => s_gth_gt_txreset_done,
      gth_gt_rxreset_done_o => s_gth_gt_rxreset_done,

      gth_gt_drp_arr_i => s_gth_gt_drp_in_arr,
      gth_gt_drp_arr_o => s_gth_gt_drp_out_arr,

      gth_tx_ctrl_arr_i   => s_gth_tx_ctrl_arr,
      gth_tx_status_arr_o => s_gth_tx_status_arr,

      gth_rx_ctrl_arr_i   => s_gth_rx_ctrl_arr,
      gth_rx_status_arr_o => s_gth_rx_status_arr,

      gth_rx_cdr_ctrl_arr_i          => s_gth_rx_cdr_ctrl_arr,
      gth_rx_eq_cdr_dfe_status_arr_o => s_gth_rx_eq_cdr_dfe_status_arr,
      gth_rx_lpm_ctrl_arr_i          => s_gth_rx_lpm_ctrl_arr,
      gth_rx_dfe_agc_ctrl_arr_i      => s_gth_rx_dfe_agc_ctrl_arr,
      gth_rx_dfe_1_ctrl_arr_i        => s_gth_rx_dfe_1_ctrl_arr,
      gth_rx_dfe_2_ctrl_arr_i        => s_gth_rx_dfe_2_ctrl_arr,
      gth_rx_os_ctrl_arr_i           => s_gth_rx_os_ctrl_arr,

      gth_misc_ctrl_arr_i   => s_gth_misc_ctrl_arr,
      gth_misc_status_arr_o => s_gth_misc_status_arr,

      gth_tx_data_arr_i => s_gth_tx_data_arr,
      gth_rx_data_arr_o => s_gth_rx_data_arr

      );

  i_ctp7_ttc : entity work.ctp7_ttc
    port map(

      clk_40_ttc_p_i => clk_40_ttc_p_i,
      clk_40_ttc_n_i => clk_40_ttc_n_i,

      ttc_data_p_i => ttc_data_p_i,
      ttc_data_n_i => ttc_data_n_i,

      clk_40_bufg_o  => s_ttc_clk_40,
      clk_120_bufg_o => s_ttc_clk_120,
      clk_240_bufg_o => s_ttc_clk_240,

      local_timing_ref_o => s_local_timing_ref,
      ttc_bgo_cmds_o     => s_ttc_bgo_cmds,

      ttc_l1a_o    => s_l1a,
      ttc_resync_o => s_resync,

      ttc_mmcm_ps_clk_i => s_ttc_mmcm_ps_clk,

      ttc_mmcm_ctrl_i => s_ttc_mmcm_ctrl,
      ttc_mmcm_stat_o => s_ttc_mmcm_stat,

      ttc_ctrl_i => s_ttc_ctrl,
      ttc_stat_o => s_ttc_stat,

      ttc_diag_cntrs_o => s_ttc_diag_cntrs_o,
      ttc_daq_cntrs_o  => s_ttc_daq_cntrs
      );


  i_link_align_ctrl : entity work.link_align_ctrl
    generic map (
      G_NUM_OF_LINKs => C_NUM_OF_GTH_GTs
      )
    port map(
      clk_240_i                      => s_ttc_clk_240,
      link_align_req_i               => s_link_align_req,
      bx0_at_240_i                   => s_local_timing_ref.bc0,
      link_align_o                   => s_link_align,
      link_fifo_read_o               => s_link_fifo_read,
      link_latency_ctrl_i            => s_link_latency_ctrl,
      link_latency_err_o             => s_link_latency_err,
      link_mask_ctrl_i               => s_link_mask_ctrl,
      link_aligned_status_arr_i      => link_aligned_RX_status_arr,
      link_aligned_diagnostics_arr_o => s_link_aligned_diagnostics_arr
      );

  i_link_buffer_ctrl_RX : entity work.link_buffer_ctrl
    port map (
      clk_240_i => s_ttc_clk_240,
      rst_i     => '0',

      local_timing_ref_i => s_local_timing_ref,
      link_realign_i     => s_link_align,

      link_aligned_data_arr_i => link_data_RX_arr_i,
      link_aligned_data_arr_o => link_data_RX_arr_o,

      link_buffer_ctrl_arr_i   => link_buffer_ctrl_RX_arr_i,
      link_buffer_status_arr_o => link_buffer_status_RX_arr_o,

      BRAM_CTRL_CAP_RAM_0_addr => BRAM_CTRL_INPUT_RAM_0_addr,
      BRAM_CTRL_CAP_RAM_0_clk  => BRAM_CTRL_INPUT_RAM_0_clk,
      BRAM_CTRL_CAP_RAM_0_din  => BRAM_CTRL_INPUT_RAM_0_din,
      BRAM_CTRL_CAP_RAM_0_dout => BRAM_CTRL_INPUT_RAM_0_dout,
      BRAM_CTRL_CAP_RAM_0_en   => BRAM_CTRL_INPUT_RAM_0_en,
      BRAM_CTRL_CAP_RAM_0_rst  => BRAM_CTRL_INPUT_RAM_0_rst,
      BRAM_CTRL_CAP_RAM_0_we   => BRAM_CTRL_INPUT_RAM_0_we,

      BRAM_CTRL_CAP_RAM_1_addr => BRAM_CTRL_INPUT_RAM_1_addr,
      BRAM_CTRL_CAP_RAM_1_clk  => BRAM_CTRL_INPUT_RAM_1_clk,
      BRAM_CTRL_CAP_RAM_1_din  => BRAM_CTRL_INPUT_RAM_1_din,
      BRAM_CTRL_CAP_RAM_1_dout => BRAM_CTRL_INPUT_RAM_1_dout,
      BRAM_CTRL_CAP_RAM_1_en   => BRAM_CTRL_INPUT_RAM_1_en,
      BRAM_CTRL_CAP_RAM_1_rst  => BRAM_CTRL_INPUT_RAM_1_rst,
      BRAM_CTRL_CAP_RAM_1_we   => BRAM_CTRL_INPUT_RAM_1_we

      );

  i_link_buffer_ctrl_TX : entity work.link_buffer_ctrl
    port map (
      clk_240_i => s_ttc_clk_240,
      rst_i     => '0',

      local_timing_ref_i => s_local_timing_ref,
      link_realign_i     => s_link_align,

      link_aligned_data_arr_i => link_data_TX_arr_i,
      link_aligned_data_arr_o => link_data_TX_arr_o,

      link_buffer_ctrl_arr_i   => link_buffer_ctrl_TX_arr_i,
      link_buffer_status_arr_o => link_buffer_status_TX_arr_o,

      BRAM_CTRL_CAP_RAM_0_addr => BRAM_CTRL_OUTPUT_RAM_0_addr,
      BRAM_CTRL_CAP_RAM_0_clk  => BRAM_CTRL_OUTPUT_RAM_0_clk,
      BRAM_CTRL_CAP_RAM_0_din  => BRAM_CTRL_OUTPUT_RAM_0_din,
      BRAM_CTRL_CAP_RAM_0_dout => BRAM_CTRL_OUTPUT_RAM_0_dout,
      BRAM_CTRL_CAP_RAM_0_en   => BRAM_CTRL_OUTPUT_RAM_0_en,
      BRAM_CTRL_CAP_RAM_0_rst  => BRAM_CTRL_OUTPUT_RAM_0_rst,
      BRAM_CTRL_CAP_RAM_0_we   => BRAM_CTRL_OUTPUT_RAM_0_we,

      BRAM_CTRL_CAP_RAM_1_addr => BRAM_CTRL_OUTPUT_RAM_1_addr,
      BRAM_CTRL_CAP_RAM_1_clk  => BRAM_CTRL_OUTPUT_RAM_1_clk,
      BRAM_CTRL_CAP_RAM_1_din  => BRAM_CTRL_OUTPUT_RAM_1_din,
      BRAM_CTRL_CAP_RAM_1_dout => BRAM_CTRL_OUTPUT_RAM_1_dout,
      BRAM_CTRL_CAP_RAM_1_en   => BRAM_CTRL_OUTPUT_RAM_1_en,
      BRAM_CTRL_CAP_RAM_1_rst  => BRAM_CTRL_OUTPUT_RAM_1_rst,
      BRAM_CTRL_CAP_RAM_1_we   => BRAM_CTRL_OUTPUT_RAM_1_we
      );

  ap_clk <= s_ttc_clk_120;

  i_algo_reset_sync : synchronizer
    generic map (
      N_STAGES => 2
      )
    port map(
      async_i => algo_reset,
      clk_i   => s_ttc_clk_40,
      sync_o  => algo_reset_sync
      );

  i_algo_reset : edge_detect
    generic map (
      EDGE_DETECT_TYPE => "RISE"
      )
    port map(
      clk  => s_ttc_clk_40,
      sig  => algo_reset_sync,
      edge => algo_reset_edge
      );

  ap_rst <= algo_in_fifo_empty(0);

  g_algo_fifos : for idx in 0 to 47 generate

    process(s_ttc_clk_240) is
    begin
      if rising_edge(s_ttc_clk_240) then

        if (algo_reset_edge = '1') then  -- todo: sync such to allow enough reset cycles
          algo_in_fifo_rst(idx) <= '1';
        elsif (link_data_RX_arr_o(idx).bx_id = x"de0") then
          algo_in_fifo_rst(idx) <= '0';
        end if;

        if (algo_reset_edge = '1') then
          algo_in_fifo_wr_en(idx) <= '0';

        elsif (link_data_RX_arr_o(idx).bx_id = x"DEB" and link_data_RX_arr_o(idx).sub_bx_id = "101") then
          algo_in_fifo_wr_en(idx) <= '1';
        end if;

        algo_out_fifo_rst(idx) <= ap_rst;

        if (ap_rst = '1') then
          algo_out_fifo_wr_en(idx) <= '0';
        elsif (link_out_master(idx).tvalid = '1') then
          algo_out_fifo_wr_en(idx) <= '1';
        end if;

      end if;
    end process;


    algo_in_fifo_rd_en(idx)  <= not algo_in_fifo_empty(idx);
    algo_out_fifo_rd_en(idx) <= not algo_out_fifo_empty(idx);


    algo_in_fifo_din(idx)(31 downto 0) <= link_data_RX_arr_o(idx).data;
    algo_in_fifo_din(idx)(32)          <= link_data_RX_arr_o(idx).data_valid;
--algo_in_fifo_din(idx)(33) <= link_data_RX_arr_o(idx).last;
    algo_in_fifo_din(idx)(33)          <= '0';


    link_in_master(idx).tdata(63 downto 32) <= algo_in_fifo_dout(idx)(31 downto 0);  
    link_in_master(idx).tdata(31 downto 0)  <= algo_in_fifo_dout(idx)(65 downto 34);  
    link_in_master(idx).tvalid              <= algo_in_fifo_dout(idx)(66);  
    link_in_master(idx).tlast               <= algo_in_fifo_dout(idx)(67);  

    algo_out_fifo_din(idx)(31 downto 0)  <= link_out_master(idx).tdata(63 downto 32);
    algo_out_fifo_din(idx)(65 downto 34) <= link_out_master(idx).tdata(31 downto 0);

    algo_out_fifo_din(idx)(32) <= link_out_master(idx).tvalid;
    algo_out_fifo_din(idx)(66) <= link_out_master(idx).tvalid;
    algo_out_fifo_din(idx)(33) <= link_out_master(idx).tlast;
    algo_out_fifo_din(idx)(67) <= '0';

    link_out_slave(idx).tready <= '1';

    link_data_TX_arr_i(idx).data       <= algo_out_fifo_dout(idx)(31 downto 0);
    link_data_TX_arr_i(idx).data_valid <= algo_out_fifo_dout(idx)(32);
    link_data_TX_arr_i(idx).last       <= algo_out_fifo_dout(idx)(33);

    link_data_TX_arr_i(idx).BX_id     <= tx_link_timing_ref(idx).bcid;
    link_data_TX_arr_i(idx).sub_BX_id <= tx_link_timing_ref(idx).sub_bcid;
    link_data_TX_arr_i(idx).bc0       <= tx_link_timing_ref(idx).bc0;
    link_data_TX_arr_i(idx).cyc       <= tx_link_timing_ref(idx).cyc;

    i_tx_link_timing_ref_gen : entity work.link_timing_ref_gen
      generic map
      (
        g_bcid_rst     => x"000",
        g_sub_bcid_rst => "000",
        g_bc0_rst      => '0',
        g_cyc_rst      => '0'
        )
      port map(
        clk_240_i    => s_ttc_clk_240,
        rst_i        => not link_data_TX_arr_i(idx).data_valid,
        timing_ref_o => tx_link_timing_ref(idx)
        );

    i_fifo_algo_in : fifo_algo_in
      port map (
        wr_rst => algo_in_fifo_rst(idx),
        rd_rst => algo_in_fifo_rst(idx),

        wr_clk    => s_ttc_clk_240,
        rd_clk    => s_ttc_clk_120,
        din       => algo_in_fifo_din(idx),
        wr_en     => algo_in_fifo_wr_en(idx),
        rd_en     => algo_in_fifo_rd_en(idx),
        dout      => algo_in_fifo_dout(idx),
        full      => open,
        overflow  => open,
        empty     => algo_in_fifo_empty(idx),
        underflow => open
        );

    i_fifo_algo_out : fifo_algo_out
      port map (
        wr_rst => algo_out_fifo_rst(idx),
        rd_rst => algo_out_fifo_rst(idx),

        wr_clk    => s_ttc_clk_120,
        rd_clk    => s_ttc_clk_240,
        din       => algo_out_fifo_din(idx),
        wr_en     => algo_out_fifo_wr_en(idx),
        rd_en     => algo_out_fifo_rd_en(idx),
        dout      => algo_out_fifo_dout(idx),
        full      => open,
        overflow  => open,
        empty     => algo_out_fifo_empty(idx),
        underflow => open
        );
  end generate;

  gen_algo : if g_algo_include = 1 generate
    i_algo_top_wrapper : algo_top_wrapper
      port map(
        ap_clk   => ap_clk,
        ap_rst   => ap_rst,
        ap_start => ap_start,
        ap_done  => ap_done,
        ap_idle  => ap_idle,
        ap_ready => ap_ready,

        link_in_master  => link_in_master,
        link_in_slave   => link_in_slave,
        link_out_master => link_out_master,
        link_out_slave  => link_out_slave
        );

  end generate;

  gen_ila : if g_ila_include = 1 generate

    ila_link_data_RX_i : ila_link_data_1
      port map (
        clk       => s_ttc_clk_240,
        probe0    => link_data_RX_arr_i(0).data,
        probe1    => link_data_RX_arr_i(0).bx_id,
        probe2(0) => link_data_RX_arr_i(0).data_valid,
        probe3(0) => link_data_RX_arr_i(0).cyc,
        probe4(0) => link_data_RX_arr_i(0).bc0
        );

    ila_link_data_RX_o : ila_link_data_1
      port map (
        clk       => s_ttc_clk_240,
        probe0    => link_data_RX_arr_o(0).data,
        probe1    => link_data_RX_arr_o(0).bx_id,
        probe2(0) => link_data_RX_arr_o(0).data_valid,
        probe3(0) => link_data_RX_arr_o(0).cyc,
        probe4(0) => link_data_RX_arr_o(0).bc0
        );

    ila_link_data_TX_i : ila_link_data_1
      port map (
        clk       => s_ttc_clk_240,
        probe0    => link_data_TX_arr_i(0).data,
        probe1    => link_data_TX_arr_i(0).bx_id,
        probe2(0) => link_data_TX_arr_i(0).data_valid,
        probe3(0) => link_data_TX_arr_i(0).cyc,
        probe4(0) => link_data_TX_arr_i(0).bc0
        );

    ila_link_data_1_TX_o : ila_link_data_1
      port map (
        clk       => s_ttc_clk_240,
        probe0    => link_data_TX_arr_o(0).data,
        probe1    => link_data_TX_arr_o(0).bx_id,
        probe2(0) => link_data_TX_arr_o(0).data_valid,
        probe3(0) => link_data_TX_arr_o(0).cyc,
        probe4(0) => link_data_TX_arr_o(0).bc0
        );

  end generate;

  gen_tx_link_driver_0_35 : for i in 0 to 35 generate
    i_tx_link_driver : entity work.tx_link_driver
      port map(
        clk240_i => s_ttc_clk_240,
        clk250_i => s_clk_gth_tx_usrclk_arr(i),
        rst_i    => s_link_align,

        link_data_i => link_data_TX_arr_o(i),
        txdata_o    => s_gth_tx_data_arr(i).txdata(31 downto 0),
        txcharisk_o => s_gth_tx_data_arr(i).txcharisk

        );
  end generate;

  gen_tx_link_driver_36_47 : for i in 36 to 47 generate
    i_tx_link_driver : entity work.tx_link_driver
      port map(
        clk240_i => s_ttc_clk_240,
        clk250_i => s_clk_gth_tx_usrclk_arr(i),
        rst_i    => s_link_align,

        link_data_i => link_data_TX_arr_o(i),
        txdata_o    => s_gth_tx_data_arr(i+16).txdata(31 downto 0),
        txcharisk_o => s_gth_tx_data_arr(i+16).txcharisk

        );
  end generate;

  gen_rx_depad_cdc_align_0_35 : for i in 0 to 35 generate
    i_rx_depad_cdc_align : entity work.rx_depad_cdc_align
      port map(
        clk_250_i             => s_clk_gth_rx_usrclk_arr(i),
        clk_240_i             => s_ttc_clk_240,
        gth_rx_data_i         => s_gth_rx_data_arr(i),
        link_8b10b_err_rst_i  => s_link_8b10b_err_rst,
        realign_i             => s_link_align,
        start_fifo_read_i     => s_link_fifo_read,
        link_aligned_data_o   => link_data_RX_arr_i(i),
        link_aligned_status_o => link_aligned_RX_status_arr(i)
        );
  end generate;

  gen_rx_depad_cdc_align_36_47 : for i in 36 to 47 generate
    i_rx_depad_cdc_align : entity work.rx_depad_cdc_align
      port map(
        clk_250_i             => s_clk_gth_rx_usrclk_arr(i+8),
        clk_240_i             => s_ttc_clk_240,
        gth_rx_data_i         => s_gth_rx_data_arr(i+8),
        link_8b10b_err_rst_i  => s_link_8b10b_err_rst,
        realign_i             => s_link_align,
        start_fifo_read_i     => s_link_fifo_read,
        link_aligned_data_o   => link_data_RX_arr_i(i),
        link_aligned_status_o => link_aligned_RX_status_arr(i)
        );
  end generate;

end ctp7_top_arch;
