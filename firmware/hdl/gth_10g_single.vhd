library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.VCOMPONENTS.all;

library work;
use work.gth_pkg.all;

--============================================================================
--                                                          Entity declaration
--============================================================================
entity gth_10gbps_buf_cc_gt is
  generic
    (
      -- Simulation attributes
      g_GT_SIM_GTRESET_SPEEDUP : string := "FALSE";  -- Set to "TRUE" to speed up sim reset
      g_CONFIG : t_gth_config := C_GTH_DISABLED
      );
  port
    (

      gth_gt_txreset_sticky_i : in std_logic;
      gth_gt_rxreset_sticky_i : in std_logic;

      gth_gt_clk_i  : in  t_gth_gt_clk_in;
      gth_refclk0_i : in  std_logic;
      gth_gt_clk_o  : out t_gth_gt_clk_out;
      gth_gt_drp_i  : in  t_gth_gt_drp_in;
      gth_gt_drp_o  : out t_gth_gt_drp_out;

      gth_tx_ctrl_i   : in  t_gth_tx_ctrl;
      gth_tx_init_i   : in  t_gth_tx_init;
      gth_tx_status_o : out t_gth_tx_status;

      gth_rx_ctrl_i   : in  t_gth_rx_ctrl;
      gth_rx_init_i   : in  t_gth_rx_init;
      gth_rx_status_o : out t_gth_rx_status;
      
      gth_cpll_ctrl_i   : in t_gth_cpll_ctrl;
      gth_cpll_status_o : out t_gth_cpll_status;

      gth_gt_rxdfelpmreset_i : in std_logic;
      gth_gt_rxcdrreset_i    : in std_logic;
      
      gth_rx_gearboxslip_i   : in std_logic;

      gth_rx_cdr_ctrl_i          : in  t_gth_rx_cdr_ctrl;
      gth_rx_eq_cdr_dfe_status_o : out t_gth_rx_eq_cdr_dfe_status;
      gth_rx_lpm_ctrl_i          : in  t_gth_rx_lpm_ctrl;
      gth_rx_dfe_agc_ctrl_i      : in  t_gth_rx_dfe_agc_ctrl;
      gth_rx_dfe_1_ctrl_i        : in  t_gth_rx_dfe_1_ctrl;
      gth_rx_dfe_2_ctrl_i        : in  t_gth_rx_dfe_2_ctrl;
      gth_rx_os_ctrl_i           : in  t_gth_rx_os_ctrl;

      gth_misc_ctrl_i   : in  t_gth_misc_ctrl;
      gth_misc_status_o : out t_gth_misc_status;

      gth_tx_data_i : in  t_gth_tx_data;
      gth_rx_data_o : out t_gth_rx_data

      );

end gth_10gbps_buf_cc_gt;

--============================================================================
--                                                        Architecture section
--============================================================================
architecture gth_10gbps_buf_cc_gt_arch of gth_10gbps_buf_cc_gt is


--============================================================================
--                                                         Signal declarations
--============================================================================
  -- ground and tied_to_vcc_i signals
  signal  tied_to_ground_i                :   std_logic;
  signal  tied_to_ground_vec_i            :   std_logic_vector(63 downto 0);
  signal  tied_to_vcc_i                   :   std_logic;

  -- dummy signals to surpress synth. warnings
  signal s_rxdata_float        : std_logic_vector(31 downto 0);
  signal s_rxchariscomma_float : std_logic_vector(3 downto 0);
  signal s_rxcharisk_float     : std_logic_vector(3 downto 0);
  signal s_rxdisperr_float     : std_logic_vector(3 downto 0);
  signal s_rxnotintable_float  : std_logic_vector(3 downto 0);

  signal s_gth_gt_txreset : std_logic;
  signal s_gth_gt_rxreset : std_logic;

  signal s_dmonitorout     :  std_logic_vector(14 downto 0);
  signal s_dmonitorout_cmp1  :  std_logic_vector(14 downto 0);
  signal s_dmonitorout_cmp2  :  std_logic_vector(14 downto 0);
  
  signal s_rxdatavalid_float : std_logic;
  signal s_rxheader_float : std_logic_vector(3 downto 0);
  signal s_rxheadervalid_float : std_logic;
  
  -- configuration signals
  function bool_to_string(b: boolean) return string is begin
    if b then return "true";
    else return "false";
    end if;
  end bool_to_string;
  
  function tx_xclksel_from_bufferen(b: boolean) return string is begin
      if b then return "TXOUT";
      else return "TXUSR";
      end if;
  end tx_xclksel_from_bufferen;
    
    function rx_xclksel_from_bufferen(b: boolean) return string is begin
        if b then return "RXREC";
        else return "RXUSR";
        end if;
    end rx_xclksel_from_bufferen;
    
    function gearbox_mode_sel(b: boolean) return bit_vector is begin
        if b then return "001";
        else return "000";
        end if;
    end gearbox_mode_sel;
  
  --type t_rxgearbox_sel is array (t_gth_encoding) of string; -- NOTE: Using array of strings would be easier, but it crashes the synth tool (2016.1)
  --constant c_gearbox_en_sel : t_rxgearbox_sel := (gth_encoding_none => "FALSE", gth_encoding_8b10b => "FALSE", gth_encoding_64b66b => "TRUE");
  type t_rxgearbox_sel is array (t_gth_encoding) of boolean;
  constant c_gearbox_en_sel : t_rxgearbox_sel := (gth_encoding_none => false, gth_encoding_8b10b => false, gth_encoding_64b66b => true);
  constant c_clk_correction_use_sel : t_rxgearbox_sel := (gth_encoding_none => false, gth_encoding_8b10b => false, gth_encoding_64b66b => false);
  
  type t_8b10ben_sel is array (t_gth_encoding) of std_logic;
  constant c_8b10b_en_sel : t_8b10ben_sel := (gth_encoding_none => '0', gth_encoding_8b10b => '1', gth_encoding_64b66b => '0');
  
  type t_bool_to_std_logic is array (boolean) of std_logic;
  constant c_bool_to_std_logic : t_bool_to_std_logic := (true => '1', false => '0');
  constant c_bool_to_std_logic_inv : t_bool_to_std_logic := (true => '0', false => '1');
  
  type t_txoutclksel_sel is array (boolean) of std_logic_vector (2 downto 0);
  constant c_txoutclksel_sel : t_txoutclksel_sel := (true => "010", false => "011");
  constant c_gearbox_mode_sel : t_txoutclksel_sel := (true => "001", false => "000");
  
  function rxcdr_cfg_sel(s: integer) return bit_vector is begin
    if (s >= 8000) then return x"0002007FE2000C208001A";
    else return x"0002007FE2000C2080018";
    end if;
  end rxcdr_cfg_sel;

