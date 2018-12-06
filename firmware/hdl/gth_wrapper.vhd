library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library UNISIM;
use UNISIM.VCOMPONENTS.all;

library work;
use work.ctp7_v7_build_cfg_pkg.all;
use work.gth_pkg.all;

--============================================================================
--                                                          Entity declaration
--============================================================================
entity gth_wrapper is
  generic
    (
      g_EXAMPLE_SIMULATION     : integer                := 1;
      g_STABLE_CLOCK_PERIOD    : integer range 4 to 250 := 20;  --Period of the stable clock driving this state-machine, unit is [ns]
      g_NUM_OF_GTH_GTs         : integer                := 64;
      g_NUM_OF_GTH_COMMONs     : integer                := 16;
      g_GT_SIM_GTRESET_SPEEDUP : string                 := "TRUE"  -- Set to "TRUE" to speed up sim reset
      );
  port (

    clk_stable_i : in std_logic;

    clk_ttc_120_i : in std_logic;
    clk_ttc_240_i : in std_logic;

    refclk_F_0_p_i : in std_logic_vector (3 downto 0);
    refclk_F_0_n_i : in std_logic_vector (3 downto 0);
    refclk_F_1_p_i : in std_logic_vector (3 downto 0);
    refclk_F_1_n_i : in std_logic_vector (3 downto 0);
    refclk_B_0_p_i : in std_logic_vector (3 downto 0);
    refclk_B_0_n_i : in std_logic_vector (3 downto 0);
    refclk_B_1_p_i : in std_logic_vector (3 downto 0);
    refclk_B_1_n_i : in std_logic_vector (3 downto 0);
    
    clk_gth_tx_usrclk_arr_o : out std_logic_vector(g_NUM_OF_GTH_GTs-1 downto 0);
    clk_gth_rx_usrclk_arr_o : out std_logic_vector(g_NUM_OF_GTH_GTs-1 downto 0);

    ------------------------
    -- GTH common

    gth_common_ctrl_arr_i : in t_gth_common_ctrl_arr(g_NUM_OF_GTH_COMMONs-1 downto 0);
    gth_common_status_arr_o : out t_gth_common_status_arr(g_NUM_OF_GTH_COMMONs-1 downto 0);

    gth_common_drp_arr_i : in  t_gth_common_drp_in_arr(g_NUM_OF_GTH_COMMONs-1 downto 0);
    gth_common_drp_arr_o : out t_gth_common_drp_out_arr(g_NUM_OF_GTH_COMMONs-1 downto 0);
    ------------------------
    
    gth_cpll_reset_arr_i : in std_logic_vector(g_NUM_OF_GTH_GTs-1 downto 0);
    gth_cpll_status_arr_o : out t_gth_cpll_status_arr(g_NUM_OF_GTH_GTs-1 downto 0);

    gth_gt_txreset_i : in std_logic_vector(g_NUM_OF_GTH_GTs-1 downto 0);
    gth_gt_rxreset_i : in std_logic_vector(g_NUM_OF_GTH_GTs-1 downto 0);

    gth_gt_txreset_sticky_i : in std_logic_vector(g_NUM_OF_GTH_GTs-1 downto 0);
    gth_gt_rxreset_sticky_i : in std_logic_vector(g_NUM_OF_GTH_GTs-1 downto 0);

    gth_gt_rxdfelpmreset_i : in std_logic_vector(g_NUM_OF_GTH_GTs-1 downto 0);
    gth_gt_rxcdrreset_i    : in std_logic_vector(g_NUM_OF_GTH_GTs-1 downto 0);

    gth_gt_txreset_done_o : out std_logic_vector(g_NUM_OF_GTH_GTs-1 downto 0);
    gth_gt_rxreset_done_o : out std_logic_vector(g_NUM_OF_GTH_GTs-1 downto 0);

    gth_gt_drp_arr_i : in  t_gth_gt_drp_in_arr(g_NUM_OF_GTH_GTs-1 downto 0);
    gth_gt_drp_arr_o : out t_gth_gt_drp_out_arr(g_NUM_OF_GTH_GTs-1 downto 0);

    gth_tx_ctrl_arr_i   : in  t_gth_tx_ctrl_arr(g_NUM_OF_GTH_GTs-1 downto 0);
    gth_tx_status_arr_o : out t_gth_tx_status_arr(g_NUM_OF_GTH_GTs-1 downto 0);

    gth_rx_ctrl_arr_i   : in  t_gth_rx_ctrl_arr(g_NUM_OF_GTH_GTs-1 downto 0);
    gth_rx_status_arr_o : out t_gth_rx_status_arr(g_NUM_OF_GTH_GTs-1 downto 0);

    gth_rx_cdr_ctrl_arr_i          : in  t_gth_rx_cdr_ctrl_arr(G_NUM_OF_GTH_GTs-1 downto 0);
    gth_rx_eq_cdr_dfe_status_arr_o : out t_gth_rx_eq_cdr_dfe_status_arr(G_NUM_OF_GTH_GTs-1 downto 0);
    gth_rx_lpm_ctrl_arr_i          : in  t_gth_rx_lpm_ctrl_arr(G_NUM_OF_GTH_GTs-1 downto 0);
    gth_rx_dfe_agc_ctrl_arr_i      : in  t_gth_rx_dfe_agc_ctrl_arr(G_NUM_OF_GTH_GTs-1 downto 0);
    gth_rx_dfe_1_ctrl_arr_i        : in  t_gth_rx_dfe_1_ctrl_arr(G_NUM_OF_GTH_GTs-1 downto 0);
    gth_rx_dfe_2_ctrl_arr_i        : in  t_gth_rx_dfe_2_ctrl_arr(G_NUM_OF_GTH_GTs-1 downto 0);
    gth_rx_os_ctrl_arr_i           : in  t_gth_rx_os_ctrl_arr(G_NUM_OF_GTH_GTs-1 downto 0);

    gth_misc_ctrl_arr_i   : in  t_gth_misc_ctrl_arr(g_NUM_OF_GTH_GTs-1 downto 0);
    gth_misc_status_arr_o : out t_gth_misc_status_arr(g_NUM_OF_GTH_GTs-1 downto 0);

    gth_tx_data_arr_i : in  t_gth_tx_data_arr(g_NUM_OF_GTH_GTs-1 downto 0);
    gth_rx_data_arr_o : out t_gth_rx_data_arr(g_NUM_OF_GTH_GTs-1 downto 0)

    );
