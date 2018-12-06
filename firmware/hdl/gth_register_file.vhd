library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.vcomponents.all;
use IEEE.std_logic_misc.all;

use work.gth_pkg.all;
use work.ctp7_utils_pkg.all;
use work.ctp7_v7_build_cfg_pkg.all;
use work.link_align_pkg.all;

--============================================================================
--                                                          Entity declaration
--============================================================================
entity gth_register_file is
  generic
    (
      G_NUM_OF_GTH_GTs     : integer := 80;
      G_NUM_OF_GTH_COMMONs : integer := 20
      );
  port (

    clk_gth_tx_usrclk_arr_i : in std_logic_vector(g_NUM_OF_GTH_GTs-1 downto 0);
    clk_gth_rx_usrclk_arr_i : in std_logic_vector(g_NUM_OF_GTH_GTs-1 downto 0);

    gth_tx_data_arr_i : in t_gth_tx_data_arr(g_NUM_OF_GTH_GTs-1 downto 0);
    gth_rx_data_arr_i : in t_gth_rx_data_arr(g_NUM_OF_GTH_GTs-1 downto 0);

    gth_common_ctrl_arr_o   : out t_gth_common_ctrl_arr(g_NUM_OF_GTH_COMMONs-1 downto 0);
    gth_common_status_arr_i : in  t_gth_common_status_arr(G_NUM_OF_GTH_COMMONs-1 downto 0);

    gth_cpll_reset_arr_o  : out std_logic_vector(G_NUM_OF_GTH_GTs-1 downto 0);
    gth_cpll_status_arr_i : in  t_gth_cpll_status_arr(G_NUM_OF_GTH_GTs-1 downto 0);

    gth_gt_txreset_o        : out std_logic_vector(G_NUM_OF_GTH_GTs-1 downto 0);
    gth_gt_txreset_sticky_o : out std_logic_vector(G_NUM_OF_GTH_GTs-1 downto 0);

    gth_gt_rxreset_o        : out std_logic_vector(G_NUM_OF_GTH_GTs-1 downto 0);
    gth_gt_rxreset_sticky_o : out std_logic_vector(G_NUM_OF_GTH_GTs-1 downto 0);

    gth_gt_rxdfelpmreset_o : out std_logic_vector(G_NUM_OF_GTH_GTs-1 downto 0);
    gth_gt_rxcdrreset_o    : out std_logic_vector(G_NUM_OF_GTH_GTs-1 downto 0);

    gth_gt_txreset_done_i : in std_logic_vector(G_NUM_OF_GTH_GTs-1 downto 0);
    gth_gt_rxreset_done_i : in std_logic_vector(G_NUM_OF_GTH_GTs-1 downto 0);

    gth_tx_ctrl_arr_o   : out t_gth_tx_ctrl_arr(G_NUM_OF_GTH_GTs-1 downto 0);
    gth_tx_status_arr_i : in  t_gth_tx_status_arr(G_NUM_OF_GTH_GTs-1 downto 0);

    gth_rx_ctrl_arr_o   : out t_gth_rx_ctrl_arr(G_NUM_OF_GTH_GTs-1 downto 0);
    gth_rx_status_arr_i : in  t_gth_rx_status_arr(G_NUM_OF_GTH_GTs-1 downto 0);

    gth_rx_cdr_ctrl_arr_o          : out t_gth_rx_cdr_ctrl_arr(G_NUM_OF_GTH_GTs-1 downto 0);
    gth_rx_eq_cdr_dfe_status_arr_i : in  t_gth_rx_eq_cdr_dfe_status_arr(G_NUM_OF_GTH_GTs-1 downto 0);
    gth_rx_lpm_ctrl_arr_o          : out t_gth_rx_lpm_ctrl_arr(G_NUM_OF_GTH_GTs-1 downto 0);
    gth_rx_dfe_agc_ctrl_arr_o      : out t_gth_rx_dfe_agc_ctrl_arr(G_NUM_OF_GTH_GTs-1 downto 0);
    gth_rx_dfe_1_ctrl_arr_o        : out t_gth_rx_dfe_1_ctrl_arr(G_NUM_OF_GTH_GTs-1 downto 0);
    gth_rx_dfe_2_ctrl_arr_o        : out t_gth_rx_dfe_2_ctrl_arr(G_NUM_OF_GTH_GTs-1 downto 0);
    gth_rx_os_ctrl_arr_o           : out t_gth_rx_os_ctrl_arr(G_NUM_OF_GTH_GTs-1 downto 0);

    gth_misc_ctrl_arr_o   : out t_gth_misc_ctrl_arr(G_NUM_OF_GTH_GTs-1 downto 0);
    gth_misc_status_arr_i : in  t_gth_misc_status_arr(G_NUM_OF_GTH_GTs-1 downto 0);

    BRAM_CTRL_GTH_REG_FILE_en   : in  std_logic;
    BRAM_CTRL_GTH_REG_FILE_dout : out std_logic_vector (31 downto 0);
    BRAM_CTRL_GTH_REG_FILE_din  : in  std_logic_vector (31 downto 0);
    BRAM_CTRL_GTH_REG_FILE_we   : in  std_logic_vector (3 downto 0);
    BRAM_CTRL_GTH_REG_FILE_addr : in  std_logic_vector (16 downto 0);
    BRAM_CTRL_GTH_REG_FILE_clk  : in  std_logic;
    BRAM_CTRL_GTH_REG_FILE_rst  : in  std_logic
    );
end gth_register_file;

--============================================================================
--                                                        Architecture section
--============================================================================
architecture gth_register_file_arch of gth_register_file is

  type t_bool_to_std_logic is array (boolean) of std_logic;
  constant c_bool_to_std_logic : t_bool_to_std_logic := (true => '1', false => '0');

--============================================================================
--                                                    GTH Channel Register Map
--============================================================================
  constant C_CH_to_CH_ADDR_OFFSET : integer := 16#100#;

  constant C_RX_BCFG_0_REG      : integer := 16#00000#;
  constant C_TX_BCFG_0_REG      : integer := 16#00008#;
  constant C_RX_RST_CTRL_REG    : integer := 16#00010#;
  constant C_RX_RST_STAT_REG    : integer := 16#00014#;
  constant C_TX_RST_CTRL_REG    : integer := 16#00018#;
  constant C_TX_RST_STAT_REG    : integer := 16#0001C#;
  constant C_CPLL_RST_REG       : integer := 16#00020#;
  constant C_CPLL_LOCK_STAT_REG : integer := 16#00024#;
  constant C_CPLL_MAIN_CTRL_REG : integer := 16#00028#;

  constant C_RX_MAIN_CTRL_REG    : integer := 16#00030#;
  constant C_TX_MAIN_CTRL_REG    : integer := 16#00034#;
  constant C_TX_DRV_CTRL_REG     : integer := 16#00038#;
  constant C_LOOPBACK_REG        : integer := 16#0003C#;
  constant C_RX_STAT_REG         : integer := 16#00040#;
  constant C_TX_STAT_REG         : integer := 16#00044#;
  constant C_RX_DEC_ERR_CNT_REG  : integer := 16#00048#;
  constant C_RX_PRBS_CNT_RST_REG : integer := 16#0004C#;

  constant C_RX_USR_CLK_FREQ_REG : integer := 16#00050#;
  constant C_TX_USR_CLK_FREQ_REG : integer := 16#00054#;

  constant C_RX_PRBS_ERR_CNT_REG : integer := 16#00060#;

  constant C_RX_CDR_CTRL_REG          : integer := 16#00080#;
  constant C_RX_EQ_CDR_DFE_STATUS_REG : integer := 16#00084#;
  constant C_RX_LPM_CTRL_REG          : integer := 16#00088#;
  constant C_RX_DFE_AGC_CTRL_REG      : integer := 16#0008C#;
  constant C_RX_DFE_1_CTRL_REG        : integer := 16#00090#;
  constant C_RX_DFE_2_CTRL_REG        : integer := 16#00094#;
  constant C_RX_OS_CTRL_REG           : integer := 16#00098#;

  constant C_DMONITOR_REG : integer := 16#000A0#;