--============================================================================
--                                                          Architecture begin
--============================================================================
begin

  ---------------------------  Static signal Assignments ---------------------   
  tied_to_ground_i                    <= '0';
  tied_to_ground_vec_i(63 downto 0)   <= (others => '0' );
  tied_to_vcc_i                       <= '1';

  --gth_rx_status_o.rxinsync <= 'Z';
 
  s_gth_gt_txreset <= gth_gt_txreset_sticky_i or gth_tx_init_i.gttxreset;
  s_gth_gt_rxreset <= gth_gt_rxreset_sticky_i or gth_rx_init_i.gtrxreset;
  
  process(gth_gt_clk_i.rxusrclk2) is
  begin
      if rising_edge(gth_gt_clk_i.rxusrclk2) then
          if (s_gth_gt_rxreset = '1' ) then
              s_dmonitorout_cmp1 <= (others => '0');
              s_dmonitorout_cmp2 <= (others => '0');
              gth_misc_status_o.dmonitorout <= (others => '0');
          else
              s_dmonitorout_cmp1 <= s_dmonitorout;
              s_dmonitorout_cmp2 <= s_dmonitorout_cmp1;
              
              if (s_dmonitorout_cmp2 = s_dmonitorout_cmp1) then
                   gth_misc_status_o.dmonitorout <= s_dmonitorout_cmp2;
              end if;
          end if;
      end if;
  end process;

  ----------------------------- GTHE2 Instance  --------------------------   

  i_gthe2 : GTHE2_CHANNEL
      generic map
  (

    --_______________________ Simulation-Only Attributes ___________________

    SIM_RECEIVER_DETECT_PASS => ("TRUE"),
    SIM_RESET_SPEEDUP        => (g_GT_SIM_GTRESET_SPEEDUP),
    SIM_TX_EIDLE_DRIVE_LEVEL => ("X"),
    SIM_CPLLREFCLK_SEL       => ("001"),
    SIM_VERSION              => ("2.0"),


    ------------------RX Byte and Word Alignment Attributes---------------
    ALIGN_COMMA_DOUBLE => ("FALSE"),
    ALIGN_COMMA_ENABLE => ("1111111111"),
    ALIGN_COMMA_WORD   => (4),
    ALIGN_MCOMMA_DET   => ("TRUE"),
    ALIGN_MCOMMA_VALUE => ("1010000011"),
    ALIGN_PCOMMA_DET   => ("TRUE"),
    ALIGN_PCOMMA_VALUE => ("0101111100"),
    SHOW_REALIGN_COMMA => ("TRUE"),
    RXSLIDE_AUTO_WAIT  => (7),
    RXSLIDE_MODE       => ("OFF"),
    RX_SIG_VALID_DLY   => (10),

    ------------------RX 8B/10B Decoder Attributes---------------
    RX_DISPERR_SEQ_MATCH => ("TRUE"),
    DEC_MCOMMA_DETECT    => ("TRUE"),
    DEC_PCOMMA_DETECT    => ("TRUE"),
    DEC_VALID_COMMA_ONLY => ("FALSE"),

    ------------------------RX Clock Correction Attributes----------------------
    CBCC_DATA_SOURCE_SEL => ("DECODED"),
    CLK_COR_SEQ_2_USE    => ("FALSE"),
    CLK_COR_KEEP_IDLE    => ("FALSE"),
    CLK_COR_MAX_LAT      => (31),
    CLK_COR_MIN_LAT      => (24),
    CLK_COR_PRECEDENCE   => ("TRUE"),
    CLK_COR_REPEAT_WAIT  => (0),
    CLK_COR_SEQ_LEN      => (4),
    CLK_COR_SEQ_1_ENABLE => ("1111"),
    CLK_COR_SEQ_1_1      => ("0111110111"),
    CLK_COR_SEQ_1_2      => ("0111110111"),
    CLK_COR_SEQ_1_3      => ("0111110111"),
    CLK_COR_SEQ_1_4      => ("0111110111"),
    CLK_CORRECT_USE      => ("TRUE"),
    CLK_COR_SEQ_2_ENABLE => ("1111"),
    CLK_COR_SEQ_2_1      => ("0000000000"),
    CLK_COR_SEQ_2_2      => ("0000000000"),
    CLK_COR_SEQ_2_3      => ("0000000000"),
    CLK_COR_SEQ_2_4      => ("0000000000"),

    ------------------------RX Channel Bonding Attributes----------------------
    CHAN_BOND_KEEP_ALIGN   => ("FALSE"),
    CHAN_BOND_MAX_SKEW     => (1),
    CHAN_BOND_SEQ_LEN      => (1),
    CHAN_BOND_SEQ_1_1      => ("0000000000"),
    CHAN_BOND_SEQ_1_2      => ("0000000000"),
    CHAN_BOND_SEQ_1_3      => ("0000000000"),
    CHAN_BOND_SEQ_1_4      => ("0000000000"),
    CHAN_BOND_SEQ_1_ENABLE => ("1111"),
    CHAN_BOND_SEQ_2_1      => ("0000000000"),
    CHAN_BOND_SEQ_2_2      => ("0000000000"),
    CHAN_BOND_SEQ_2_3      => ("0000000000"),
    CHAN_BOND_SEQ_2_4      => ("0000000000"),
    CHAN_BOND_SEQ_2_ENABLE => ("1111"),
    CHAN_BOND_SEQ_2_USE    => ("FALSE"),
    FTS_DESKEW_SEQ_ENABLE  => ("1111"),
    FTS_LANE_DESKEW_CFG    => ("1111"),
    FTS_LANE_DESKEW_EN     => ("FALSE"),

    ---------------------------RX Margin Analysis Attributes----------------------------
    ES_CONTROL     => ("000000"),
    ES_ERRDET_EN   => ("FALSE"),
    ES_EYE_SCAN_EN => ("TRUE"),
    ES_HORZ_OFFSET => (x"000"),
    ES_PMA_CFG     => ("0000000000"),
    ES_PRESCALE    => ("00000"),
    ES_QUALIFIER   => (x"00000000000000000000"),
    ES_QUAL_MASK   => (x"00000000000000000000"),
    ES_SDATA_MASK  => (x"00000000000000000000"),
    ES_VERT_OFFSET => ("000000000"),

    -------------------------FPGA RX Interface Attributes-------------------------
    RX_DATA_WIDTH => (40),

    ---------------------------PMA Attributes----------------------------
    OUTREFCLK_SEL_INV => ("11"),
    PMA_RSV           => (x"001E7080"),
    PMA_RSV2          => (x"1C00000A"),
    PMA_RSV3          => ("00"),
    PMA_RSV4          => (x"0008"),
    RX_BIAS_CFG       => ("000011000000000000010000"),
    DMONITOR_CFG      => (x"000A00"),
    RX_CM_SEL         => ("00"),
    RX_CM_TRIM        => ("0000"),
    RX_DEBUG_CFG      => ("00000000000000"),
    RX_OS_CFG         => ("0000010000000"),
    TERM_RCAL_CFG     => ("100001000010000"),
    TERM_RCAL_OVRD    => ("000"),
    TST_RSV           => (x"00000000"),
    RX_CLK25_DIV      => (10),
    TX_CLK25_DIV      => (10),
    UCODEER_CLR       => ('0'),

    ---------------------------PCI Express Attributes----------------------------
    PCS_PCIE_EN => ("FALSE"),

    ---------------------------PCS Attributes----------------------------
    PCS_RSVD_ATTR => (x"000000000000"),

    -------------RX Buffer Attributes------------
    RXBUF_ADDR_MODE            => ("FULL"),
    RXBUF_EIDLE_HI_CNT         => ("1000"),
    RXBUF_EIDLE_LO_CNT         => ("0000"),
    RXBUF_EN                   => ("TRUE"),
    RX_BUFFER_CFG              => ("000000"),
    RXBUF_RESET_ON_CB_CHANGE   => ("TRUE"),
    RXBUF_RESET_ON_COMMAALIGN  => ("FALSE"),
    RXBUF_RESET_ON_EIDLE       => ("FALSE"),
    RXBUF_RESET_ON_RATE_CHANGE => ("TRUE"),
    RXBUFRESET_TIME            => ("00001"),
    RXBUF_THRESH_OVFLW         => (61),
    RXBUF_THRESH_OVRD          => ("FALSE"),
    RXBUF_THRESH_UNDFLW        => (4),
    RXDLY_CFG                  => (x"001F"),
    RXDLY_LCFG                 => (x"030"),
    RXDLY_TAP_CFG              => (x"0000"),
    RXPH_CFG                   => (x"C00002"),
    RXPHDLY_CFG                => (x"084020"),
    RXPH_MONITOR_SEL           => ("00000"),
    RX_XCLK_SEL                => ("RXREC"),
    RX_DDI_SEL                 => ("000000"),
    RX_DEFER_RESET_BUF_EN      => ("TRUE"),

    -----------------------CDR Attributes-------------------------

    --For Display Port, HBR/RBR- set RXCDR_CFG=72'h0380008bff40200008

    --For Display Port, HBR2 -   set RXCDR_CFG=72'h038c008bff20200010
    RXCDR_CFG               => (x"0002007FE2000C208001A"),
    RXCDR_FR_RESET_ON_EIDLE => ('0'),
    RXCDR_HOLD_DURING_EIDLE => ('0'),
    RXCDR_PH_RESET_ON_EIDLE => ('0'),
    RXCDR_LOCK_CFG          => ("010101"),

    -------------------RX Initialization and Reset Attributes-------------------
    RXCDRFREQRESET_TIME => ("00001"),
    RXCDRPHRESET_TIME   => ("00001"),
    RXISCANRESET_TIME   => ("00001"),
    RXPCSRESET_TIME     => ("00001"),
    RXPMARESET_TIME     => ("00011"),

    -------------------RX OOB Signaling Attributes-------------------
    RXOOB_CFG => ("0000110"),

    -------------------------RX Gearbox Attributes---------------------------
    RXGEARBOX_EN => ("FALSE"),
    GEARBOX_MODE => ("000"),

    -------------------------PRBS Detection Attribute-----------------------
    RXPRBS_ERR_LOOPBACK => ('1'),

    -------------Power-Down Attributes----------
    PD_TRANS_TIME_FROM_P2 => (x"03c"),
    PD_TRANS_TIME_NONE_P2 => (x"3c"),
    PD_TRANS_TIME_TO_P2   => (x"64"),

    -------------RX OOB Signaling Attributes----------
    SAS_MAX_COM        => (64),
    SAS_MIN_COM        => (36),
    SATA_BURST_SEQ_LEN => ("1111"),
    SATA_BURST_VAL     => ("100"),
    SATA_EIDLE_VAL     => ("100"),
    SATA_MAX_BURST     => (8),
    SATA_MAX_INIT      => (21),
    SATA_MAX_WAKE      => (7),
    SATA_MIN_BURST     => (4),
    SATA_MIN_INIT      => (12),
    SATA_MIN_WAKE      => (4),

    -------------RX Fabric Clock Output Control Attributes----------
    TRANS_TIME_RATE => (x"0E"),

    --------------TX Buffer Attributes----------------
    TXBUF_EN                   => ("TRUE"),
    TXBUF_RESET_ON_RATE_CHANGE => ("TRUE"),
    TXDLY_CFG                  => (x"001F"),
    TXDLY_LCFG                 => (x"030"),
    TXDLY_TAP_CFG              => (x"0000"),
    TXPH_CFG                   => (x"0780"),
    TXPHDLY_CFG                => (x"084020"),
    TXPH_MONITOR_SEL           => ("00000"),
    TX_XCLK_SEL                => ("TXOUT"),

    -------------------------FPGA TX Interface Attributes-------------------------
    TX_DATA_WIDTH => (40),

    -------------------------TX Configurable Driver Attributes-------------------------
    TX_DEEMPH0              => ("000000"),
    TX_DEEMPH1              => ("000000"),
    TX_EIDLE_ASSERT_DELAY   => ("110"),
    TX_EIDLE_DEASSERT_DELAY => ("100"),
    TX_LOOPBACK_DRIVE_HIZ   => ("FALSE"),
    TX_MAINCURSOR_SEL       => ('0'),
    TX_DRIVE_MODE           => ("DIRECT"),
    TX_MARGIN_FULL_0        => ("1001110"),
    TX_MARGIN_FULL_1        => ("1001001"),
    TX_MARGIN_FULL_2        => ("1000101"),
    TX_MARGIN_FULL_3        => ("1000010"),
    TX_MARGIN_FULL_4        => ("1000000"),
    TX_MARGIN_LOW_0         => ("1000110"),
    TX_MARGIN_LOW_1         => ("1000100"),
    TX_MARGIN_LOW_2         => ("1000010"),
    TX_MARGIN_LOW_3         => ("1000000"),
    TX_MARGIN_LOW_4         => ("1000000"),

    -------------------------TX Gearbox Attributes--------------------------
    TXGEARBOX_EN => ("FALSE"),

    -------------------------TX Initialization and Reset Attributes--------------------------
    TXPCSRESET_TIME => ("00001"),
    TXPMARESET_TIME => ("00001"),

    -------------------------TX Receiver Detection Attributes--------------------------
    TX_RXDETECT_CFG => (x"1832"),
    TX_RXDETECT_REF => ("100"),

    ----------------------------CPLL Attributes----------------------------
    CPLL_CFG        => (x"00BC07DC"),
    CPLL_FBDIV      => (5),
    CPLL_FBDIV_45   => (5),
    CPLL_INIT_CFG   => (x"00001E"),
    CPLL_LOCK_CFG   => (x"01E8"),
    CPLL_REFCLK_DIV => (1),
    RXOUT_DIV       => (1),
    TXOUT_DIV       => (1),
    SATA_CPLL_CFG   => ("VCO_3000MHZ"),

    --------------RX Initialization and Reset Attributes-------------
    RXDFELPMRESET_TIME => ("0001111"),

    --------------RX Equalizer Attributes-------------
    RXLPM_HF_CFG                 => ("00001000000000"),
    RXLPM_LF_CFG                 => ("001001000000000000"),
    RX_DFE_GAIN_CFG              => (x"0020C0"),
    RX_DFE_H2_CFG                => ("000000000000"),
    RX_DFE_H3_CFG                => ("000001000000"),
    RX_DFE_H4_CFG                => ("00011100000"),
    RX_DFE_H5_CFG                => ("00011100000"),
    RX_DFE_KL_CFG                => ("001000001000000000000001100010000"),
    RX_DFE_LPM_CFG               => (x"0080"),
    RX_DFE_LPM_HOLD_DURING_EIDLE => ('0'),
    RX_DFE_UT_CFG                => ("00011100000000000"),
    RX_DFE_VP_CFG                => ("00011101010100011"),

    -------------------------Power-Down Attributes-------------------------
    RX_CLKMUX_PD => ('1'),
    TX_CLKMUX_PD => ('1'),

    -------------------------FPGA RX Interface Attribute-------------------------
    RX_INT_DATAWIDTH => (1),

    -------------------------FPGA TX Interface Attribute-------------------------
    TX_INT_DATAWIDTH => (1),

    ------------------TX Configurable Driver Attributes---------------
    TX_QPI_STATUS_EN => ('0'),

    ------------------ JTAG Attributes ---------------
    ACJTAG_DEBUG_MODE       => ('0'),
    ACJTAG_MODE             => ('0'),
    ACJTAG_RESET            => ('0'),
    ADAPT_CFG0              => (x"00C10"),
    CFOK_CFG                => (x"24800040E80"),
    CFOK_CFG2               => (x"20"),
    CFOK_CFG3               => (x"20"),
    ES_CLK_PHASE_SEL        => ('0'),
    PMA_RSV5                => (x"0"),
    RESET_POWERSAVE_DISABLE => ('0'),
    USE_PCS_CLK_PHASE_SEL   => ('0'),
    A_RXOSCALRESET          => ('0'),

    ------------------ RX Phase Interpolator Attributes---------------
    RXPI_CFG0 => ("00"),
    RXPI_CFG1 => ("11"),
    RXPI_CFG2 => ("11"),
    RXPI_CFG3 => ("11"),
    RXPI_CFG4 => ('0'),
    RXPI_CFG5 => ('0'),
    RXPI_CFG6 => ("100"),

    --------------RX Decision Feedback Equalizer(DFE)-------------
    RX_DFELPM_CFG0             => ("0110"),
    RX_DFELPM_CFG1             => ('0'),
    RX_DFELPM_KLKH_AGC_STUP_EN => ('1'),
    RX_DFE_AGC_CFG0            => ("00"),
    RX_DFE_AGC_CFG1            => ("100"),
    RX_DFE_AGC_CFG2            => ("0000"),
    RX_DFE_AGC_OVRDEN          => ('1'),
    RX_DFE_H6_CFG              => (x"020"),
    RX_DFE_H7_CFG              => (x"020"),
    RX_DFE_KL_LPM_KH_CFG0      => ("01"),
    RX_DFE_KL_LPM_KH_CFG1      => ("010"),
    RX_DFE_KL_LPM_KH_CFG2      => ("0010"),
    RX_DFE_KL_LPM_KH_OVRDEN    => ('1'),
    RX_DFE_KL_LPM_KL_CFG0      => ("10"),
    RX_DFE_KL_LPM_KL_CFG1      => ("010"),
    RX_DFE_KL_LPM_KL_CFG2      => ("0010"),
    RX_DFE_KL_LPM_KL_OVRDEN    => ('1'),
    RX_DFE_ST_CFG              => (x"00E100000C003F"),

    ------------------ TX Phase Interpolator Attributes---------------
    TXPI_CFG0                  => ("00"),
    TXPI_CFG1                  => ("00"),
    TXPI_CFG2                  => ("00"),
    TXPI_CFG3                  => ('0'),
    TXPI_CFG4                  => ('0'),
    TXPI_CFG5                  => ("100"),
    TXPI_GREY_SEL              => ('0'),
    TXPI_INVSTROBE_SEL         => ('0'),
    TXPI_PPMCLK_SEL            => ("TXUSRCLK2"),
    TXPI_PPM_CFG               => (x"00"),
    TXPI_SYNFREQ_PPM           => ("000"),
    TX_RXDETECT_PRECHARGE_TIME => (x"155CC"),

    ------------------ LOOPBACK Attributes---------------
    LOOPBACK_CFG => ('0'),

    ------------------RX OOB Signalling Attributes---------------
    RXOOB_CLK_CFG => ("PMA"),

    ------------------ CDR Attributes ---------------
    RXOSCALRESET_TIME    => ("00011"),
    RXOSCALRESET_TIMEOUT => ("00000"),

    ------------------TX OOB Signalling Attributes---------------
    TXOOB_CFG => ('0'),

    ------------------RX Buffer Attributes---------------
    RXSYNC_MULTILANE => ('1'),
    RXSYNC_OVRD      => ('0'),
    RXSYNC_SKIP_DA   => ('0'),

    ------------------TX Buffer Attributes---------------
    TXSYNC_MULTILANE => ('0'),
    TXSYNC_OVRD      => ('0'),
    TXSYNC_SKIP_DA   => ('0')
    )
    port map
    (
      --------------------------------- CPLL Ports -------------------------------
      CPLLFBCLKLOST         => gth_cpll_status_o.cpllfbclklost,
      CPLLLOCK              => gth_cpll_status_o.cplllock,
      CPLLLOCKDETCLK        => gth_gt_drp_i.DRPCLK,
      CPLLLOCKEN            => tied_to_vcc_i,
      CPLLPD                => c_bool_to_std_logic(g_CONFIG.tx_config.qpll_used and g_CONFIG.rx_config.qpll_used),
      CPLLREFCLKLOST        => gth_cpll_status_o.CPLLREFCLKLOST,
      CPLLREFCLKSEL         => "001",
      CPLLRESET             => gth_cpll_ctrl_i.cpllreset,
      GTRSVD                => "0000000000000000",
      PCSRSVDIN             => "0000000000000000",
      PCSRSVDIN2            => "00000",
      PMARSVDIN             => "00000",
      TSTIN                 => "11111111111111111111",
      -------------------------- Channel - Clocking Ports ------------------------
      GTGREFCLK             => tied_to_ground_i,
      GTNORTHREFCLK0        => tied_to_ground_i,
      GTNORTHREFCLK1        => tied_to_ground_i,
      GTREFCLK0             => gth_refclk0_i,
      GTREFCLK1             => tied_to_ground_i,
      GTSOUTHREFCLK0        => tied_to_ground_i,
      GTSOUTHREFCLK1        => tied_to_ground_i,
      ---------------------------- Channel - DRP Ports  --------------------------
      DRPADDR               => gth_gt_drp_i.DRPADDR,
      DRPCLK                => gth_gt_drp_i.DRPCLK,
      DRPDI                 => gth_gt_drp_i.DRPDI,
      DRPDO                 => gth_gt_drp_o.DRPDO,
      DRPEN                 => gth_gt_drp_i.DRPEN,
      DRPRDY                => gth_gt_drp_o.DRPRDY,
      DRPWE                 => gth_gt_drp_i.DRPWE,
      ------------------------------- Clocking Ports -----------------------------
      GTREFCLKMONITOR       => open,
      QPLLCLK               => gth_gt_clk_i.qpllclk,
      QPLLREFCLK            => gth_gt_clk_i.qpllrefclk,
      RXSYSCLKSEL           => gth_rx_ctrl_i.rxsysclksel,
      TXSYSCLKSEL           => gth_tx_ctrl_i.txsysclksel,
      ----------------- FPGA TX Interface Datapath Configuration  ----------------
      TX8B10BEN             => c_8b10b_en_sel(g_CONFIG.tx_config.encoding),
      ------------------------------- Loopback Ports -----------------------------
      LOOPBACK              => gth_misc_ctrl_i.loopback,
      ----------------------------- PCI Express Ports ----------------------------
      PHYSTATUS             => open,
      RXRATE                => tied_to_ground_vec_i(2 downto 0),
      RXVALID               => open,
      ------------------------------ Power-Down Ports ----------------------------
      RXPD                  => gth_rx_ctrl_i.rxpd,
      TXPD                  => gth_tx_ctrl_i.txpd,
      -------------------------- RX 8B/10B Decoder Ports -------------------------
      SETERRSTATUS          => tied_to_ground_i,
      --------------------- RX Initialization and Reset Ports --------------------
      EYESCANRESET          => gth_misc_ctrl_i.eyescanreset,
      RXUSERRDY             => gth_rx_init_i.rxuserrdy,
      -------------------------- RX Margin Analysis Ports ------------------------
      EYESCANDATAERROR      => gth_misc_status_o.eyescandataerror,
      EYESCANMODE           => tied_to_ground_i,     -- reserved
      EYESCANTRIGGER        => gth_misc_ctrl_i.eyescantrigger,
      ------------------------------- Receive Ports ------------------------------
      CLKRSVD0              => tied_to_ground_i,
      CLKRSVD1              => tied_to_ground_i,
      DMONFIFORESET         => tied_to_ground_i,
      DMONITORCLK           => gth_gt_drp_i.DRPCLK,
      RXPMARESETDONE        => gth_rx_status_o.RXPMARESETDONE,
      RXRATEMODE            => tied_to_ground_i,
      SIGVALIDCLK           => tied_to_ground_i,
      TXPMARESETDONE        => gth_tx_status_o.TXPMARESETDONE,
      -------------- Receive Ports - 64b66b and 64b67b Gearbox Ports -------------
      RXSTARTOFSEQ          => open,
      ------------------------- Receive Ports - CDR Ports ------------------------
      RXCDRFREQRESET        => gth_rx_cdr_ctrl_i.RXCDRFREQRESET,
      RXCDRHOLD             => gth_rx_cdr_ctrl_i.RXCDRHOLD,
      RXCDRLOCK             => gth_rx_eq_cdr_dfe_status_o.RXCDRLOCK,
      RXCDROVRDEN           => gth_rx_cdr_ctrl_i.RXCDROVRDEN,
      RXCDRRESET            => gth_gt_rxcdrreset_i,
      RXCDRRESETRSV         => gth_rx_cdr_ctrl_i.RXCDRRESETRSV,
      ------------------- Receive Ports - Clock Correction Ports -----------------
      RXCLKCORCNT           => gth_rx_status_o.rxclkcorcnt,
      --------------- Receive Ports - Comma Detection and Alignment --------------
      RXSLIDE               => tied_to_ground_i,
      ------------------- Receive Ports - Digital Monitor Ports ------------------
      DMONITOROUT           => s_dmonitorout,
      ---------- Receive Ports - FPGA RX Interface Datapath Configuration --------
      RX8B10BEN             => c_8b10b_en_sel(g_CONFIG.rx_config.encoding),
      ------------------ Receive Ports - FPGA RX Interface Ports -----------------
      RXUSRCLK              => gth_gt_clk_i.rxusrclk,
      RXUSRCLK2             => gth_gt_clk_i.rxusrclk2,
      ------------------ Receive Ports - FPGA RX interface Ports -----------------
      RXDATA(63 downto 32)  => s_rxdata_float,
      RXDATA(31 downto 0)   => gth_rx_data_o.rxdata(31 downto 0),
      ------------------- Receive Ports - Pattern Checker Ports ------------------
      RXPRBSERR             => gth_rx_status_o.rxprbserr,
      RXPRBSSEL             => gth_rx_ctrl_i.rxprbssel,
      ------------------- Receive Ports - Pattern Checker ports ------------------
      RXPRBSCNTRESET        => gth_rx_ctrl_i.rxprbscntreset,
      ------------------ Receive Ports - RX 8B/10B Decoder Ports -----------------
      RXDISPERR(7 downto 4) => s_rxdisperr_float,
      RXDISPERR(3 downto 0) => gth_rx_data_o.rxdisperr,

      RXNOTINTABLE(7 downto 4)   => s_rxnotintable_float,
      RXNOTINTABLE(3 downto 0)   => gth_rx_data_o.rxnotintable,
      ------------------------ Receive Ports - RX AFE Ports ----------------------
      GTHRXN                     => tied_to_ground_i,
      ------------------- Receive Ports - RX Buffer Bypass Ports -----------------
      RXBUFRESET                 => gth_rx_ctrl_i.rxbufreset,
      RXBUFSTATUS                => gth_rx_status_o.rxbufstatus,
      RXDDIEN                    => c_bool_to_std_logic_inv(g_CONFIG.rx_config.buffer_enabled),
      RXDLYBYPASS                => c_bool_to_std_logic(g_CONFIG.rx_config.buffer_enabled),
      RXDLYEN                    => gth_rx_init_i.RXDLYEN,
      RXDLYOVRDEN                => tied_to_ground_i,
      RXDLYSRESET                => gth_rx_init_i.RXDLYSRESET,
      RXDLYSRESETDONE            => gth_rx_status_o.RXDLYSRESETDONE,
      RXPHALIGN                  => gth_rx_init_i.RXPHALIGN,
      RXPHALIGNDONE              => gth_rx_status_o.RXPHALIGNDONE,
      RXPHALIGNEN                => gth_rx_init_i.RXPHALIGNEN,
      RXPHDLYPD                  => tied_to_ground_i,
      RXPHDLYRESET               => gth_rx_init_i.RXPHDLYRESET,
      RXPHMONITOR                => open,
      RXPHOVRDEN                 => tied_to_ground_i,
      RXPHSLIPMONITOR            => open,
      RXSTATUS                   => open,
      RXSYNCALLIN                => gth_rx_init_i.RXSYNCALLIN,
      RXSYNCDONE                 => gth_rx_status_o.RXSYNCDONE,
      RXSYNCIN                   => gth_rx_init_i.RXSYNCIN,
      RXSYNCMODE                 => gth_rx_init_i.RXSYNCMODE,
      RXSYNCOUT                  => gth_rx_status_o.RXSYNCOUT,
      -------------- Receive Ports - RX Byte and Word Alignment Ports ------------
      RXBYTEISALIGNED            => gth_rx_data_o.rxbyteisaligned,
      RXBYTEREALIGN              => gth_rx_data_o.rxbyterealign,
      RXCOMMADET                 => gth_rx_data_o.rxcommadet,
      RXCOMMADETEN               => c_8b10b_en_sel(g_CONFIG.tx_config.encoding),
      RXMCOMMAALIGNEN            => c_8b10b_en_sel(g_CONFIG.tx_config.encoding),
      RXPCOMMAALIGNEN            => c_8b10b_en_sel(g_CONFIG.tx_config.encoding),
      ------------------ Receive Ports - RX Channel Bonding Ports ----------------
      RXCHANBONDSEQ              => open,
      RXCHBONDEN                 => tied_to_ground_i,
      RXCHBONDLEVEL              => "000",
      RXCHBONDMASTER             => tied_to_ground_i,
      RXCHBONDO                  => open,
      RXCHBONDSLAVE              => tied_to_ground_i,
      ----------------- Receive Ports - RX Channel Bonding Ports  ----------------
      RXCHANISALIGNED            => open,
      RXCHANREALIGN              => open,
      ------------ Receive Ports - RX Decision Feedback Equalizer(DFE) -----------
      RSOSINTDONE                => gth_rx_eq_cdr_dfe_status_o.RSOSINTDONE,
      RXDFESLIDETAPOVRDEN        => gth_rx_dfe_1_ctrl_i.RXDFESLIDETAPOVRDEN,
      RXOSCALRESET               => gth_rx_os_ctrl_i.RXOSCALRESET,
      -------------------- Receive Ports - RX Equailizer Ports -------------------
      RXLPMHFHOLD                => gth_rx_lpm_ctrl_i.RXLPMHFHOLD,
      RXLPMHFOVRDEN              => gth_rx_lpm_ctrl_i.RXLPMHFOVRDEN,
      RXLPMLFHOLD                => gth_rx_lpm_ctrl_i.RXLPMLFHOLD,
      --------------------- Receive Ports - RX Equalizar Ports -------------------
      RXDFESLIDETAPSTARTED       => gth_rx_eq_cdr_dfe_status_o.RXDFESLIDETAPSTARTED,
      RXDFESLIDETAPSTROBEDONE    => gth_rx_eq_cdr_dfe_status_o.RXDFESLIDETAPSTROBEDONE,
      RXDFESLIDETAPSTROBESTARTED => gth_rx_eq_cdr_dfe_status_o.RXDFESLIDETAPSTROBESTARTED,
      --------------------- Receive Ports - RX Equalizer Ports -------------------
      RXADAPTSELTEST             => tied_to_ground_vec_i(13 downto 0),
      RXDFEAGCHOLD               => gth_rx_dfe_agc_ctrl_i.RXDFEAGCHOLD,
      RXDFEAGCOVRDEN             => gth_rx_dfe_agc_ctrl_i.RXDFEAGCOVRDEN,
      RXDFEAGCTRL                => gth_rx_dfe_agc_ctrl_i.RXDFEAGCTRL,
      RXDFECM1EN                 => gth_rx_dfe_1_ctrl_i.RXDFECM1EN,
      RXDFELFHOLD                => gth_rx_dfe_1_ctrl_i.RXDFELFHOLD,
      RXDFELFOVRDEN              => gth_rx_dfe_1_ctrl_i.RXDFELFOVRDEN,
      RXDFELPMRESET              => gth_gt_rxdfelpmreset_i,
      RXDFESLIDETAP              => gth_rx_dfe_2_ctrl_i.RXDFESLIDETAP,
      RXDFESLIDETAPADAPTEN       => gth_rx_dfe_1_ctrl_i.RXDFESLIDETAPADAPTEN,
      RXDFESLIDETAPHOLD          => gth_rx_dfe_1_ctrl_i.RXDFESLIDETAPHOLD,
      RXDFESLIDETAPID            => gth_rx_dfe_2_ctrl_i.RXDFESLIDETAPID,
      RXDFESLIDETAPINITOVRDEN    => gth_rx_dfe_1_ctrl_i.RXDFESLIDETAPINITOVRDEN,
      RXDFESLIDETAPONLYADAPTEN   => gth_rx_dfe_1_ctrl_i.RXDFESLIDETAPONLYADAPTEN,
      RXDFESLIDETAPSTROBE        => gth_rx_dfe_1_ctrl_i.RXDFESLIDETAPSTROBE,
      RXDFESTADAPTDONE           => gth_rx_eq_cdr_dfe_status_o.RXDFESTADAPTDONE,
      RXDFETAP2HOLD              => gth_rx_dfe_1_ctrl_i.RXDFETAP2HOLD,
      RXDFETAP2OVRDEN            => gth_rx_dfe_1_ctrl_i.RXDFETAP2OVRDEN,
      RXDFETAP3HOLD              => gth_rx_dfe_1_ctrl_i.RXDFETAP3HOLD,
      RXDFETAP3OVRDEN            => gth_rx_dfe_1_ctrl_i.RXDFETAP3OVRDEN,
      RXDFETAP4HOLD              => gth_rx_dfe_1_ctrl_i.RXDFETAP4HOLD,
      RXDFETAP4OVRDEN            => gth_rx_dfe_1_ctrl_i.RXDFETAP4OVRDEN,
      RXDFETAP5HOLD              => gth_rx_dfe_1_ctrl_i.RXDFETAP5HOLD,
      RXDFETAP5OVRDEN            => gth_rx_dfe_1_ctrl_i.RXDFETAP5OVRDEN,
      RXDFETAP6HOLD              => gth_rx_dfe_1_ctrl_i.RXDFETAP6HOLD,
      RXDFETAP6OVRDEN            => gth_rx_dfe_1_ctrl_i.RXDFETAP6OVRDEN,
      RXDFETAP7HOLD              => gth_rx_dfe_1_ctrl_i.RXDFETAP7HOLD,
      RXDFETAP7OVRDEN            => gth_rx_dfe_1_ctrl_i.RXDFETAP7OVRDEN,
      RXDFEUTHOLD                => gth_rx_dfe_1_ctrl_i.RXDFEUTHOLD,
      RXDFEUTOVRDEN              => gth_rx_dfe_1_ctrl_i.RXDFEUTOVRDEN,
      RXDFEVPHOLD                => gth_rx_dfe_1_ctrl_i.RXDFEVPHOLD,
      RXDFEVPOVRDEN              => gth_rx_dfe_1_ctrl_i.RXDFEVPOVRDEN,
      RXDFEVSEN                  => gth_rx_dfe_1_ctrl_i.RXDFEVSEN,
      RXDFEXYDEN                 => gth_rx_dfe_1_ctrl_i.RXDFEXYDEN,
      RXLPMLFKLOVRDEN            => gth_rx_lpm_ctrl_i.RXLPMLFKLOVRDEN,
      RXMONITOROUT               => open,
      RXMONITORSEL               => "11",
      RXOSHOLD                   => gth_rx_os_ctrl_i.RXOSHOLD,
      RXOSINTCFG                 => gth_rx_os_ctrl_i.RXOSINTCFG,
      RXOSINTEN                  => gth_rx_os_ctrl_i.RXOSINTEN,
      RXOSINTHOLD                => gth_rx_os_ctrl_i.RXOSINTHOLD,
      RXOSINTID0                 => gth_rx_os_ctrl_i.RXOSINTID0,
      RXOSINTNTRLEN              => gth_rx_os_ctrl_i.RXOSINTNTRLEN,
      RXOSINTOVRDEN              => gth_rx_os_ctrl_i.RXOSINTOVRDEN,
      RXOSINTSTARTED             => gth_rx_eq_cdr_dfe_status_o.RXOSINTSTARTED,
      RXOSINTSTROBE              => gth_rx_os_ctrl_i.RXOSINTSTROBE,
      RXOSINTSTROBEDONE          => gth_rx_eq_cdr_dfe_status_o.RXOSINTSTROBEDONE,
      RXOSINTSTROBESTARTED       => gth_rx_eq_cdr_dfe_status_o.RXOSINTSTROBESTARTED,
      RXOSINTTESTOVRDEN          => gth_rx_os_ctrl_i.RXOSINTTESTOVRDEN,
      RXOSOVRDEN                 => gth_rx_os_ctrl_i.RXOSOVRDEN,
      ------------ Receive Ports - RX Fabric ClocK Output Control Ports ----------
      RXRATEDONE                 => open,
      --------------- Receive Ports - RX Fabric Output Control Ports -------------
      RXOUTCLK                   => gth_gt_clk_o.rxoutclk,
      RXOUTCLKFABRIC             => open,
      RXOUTCLKPCS                => open,
      RXOUTCLKSEL                => "010",
      ---------------------- Receive Ports - RX Gearbox Ports --------------------
      RXDATAVALID(1)             => s_rxdatavalid_float,
      RXDATAVALID(0)             => gth_rx_data_o.rxdatavalid,
      RXHEADER(5 downto 2)       => s_rxheader_float,
      RXHEADER(1 downto 0)       => gth_rx_data_o.rxheader,
      RXHEADERVALID(1)           => s_rxheadervalid_float,
      RXHEADERVALID(0)           => gth_rx_data_o.rxheadervalid,
      --------------------- Receive Ports - RX Gearbox Ports  --------------------
      RXGEARBOXSLIP              => gth_rx_gearboxslip_i,
      ------------- Receive Ports - RX Initialization and Reset Ports ------------
      GTRXRESET                  => s_gth_gt_rxreset,
      RXOOBRESET                 => tied_to_ground_i,
      RXPCSRESET                 => tied_to_ground_i,
      RXPMARESET                 => tied_to_ground_i,
      ------------------ Receive Ports - RX Margin Analysis ports ----------------
      RXLPMEN                    => gth_rx_ctrl_i.rxlpmen,
      ------------------- Receive Ports - RX OOB Signaling ports -----------------
      RXCOMSASDET                => open,
      RXCOMWAKEDET               => open,
      ------------------ Receive Ports - RX OOB Signaling ports  -----------------
      RXCOMINITDET               => open,
      ------------------ Receive Ports - RX OOB signalling Ports -----------------
      RXELECIDLE                 => open,
      RXELECIDLEMODE             => "11",
      ----------------- Receive Ports - RX Polarity Control Ports ----------------
      RXPOLARITY                 => gth_rx_ctrl_i.rxpolarity,
      ------------------- Receive Ports - RX8B/10B Decoder Ports -----------------
      RXCHARISCOMMA(7 downto 4)  => s_rxchariscomma_float,
      RXCHARISCOMMA(3 downto 0)  => gth_rx_data_o.rxchariscomma,
      RXCHARISK(7 downto 4)      => s_rxcharisk_float,
      RXCHARISK(3 downto 0)      => gth_rx_data_o.rxcharisk,
      ------------------ Receive Ports - Rx Channel Bonding Ports ----------------
      RXCHBONDI                  => "00000",
      ------------------------ Receive Ports -RX AFE Ports -----------------------
      GTHRXP                     => tied_to_vcc_i,
      -------------- Receive Ports -RX Initialization and Reset Ports ------------
      RXRESETDONE                => gth_rx_status_o.rxresetdone,
      -------------------------------- Rx AFE Ports ------------------------------
      RXQPIEN                    => tied_to_ground_i,
      RXQPISENN                  => open,
      RXQPISENP                  => open,
      --------------------------- TX Buffer Bypass Ports -------------------------
      TXPHDLYTSTCLK              => tied_to_ground_i,
      ------------------------ TX Configurable Driver Ports ----------------------
      TXPOSTCURSOR               => gth_tx_ctrl_i.txpostcursor,
      TXPOSTCURSORINV            => gth_tx_ctrl_i.txpostcursorinv,
      TXPRECURSOR                => gth_tx_ctrl_i.txprecursor,
      TXPRECURSORINV             => gth_tx_ctrl_i.txprecursorinv,
      TXQPIBIASEN                => tied_to_ground_i,
      TXQPISTRONGPDOWN           => tied_to_ground_i,
      TXQPIWEAKPUP               => tied_to_ground_i,
      --------------------- TX Initialization and Reset Ports --------------------
      CFGRESET                   => tied_to_ground_i,
      GTTXRESET                  => s_gth_gt_txreset,
      PCSRSVDOUT                 => open,
      TXUSERRDY                  => gth_tx_init_i.txuserrdy,
      ----------------- TX Phase Interpolator PPM Controller Ports ---------------
      TXPIPPMEN                  => tied_to_ground_i,
      TXPIPPMOVRDEN              => tied_to_ground_i,
      TXPIPPMPD                  => tied_to_ground_i,
      TXPIPPMSEL                 => tied_to_ground_i,
      TXPIPPMSTEPSIZE            => tied_to_ground_vec_i(4 downto 0),
      ---------------------- Transceiver Reset Mode Operation --------------------
      GTRESETSEL                 => tied_to_ground_i,
      RESETOVRD                  => tied_to_ground_i,
      ------------------------------- Transmit Ports -----------------------------
      TXRATEMODE                 => tied_to_ground_i,
      -------------- Transmit Ports - 64b66b and 64b67b Gearbox Ports ------------
      TXHEADER                   => gth_tx_data_i.txheader,
      ---------------- Transmit Ports - 8b10b Encoder Control Ports --------------
      TXCHARDISPMODE             => "0000" & gth_tx_data_i.txchardispmode,
      TXCHARDISPVAL              => "0000" & gth_tx_data_i.txchardispval,
      ------------------ Transmit Ports - FPGA TX Interface Ports ----------------
      TXUSRCLK                   => gth_gt_clk_i.txusrclk,
      TXUSRCLK2                  => gth_gt_clk_i.txusrclk2,
      --------------------- Transmit Ports - PCI Express Ports -------------------
      TXELECIDLE                 => tied_to_ground_i,
      TXMARGIN                   => tied_to_ground_vec_i(2 downto 0),
      TXRATE                     => tied_to_ground_vec_i(2 downto 0),
      TXSWING                    => tied_to_ground_i,
      ------------------ Transmit Ports - Pattern Generator Ports ----------------
      TXPRBSFORCEERR             => gth_tx_ctrl_i.txprbsforceerr,
      ------------------ Transmit Ports - TX Buffer Bypass Ports -----------------
      TXDLYBYPASS               => tied_to_ground_i,
      TXDLYEN                   => gth_tx_init_i.TXDLYEN,
      TXDLYHOLD                 => tied_to_ground_i,
      TXDLYOVRDEN               => tied_to_ground_i,
      TXDLYSRESET               => gth_tx_init_i.TXDLYSRESET,
      TXDLYSRESETDONE           => gth_tx_status_o.TXDLYSRESETDONE,
      TXDLYUPDOWN               => tied_to_ground_i,
      TXPHALIGN                 => gth_tx_init_i.TXPHALIGN,
      TXPHALIGNDONE             => gth_tx_status_o.TXPHALIGNDONE,
      TXPHALIGNEN               => gth_tx_init_i.TXPHALIGNEN,
      TXPHDLYPD                 => tied_to_ground_i,
      TXPHDLYRESET              => gth_tx_init_i.TXPHDLYRESET,
      TXPHINIT                  => gth_tx_init_i.TXPHINIT,
      TXPHINITDONE              => gth_tx_status_o.TXPHINITDONE,
      TXPHOVRDEN                => tied_to_ground_i,
      TXSYNCALLIN               => tied_to_ground_i,
      TXSYNCDONE                => open,
      TXSYNCIN                  => tied_to_ground_i,
      TXSYNCMODE                => tied_to_ground_i,
      TXSYNCOUT                 => open,
      ---------------------- Transmit Ports - TX Buffer Ports --------------------
      TXBUFSTATUS                => gth_tx_status_o.txbufstatus,
      --------------- Transmit Ports - TX Configurable Driver Ports --------------
      TXBUFDIFFCTRL              => "100",
      TXDEEMPH                   => tied_to_ground_i,
      TXDIFFCTRL                 => gth_tx_ctrl_i.txdiffctrl,
      TXDIFFPD                   => tied_to_ground_i,
      TXINHIBIT                  => gth_tx_ctrl_i.txinhibit,
      TXMAINCURSOR               => gth_tx_ctrl_i.txmaincursor,
      TXPISOPD                   => tied_to_ground_i,
      ------------------ Transmit Ports - TX Data Path interface -----------------
      TXDATA(63 downto 32)       => x"00000000",
      TXDATA(31 downto 0)        => gth_tx_data_i.txdata(31 downto 0),
      ---------------- Transmit Ports - TX Driver and OOB signaling --------------
      GTHTXN                     => open,
      GTHTXP                     => open,
      ----------- Transmit Ports - TX Fabric Clock Output Control Ports ----------
      TXOUTCLK                   => gth_gt_clk_o.txoutclk,
      TXOUTCLKFABRIC             => open,
      TXOUTCLKPCS                => open,
      TXOUTCLKSEL                => c_txoutclksel_sel(g_CONFIG.rx_config.buffer_enabled),
      TXRATEDONE                 => open,
      --------------------- Transmit Ports - TX Gearbox Ports --------------------
      TXGEARBOXREADY             => gth_tx_status_o.txgearboxready,
      TXSEQUENCE                 => gth_tx_data_i.txsequence,
      TXSTARTSEQ                 => tied_to_ground_i,
      ------------- Transmit Ports - TX Initialization and Reset Ports -----------
      TXPCSRESET                 => tied_to_ground_i,
      TXPMARESET                 => tied_to_ground_i,
      TXRESETDONE                => gth_tx_status_o.txresetdone,
      ------------------ Transmit Ports - TX OOB signalling Ports ----------------
      TXCOMFINISH                => open,
      TXCOMINIT                  => tied_to_ground_i,
      TXCOMSAS                   => tied_to_ground_i,
      TXCOMWAKE                  => tied_to_ground_i,
      TXPDELECIDLEMODE           => tied_to_ground_i,
      ----------------- Transmit Ports - TX Polarity Control Ports ---------------
      TXPOLARITY                 => gth_tx_ctrl_i.txpolarity,
      --------------- Transmit Ports - TX Receiver Detection Ports  --------------
      TXDETECTRX                 => tied_to_ground_i,
      ------------------ Transmit Ports - TX8b/10b Encoder Ports -----------------
      TX8B10BBYPASS              => tied_to_ground_vec_i(7 downto 0),
      ------------------ Transmit Ports - pattern Generator Ports ----------------
      TXPRBSSEL                  => gth_tx_ctrl_i.txprbssel,
      ----------- Transmit Transmit Ports - 8b10b Encoder Control Ports ----------
      TXCHARISK(7 downto 4)      => tied_to_ground_vec_i(3 downto 0),
      TXCHARISK(3 downto 0)      => gth_tx_data_i.txcharisk,
      ----------------------- Tx Configurable Driver  Ports ----------------------
      TXQPISENN                  => open,
      TXQPISENP                  => open

      );

end gth_10gbps_buf_cc_gt_arch;
--============================================================================
--                                                            Architecture end
--============================================================================
