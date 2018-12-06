library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package gth_pkg is

  -------------------------- Configuration records ------------------------
  type t_gth_encoding is (gth_encoding_none, gth_encoding_8b10b, gth_encoding_64b66b);
  type t_gth_clk_source is (gth_clk_self, gth_clk_ttc_120, gth_clk_ttc_240);
  
  type t_gth_base_config is record
    enable            : boolean;
    link_rate         : integer;
    qpll_used         : boolean;
    encoding          : t_gth_encoding;
    buffer_enabled    : boolean;
    data_width        : integer;
    clk_source        : t_gth_clk_source; -- For TX, gth_clk_self will be shared based on clk_config setting
  end record;
  
  --type t_gth_txclk_config is record
  --  tx_clock_master : boolean;
  --end record;
  
  type t_gth_config is record
    tx_config         : t_gth_base_config;
    rx_config         : t_gth_base_config;
    txclk_master      : boolean;
  end record;
  
  -- Standard GTH BASE configurations
  constant C_GTH_NONE             : t_gth_base_config := (false, 0, false, gth_encoding_none, false, 0, gth_clk_self);
  constant C_GTH_4P8G_NOENC_SYNC  : t_gth_base_config := (true, 4800, false, gth_encoding_none, false, 40, gth_clk_ttc_120);
  constant C_GTH_4P8G_8B10B_SYNC  : t_gth_base_config := (true, 4800, false, gth_encoding_8b10b, false, 40, gth_clk_ttc_120);
  constant C_GTH_4P8G_8B10B_ASYNC : t_gth_base_config := (true, 4800, false, gth_encoding_8b10b, false, 40, gth_clk_self);
  constant C_GTH_10P0G_8B10B_BUF  : t_gth_base_config := (true, 10000, true, gth_encoding_8b10b, true, 40, gth_clk_self);
  constant C_GTH_8P0G_8B10B_BUF   : t_gth_base_config := (true, 8000,  true, gth_encoding_8b10b, true, 40, gth_clk_self);
  constant C_GTH_7P2G_8B10B_BUF   : t_gth_base_config := (true, 7200,  true, gth_encoding_8b10b, true, 40, gth_clk_self);
  constant C_GTH_10P0G_64B66B_BUF : t_gth_base_config := (true, 10000, true, gth_encoding_64b66b, true, 32, gth_clk_self);
  constant C_GTH_8P0G_64B66B_BUF  : t_gth_base_config := (true, 8000, true, gth_encoding_64b66b, true, 32, gth_clk_self);
  
  -- Standard GTH CLOCKING configurations
  constant C_GTH_TXCLK_SYNC             : boolean := false;
  constant C_GTH_TXCLK_ASYNC_MASTER     : boolean := true;
  constant C_GTH_TXCLK_ASYNC_SLAVE      : boolean := false;
  
  -- Standard full configurations
  constant C_GTH_DISABLED         : t_gth_config := (C_GTH_NONE, C_GTH_NONE, C_GTH_TXCLK_SYNC);
  
  -------------------------- ------------------------

  type t_gth_common_drp_in is record
    DRPADDR : std_logic_vector(7 downto 0);
    DRPCLK  : std_logic;
    DRPDI   : std_logic_vector(15 downto 0);
    DRPEN   : std_logic;
    DRPWE   : std_logic;
  end record;

  type t_gth_common_drp_out is record
    DRPDO  : std_logic_vector(15 downto 0);
    DRPRDY : std_logic;
  end record;

  type t_gth_common_clk_out is record
    QPLLOUTCLK    : std_logic;
    QPLLOUTREFCLK : std_logic;
  end record;

  type t_gth_common_ctrl is record
    QPLLRESET : std_logic;
    QPLLPD    : std_logic;
  end record;

  type t_gth_common_status is record
    QPLLLOCK       : std_logic;
    QPLLFBCLKLOST  : std_logic;
    QPLLREFCLKLOST : std_logic;
  end record;

  type t_gth_cpll_ctrl is record
    cpllrefclksel  : std_logic_vector(2 downto 0);
    cplllockdetclk : std_logic;
    cpllreset : std_logic;
  end record;

  type t_gth_cpll_status is record
    cpllfbclklost  : std_logic;
    cplllock       : std_logic;
    cpllrefclklost : std_logic;
  end record;

  -------------------------- Channel - Clocking Ports ------------------------

  type t_gth_gt_clk_in is record
    qpllclk    : std_logic;
    qpllrefclk : std_logic;
    rxusrclk   : std_logic;
    rxusrclk2  : std_logic;
    txusrclk   : std_logic;
    txusrclk2  : std_logic;
  end record;

  type t_gth_gt_clk_out is record
    rxoutclk : std_logic;
    txoutclk : std_logic;
  end record;

  ---------------------------- Channel - DRP Ports  --------------------------

  type t_gth_gt_drp_in is record
    DRPADDR : std_logic_vector(8 downto 0);
    DRPCLK  : std_logic;
    DRPDI   : std_logic_vector(15 downto 0);
    DRPEN   : std_logic;
    DRPWE   : std_logic;
  end record;

  type t_gth_gt_drp_out is record
    DRPDO  : std_logic_vector(15 downto 0);
    DRPRDY : std_logic;
  end record;


  type t_gth_tx_ctrl is record
    txsysclksel  : std_logic_vector(1 downto 0);
    ------------------------ TX Configurable Driver Ports ----------------------
    txpostcursor : std_logic_vector(4 downto 0);
    txprecursor  : std_logic_vector(4 downto 0);

    txpostcursorinv : std_logic;
    txprecursorinv  : std_logic;
    --------------- Transmit Ports - TX Configurable Driver Ports --------------
    txdiffctrl      : std_logic_vector(3 downto 0);
    txinhibit       : std_logic;
    txmaincursor    : std_logic_vector(6 downto 0);
    --------------------- TX Initialization and Reset Ports --------------------

    txpolarity     : std_logic;
    txprbssel      : std_logic_vector(2 downto 0);
    txprbsforceerr : std_logic;

    txpd : std_logic_vector(1 downto 0);
  end record;
  
  type t_gth_tx_init is record
    gttxreset    : std_logic;
    txuserrdy    : std_logic;
    TXDLYEN      : std_logic;
    TXDLYSRESET  : std_logic;
    TXPHALIGN    : std_logic;
    TXPHALIGNEN  : std_logic;
    TXPHDLYRESET : std_logic;
    TXPHINIT     : std_logic;
  end record;

  type t_gth_tx_status is record
    txresetdone    : std_logic;
    txbufstatus    : std_logic_vector(1 downto 0);
    TXPMARESETDONE  : std_logic;
    TXDLYSRESETDONE : std_logic;
    TXPHALIGNDONE   : std_logic;
    TXPHINITDONE    : std_logic;
    txgearboxready : std_logic;
  end record;


  type t_gth_rx_ctrl is record
    rxsysclksel : std_logic_vector(1 downto 0);

    rxpolarity : std_logic;
    rxlpmen    : std_logic;
    rxbufreset : std_logic;

    rxprbssel      : std_logic_vector(2 downto 0);
    rxprbscntreset : std_logic;

    rxpd : std_logic_vector(1 downto 0);
  end record;
  
  type t_gth_rx_init is record
    gtrxreset       : std_logic;
    rxuserrdy       : std_logic;
    
    rxdfeagchold    : std_logic;
    rxdfeagcovrden  : std_logic;
    rxdfelfhold     : std_logic;
    rxdfelpmreset   : std_logic;
    rxlpmlfklovrden : std_logic;
    RXDFELFOVRDEN   : std_logic;
    RXLPMHFHOLD     : std_logic;
    RXLPMHFOVRDEN   : std_logic;
    RXLPMLFHOLD     : std_logic;
  
    RXDLYEN      : std_logic;
    RXDLYSRESET  : std_logic;
    RXPHALIGN    : std_logic;
    RXPHALIGNEN  : std_logic;
    RXPHDLYRESET : std_logic;
    RXSYNCALLIN  : std_logic;
    RXSYNCIN     : std_logic;
    RXSYNCMODE   : std_logic;
    RXCDRHOLD    : std_logic;
  end record;

  type t_gth_rx_cdr_ctrl is record
    RXCDRFREQRESET : std_logic;
    RXCDRHOLD      : std_logic;
    RXCDROVRDEN    : std_logic;
    RXCDRRESETRSV  : std_logic;
  end record;

  type t_gth_rx_eq_cdr_dfe_status is record
    RXCDRLOCK                  : std_logic;
    RSOSINTDONE                : std_logic;
    RXDFESLIDETAPSTARTED       : std_logic;
    RXDFESLIDETAPSTROBEDONE    : std_logic;
    RXDFESLIDETAPSTROBESTARTED : std_logic;
    RXDFESTADAPTDONE           : std_logic;
    RXOSINTSTARTED             : std_logic;
    RXOSINTSTROBESTARTED       : std_logic;
    RXOSINTSTROBEDONE : std_logic;    
  end record;

  type t_gth_rx_lpm_ctrl is record
    RXLPMHFHOLD     : std_logic;
    RXLPMHFOVRDEN   : std_logic;
    RXLPMLFHOLD     : std_logic;
    RXLPMLFKLOVRDEN : std_logic;
  end record;

  type t_gth_rx_dfe_agc_ctrl is record
    RXDFEAGCHOLD   : std_logic;
    RXDFEAGCOVRDEN : std_logic;
    RXDFEAGCTRL    : std_logic_vector(4 downto 0);
  end record;

  type t_gth_rx_dfe_1_ctrl is record
    RXDFEXYDEN               : std_logic;
    RXDFECM1EN               : std_logic;
    RXDFELFHOLD              : std_logic;
    RXDFELFOVRDEN            : std_logic;
    RXDFESLIDETAPADAPTEN     : std_logic;
    RXDFESLIDETAPHOLD        : std_logic;
    RXDFESLIDETAPINITOVRDEN  : std_logic;
    RXDFESLIDETAPONLYADAPTEN : std_logic;
    RXDFESLIDETAPSTROBE      : std_logic;
    RXDFETAP2HOLD            : std_logic;
    RXDFETAP2OVRDEN          : std_logic;
    RXDFETAP3HOLD            : std_logic;
    RXDFETAP3OVRDEN          : std_logic;
    RXDFETAP4HOLD            : std_logic;
    RXDFETAP4OVRDEN          : std_logic;
    RXDFETAP5HOLD            : std_logic;
    RXDFETAP5OVRDEN          : std_logic;
    RXDFETAP6HOLD            : std_logic;
    RXDFETAP6OVRDEN          : std_logic;
    RXDFETAP7HOLD            : std_logic;
    RXDFETAP7OVRDEN          : std_logic;
    RXDFEUTHOLD              : std_logic;
    RXDFEUTOVRDEN            : std_logic;
    RXDFEVPHOLD              : std_logic;
    RXDFEVPOVRDEN            : std_logic;
    RXDFEVSEN                : std_logic;
    RXDFESLIDETAPOVRDEN      : std_logic;
  end record;

  type t_gth_rx_dfe_2_ctrl is record
    RXDFESLIDETAP   : std_logic_vector(4 downto 0);
    RXDFESLIDETAPID : std_logic_vector(5 downto 0);
  end record;

  type t_gth_rx_os_ctrl is record
    RXOSCALRESET      : std_logic;
    RXOSHOLD          : std_logic;
    RXOSINTEN         : std_logic;
    RXOSINTHOLD       : std_logic;
    RXOSINTNTRLEN     : std_logic;
    RXOSINTOVRDEN     : std_logic;
    RXOSINTSTROBE     : std_logic;
    RXOSINTTESTOVRDEN : std_logic;
    RXOSOVRDEN        : std_logic;
    RXOSINTCFG        : std_logic_vector(3 downto 0);
    RXOSINTID0        : std_logic_vector(3 downto 0);
  end record;

  type t_gth_rx_status is record
    rxprbserr      : std_logic;
    rxbufstatus    : std_logic_vector(2 downto 0);
    rxclkcorcnt    : std_logic_vector(1 downto 0);
    rxresetdone    : std_logic;
    RXPMARESETDONE  : std_logic;
    RXDLYSRESETDONE : std_logic;
    RXPHALIGNDONE   : std_logic;
    RXSYNCDONE      : std_logic;
    RXSYNCOUT       : std_logic;
    rxinsync       : std_logic; -- from 64b66b slip controller
  end record;

  type t_gth_misc_ctrl is record
    loopback       : std_logic_vector(2 downto 0);
    eyescanreset   : std_logic;
    eyescantrigger : std_logic;
  end record;

  type t_gth_misc_status is record
    eyescandataerror : std_logic;
    dmonitorout  :  std_logic_vector(14 downto 0);
  end record;

  type t_gth_tx_data is record
    txdata     : std_logic_vector(39 downto 0); -- Only bits 31-0 are available for 8b10b
    -- For 8b10b
    txcharisk  : std_logic_vector(3 downto 0);
    txchardispmode : std_logic_vector(3 downto 0);
    txchardispval  : std_logic_vector(3 downto 0);
    -- For 64b66b
    txheader   : std_logic_vector(2 downto 0);
    txsequence : std_logic_vector(6 downto 0);
  end record;

  type t_gth_rx_data is record
    rxdata          : std_logic_vector(39 downto 0); -- Only bits 31-0 are available for 8b10b
    rxbyteisaligned : std_logic;
    rxbyterealign   : std_logic;
    rxcommadet      : std_logic;
    -- For 8b10b
    rxchariscomma   : std_logic_vector(3 downto 0);
    rxcharisk       : std_logic_vector(3 downto 0);
    rxnotintable    : std_logic_vector(3 downto 0);
    rxdisperr       : std_logic_vector(3 downto 0);
    -- For 64b66b
    rxdatavalid     : std_logic;
    rxheader        : std_logic_vector(1 downto 0);
    rxheadervalid   : std_logic;
  end record;

  type t_gth_common_clk_out_arr is array(integer range <>) of t_gth_common_clk_out;
  type t_gth_common_ctrl_arr is array(integer range <>) of t_gth_common_ctrl;
  type t_gth_common_status_arr is array(integer range <>) of t_gth_common_status;
  type t_gth_common_drp_in_arr is array(integer range <>) of t_gth_common_drp_in;
  type t_gth_common_drp_out_arr is array(integer range <>) of t_gth_common_drp_out;

  type t_gth_cpll_ctrl_arr is array(integer range <>) of t_gth_cpll_ctrl;
  type t_gth_cpll_status_arr is array(integer range <>) of t_gth_cpll_status;

  type t_gth_gt_clk_in_arr is array(integer range <>) of t_gth_gt_clk_in;
  type t_gth_gt_clk_out_arr is array(integer range <>) of t_gth_gt_clk_out;
  type t_gth_gt_drp_in_arr is array(integer range <>) of t_gth_gt_drp_in;
  type t_gth_gt_drp_out_arr is array(integer range <>) of t_gth_gt_drp_out;
  type t_gth_tx_ctrl_arr is array(integer range <>) of t_gth_tx_ctrl;
  type t_gth_tx_status_arr is array(integer range <>) of t_gth_tx_status;
  type t_gth_rx_ctrl_arr is array(integer range <>) of t_gth_rx_ctrl;
  type t_gth_rx_status_arr is array(integer range <>) of t_gth_rx_status;
  type t_gth_misc_ctrl_arr is array(integer range <>) of t_gth_misc_ctrl;
  type t_gth_misc_status_arr is array(integer range <>) of t_gth_misc_status;
  type t_gth_tx_data_arr is array(integer range <>) of t_gth_tx_data;
  type t_gth_rx_data_arr is array(integer range <>) of t_gth_rx_data;
  type t_gth_tx_init_arr is array(integer range <>) of t_gth_tx_init;
  type t_gth_rx_init_arr is array(integer range <>) of t_gth_rx_init;

  type t_gth_rx_cdr_ctrl_arr is array(integer range <>) of t_gth_rx_cdr_ctrl;
  type t_gth_rx_eq_cdr_dfe_status_arr is array(integer range <>) of t_gth_rx_eq_cdr_dfe_status;
  type t_gth_rx_lpm_ctrl_arr is array(integer range <>) of t_gth_rx_lpm_ctrl;
  type t_gth_rx_dfe_agc_ctrl_arr is array(integer range <>) of t_gth_rx_dfe_agc_ctrl;
  type t_gth_rx_dfe_1_ctrl_arr is array(integer range <>) of t_gth_rx_dfe_1_ctrl;
  type t_gth_rx_dfe_2_ctrl_arr is array(integer range <>) of t_gth_rx_dfe_2_ctrl;
  type t_gth_rx_os_ctrl_arr is array(integer range <>) of t_gth_rx_os_ctrl;

end package;