--============================================================================
--                                              QPLL (GTH Common) Register Map 
--============================================================================

  constant C_QPLL_RST_CTRL_REG  : integer := 16#10000#;
  constant C_QPLL_LOCK_STAT_REG : integer := 16#10004#;
  constant C_QPLL_MAIN_CTRL_REG : integer := 16#10008#;

--============================================================================
--                                                       Register declarations
--============================================================================
--constant C_RX_BCFG_0_REG      : integer := 16#00000#;

  -- C_RX_enable = 0
  -- C_RX_8b10b = 1
  -- C_RX_gearbox = 0
  -- C_RX_buffer = 1
  -- C_RX_CPLL_nQPLL = 0
  -- C_RX_data_width = 32
  -- C_RX_link_speed = 10000
  --signal s_rx_bcfg_0_reg : t_logic_vector_array(G_NUM_OF_GTH_GTs-1 downto 0)(31 downto 0) := (others => x"00000000");
  signal s_rx_bcfg_0_reg : t_slv_arr_32(G_NUM_OF_GTH_GTs-1 downto 0) := (others => x"00000000");

--------------------------------------------------------------------------------
--constant C_TX_BCFG_0_REG      : integer := 16#00008#;

  -- C_TX_enable = 0
  -- C_TX_8b10b = 1
  -- C_TX_gearbox = 0
  -- C_TX_buffer = 1
  -- C_TX_CPLL_nQPLL = 0
  -- C_TX_data_width = 32
  -- C_TX_link_speed = 10000

  signal s_tx_bcfg_0_reg : t_slv_arr_32(G_NUM_OF_GTH_GTs-1 downto 0) := (others => x"00000000");

--------------------------------------------------------------------------------
--  constant C_RX_RST_CTRL_REG    : integer := 16#00010#;

  signal s_rx_rst_ctrl_reg : t_slv_arr_32(G_NUM_OF_GTH_GTs-1 downto 0);

--------------------------------------------------------------------------------
--  constant C_RX_RST_STAT_REG    : integer := 16#00014#;

  signal s_rx_rst_stat_reg : t_slv_arr_3(G_NUM_OF_GTH_GTs-1 downto 0);

--------------------------------------------------------------------------------
-- constant C_TX_RST_CTRL_REG    : integer := 16#00018#;

  signal s_tx_rst_ctrl_reg : t_slv_arr_32(G_NUM_OF_GTH_GTs-1 downto 0);

--------------------------------------------------------------------------------
--  constant C_TX_RST_STAT_REG    : integer := 16#0001C#;
  signal s_tx_rst_stat_reg : t_slv_arr_4(G_NUM_OF_GTH_GTs-1 downto 0);

--------------------------------------------------------------------------------
--constant C_CPLL_RST_REG : integer := 16#00030#;
  signal s_cpll_rst_reg : std_logic_vector(G_NUM_OF_GTH_GTs-1 downto 0);

--------------------------------------------------------------------------------
--constant C_CPLL_LOCK_STAT_REG : integer := 16#00024#;

  signal s_cpll_lock_stat_reg : t_slv_arr_3(G_NUM_OF_GTH_GTs-1 downto 0);

--------------------------------------------------------------------------------
-- constant C_RX_MAIN_CTRL_REG   : integer := 16#00030#;

  -- PD  = 1
  -- POL = 0
  -- PRBS = 0
  -- LPMEN = 1

  signal s_rx_main_ctrl_reg : t_slv_arr_6(G_NUM_OF_GTH_GTs-1 downto 0) := (others => ("100001"));

  signal s_rx_pd       : std_logic_vector(G_NUM_OF_GTH_GTs-1 downto 0);
  signal s_rx_polarity : std_logic_vector(G_NUM_OF_GTH_GTs-1 downto 0);
  signal s_rx_prbs_sel : t_slv_arr_3(G_NUM_OF_GTH_GTs-1 downto 0);
  signal s_rx_lpmen    : std_logic_vector(G_NUM_OF_GTH_GTs-1 downto 0);

--------------------------------------------------------------------------------
-- constant C_TX_MAIN_CTRL_REG   : integer := 16#00034#;

  signal s_tx_main_ctrl_reg : t_slv_arr_5(G_NUM_OF_GTH_GTs-1 downto 0) := (others => ("00001"));

  signal s_tx_pd       : std_logic_vector(G_NUM_OF_GTH_GTs-1 downto 0);
  signal s_tx_polarity : std_logic_vector(G_NUM_OF_GTH_GTs-1 downto 0);
  signal s_tx_prbs_sel : t_slv_arr_3(G_NUM_OF_GTH_GTs-1 downto 0);

--------------------------------------------------------------------------------
--  constant C_TX_DRV_CTRL_REG    : integer := 16#00038#;

  signal s_tx_drv_ctrl_reg : t_slv_arr_23(G_NUM_OF_GTH_GTs-1 downto 0) := (others => "00000000000000000001000");

  signal s_tx_diff_ctrl       : t_slv_arr_4(G_NUM_OF_GTH_GTs-1 downto 0);
  signal s_tx_main_cursor     : t_slv_arr_7(G_NUM_OF_GTH_GTs-1 downto 0);
  signal s_tx_post_cursor     : t_slv_arr_5(G_NUM_OF_GTH_GTs-1 downto 0);
  signal s_tx_post_cursor_inv : std_logic_vector(G_NUM_OF_GTH_GTs-1 downto 0);
  signal s_tx_pre_cursor      : t_slv_arr_5(G_NUM_OF_GTH_GTs-1 downto 0);
  signal s_tx_pre_cursor_inv  : std_logic_vector(G_NUM_OF_GTH_GTs-1 downto 0);

--------------------------------------------------------------------------------
--  constant C_LOOPBACK_REG       : integer := 16#0003C#;

  signal s_loopback_reg : t_slv_arr_3(G_NUM_OF_GTH_GTs-1 downto 0) := (others => "000");

--------------------------------------------------------------------------------
--constant C_RX_STAT_REG        : integer := 16#00040#;

  signal s_rx_stat_reg : t_slv_arr_3(G_NUM_OF_GTH_GTs-1 downto 0);

  signal s_rx_link_locked       : std_logic_vector(G_NUM_OF_GTH_GTs-1 downto 0);
  signal s_rx_link_8b10_aligned : std_logic_vector(G_NUM_OF_GTH_GTs-1 downto 0);

--------------------------------------------------------------------------------
-- constant C_TX_STAT_REG        : integer := 16#00044#;
-- in this link interface version, read as 0 by default, write ignored

--------------------------------------------------------------------------------
-- constant C_RX_DEC_ERR_CNT_REG : integer := 16#00048#;
  signal s_rx_dec_err_cnt_reg     : t_slv_arr_32(G_NUM_OF_GTH_GTs-1 downto 0);
  signal s_rx_dec_err_cnt_rst_reg : std_logic_vector(G_NUM_OF_GTH_GTs-1 downto 0);