end gth_wrapper;

--============================================================================
--                                                        Architecture section
--============================================================================
architecture gth_wrapper_arch of gth_wrapper is

--============================================================================
--                                                         Signal declarations
--============================================================================
    attribute syn_noclockbuf : boolean;
    
    signal s_refclk_common_arr : std_logic_vector (19 downto 0);
    attribute syn_noclockbuf of s_refclk_common_arr : signal is true;
    signal s_refclk_gt_arr : std_logic_vector (19 downto 0);
    attribute syn_noclockbuf of s_refclk_gt_arr : signal is true;
    
    signal s_gth_gt_clk_in_arr  : t_gth_gt_clk_in_arr(g_NUM_OF_GTH_GTs-1 downto 0);
    signal s_gth_gt_clk_out_arr : t_gth_gt_clk_out_arr(g_NUM_OF_GTH_GTs-1 downto 0);
    
    signal s_gth_cpll_ctrl_arr   : t_gth_cpll_ctrl_arr(g_NUM_OF_GTH_GTs-1 downto 0);
    signal s_gth_cpll_status_arr : t_gth_cpll_status_arr(g_NUM_OF_GTH_GTs-1 downto 0);
    
    signal s_gth_gt_drp_in_arr  : t_gth_gt_drp_in_arr(g_NUM_OF_GTH_GTs-1 downto 0);
    signal s_gth_gt_drp_out_arr : t_gth_gt_drp_out_arr(g_NUM_OF_GTH_GTs-1 downto 0);
    
    signal s_gth_tx_ctrl_arr   : t_gth_tx_ctrl_arr(g_NUM_OF_GTH_GTs-1 downto 0);
    signal s_gth_tx_status_arr : t_gth_tx_status_arr(g_NUM_OF_GTH_GTs-1 downto 0);
    signal s_gth_tx_init_arr    : t_gth_tx_init_arr(g_NUM_OF_GTH_GTs-1 downto 0);
    
    signal s_gth_rx_ctrl_arr   : t_gth_rx_ctrl_arr(g_NUM_OF_GTH_GTs-1 downto 0);
    signal s_gth_rx_status_arr : t_gth_rx_status_arr(g_NUM_OF_GTH_GTs-1 downto 0);
    signal s_gth_rx_init_arr    : t_gth_rx_init_arr(g_NUM_OF_GTH_GTs-1 downto 0);
    
    signal s_gth_misc_ctrl_arr   : t_gth_misc_ctrl_arr(g_NUM_OF_GTH_GTs-1 downto 0);
    signal s_gth_misc_status_arr : t_gth_misc_status_arr(g_NUM_OF_GTH_GTs-1 downto 0);
    
    signal s_gth_tx_data_arr : t_gth_tx_data_arr(g_NUM_OF_GTH_GTs-1 downto 0);
    signal s_gth_rx_data_arr : t_gth_rx_data_arr(g_NUM_OF_GTH_GTs-1 downto 0);
    
    ---------------------
    function get_cdrlock_time(is_sim : in integer) return integer is
        variable lock_time : integer;
    begin
        if (is_sim = 1) then
            lock_time := 1000;
        else
            lock_time := 50000 / integer(3.2);  --Typical CDR lock time is 50,000UI as per DS183
        end if;
        
        return lock_time;
    end function;
    
    constant C_RX_CDRLOCK_TIME   : integer := get_cdrlock_time(g_EXAMPLE_SIMULATION);  -- 200us
    constant C_WAIT_TIME_CDRLOCK : integer := C_RX_CDRLOCK_TIME / g_STABLE_CLOCK_PERIOD;  -- 200 us time-out
    
    type t_rx_cdr_lock_counter_arr is array(integer range <>) of integer range 0 to C_WAIT_TIME_CDRLOCK;
    
    signal s_gth_tx_run_phalignment      : std_logic_vector(g_NUM_OF_GTH_GTs-1 downto 0);
    signal s_gth_tx_run_phalignment_done : std_logic_vector(g_NUM_OF_GTH_GTs-1 downto 0);
    signal s_gth_tx_rst_phalignment      : std_logic_vector(g_NUM_OF_GTH_GTs-1 downto 0);
    
    signal s_gth_rx_run_phalignment      : std_logic_vector(g_NUM_OF_GTH_GTs-1 downto 0);
    signal s_gth_rx_run_phalignment_done : std_logic_vector(g_NUM_OF_GTH_GTs-1 downto 0);
    signal s_gth_rx_rst_phalignment      : std_logic_vector(g_NUM_OF_GTH_GTs-1 downto 0);
    
    signal s_gth_recclk_stable      : std_logic_vector(g_NUM_OF_GTH_GTs-1 downto 0);
    signal s_gth_rx_cdrlocked       : std_logic_vector(g_NUM_OF_GTH_GTs-1 downto 0);
    signal s_gth_rx_cdrlock_counter : t_rx_cdr_lock_counter_arr(g_NUM_OF_GTH_GTs-1 downto 0);
    
    signal s_clk_gth_tx_usrclk_arr : std_logic_vector(g_NUM_OF_GTH_GTs-1 downto 0);
    signal s_clk_gth_rx_usrclk_arr : std_logic_vector(g_NUM_OF_GTH_GTs-1 downto 0);
    
    ---------------------
    
    signal s_gth_common_clk_out_arr : t_gth_common_clk_out_arr(g_NUM_OF_GTH_COMMONs-1 downto 0);
    
    signal s_gth_common_ctrl_arr   : t_gth_common_ctrl_arr(g_NUM_OF_GTH_COMMONs-1 downto 0);
    signal s_gth_common_status_arr : t_gth_common_status_arr(g_NUM_OF_GTH_COMMONs-1 downto 0);
    
    signal s_gth_common_drp_in_arr  : t_gth_common_drp_in_arr(g_NUM_OF_GTH_COMMONs-1 downto 0);
    signal s_gth_common_drp_out_arr : t_gth_common_drp_out_arr(g_NUM_OF_GTH_COMMONs-1 downto 0);
    
    ---------------------
    
    signal s_gth_gt_rxreset_done_arr : std_logic_vector (g_NUM_OF_GTH_GTs-1 downto 0);
    signal s_gth_gt_gearbox_sync_reset_arr : std_logic_vector (g_NUM_OF_GTH_GTs-1 downto 0);
    signal s_gth_rx_gearboxslip_arr : std_logic_vector (g_NUM_OF_GTH_GTs-1 downto 0) := (others => '0');
    signal s_rxinsync_arr : std_logic_vector (g_NUM_OF_GTH_GTs-1 downto 0);
    
    
    attribute keep       : boolean;
    attribute mark_debug : boolean;
    
    --attribute keep of s_gth_tx_run_phalignment, s_gth_tx_run_phalignment_done, s_gth_tx_rst_phalignment, s_gth_tx_status_arr, s_gth_tx_init_arr  : signal is true;
    --attribute mark_debug of s_gth_tx_run_phalignment, s_gth_tx_run_phalignment_done, s_gth_tx_rst_phalignment, s_gth_tx_status_arr, s_gth_tx_init_arr : signal is true;
    
    --attribute keep of s_gth_rx_run_phalignment, s_gth_rx_run_phalignment_done, s_gth_rx_rst_phalignment, s_gth_rx_status_arr, s_gth_rx_init_arr  : signal is true;
    --attribute mark_debug of s_gth_rx_run_phalignment, s_gth_rx_run_phalignment_done, s_gth_rx_rst_phalignment, s_gth_rx_status_arr, s_gth_rx_init_arr : signal is true;