--------------------------------------------------------------------------------
--   constant C_RX_PRBS_CNT_RST_REG : integer  := 16#0004C#;
  signal s_rx_prbs_cnt_rst_reg : std_logic_vector(G_NUM_OF_GTH_GTs-1 downto 0);


--------------------------------------------------------------------------------
--  constant C_RX_USR_CLK_FREQ_REG : integer := 16#00050#;
  signal s_rx_usr_clk_reg : t_slv_arr_32(G_NUM_OF_GTH_GTs-1 downto 0);

--------------------------------------------------------------------------------
-- constant C_TX_USR_CLK_FREQ_REG : integer := 16#00054#;
  signal s_tx_usr_clk_reg : t_slv_arr_32(G_NUM_OF_GTH_GTs-1 downto 0);

--------------------------------------------------------------------------------
--  constant C_RX_PRBS_ERR_CNT_REG : integer  := 16#00060#;
  signal s_rx_prbs_fw_err_cnt_reg      : t_slv_arr_32(G_NUM_OF_GTH_GTs-1 downto 0);
  signal s_rx_prbs_fw_err_cnt_hold_reg : t_slv_arr_32(G_NUM_OF_GTH_GTs-1 downto 0);

  signal s_rx_prbs_fw_err_cnt_rd_reg      : std_logic_vector(G_NUM_OF_GTH_GTs-1 downto 0);
  signal s_rx_prbs_fw_err_cnt_rd_sync_reg : std_logic_vector(G_NUM_OF_GTH_GTs-1 downto 0);


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--constant C_QPLL_RST_CTRL_REG  : integer := 16#10000#;
  signal s_qpll_rst_ctrl_reg : std_logic_vector(G_NUM_OF_GTH_COMMONs-1 downto 0) := (others => '0');

--------------------------------------------------------------------------------
-- constant C_QPLL_LOCK_STAT_REG : integer := 16#10004#;
  signal s_qpll_lock_stat_reg : t_slv_arr_3(G_NUM_OF_GTH_COMMONs-1 downto 0);

--------------------------------------------------------------------------------  
  --constant C_QPLL_MAIN_CTRL_REG : integer := 16#10008#;

  signal s_qpll_main_ctrl_reg : std_logic_vector(G_NUM_OF_GTH_COMMONs-1 downto 0) := (others => '1');

  signal s_qpll_pd : std_logic_vector(G_NUM_OF_GTH_COMMONs-1 downto 0);


--------------------------------------------------------------------------------  
--  constant C_RX_CDR_CTRL_REG : integer := 16#00080#;
  signal s_gth_rx_cdr_ctrl_reg : t_slv_arr_4(G_NUM_OF_GTH_GTs-1 downto 0) := (others => "0000");

--------------------------------------------------------------------------------    
--  constant C_RX_EQ_CDR_DFE_STATUS_REG : integer := 16#00084#;
  signal s_gth_rx_eq_cdr_dfe_status_reg : t_slv_arr_9(G_NUM_OF_GTH_GTs-1 downto 0) := (others => "000000000");

--------------------------------------------------------------------------------  
--  constant C_RX_LPM_CTRL_REG : integer := 16#00088#;
  signal s_gth_rx_lpm_ctrl_reg : t_slv_arr_4(G_NUM_OF_GTH_GTs-1 downto 0) := (others => "0000");

--------------------------------------------------------------------------------  
--  constant C_RX_DFE_AGC_CTRL_REG : integer := 16#0008C#;
  signal s_gth_rx_dfe_agc_ctrl_reg : t_slv_arr_7(G_NUM_OF_GTH_GTs-1 downto 0) := (others => "1000000");

--------------------------------------------------------------------------------  
--  constant C_RX_DFE_1_CTRL_REG : integer := 16#00090#;
  signal s_gth_rx_dfe_1_ctrl_reg : t_slv_arr_27(G_NUM_OF_GTH_GTs-1 downto 0) := (others => "000000000000000000000000001");

--------------------------------------------------------------------------------  
--  constant C_RX_DFE_2_CTRL_REG : integer := 16#00094#;
  signal s_gth_rx_dfe_2_ctrl_reg : t_slv_arr_11(G_NUM_OF_GTH_GTs-1 downto 0) := (others => "00000000000");

--------------------------------------------------------------------------------  
--  constant C_RX_OS_CTRL_REG : integer := 16#00098#;
  signal s_gth_rx_os_ctrl_reg : t_slv_arr_17(G_NUM_OF_GTH_GTs-1 downto 0) := (others => "00000110000000100");

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


  signal s_gth_gt_rxreset_pulse : std_logic_vector(G_NUM_OF_GTH_GTs-1 downto 0);
  signal s_gth_gt_rxreset_latch : std_logic_vector(G_NUM_OF_GTH_GTs-1 downto 0);

  signal s_gth_gt_txreset_pulse : std_logic_vector(G_NUM_OF_GTH_GTs-1 downto 0);
  signal s_gth_gt_txreset_latch : std_logic_vector(G_NUM_OF_GTH_GTs-1 downto 0);

  signal s_rx_not_in_table_aggr : std_logic_vector(G_NUM_OF_GTH_GTs-1 downto 0);
  signal s_rx_disp_err_aggr     : std_logic_vector(G_NUM_OF_GTH_GTs-1 downto 0);
  signal s_rx_link_err_aggr     : std_logic_vector(G_NUM_OF_GTH_GTs-1 downto 0);


  signal s_gnd_i : std_logic_vector (31 downto 0) := (others => '0');

--============================================================================
--                                                          Architecture begin
--============================================================================

begin

  gen_gth_cpll_regs : for i in 0 to G_NUM_OF_GTH_GTs-1 generate
    s_cpll_lock_stat_reg(i)(0) <= gth_cpll_status_arr_i(i).CPLLLOCK;
    s_cpll_lock_stat_reg(i)(1) <= gth_cpll_status_arr_i(i).CPLLFBCLKLOST;
    s_cpll_lock_stat_reg(i)(2) <= gth_cpll_status_arr_i(i).CPLLREFCLKLOST;

  end generate;

----


  gen_gth_8b10b_err : for i in 0 to G_NUM_OF_GTH_GTs-1 generate

    s_rx_link_err_aggr(i) <= s_rx_not_in_table_aggr(i) or s_rx_disp_err_aggr(i);

    process (clk_gth_rx_usrclk_arr_i(i))
    begin
      if(rising_edge(clk_gth_rx_usrclk_arr_i(i))) then

        s_rx_not_in_table_aggr(i) <= or_reduce(gth_rx_data_arr_i(i).rxnotintable);
        s_rx_disp_err_aggr(i)     <= or_reduce(gth_rx_data_arr_i(i).rxdisperr);

--      if (s_rx_dec_err_cnt_rst_reg(i) = '1') then
--        s_rx_dec_err_cnt_reg(i) <= (others => '0');
--      elsif (s_rx_link_err_aggr(i) = '1' and s_rx_dec_err_cnt_reg(i) /= x"FFFFFFFF") then
--        s_rx_dec_err_cnt_reg(i) <= std_logic_vector(unsigned(s_rx_dec_err_cnt_reg(i)) + 1);
--      end if;
      end if;
    end process;

  end generate;
----


  -- Register assignment for GTHs
  gen_gth_regs : for i in 0 to G_NUM_OF_GTH_GTs-1 generate

    -- Static configuration registers for RX
    s_rx_bcfg_0_reg(i)(0) <= c_bool_to_std_logic(c_gth_config_arr(i).rx_config.enable);  -- Enabled

    gen_gth_rx_encoding : case c_gth_config_arr(i).rx_config.encoding generate
      when gth_encoding_none   => s_rx_bcfg_0_reg(i)(2 downto 1) <= "00";  -- 8b10b disabled, gearbox disabled
      when gth_encoding_8b10b  => s_rx_bcfg_0_reg(i)(2 downto 1) <= "01";  -- 8b10b enabled, gearbox disabled
      when gth_encoding_64b66b => s_rx_bcfg_0_reg(i)(2 downto 1) <= "10";  -- 8b10b disabled, gearbox enabled
    end generate gen_gth_rx_encoding;

--        gen_gth_rx_encoding_none : if c_gth_config_arr(i).rx_config.encoding = gth_encoding_none generate
--           s_rx_bcfg_0_reg(i)(2 downto 1) <= "00"; -- 8b10b disabled, gearbox disabled
--        else if c_gth_config_arr(i).rx_config.encoding = gth_encoding_8b10b generate
--            s_rx_bcfg_0_reg(i)(2 downto 1) <= "01"; -- 8b10b enabled, gearbox disabled
--        else generate
--            s_rx_bcfg_0_reg(i)(2 downto 1) <= "10"; -- 8b10b disabled, gearbox enabled
--        end generate gen_gth_rx_encoding_none;

--        gen_gth_rx_encoding_8b10b : if c_gth_config_arr(i).rx_config.encoding = gth_encoding_8b10b generate
--           s_rx_bcfg_0_reg(i)(2 downto 1) <= "01"; -- 8b10b enabled, gearbox disabled
--        end generate; 