--============================================================================
--                                                          Architecture begin
--============================================================================

begin

    -- Input/output assignments
    gth_cpll_status_arr_o <= s_gth_cpll_status_arr;
    clk_gth_tx_usrclk_arr_o <= s_clk_gth_tx_usrclk_arr;
    clk_gth_rx_usrclk_arr_o <= s_clk_gth_rx_usrclk_arr;
    
    i_gth_clk_bufs : entity work.gth_clk_bufs
    port map (
        -- Reference clock
        refclk_F_0_p_i => refclk_F_0_p_i,
        refclk_F_0_n_i => refclk_F_0_n_i,
        refclk_F_1_p_i => refclk_F_1_p_i,
        refclk_F_1_n_i => refclk_F_1_n_i,
        refclk_B_0_p_i => refclk_B_0_p_i,
        refclk_B_0_n_i => refclk_B_0_n_i,
        refclk_B_1_p_i => refclk_B_1_p_i,
        refclk_B_1_n_i => refclk_B_1_n_i,
        
        refclk_common_arr_o => s_refclk_common_arr,
        refclk_gt_arr_o => s_refclk_gt_arr,
        
        -- User clock
        gth_gt_clk_out_arr_i => s_gth_gt_clk_out_arr,
        clk_ttc_120_i => clk_ttc_120_i,
        clk_ttc_240_i => clk_ttc_240_i,
        
        clk_gth_tx_usrclk_arr_o => s_clk_gth_tx_usrclk_arr,
        clk_gth_rx_usrclk_arr_o => s_clk_gth_rx_usrclk_arr
    );
    
    ------------------------
    
    s_gth_common_drp_in_arr <= gth_common_drp_arr_i;
    gth_common_drp_arr_o    <= s_gth_common_drp_out_arr;
    
    gth_common_status_arr_o <= s_gth_common_status_arr;
    
    gen_gth_common : for n in 0 to (g_NUM_OF_GTH_COMMONs-1) generate
        gen_qpll_if_enabled : if (is_qpll_enabled(n)) generate
            inst_gth_common : entity work.gth_10gbps_buf_cc_common
            generic map (
                -- Simulation attributes
                g_GT_SIM_GTRESET_SPEEDUP => g_GT_SIM_GTRESET_SPEEDUP,  -- Set to "true" to speed up sim reset
                g_STABLE_CLOCK_PERIOD    => g_STABLE_CLOCK_PERIOD  -- Period of the stable clock driving this state-machine, unit is [ns]
            ) port map (
                clk_stable_i        => clk_stable_i,
                gth_common_clk_i    => s_refclk_common_arr(n),
                gth_common_clk_o    => s_gth_common_clk_out_arr(n),
                gth_common_ctrl_i   => gth_common_ctrl_arr_i(n),
                gth_common_status_o => s_gth_common_status_arr(n),
                gth_common_drp_i    => s_gth_common_drp_in_arr(n),
                gth_common_drp_o    => s_gth_common_drp_out_arr(n)
            );
        end generate gen_qpll_if_enabled;
    end generate gen_gth_common;
    
    ------------------------
    
    s_gth_gt_drp_in_arr <= gth_gt_drp_arr_i;
    gth_gt_drp_arr_o    <= s_gth_gt_drp_out_arr;
    
    s_gth_tx_ctrl_arr     <= gth_tx_ctrl_arr_i;
    gth_tx_status_arr_o   <= s_gth_tx_status_arr;
    s_gth_rx_ctrl_arr     <= gth_rx_ctrl_arr_i;
    gth_rx_status_arr_o   <= s_gth_rx_status_arr;
    s_gth_misc_ctrl_arr   <= gth_misc_ctrl_arr_i;
    gth_misc_status_arr_o <= s_gth_misc_status_arr;
    
    gen_single_gt : for n in 0 to (g_NUM_OF_GTH_GTs-1) generate
        gen_gth_if_enabled : if (is_gth_enabled(n)) generate
            -- From Xilinx UG476
            -- The CPLLREFCLKSEL port is required when multiple reference clock sources are 
            -- connected to this multiplexer. A single reference clock is most commonly used. 
            -- In this case, the CPLLREFCLKSEL port can be tied to 3'b001, and the Xilinx software 
            -- tools handle the complexity of the multiplexers and associated routing.
            s_gth_cpll_ctrl_arr(n).CPLLREFCLKSEL  <= "001";  -- Let the tool figure out proper reference clock routing
            s_gth_cpll_ctrl_arr(n).cplllockdetclk <= clk_stable_i;
            
            s_gth_gt_clk_in_arr(n).qpllclk    <= s_gth_common_clk_out_arr(n/4).QPLLOUTCLK;
            s_gth_gt_clk_in_arr(n).qpllrefclk <= s_gth_common_clk_out_arr(n/4).QPLLOUTREFCLK;
            
            s_gth_gt_clk_in_arr(n).rxusrclk   <= s_clk_gth_rx_usrclk_arr(n);
            s_gth_gt_clk_in_arr(n).rxusrclk2  <= s_clk_gth_rx_usrclk_arr(n);
            s_gth_gt_clk_in_arr(n).txusrclk   <= s_clk_gth_tx_usrclk_arr(n);
            s_gth_gt_clk_in_arr(n).txusrclk2  <= s_clk_gth_tx_usrclk_arr(n);
                
            -- Special TX data mapping for no encoding
            gen_tx_data_mapping : if (c_gth_config_arr(n).tx_config.encoding = gth_encoding_none) generate
                s_gth_tx_data_arr(n).txdata <= gth_tx_data_arr_i(n).txdata(37 downto 30) &
                           gth_tx_data_arr_i(n).txdata(27 downto 20) &
                           gth_tx_data_arr_i(n).txdata(17 downto 10) &
                           gth_tx_data_arr_i(n).txdata(7 downto 0);
                
                s_gth_tx_data_arr(n).txchardispmode <= gth_tx_data_arr_i(n).txdata(39) &
                                   gth_tx_data_arr_i(n).txdata(29) &
                                   gth_tx_data_arr_i(n).txdata(19) &
                                   gth_tx_data_arr_i(n).txdata(9);
                
                s_gth_tx_data_arr(n).txchardispval <= gth_tx_data_arr_i(n).txdata(38) &
                                  gth_tx_data_arr_i(n).txdata(28) &
                                  gth_tx_data_arr_i(n).txdata(18) &
                                  gth_tx_data_arr_i(n).txdata(8);
                
                s_gth_tx_data_arr(n).txcharisk <= (others => '0');
                s_gth_tx_data_arr(n).txheader <= (others => '0');
                s_gth_tx_data_arr(n).txsequence <= (others => '0');
            else generate
                s_gth_tx_data_arr(n) <= gth_tx_data_arr_i(n);
            end generate gen_tx_data_mapping;
            
            -- Special RX data mapping for no encoding
            gen_rx_data_mapping : if (c_gth_config_arr(n).rx_config.encoding = gth_encoding_none) generate
                gth_rx_data_arr_o(n).rxdata <= s_gth_rx_data_arr(n).rxdisperr(3) &
                                               s_gth_rx_data_arr(n).rxcharisk(3) &
                                               s_gth_rx_data_arr(n).rxdata(31 downto 24) &
                                               s_gth_rx_data_arr(n).rxdisperr(2) &
                                               s_gth_rx_data_arr(n).rxcharisk(2) &
                                               s_gth_rx_data_arr(n).rxdata(23 downto 16) &
                                               s_gth_rx_data_arr(n).rxdisperr(1) &
                                               s_gth_rx_data_arr(n).rxcharisk(1) &
                                               s_gth_rx_data_arr(n).rxdata(15 downto 8) &
                                               s_gth_rx_data_arr(n).rxdisperr(0) &
                                               s_gth_rx_data_arr(n).rxcharisk(0) &
                                               s_gth_rx_data_arr(n).rxdata(7 downto 0);
                                               
                gth_rx_data_arr_o(n).rxbyteisaligned <= s_gth_rx_data_arr(n).rxbyteisaligned;
                gth_rx_data_arr_o(n).rxbyterealign <= s_gth_rx_data_arr(n).rxbyterealign;
                gth_rx_data_arr_o(n).rxcommadet <= s_gth_rx_data_arr(n).rxcommadet;
                
                gth_rx_data_arr_o(n).rxchariscomma <= (others => '0');
                gth_rx_data_arr_o(n).rxcharisk <= (others => '0');
                gth_rx_data_arr_o(n).rxnotintable <= (others => '0');
                gth_rx_data_arr_o(n).rxdisperr <= (others => '0');
                gth_rx_data_arr_o(n).rxdatavalid <= '0';
                gth_rx_data_arr_o(n).rxheader <= (others => '0');
                gth_rx_data_arr_o(n).rxheadervalid <= '0';
            else generate
                gth_rx_data_arr_o(n) <= s_gth_rx_data_arr(n);
            end generate gen_rx_data_mapping;
            
            i_gth_10gbps_buf_cc_gt : entity work.gth_10gbps_buf_cc_gt
            generic map (
                g_GT_SIM_GTRESET_SPEEDUP => g_GT_SIM_GTRESET_SPEEDUP,
                g_CONFIG => c_gth_config_arr(n)
            ) port map (
                gth_gt_txreset_sticky_i => gth_gt_txreset_sticky_i(n),
                gth_gt_rxreset_sticky_i => gth_gt_rxreset_sticky_i(n),
                
                gth_cpll_ctrl_i   => s_gth_cpll_ctrl_arr(n),
                gth_cpll_status_o => s_gth_cpll_status_arr(n),
                
                gth_gt_rxdfelpmreset_i => gth_gt_rxdfelpmreset_i(n),
                gth_gt_rxcdrreset_i    => gth_gt_rxcdrreset_i(n),
                
                gth_rx_gearboxslip_i   => s_gth_rx_gearboxslip_arr(n),
                
                gth_gt_clk_i    => s_gth_gt_clk_in_arr(n),
                gth_refclk0_i   => s_refclk_gt_arr(n/4),
                gth_gt_clk_o    => s_gth_gt_clk_out_arr(n),
                gth_gt_drp_i    => s_gth_gt_drp_in_arr(n),
                gth_gt_drp_o    => s_gth_gt_drp_out_arr(n),
                
                gth_tx_ctrl_i   => s_gth_tx_ctrl_arr(n),
                gth_tx_init_i   => s_gth_tx_init_arr(n),
                gth_tx_status_o => s_gth_tx_status_arr(n),
                
                gth_rx_ctrl_i   => s_gth_rx_ctrl_arr(n),
                gth_rx_init_i   => s_gth_rx_init_arr(n),
                gth_rx_status_o => s_gth_rx_status_arr(n),
                
                gth_rx_cdr_ctrl_i          => gth_rx_cdr_ctrl_arr_i(n),
                gth_rx_eq_cdr_dfe_status_o => gth_rx_eq_cdr_dfe_status_arr_o(n),
                gth_rx_lpm_ctrl_i          => gth_rx_lpm_ctrl_arr_i(n),
                gth_rx_dfe_agc_ctrl_i      => gth_rx_dfe_agc_ctrl_arr_i(n),
                gth_rx_dfe_1_ctrl_i        => gth_rx_dfe_1_ctrl_arr_i(n),
                gth_rx_dfe_2_ctrl_i        => gth_rx_dfe_2_ctrl_arr_i(n),
                gth_rx_os_ctrl_i           => gth_rx_os_ctrl_arr_i(n),
                
                gth_misc_ctrl_i   => s_gth_misc_ctrl_arr(n),
                gth_misc_status_o => s_gth_misc_status_arr(n),
                gth_tx_data_i     => s_gth_tx_data_arr(n),
                gth_rx_data_o     => s_gth_rx_data_arr(n)
            );
            
            -- Generate gearbox controller if 6466 encoding is required
            gen_rx_gearboxctrl : if c_gth_config_arr(n).rx_config.encoding = gth_encoding_64b66b generate
                block_sync_sm_0_i : entity work.gtwizard_0_BLOCK_SYNC_SM 
                generic map (
                    SH_CNT_MAX          => 64,    
                    SH_INVALID_CNT_MAX  => 16    
                ) port map (
                    -- User Interface
                    BLOCKSYNC_OUT             =>    s_rxinsync_arr(n),
                    RXGEARBOXSLIP_OUT         =>    s_gth_rx_gearboxslip_arr(n),
                    RXHEADER_IN(2)            =>    '0',
                    RXHEADER_IN(1 downto 0)   =>    s_gth_rx_data_arr(n).rxheader,
                    RXHEADERVALID_IN          =>    s_gth_rx_data_arr(n).rxheadervalid,
                    
                    -- System Interface
                    USER_CLK                  =>    s_clk_gth_rx_usrclk_arr(n),
                    SYSTEM_RESET              =>    s_gth_gt_gearbox_sync_reset_arr(n)
                ); 
                
                --s_gth_rx_status_arr(n).rxinsync <= s_rxinsync_arr(n);
            else generate
                --s_gth_rx_status_arr(n).rxinsync <= '0';
                s_gth_rx_gearboxslip_arr(n) <= '0';
            end generate gen_rx_gearboxctrl;
        
        end generate gen_gth_if_enabled;
    end generate gen_single_gt;
    
    -- TX reset FSM
    gen_gt_resetfsm : for i in 0 to (g_NUM_OF_GTH_GTs/4-1) generate
        gen_txresetfsm_inner : for j in 0 to 3 generate
            gen_tx_enabled : if (c_gth_config_arr(i*4+j).tx_config.enable) generate
        
                inst_gt_txresetfsm : entity work.gth_single_TX_STARTUP_FSM
                generic map (
                    EXAMPLE_SIMULATION     => g_EXAMPLE_SIMULATION,
                    STABLE_CLOCK_PERIOD    => g_STABLE_CLOCK_PERIOD,  -- Period of the stable clock driving this state-machine, unit is [ns]
                    RETRY_COUNTER_BITWIDTH => 8,
                    TX_QPLL_USED           => c_gth_config_arr(i*4+j).tx_config.qpll_used,  -- the TX and RX Reset FSMs must
                    RX_QPLL_USED           => c_gth_config_arr(i*4+j).rx_config.qpll_used,  -- share these two generic values
                    PHASE_ALIGNMENT_MANUAL => true  -- Decision if a manual phase-alignment is necessary or the automatic
                                                     -- is enough. For single-lane applications the automatic alignment is
                                                     -- sufficient
                ) port map (
                    STABLE_CLOCK      => clk_stable_i,
                    TXUSERCLK         => s_clk_gth_tx_usrclk_arr(i*4+j),
                    SOFT_RESET        => gth_gt_txreset_i(i*4+j),
                    QPLLREFCLKLOST    => s_gth_common_status_arr(i).QPLLREFCLKLOST,
                    CPLLREFCLKLOST    => s_gth_cpll_status_arr(i*4+j).CPLLREFCLKLOST,
                    QPLLLOCK          => s_gth_common_status_arr(i).QPLLLOCK,
                    CPLLLOCK          => s_gth_cpll_status_arr(i*4+j).CPLLLOCK,
                    TXRESETDONE       => s_gth_tx_status_arr(i*4+j).txresetdone,
                    MMCM_LOCK         => '1',
                    GTTXRESET         => s_gth_tx_init_arr(i*4+j).gttxreset,
                    MMCM_RESET        => open,
                    QPLL_RESET        => open,
                    CPLL_RESET        => open,
                    TX_FSM_RESET_DONE => gth_gt_txreset_done_o(i*4+j),
                    TXUSERRDY         => s_gth_tx_init_arr(i*4+j).txuserrdy,
                    RUN_PHALIGNMENT   => s_gth_tx_run_phalignment(i*4+j),
                    RESET_PHALIGNMENT => s_gth_tx_rst_phalignment(i*4+j),
                    PHALIGNMENT_DONE  => s_gth_tx_run_phalignment_done(i*4+j),
                    RETRY_COUNTER     => open
                );
                
                --------------------------- TX Buffer Bypass Logic --------------------
                gen_tx_manual_phase_align: if (c_gth_config_arr(i*4+j).tx_config.buffer_enabled = false) generate
                    i_gth_single_tx_manual_phase_align : entity work.gth_single_TX_MANUAL_PHASE_ALIGN
                    generic map (
                        NUMBER_OF_LANES => 1,
                        MASTER_LANE_ID  => 0
                    ) port map (
                        STABLE_CLOCK         => clk_stable_i,
                        RESET_PHALIGNMENT    => s_gth_tx_rst_phalignment(i*4+j),  --TODO
                        RUN_PHALIGNMENT      => s_gth_tx_run_phalignment(i*4+j),  --TODO
                        PHASE_ALIGNMENT_DONE => s_gth_tx_run_phalignment_done(i*4+j),
                        TXDLYSRESET(0)       => s_gth_tx_init_arr(i*4+j).TXDLYSRESET,
                        TXDLYSRESETDONE(0)   => s_gth_tx_status_arr(i*4+j).TXDLYSRESETDONE,
                        TXPHINIT(0)          => s_gth_tx_init_arr(i*4+j).TXPHINIT,
                        TXPHINITDONE(0)      => s_gth_tx_status_arr(i*4+j).TXPHINITDONE,
                        TXPHALIGN(0)         => s_gth_tx_init_arr(i*4+j).TXPHALIGN,
                        TXPHALIGNDONE(0)     => s_gth_tx_status_arr(i*4+j).TXPHALIGNDONE,
                        TXDLYEN(0)           => s_gth_tx_init_arr(i*4+j).TXDLYEN
                    );
                    
                    s_gth_tx_init_arr(i*4+j).TXPHALIGNEN  <= '1';
                    s_gth_tx_init_arr(i*4+j).TXPHDLYRESET <= '0';
                else generate
                    s_gth_tx_init_arr(i*4+j).TXDLYEN <= '0';
                    s_gth_tx_init_arr(i*4+j).TXDLYSRESET <= '0';
                    s_gth_tx_init_arr(i*4+j).TXPHALIGN <= '0';
                    s_gth_tx_init_arr(i*4+j).TXPHALIGNEN  <= '0';
                    s_gth_tx_init_arr(i*4+j).TXPHDLYRESET <= '0';
                    s_gth_tx_init_arr(i*4+j).TXPHINIT <= '0';
                    s_gth_tx_run_phalignment_done(i*4+j) <= '1';
                end generate gen_tx_manual_phase_align;
            end generate gen_tx_enabled;
            
            gen_rx_enabled : if (c_gth_config_arr(i*4+j).rx_config.enable) generate
                inst_gt_rxresetfsm : entity work.gth_single_RX_STARTUP_FSM
                generic map (
                    EXAMPLE_SIMULATION     => g_EXAMPLE_SIMULATION,
                    EQ_MODE                => "LPM",  --Rx Equalization Mode - Set to DFE or LPM
                    STABLE_CLOCK_PERIOD    => g_STABLE_CLOCK_PERIOD,  --Period of the stable clock driving this state-machine, unit is [ns]
                    RETRY_COUNTER_BITWIDTH => 8,
                    TX_QPLL_USED           => c_gth_config_arr(i*4+j).tx_config.qpll_used,  -- the TX and RX Reset FSMs must
                    RX_QPLL_USED           => c_gth_config_arr(i*4+j).rx_config.qpll_used,  -- share these two generic values
                    PHASE_ALIGNMENT_MANUAL => false  -- Decision if a manual phase-alignment is necessary or the automatic
                                                     -- is enough. For single-lane applications the automatic alignment is
                                                     -- sufficient
                ) port map (
                    STABLE_CLOCK             => clk_stable_i,
                    RXUSERCLK                => s_clk_gth_rx_usrclk_arr(i*4+j),
                    SOFT_RESET               => gth_gt_rxreset_i(i*4+j),
                    DONT_RESET_ON_DATA_ERROR => '1',
                    RXPMARESETDONE           => s_gth_rx_status_arr(i*4+j).RXPMARESETDONE,
                    RXOUTCLK                 => s_clk_gth_rx_usrclk_arr(i*4+j),
                    --TXPMARESETDONE           => s_gth_tx_status_arr(i*4+j).TXPMARESETDONE,
                    --TXOUTCLK                 => s_clk_gth_tx_usrclk_arr(i*4+j),
                    QPLLREFCLKLOST           => s_gth_common_status_arr(i).QPLLREFCLKLOST,
                    CPLLREFCLKLOST           => s_gth_cpll_status_arr(i*4+j).CPLLREFCLKLOST,
                    QPLLLOCK                 => s_gth_common_status_arr(i).QPLLLOCK,
                    CPLLLOCK                 => s_gth_cpll_status_arr(i*4+j).CPLLLOCK,
                    RXRESETDONE              => s_gth_rx_status_arr(i*4+j).rxresetdone,
                    MMCM_LOCK                => '1',
                    RECCLK_STABLE            => s_gth_recclk_stable(i*4+j),
                    RECCLK_MONITOR_RESTART   => '0',
                    DATA_VALID               => '1',
                    TXUSERRDY                => s_gth_tx_init_arr(i*4+j).txuserrdy,
                    GTRXRESET                => s_gth_rx_init_arr(i*4+j).gtrxreset,
                    MMCM_RESET               => open,
                    QPLL_RESET               => open,
                    CPLL_RESET               => open,
                    RX_FSM_RESET_DONE        => s_gth_gt_rxreset_done_arr(i*4+j),
                    RXUSERRDY                => s_gth_rx_init_arr(i*4+j).rxuserrdy,
                    RUN_PHALIGNMENT          => s_gth_rx_run_phalignment(i*4+j),
                    RESET_PHALIGNMENT        => s_gth_rx_rst_phalignment(i*4+j),
                    PHALIGNMENT_DONE         => s_gth_rx_run_phalignment_done(i*4+j),
                    RXDFEAGCHOLD             => s_gth_rx_init_arr(i*4+j).RXDFEAGCHOLD,
                    RXDFELFHOLD              => s_gth_rx_init_arr(i*4+j).RXDFELFHOLD,
                    RXLPMLFHOLD              => s_gth_rx_init_arr(i*4+j).RXLPMLFHOLD,
                    RXLPMHFHOLD              => s_gth_rx_init_arr(i*4+j).RXLPMHFHOLD,
                    RETRY_COUNTER            => open
                );
                
                s_gth_cpll_ctrl_arr(i*4+j).cpllreset <= gth_cpll_reset_arr_i(i*4+j);
                
                s_gth_rx_init_arr(i*4+j).rxdfeagcovrden  <= '0';
                s_gth_rx_init_arr(i*4+j).rxdfelpmreset   <= '0';
                s_gth_rx_init_arr(i*4+j).rxlpmlfklovrden <= '0';
                s_gth_rx_init_arr(i*4+j).RXDFELFOVRDEN   <= '0';
                s_gth_rx_init_arr(i*4+j).RXLPMHFOVRDEN   <= '0';
                
                s_gth_gt_gearbox_sync_reset_arr(i*4+j) <= not s_gth_gt_rxreset_done_arr(i*4+j);
                    
                gen_rx_auto_phase_align: if (c_gth_config_arr(i*4+j).rx_config.buffer_enabled = false) generate
                    gt_cdrlock_timeout : process(clk_stable_i) begin
                        if rising_edge(clk_stable_i) then
                            if(gth_gt_rxreset_i(i*4+j) = '1') then
                                s_gth_rx_cdrlocked(i*4+j)       <= '0';
                                s_gth_rx_cdrlock_counter(i*4+j) <= 0;
                            elsif (s_gth_rx_cdrlock_counter(i*4+j) = C_WAIT_TIME_CDRLOCK) then
                                s_gth_rx_cdrlocked(i*4+j)       <= '1';
                                s_gth_rx_cdrlock_counter(i*4+j) <= s_gth_rx_cdrlock_counter(i*4+j);
                            else
                                s_gth_rx_cdrlock_counter(i*4+j) <= s_gth_rx_cdrlock_counter(i*4+j) + 1;
                            end if;
                        end if;
                    end process;
                    
                    s_gth_recclk_stable(i*4+j) <= s_gth_rx_cdrlocked(i*4+j);
                    
                    --------------------------- RX Buffer Bypass Logic --------------------
                    i_rx_auto_phase_align : entity work.gth_single_AUTO_PHASE_ALIGN
                    port map (
                        STABLE_CLOCK         => clk_stable_i,
                        RUN_PHALIGNMENT      => s_gth_rx_run_phalignment(i*4+j),
                        PHASE_ALIGNMENT_DONE => s_gth_rx_run_phalignment_done(i*4+j),
                        PHALIGNDONE          => s_gth_rx_status_arr(i*4+j).RXSYNCDONE,
                        DLYSRESET            => s_gth_rx_init_arr(i*4+j).RXDLYSRESET,
                        DLYSRESETDONE        => s_gth_rx_status_arr(i*4+j).RXDLYSRESETDONE,
                        RECCLKSTABLE         => s_gth_recclk_stable(i*4+j)
                    );
                    s_gth_rx_init_arr(i*4+j).RXSYNCALLIN  <= s_gth_rx_status_arr(i*4+j).RXPHALIGNDONE;
                else generate
                    s_gth_recclk_stable(i*4+j) <= '1';
                    s_gth_rx_run_phalignment_done(i*4+j) <= '1';
                    s_gth_rx_init_arr(i*4+j).RXSYNCALLIN <= '0';
                    s_gth_rx_init_arr(i*4+j).RXDLYSRESET <= '0';
                end generate gen_rx_auto_phase_align;
                
                s_gth_rx_init_arr(i*4+j).RXCDRHOLD    <= '0';
                s_gth_rx_init_arr(i*4+j).RXPHDLYRESET <= '0';
                s_gth_rx_init_arr(i*4+j).RXPHALIGNEN  <= '0';
                s_gth_rx_init_arr(i*4+j).RXDLYEN      <= '0';
                s_gth_rx_init_arr(i*4+j).RXPHALIGN    <= '0';
                s_gth_rx_init_arr(i*4+j).RXSYNCMODE   <= '1';
                s_gth_rx_init_arr(i*4+j).RXSYNCIN     <= '0';
            end generate gen_rx_enabled;
        end generate gen_txresetfsm_inner;
    end generate gen_gt_resetfsm;
    
    gth_gt_rxreset_done_o <= s_gth_gt_rxreset_done_arr;

end gth_wrapper_arch;
--============================================================================
--                                                            Architecture end
--============================================================================