--        gen_gth_rx_encoding_64b66b : if c_gth_config_arr(i).rx_config.encoding = gth_encoding_64b66b generate
--           s_rx_bcfg_0_reg(i)(2 downto 1) <= "10"; -- 8b10b disabled, gearbox enabled
--        end generate;

    gen_gth_rx_buffer_en : if c_gth_config_arr(i).rx_config.buffer_enabled = true generate
      s_rx_bcfg_0_reg(i)(3) <= '1';     -- Buffer enable
    end generate;

    gen_gth_rx_CPLL_nQPLL : if c_gth_config_arr(i).rx_config.qpll_used = false generate
      s_rx_bcfg_0_reg(i)(4) <= '1';
    end generate;

    s_rx_bcfg_0_reg(i)(10 downto 5)  <= std_logic_vector(to_unsigned(c_gth_config_arr(i).rx_config.data_width, 6));
    s_rx_bcfg_0_reg(i)(31 downto 16) <= std_logic_vector(to_unsigned(c_gth_config_arr(i).rx_config.link_rate, 16));

    -- Static configuration registers for TX
    s_tx_bcfg_0_reg(i)(0) <= c_bool_to_std_logic(c_gth_config_arr(i).tx_config.enable);  -- Enabled

    gen_gth_tx_encoding_none : if c_gth_config_arr(i).tx_config.encoding = gth_encoding_none generate
      s_tx_bcfg_0_reg(i)(2 downto 1) <= "00";  -- 8b10b disabled, gearbox disabled
    end generate;

    gen_gth_tx_encoding_8b10b : if c_gth_config_arr(i).tx_config.encoding = gth_encoding_8b10b generate
      s_tx_bcfg_0_reg(i)(2 downto 1) <= "01";  -- 8b10b enabled, gearbox disabled
    end generate;

    gen_gth_tx_encoding_64b66b : if c_gth_config_arr(i).tx_config.encoding = gth_encoding_64b66b generate
      s_tx_bcfg_0_reg(i)(2 downto 1) <= "10";  -- 8b10b disabled, gearbox enabled
    end generate;

    gen_gth_tx_buffer_en : if c_gth_config_arr(i).tx_config.buffer_enabled = true generate
      s_tx_bcfg_0_reg(i)(3) <= '1';     -- Buffer enable
    end generate;

    gen_gth_tx_CPLL_nQPLL : if c_gth_config_arr(i).tx_config.qpll_used = false generate
      s_tx_bcfg_0_reg(i)(4) <= '1';
    end generate;

    s_tx_bcfg_0_reg(i)(10 downto 5)  <= std_logic_vector(to_unsigned(c_gth_config_arr(i).tx_config.data_width, 6));
    s_tx_bcfg_0_reg(i)(31 downto 16) <= std_logic_vector(to_unsigned(c_gth_config_arr(i).tx_config.link_rate, 16));



    s_gth_gt_rxreset_pulse(i) <= s_rx_rst_ctrl_reg(i)(0);
    gth_gt_rxdfelpmreset_o(i) <= s_rx_rst_ctrl_reg(i)(1);
    gth_gt_rxcdrreset_o(i)    <= s_rx_rst_ctrl_reg(i)(2);
    s_gth_gt_rxreset_latch(i) <= s_rx_rst_ctrl_reg(i)(31);

    gth_gt_rxreset_o(i)        <= s_gth_gt_rxreset_pulse(i);
    gth_gt_rxreset_sticky_o(i) <= s_gth_gt_rxreset_latch(i);

    s_gth_gt_txreset_pulse(i) <= s_tx_rst_ctrl_reg(i)(0);
    s_gth_gt_txreset_latch(i) <= s_tx_rst_ctrl_reg(i)(31);

    gth_gt_txreset_o(i)        <= s_gth_gt_txreset_pulse(i);
    gth_gt_txreset_sticky_o(i) <= s_gth_gt_txreset_latch(i);

    s_rx_rst_stat_reg(i)(0) <= gth_gt_rxreset_done_i(i);            -- From FSM
    s_rx_rst_stat_reg(i)(1) <= gth_rx_status_arr_i(i).rxresetdone;  -- From GTH
    s_rx_rst_stat_reg(i)(2) <= gth_rx_status_arr_i(i).RXPMARESETDONE;

    s_tx_rst_stat_reg(i)(0) <= gth_gt_txreset_done_i(i);
    s_tx_rst_stat_reg(i)(1) <= gth_tx_status_arr_i(i).txresetdone;
    s_tx_rst_stat_reg(i)(2) <= gth_tx_status_arr_i(i).TXPMARESETDONE;
    s_tx_rst_stat_reg(i)(3) <= gth_tx_status_arr_i(i).txgearboxready;

    gth_cpll_reset_arr_o(i) <= s_cpll_rst_reg(i);


    -- RX Main Control
    s_rx_pd(i)       <= s_rx_main_ctrl_reg(i)(0);
    s_rx_polarity(i) <= s_rx_main_ctrl_reg(i)(1);
    s_rx_prbs_sel(i) <= s_rx_main_ctrl_reg(i)(4 downto 2);
    s_rx_lpmen(i)    <= s_rx_main_ctrl_reg(i)(5);

    gth_rx_ctrl_arr_o(i).rxpd       <= "00" when s_rx_pd(i) = '0' else "11";
    gth_rx_ctrl_arr_o(i).rxpolarity <= s_rx_polarity(i);
    gth_rx_ctrl_arr_o(i).rxprbssel  <= s_rx_prbs_sel(i);
    gth_rx_ctrl_arr_o(i).rxlpmen    <= s_rx_lpmen(i);

    gen_gth_rxsysclk_qpll : if c_gth_config_arr(i).rx_config.qpll_used = true generate
      gth_rx_ctrl_arr_o(i).rxsysclksel <= "11";
    end generate;

    gen_gth_rxsysclk_cpll : if c_gth_config_arr(i).rx_config.qpll_used = false generate
      gth_rx_ctrl_arr_o(i).rxsysclksel <= "00";
    end generate;

    gth_rx_ctrl_arr_o(i).rxbufreset <= '0';

    gth_rx_ctrl_arr_o(i).rxprbscntreset <= s_rx_prbs_cnt_rst_reg(i);


    -- TX Main Control
    s_tx_pd(i)       <= s_tx_main_ctrl_reg(i)(0);
    s_tx_polarity(i) <= s_tx_main_ctrl_reg(i)(1);
    s_tx_prbs_sel(i) <= s_tx_main_ctrl_reg(i)(4 downto 2);


    gth_tx_ctrl_arr_o(i).txpd       <= "00" when s_tx_pd(i) = '0' else "11";
    gth_tx_ctrl_arr_o(i).txpolarity <= s_tx_polarity(i);
    gth_tx_ctrl_arr_o(i).txprbssel  <= s_tx_prbs_sel(i);

    gen_gth_txsysclk_qpll : if c_gth_config_arr(i).tx_config.qpll_used = true generate
      gth_tx_ctrl_arr_o(i).txsysclksel <= "11";
    end generate;

    gen_gth_txsysclk_cpll : if c_gth_config_arr(i).tx_config.qpll_used = false generate
      gth_tx_ctrl_arr_o(i).txsysclksel <= "00";
    end generate;

    --gth_tx_ctrl_arr_o(i).txprbscntreset <= '0';
    gth_tx_ctrl_arr_o(i).txinhibit <= '0';

    -- TX Driver Control

    s_tx_diff_ctrl(i)       <= s_tx_drv_ctrl_reg(i)(3 downto 0);
    s_tx_main_cursor(i)     <= s_tx_drv_ctrl_reg(i)(10 downto 4);
    s_tx_post_cursor(i)     <= s_tx_drv_ctrl_reg(i)(15 downto 11);
    s_tx_post_cursor_inv(i) <= s_tx_drv_ctrl_reg(i)(16);
    s_tx_pre_cursor(i)      <= s_tx_drv_ctrl_reg(i)(21 downto 17);
    s_tx_pre_cursor_inv(i)  <= s_tx_drv_ctrl_reg(i)(22);


    gth_tx_ctrl_arr_o(i).txdiffctrl      <= s_tx_diff_ctrl(i);
    gth_tx_ctrl_arr_o(i).txmaincursor    <= s_tx_main_cursor(i);
    gth_tx_ctrl_arr_o(i).txpostcursor    <= s_tx_post_cursor(i);
    gth_tx_ctrl_arr_o(i).txprecursor     <= s_tx_pre_cursor(i);
    gth_tx_ctrl_arr_o(i).txpostcursorinv <= s_tx_post_cursor_inv(i);
    gth_tx_ctrl_arr_o(i).txprecursorinv  <= s_tx_pre_cursor_inv(i);

    -- Loopback

    gth_misc_ctrl_arr_o(i).loopback <= s_loopback_reg(i);

    -- RX Status

    s_rx_stat_reg(i)(0) <= '0';         -- TODO 
    s_rx_stat_reg(i)(1) <= '0';         -- TODO 
    s_rx_stat_reg(i)(2) <= gth_rx_status_arr_i(i).rxinsync;


    -- RX Link Errors


    --------------------------------------------------------------------------------

    gth_rx_cdr_ctrl_arr_o(i).RXCDRFREQRESET <= s_gth_rx_cdr_ctrl_reg(i)(0);
    gth_rx_cdr_ctrl_arr_o(i).RXCDRHOLD      <= s_gth_rx_cdr_ctrl_reg(i)(1);
    gth_rx_cdr_ctrl_arr_o(i).RXCDROVRDEN    <= s_gth_rx_cdr_ctrl_reg(i)(2);
    gth_rx_cdr_ctrl_arr_o(i).RXCDRRESETRSV  <= s_gth_rx_cdr_ctrl_reg(i)(3);

    s_gth_rx_eq_cdr_dfe_status_reg(i)(0) <= gth_rx_eq_cdr_dfe_status_arr_i(i).RXCDRLOCK;
    s_gth_rx_eq_cdr_dfe_status_reg(i)(1) <= gth_rx_eq_cdr_dfe_status_arr_i(i).RSOSINTDONE;
    s_gth_rx_eq_cdr_dfe_status_reg(i)(2) <= gth_rx_eq_cdr_dfe_status_arr_i(i).RXDFESLIDETAPSTARTED;
    s_gth_rx_eq_cdr_dfe_status_reg(i)(3) <= gth_rx_eq_cdr_dfe_status_arr_i(i).RXDFESLIDETAPSTROBEDONE;
    s_gth_rx_eq_cdr_dfe_status_reg(i)(4) <= gth_rx_eq_cdr_dfe_status_arr_i(i).RXDFESLIDETAPSTROBESTARTED;
    s_gth_rx_eq_cdr_dfe_status_reg(i)(5) <= gth_rx_eq_cdr_dfe_status_arr_i(i).RXDFESTADAPTDONE;
    s_gth_rx_eq_cdr_dfe_status_reg(i)(6) <= gth_rx_eq_cdr_dfe_status_arr_i(i).RXOSINTSTARTED;
    s_gth_rx_eq_cdr_dfe_status_reg(i)(7) <= gth_rx_eq_cdr_dfe_status_arr_i(i).RXOSINTSTROBESTARTED;
    s_gth_rx_eq_cdr_dfe_status_reg(i)(8) <= gth_rx_eq_cdr_dfe_status_arr_i(i).RXOSINTSTROBEDONE;

    gth_rx_lpm_ctrl_arr_o(i).RXLPMHFHOLD     <= s_gth_rx_lpm_ctrl_reg(i)(0);
    gth_rx_lpm_ctrl_arr_o(i).RXLPMHFOVRDEN   <= s_gth_rx_lpm_ctrl_reg(i)(1);
    gth_rx_lpm_ctrl_arr_o(i).RXLPMLFHOLD     <= s_gth_rx_lpm_ctrl_reg(i)(2);
    gth_rx_lpm_ctrl_arr_o(i).RXLPMLFKLOVRDEN <= s_gth_rx_lpm_ctrl_reg(i)(3);

    gth_rx_dfe_agc_ctrl_arr_o(i).RXDFEAGCHOLD   <= s_gth_rx_dfe_agc_ctrl_reg(i)(0);
    gth_rx_dfe_agc_ctrl_arr_o(i).RXDFEAGCOVRDEN <= s_gth_rx_dfe_agc_ctrl_reg(i)(1);
    gth_rx_dfe_agc_ctrl_arr_o(i).RXDFEAGCTRL    <= s_gth_rx_dfe_agc_ctrl_reg(i)(6 downto 2);

    gth_rx_dfe_1_ctrl_arr_o(i).RXDFEXYDEN               <= s_gth_rx_dfe_1_ctrl_reg(i)(0);
    gth_rx_dfe_1_ctrl_arr_o(i).RXDFECM1EN               <= s_gth_rx_dfe_1_ctrl_reg(i)(1);
    gth_rx_dfe_1_ctrl_arr_o(i).RXDFELFHOLD              <= s_gth_rx_dfe_1_ctrl_reg(i)(2);
    gth_rx_dfe_1_ctrl_arr_o(i).RXDFELFOVRDEN            <= s_gth_rx_dfe_1_ctrl_reg(i)(3);
    gth_rx_dfe_1_ctrl_arr_o(i).RXDFESLIDETAPADAPTEN     <= s_gth_rx_dfe_1_ctrl_reg(i)(4);
    gth_rx_dfe_1_ctrl_arr_o(i).RXDFESLIDETAPHOLD        <= s_gth_rx_dfe_1_ctrl_reg(i)(5);
    gth_rx_dfe_1_ctrl_arr_o(i).RXDFESLIDETAPINITOVRDEN  <= s_gth_rx_dfe_1_ctrl_reg(i)(6);
    gth_rx_dfe_1_ctrl_arr_o(i).RXDFESLIDETAPONLYADAPTEN <= s_gth_rx_dfe_1_ctrl_reg(i)(7);
    gth_rx_dfe_1_ctrl_arr_o(i).RXDFESLIDETAPSTROBE      <= s_gth_rx_dfe_1_ctrl_reg(i)(8);
    gth_rx_dfe_1_ctrl_arr_o(i).RXDFETAP2HOLD            <= s_gth_rx_dfe_1_ctrl_reg(i)(9);
    gth_rx_dfe_1_ctrl_arr_o(i).RXDFETAP2OVRDEN          <= s_gth_rx_dfe_1_ctrl_reg(i)(10);
    gth_rx_dfe_1_ctrl_arr_o(i).RXDFETAP3HOLD            <= s_gth_rx_dfe_1_ctrl_reg(i)(11);
    gth_rx_dfe_1_ctrl_arr_o(i).RXDFETAP3OVRDEN          <= s_gth_rx_dfe_1_ctrl_reg(i)(12);
    gth_rx_dfe_1_ctrl_arr_o(i).RXDFETAP4HOLD            <= s_gth_rx_dfe_1_ctrl_reg(i)(13);
    gth_rx_dfe_1_ctrl_arr_o(i).RXDFETAP4OVRDEN          <= s_gth_rx_dfe_1_ctrl_reg(i)(14);
    gth_rx_dfe_1_ctrl_arr_o(i).RXDFETAP5HOLD            <= s_gth_rx_dfe_1_ctrl_reg(i)(15);
    gth_rx_dfe_1_ctrl_arr_o(i).RXDFETAP5OVRDEN          <= s_gth_rx_dfe_1_ctrl_reg(i)(16);
    gth_rx_dfe_1_ctrl_arr_o(i).RXDFETAP6HOLD            <= s_gth_rx_dfe_1_ctrl_reg(i)(17);
    gth_rx_dfe_1_ctrl_arr_o(i).RXDFETAP6OVRDEN          <= s_gth_rx_dfe_1_ctrl_reg(i)(18);
    gth_rx_dfe_1_ctrl_arr_o(i).RXDFETAP7HOLD            <= s_gth_rx_dfe_1_ctrl_reg(i)(19);
    gth_rx_dfe_1_ctrl_arr_o(i).RXDFETAP7OVRDEN          <= s_gth_rx_dfe_1_ctrl_reg(i)(20);
    gth_rx_dfe_1_ctrl_arr_o(i).RXDFEUTHOLD              <= s_gth_rx_dfe_1_ctrl_reg(i)(21);
    gth_rx_dfe_1_ctrl_arr_o(i).RXDFEUTOVRDEN            <= s_gth_rx_dfe_1_ctrl_reg(i)(22);
    gth_rx_dfe_1_ctrl_arr_o(i).RXDFEVPHOLD              <= s_gth_rx_dfe_1_ctrl_reg(i)(23);
    gth_rx_dfe_1_ctrl_arr_o(i).RXDFEVPOVRDEN            <= s_gth_rx_dfe_1_ctrl_reg(i)(24);
    gth_rx_dfe_1_ctrl_arr_o(i).RXDFEVSEN                <= s_gth_rx_dfe_1_ctrl_reg(i)(25);
    gth_rx_dfe_1_ctrl_arr_o(i).RXDFESLIDETAPOVRDEN      <= s_gth_rx_dfe_1_ctrl_reg(i)(26);

    gth_rx_dfe_2_ctrl_arr_o(i).RXDFESLIDETAP   <= s_gth_rx_dfe_2_ctrl_reg(i)(4 downto 0);
    gth_rx_dfe_2_ctrl_arr_o(i).RXDFESLIDETAPID <= s_gth_rx_dfe_2_ctrl_reg(i)(10 downto 5);

    gth_rx_os_ctrl_arr_o(i).RXOSCALRESET      <= s_gth_rx_os_ctrl_reg(i)(0);
    gth_rx_os_ctrl_arr_o(i).RXOSHOLD          <= s_gth_rx_os_ctrl_reg(i)(1);
    gth_rx_os_ctrl_arr_o(i).RXOSINTEN         <= s_gth_rx_os_ctrl_reg(i)(2);
    gth_rx_os_ctrl_arr_o(i).RXOSINTHOLD       <= s_gth_rx_os_ctrl_reg(i)(3);
    gth_rx_os_ctrl_arr_o(i).RXOSINTNTRLEN     <= s_gth_rx_os_ctrl_reg(i)(4);
    gth_rx_os_ctrl_arr_o(i).RXOSINTOVRDEN     <= s_gth_rx_os_ctrl_reg(i)(5);
    gth_rx_os_ctrl_arr_o(i).RXOSINTSTROBE     <= s_gth_rx_os_ctrl_reg(i)(6);
    gth_rx_os_ctrl_arr_o(i).RXOSINTTESTOVRDEN <= s_gth_rx_os_ctrl_reg(i)(7);
    gth_rx_os_ctrl_arr_o(i).RXOSOVRDEN        <= s_gth_rx_os_ctrl_reg(i)(8);
    gth_rx_os_ctrl_arr_o(i).RXOSINTCFG        <= s_gth_rx_os_ctrl_reg(i)(12 downto 9);
    gth_rx_os_ctrl_arr_o(i).RXOSINTID0        <= s_gth_rx_os_ctrl_reg(i)(16 downto 13);

    -- Frequency measument
    i_rxusrclk_measure : entity work.clock_measure
      generic map (
        REFCLK_FREQ => 50000000
        ) port map (
          REFCLK_IN => BRAM_CTRL_GTH_REG_FILE_clk,
          CLK_IN    => clk_gth_rx_usrclk_arr_i(i),
          FREQ_OUT  => s_rx_usr_clk_reg(i)
          );

    i_txusrclk_measure : entity work.clock_measure
      generic map (
        REFCLK_FREQ => 50000000
        ) port map (
          REFCLK_IN => BRAM_CTRL_GTH_REG_FILE_clk,
          CLK_IN    => clk_gth_tx_usrclk_arr_i(i),
          FREQ_OUT  => s_tx_usr_clk_reg(i)
          );

  end generate gen_gth_regs;

  gen_gth_common_qpll_regs : for i in 0 to G_NUM_OF_GTH_COMMONs-1 generate

    s_qpll_pd(i) <= s_qpll_main_ctrl_reg(i);

    gth_common_ctrl_arr_o(i).QPLLRESET <= s_qpll_rst_ctrl_reg(i);
    gth_common_ctrl_arr_o(i).QPLLPD    <= s_qpll_pd(i);

    s_qpll_lock_stat_reg(i)(0) <= gth_common_status_arr_i(i).QPLLLOCK;
    s_qpll_lock_stat_reg(i)(1) <= gth_common_status_arr_i(i).QPLLFBCLKLOST;
    s_qpll_lock_stat_reg(i)(2) <= gth_common_status_arr_i(i).QPLLREFCLKLOST;

  end generate;

  -- New register assignment for GTs
  process (BRAM_CTRL_GTH_REG_FILE_clk) is
    variable dout : std_logic_vector (31 downto 0);
  begin
    if BRAM_CTRL_GTH_REG_FILE_clk'event and BRAM_CTRL_GTH_REG_FILE_clk = '1' then
      dout := (others => '0');

      --gen_gt_bram_reg_mapping : for i in 0 to G_NUM_OF_GTH_GTs-1 loop
      -- Read
      for i in 0 to G_NUM_OF_GTH_GTs-1 loop
        if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_RX_RST_CTRL_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then dout := dout or s_rx_rst_ctrl_reg(i); end if; end loop;
      for i in 0 to G_NUM_OF_GTH_GTs-1 loop
        if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_TX_RST_CTRL_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then dout := dout or s_tx_rst_ctrl_reg(i); end if; end loop;
      for i in 0 to G_NUM_OF_GTH_GTs-1 loop
        if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_RX_BCFG_0_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then dout := dout or s_rx_bcfg_0_reg(i); end if; end loop;
      for i in 0 to G_NUM_OF_GTH_GTs-1 loop
        if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_TX_BCFG_0_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then dout := dout or s_tx_bcfg_0_reg(i); end if; end loop;
      for i in 0 to G_NUM_OF_GTH_GTs-1 loop
        if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_RX_RST_STAT_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then dout := dout or s_gnd_i(31 downto 3) & s_rx_rst_stat_reg(i); end if; end loop;
      for i in 0 to G_NUM_OF_GTH_GTs-1 loop
        if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_TX_RST_STAT_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then dout := dout or s_gnd_i(31 downto 4) & s_tx_rst_stat_reg(i); end if; end loop;
      for i in 0 to G_NUM_OF_GTH_GTs-1 loop
        if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_CPLL_RST_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then dout := dout or s_gnd_i(31 downto 1) & s_cpll_rst_reg(i); end if; end loop;
      for i in 0 to G_NUM_OF_GTH_GTs-1 loop
        if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_CPLL_LOCK_STAT_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then dout := dout or s_gnd_i(31 downto 3) & s_cpll_lock_stat_reg(i); end if; end loop;
      for i in 0 to G_NUM_OF_GTH_GTs-1 loop
        if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_RX_MAIN_CTRL_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then dout := dout or s_gnd_i(31 downto 6) & s_rx_main_ctrl_reg(i); end if; end loop;
      for i in 0 to G_NUM_OF_GTH_GTs-1 loop
        if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_TX_MAIN_CTRL_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then dout := dout or s_gnd_i(31 downto 5) & s_tx_main_ctrl_reg(i); end if; end loop;
      for i in 0 to G_NUM_OF_GTH_GTs-1 loop
        if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_TX_DRV_CTRL_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then dout := dout or s_gnd_i(31 downto 23) & s_tx_drv_ctrl_reg(i); end if; end loop;
      for i in 0 to G_NUM_OF_GTH_GTs-1 loop
        if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_LOOPBACK_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then dout := dout or s_gnd_i(31 downto 3) & s_loopback_reg(i); end if; end loop;
      for i in 0 to G_NUM_OF_GTH_GTs-1 loop
        if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_RX_STAT_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then dout := dout or s_gnd_i(31 downto 3) & s_rx_stat_reg(i); end if; end loop;
      for i in 0 to G_NUM_OF_GTH_GTs-1 loop
        if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_RX_DEC_ERR_CNT_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then dout := dout or s_rx_dec_err_cnt_reg(i); end if; end loop;
      for i in 0 to G_NUM_OF_GTH_GTs-1 loop
        if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_RX_USR_CLK_FREQ_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then dout := dout or s_rx_usr_clk_reg(i); end if; end loop;
      for i in 0 to G_NUM_OF_GTH_GTs-1 loop
        if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_TX_USR_CLK_FREQ_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then dout := dout or s_tx_usr_clk_reg(i); end if; end loop;
      for i in 0 to G_NUM_OF_GTH_GTs-1 loop
        if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_RX_PRBS_ERR_CNT_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then dout := dout or s_rx_prbs_fw_err_cnt_hold_reg(i); end if; end loop;
      for i in 0 to G_NUM_OF_GTH_GTs-1 loop
        if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_RX_CDR_CTRL_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then dout := dout or s_gnd_i(31 downto 4) & s_gth_rx_cdr_ctrl_reg(i); end if; end loop;
      for i in 0 to G_NUM_OF_GTH_GTs-1 loop
        if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_RX_EQ_CDR_DFE_STATUS_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then dout := dout or s_gnd_i(31 downto 9) & s_gth_rx_eq_cdr_dfe_status_reg(i); end if; end loop;
      for i in 0 to G_NUM_OF_GTH_GTs-1 loop
        if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_RX_LPM_CTRL_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then dout := dout or s_gnd_i(31 downto 4) & s_gth_rx_lpm_ctrl_reg(i); end if; end loop;
      for i in 0 to G_NUM_OF_GTH_GTs-1 loop
        if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_RX_DFE_AGC_CTRL_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then dout := dout or s_gnd_i(31 downto 7) & s_gth_rx_dfe_agc_ctrl_reg(i); end if; end loop;
      for i in 0 to G_NUM_OF_GTH_GTs-1 loop
        if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_RX_DFE_1_CTRL_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then dout := dout or s_gnd_i(31 downto 27) & s_gth_rx_dfe_1_ctrl_reg(i); end if; end loop;
      for i in 0 to G_NUM_OF_GTH_GTs-1 loop
        if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_RX_DFE_2_CTRL_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then dout := dout or s_gnd_i(31 downto 11) & s_gth_rx_dfe_2_ctrl_reg(i); end if; end loop;
      for i in 0 to G_NUM_OF_GTH_GTs-1 loop
        if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_RX_OS_CTRL_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then dout := dout or s_gnd_i(31 downto 17) & s_gth_rx_os_ctrl_reg(i); end if; end loop;
      for i in 0 to G_NUM_OF_GTH_GTs-1 loop
        if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_DMONITOR_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then dout := dout or s_gnd_i(31 downto 15) & gth_misc_status_arr_i(i).dmonitorout; end if; end loop;
      --end loop;

      --gen_common_bram_reg_mapping : for i in 0 to G_NUM_OF_GTH_COMMONs-1 loop
      -- Read
      for i in 0 to G_NUM_OF_GTH_COMMONs-1 loop
        if (BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_QPLL_LOCK_STAT_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then dout := dout or s_gnd_i(31 downto 3) & s_qpll_lock_stat_reg(i); end if; end loop;
      for i in 0 to G_NUM_OF_GTH_COMMONs-1 loop
        if (BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_QPLL_MAIN_CTRL_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then dout := dout or s_gnd_i(31 downto 1) & s_qpll_main_ctrl_reg(i); end if; end loop;
      --end loop;

      BRAM_CTRL_GTH_REG_FILE_dout <= dout;
    end if;
  end process;

  -- New register assignment for GTs
  process (BRAM_CTRL_GTH_REG_FILE_clk)
  begin
    if BRAM_CTRL_GTH_REG_FILE_clk'event and BRAM_CTRL_GTH_REG_FILE_clk = '1' then
      -- Default
      gen_gt_bram_reg_mapping_def : for i in 0 to G_NUM_OF_GTH_GTs-1 loop
        s_rx_prbs_fw_err_cnt_rd_reg(i) <= '0';
        s_rx_dec_err_cnt_rst_reg(i)    <= '0';
        s_rx_prbs_cnt_rst_reg(i)       <= '0';
        s_rx_rst_ctrl_reg(i)(0)        <= '0';
        s_tx_rst_ctrl_reg(i)(0)        <= '0';
      end loop;
      gen_common_bram_reg_mapping_def : for i in 0 to G_NUM_OF_GTH_COMMONs-1 loop
        s_qpll_rst_ctrl_reg(i) <= '0';
      end loop;

      if (BRAM_CTRL_GTH_REG_FILE_en = '1' and BRAM_CTRL_GTH_REG_FILE_we = "1111") then
        -- Write
        --gen_gt_bram_reg_mapping : for i in 0 to G_NUM_OF_GTH_GTs-1 loop 
        for i in 0 to G_NUM_OF_GTH_GTs-1 loop
          if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_RX_RST_CTRL_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then s_rx_rst_ctrl_reg(i) <= BRAM_CTRL_GTH_REG_FILE_din; end if; end loop;
        for i in 0 to G_NUM_OF_GTH_GTs-1 loop
          if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_TX_RST_CTRL_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then s_tx_rst_ctrl_reg(i) <= BRAM_CTRL_GTH_REG_FILE_din; end if; end loop;
        for i in 0 to G_NUM_OF_GTH_GTs-1 loop
          if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_CPLL_RST_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then s_cpll_rst_reg(i) <= BRAM_CTRL_GTH_REG_FILE_din(0); end if; end loop;
        for i in 0 to G_NUM_OF_GTH_GTs-1 loop
          if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_RX_MAIN_CTRL_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then s_rx_main_ctrl_reg(i) <= BRAM_CTRL_GTH_REG_FILE_din(5 downto 0); end if; end loop;
        for i in 0 to G_NUM_OF_GTH_GTs-1 loop
          if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_TX_MAIN_CTRL_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then s_tx_main_ctrl_reg(i) <= BRAM_CTRL_GTH_REG_FILE_din(4 downto 0); end if; end loop;
        for i in 0 to G_NUM_OF_GTH_GTs-1 loop
          if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_TX_DRV_CTRL_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then s_tx_drv_ctrl_reg(i) <= BRAM_CTRL_GTH_REG_FILE_din(22 downto 0); end if; end loop;
        for i in 0 to G_NUM_OF_GTH_GTs-1 loop
          if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_LOOPBACK_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then s_loopback_reg(i) <= BRAM_CTRL_GTH_REG_FILE_din(2 downto 0); end if; end loop;
        for i in 0 to G_NUM_OF_GTH_GTs-1 loop
          if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_RX_DEC_ERR_CNT_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then s_rx_dec_err_cnt_rst_reg(i) <= BRAM_CTRL_GTH_REG_FILE_din(0); end if; end loop;
        for i in 0 to G_NUM_OF_GTH_GTs-1 loop
          if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_RX_PRBS_ERR_CNT_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then s_rx_prbs_fw_err_cnt_rd_reg(i) <= BRAM_CTRL_GTH_REG_FILE_din(0); end if; end loop;
        for i in 0 to G_NUM_OF_GTH_GTs-1 loop
          if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_RX_PRBS_CNT_RST_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then s_rx_prbs_cnt_rst_reg(i) <= BRAM_CTRL_GTH_REG_FILE_din(0); end if; end loop;
        for i in 0 to G_NUM_OF_GTH_GTs-1 loop
          if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_RX_CDR_CTRL_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then s_gth_rx_cdr_ctrl_reg(i) <= BRAM_CTRL_GTH_REG_FILE_din(3 downto 0); end if; end loop;
        for i in 0 to G_NUM_OF_GTH_GTs-1 loop
          if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_RX_LPM_CTRL_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then s_gth_rx_lpm_ctrl_reg(i) <= BRAM_CTRL_GTH_REG_FILE_din(3 downto 0); end if; end loop;
        for i in 0 to G_NUM_OF_GTH_GTs-1 loop
          if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_RX_DFE_AGC_CTRL_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then s_gth_rx_dfe_agc_ctrl_reg(i) <= BRAM_CTRL_GTH_REG_FILE_din(6 downto 0); end if; end loop;
        for i in 0 to G_NUM_OF_GTH_GTs-1 loop
          if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_RX_DFE_1_CTRL_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then s_gth_rx_dfe_1_ctrl_reg(i) <= BRAM_CTRL_GTH_REG_FILE_din(26 downto 0); end if; end loop;
        for i in 0 to G_NUM_OF_GTH_GTs-1 loop
          if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_RX_DFE_2_CTRL_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then s_gth_rx_dfe_2_ctrl_reg(i) <= BRAM_CTRL_GTH_REG_FILE_din(10 downto 0); end if; end loop;
        for i in 0 to G_NUM_OF_GTH_GTs-1 loop
          if (is_gth_enabled(i) and BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_RX_OS_CTRL_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then s_gth_rx_os_ctrl_reg(i) <= BRAM_CTRL_GTH_REG_FILE_din(16 downto 0); end if; end loop;
        --end loop;

        --gen_common_bram_reg_mapping : for i in 0 to G_NUM_OF_GTH_COMMONs-1 loop 
        for i in 0 to G_NUM_OF_GTH_COMMONs-1 loop
          if (BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_QPLL_RST_CTRL_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then s_qpll_rst_ctrl_reg(i) <= BRAM_CTRL_GTH_REG_FILE_din(0); end if; end loop;
        for i in 0 to G_NUM_OF_GTH_COMMONs-1 loop
          if (BRAM_CTRL_GTH_REG_FILE_addr = addr_encode(C_QPLL_MAIN_CTRL_REG, C_CH_to_CH_ADDR_OFFSET, i, 17)) then s_qpll_main_ctrl_reg(i) <= BRAM_CTRL_GTH_REG_FILE_din(0); end if; end loop;
      --end loop;
      end if;
    end if;
  end process;

--  gen_prbs_regs : for i in 0 to G_NUM_OF_GTH_GTs-1 generate

--    i_pulse_sync_1_way_prbs_rd : pulse_sync_1_way

--      port map(
--        clk1_i           => BRAM_CTRL_GTH_REG_FILE_clk,
--        pulse_in_clk1_i  => s_rx_prbs_fw_err_cnt_rd_reg(i),
--        clk2_i           => clk_gth_rx_usrclk_arr_i(i),
--        pulse_out_clk2_o => s_rx_prbs_fw_err_cnt_rd_sync_reg(i)
--        );

--    process(clk_gth_rx_usrclk_arr_i(i)) is
--    begin
--      if (rising_edge(clk_gth_rx_usrclk_arr_i(i))) then
--        if(s_rx_prbs_fw_err_cnt_rd_sync_reg(i) = '1') then
--          s_rx_prbs_fw_err_cnt_reg(i)      <= (others => '0');
--          s_rx_prbs_fw_err_cnt_hold_reg(i) <= s_rx_prbs_fw_err_cnt_reg(i);
--        elsif (gth_rx_status_arr_i(i).rxprbserr = '1') then
--          s_rx_prbs_fw_err_cnt_reg(i) <= std_logic_vector(unsigned(s_rx_prbs_fw_err_cnt_reg(i)) + 1);
--          if (s_rx_prbs_fw_err_cnt_reg(i) = x"FFFFFFFF") then
--            s_rx_prbs_fw_err_cnt_reg(i) <= x"FFFFFFFF";
--          end if;
--        end if;
--      end if;
--    end process;

--  end generate;

end gth_register_file_arch;
--============================================================================
--                                                            Architecture end
--============================================================================
