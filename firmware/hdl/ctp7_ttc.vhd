--============================================================================
--                                                                   Libraries
--============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library UNISIM;
use UNISIM.VComponents.all;

use work.ctp7_utils_pkg.all;
use work.ttc_pkg.all;

--============================================================================
--                                                          Entity declaration
--============================================================================
entity ctp7_ttc is
  port(

    clk_40_ttc_p_i : in std_logic;      -- TTC backplane clock signals
    clk_40_ttc_n_i : in std_logic;

    ttc_data_p_i : in std_logic;        -- TTC protocol backplane signals
    ttc_data_n_i : in std_logic;

    clk_40_bufg_o  : out std_logic;
    clk_120_bufg_o  : out std_logic;
    clk_240_bufg_o : out std_logic;

    local_timing_ref_o : out t_timing_ref;
    ttc_bgo_cmds_o     : out t_ttc_bgo_cmds;

    ttc_l1a_o       : out std_logic;
    ttc_resync_o    : out std_logic;
    ttc_resync_ep_o : out std_logic;


    ttc_mmcm_ps_clk_i : in  std_logic;
    ttc_mmcm_ctrl_i   : in  t_ttc_mmcm_ctrl;
    ttc_mmcm_stat_o   : out t_ttc_mmcm_stat;

    ttc_ctrl_i : in  t_ttc_ctrl;
    ttc_stat_o : out t_ttc_stat;

    ttc_diag_cntrs_o : out t_ttc_diag_cntrs;
    ttc_daq_cntrs_o  : out t_ttc_daq_cntrs
    );

end ctp7_ttc;

--============================================================================
--                                                        Architecture section
--============================================================================
architecture ctp7_ttc_arch of ctp7_ttc is

  component local_timing_ref_gen
    port (
      clk_240_i : in std_logic;
      bc0_i     : in std_logic;

      bc0_stat_rst_i : in  std_logic;
      bc0_stat_o     : out t_bc0_stat;

      local_timing_ref_o : out t_timing_ref
      );
  end component local_timing_ref_gen;

  component pulse_delay
    generic (
      DELAY_CNT_LENGTH : integer := 8
      );
    port (
      clk_i    : in  std_logic;
      delay_i  : in  std_logic_vector (DELAY_CNT_LENGTH-1 downto 0);
      signal_i : in  std_logic;
      signal_o : out std_logic
      );
  end component pulse_delay;
--============================================================================
--                                                         Signal declarations
--============================================================================
  signal s_clk_40  : std_logic;
  signal s_clk_120  : std_logic;
  signal s_clk_240 : std_logic;

  signal s_ttc_cmd : std_logic_vector(7 downto 0);
  signal s_ttc_l1a : std_logic;

  signal s_bc0_cmd_dly, s_bc0_240 : std_logic;

  signal s_l1a_240 : std_logic;

  signal s_local_timing_ref : t_timing_ref;

  signal s_l1a_cmd       : std_logic;
  signal s_bc0_cmd       : std_logic;
  signal s_ec0_cmd       : std_logic;
  signal s_resync_cmd    : std_logic;
  signal s_oc0_cmd       : std_logic;
  signal s_test_sync_cmd : std_logic;
  signal s_start_cmd     : std_logic;
  signal s_stop_cmd      : std_logic;


  signal s_start_cmd_ext : std_logic;


  constant C_NUM_OF_DECODED_TTC_CMDS : integer := 8;

  signal s_ttc_cmd_decoded     : std_logic_vector(C_NUM_OF_DECODED_TTC_CMDS-1 downto 0);
  signal s_ttc_cmd_decoded_cnt : t_slv_arr_32(C_NUM_OF_DECODED_TTC_CMDS-1 downto 0);

  signal s_l1id_cnt  : std_logic_vector(31 downto 0);
  signal s_orbit_cnt : std_logic_vector(31 downto 0);

  signal s_resync_ep : std_logic;
  signal s_bc0_stat  : t_bc0_stat;
  
  component ttc_mmcm
  port
   (-- Clock in ports
    clk_in1_p         : in     std_logic;
    clk_in1_n         : in     std_logic;
    -- Clock out ports
    clk_ttc40_out          : out    std_logic;
    clk_ttc120_out          : out    std_logic;
    clk_ttc240_out          : out    std_logic;
    -- Dynamic phase shift ports
    psclk             : in     std_logic;
    psen              : in     std_logic;
    psincdec          : in     std_logic;
    psdone            : out    std_logic;
    -- Status and control signals
    reset             : in     std_logic;
    locked            : out    std_logic
   );
  end component;

begin

--============================================================================
--                                                          Architecture begin
--============================================================================
      
    i_ctp7_ttc_clocks : ttc_mmcm
    port map ( 
        -- Clock in ports
        clk_in1_p => clk_40_ttc_p_i,
        clk_in1_n => clk_40_ttc_n_i,
        -- Clock out ports  
        clk_ttc40_out => s_clk_40,
        clk_ttc120_out => s_clk_120,
        clk_ttc240_out => s_clk_240,
        -- Dynamic phase shift ports                 
        psclk => ttc_mmcm_ps_clk_i,
        psen => ttc_mmcm_ctrl_i.phase_shift,
        psincdec => '1',
        psdone => open,
        -- Status and control signals                
        reset => ttc_mmcm_ctrl_i.reset,
        locked => ttc_mmcm_stat_o.locked            
    );

  i_ttc_cmd : entity work.ttc_cmd
    port map(
      clk_40_i             => s_clk_40,
      ttc_data_p_i         => ttc_data_p_i,
      ttc_data_n_i         => ttc_data_n_i,
      ttc_cmd_o            => s_ttc_cmd,
      ttc_l1a_o            => s_ttc_l1a,
      tcc_err_cnt_rst_i    => ttc_ctrl_i.stat_reset,
      ttc_err_single_cnt_o => ttc_stat_o.single_err,
      ttc_err_double_cnt_o => ttc_stat_o.double_err
      );


  i_pulse_delay_orn_delay : pulse_delay
    generic map (
      DELAY_CNT_LENGTH => 8
      )
    port map(
      clk_i    => s_clk_40,
      delay_i  => ttc_ctrl_i.orbit_delay,
      signal_i => s_bc0_cmd,
      signal_o => s_bc0_cmd_dly
      );

  process(s_clk_40) is
  begin
    if (rising_edge(s_clk_40)) then

      if (s_ttc_cmd = ttc_ctrl_i.bc0_cmd) then s_bc0_cmd             <= '1'; else s_bc0_cmd <= '0'; end if;
      if (s_ttc_cmd = ttc_ctrl_i.ec0_cmd) then s_ec0_cmd             <= '1'; else s_ec0_cmd <= '0'; end if;
      if (s_ttc_cmd = ttc_ctrl_i.resync_cmd) then s_resync_cmd       <= '1'; else s_resync_cmd <= '0'; end if;
      if (s_ttc_cmd = ttc_ctrl_i.oc0_cmd) then s_oc0_cmd             <= '1'; else s_oc0_cmd <= '0'; end if;
      if (s_ttc_cmd = ttc_ctrl_i.test_sync_cmd) then s_test_sync_cmd <= '1'; else s_test_sync_cmd <= '0'; end if;
      if (s_ttc_cmd = ttc_ctrl_i.start_cmd) then s_start_cmd         <= '1'; else s_start_cmd <= '0'; end if;
      if (s_ttc_cmd = ttc_ctrl_i.stop_cmd) then s_stop_cmd           <= '1'; else s_stop_cmd <= '0'; end if;

      s_l1a_cmd <= s_ttc_l1a and ttc_ctrl_i.l1a_enable and s_bc0_stat.locked;

    end if;
  end process;

  i_edge_detect_l1a : edge_detect
    port map
    (
      clk  => s_clk_240,
      sig  => s_l1a_cmd,
      edge => s_l1a_240
      );

  process(s_clk_40) is
  begin
    if (rising_edge(s_clk_40)) then

      if (s_oc0_cmd = '1') then
        s_orbit_cnt <= (others => '0');
      elsif (s_bc0_cmd_dly = '1') then
        s_orbit_cnt <= std_logic_vector(unsigned(s_orbit_cnt) + 1);
      end if;

    end if;
  end process;

  process(s_clk_40) is
  begin
    if (rising_edge(s_clk_40)) then

      if (s_ec0_cmd = '1') then
        s_l1id_cnt <= (others => '0');
      elsif (s_l1a_cmd = '1') then
        s_l1id_cnt <= std_logic_vector(unsigned(s_l1id_cnt) + 1);
      end if;

    end if;
  end process;


  ttc_daq_cntrs_o.orbit <= s_orbit_cnt;
  ttc_daq_cntrs_o.L1ID  <= s_l1id_cnt;

  s_ttc_cmd_decoded(0) <= s_l1a_cmd;
  s_ttc_cmd_decoded(1) <= s_bc0_cmd;
  s_ttc_cmd_decoded(2) <= s_ec0_cmd;
  s_ttc_cmd_decoded(3) <= s_resync_cmd;
  s_ttc_cmd_decoded(4) <= s_oc0_cmd;
  s_ttc_cmd_decoded(5) <= s_test_sync_cmd;
  s_ttc_cmd_decoded(6) <= s_start_cmd;
  s_ttc_cmd_decoded(7) <= s_stop_cmd;

  ttc_diag_cntrs_o.l1a       <= s_ttc_cmd_decoded_cnt(0);
  ttc_diag_cntrs_o.bc0       <= s_ttc_cmd_decoded_cnt(1);
  ttc_diag_cntrs_o.ec0       <= s_ttc_cmd_decoded_cnt(2);
  ttc_diag_cntrs_o.resync    <= s_ttc_cmd_decoded_cnt(3);
  ttc_diag_cntrs_o.oc0       <= s_ttc_cmd_decoded_cnt(4);
  ttc_diag_cntrs_o.test_sync <= s_ttc_cmd_decoded_cnt(5);
  ttc_diag_cntrs_o.start     <= s_ttc_cmd_decoded_cnt(6);
  ttc_diag_cntrs_o.stop      <= s_ttc_cmd_decoded_cnt(7);

  gen_ttc_cmd_cnt : for i in 0 to C_NUM_OF_DECODED_TTC_CMDS-1 generate
    process(s_clk_40) is
    begin
      if (rising_edge(s_clk_40)) then

        if (ttc_ctrl_i.stat_reset = '1') then
          s_ttc_cmd_decoded_cnt(i) <= (others => '0');
        elsif (s_ttc_cmd_decoded(i) = '1') then
          s_ttc_cmd_decoded_cnt(i) <= std_logic_vector(unsigned(s_ttc_cmd_decoded_cnt(i)) + 1);
        end if;
      end if;
    end process;
  end generate;

  i_local_timing_ref_gen : local_timing_ref_gen
    port map (
      clk_240_i          => s_clk_240,
      bc0_i              => s_bc0_cmd,
      bc0_stat_rst_i     => ttc_ctrl_i.stat_reset,
      bc0_stat_o         => s_bc0_stat,
      local_timing_ref_o => s_local_timing_ref
      );

  ttc_stat_o.bc0_stat <= s_bc0_stat;

  ttc_bgo_cmds_o.bc0       <= s_bc0_cmd;
  ttc_bgo_cmds_o.resync    <= s_resync_cmd;
  ttc_bgo_cmds_o.start     <= s_start_cmd;
  ttc_bgo_cmds_o.stop      <= s_stop_cmd;
  ttc_bgo_cmds_o.ec0       <= s_ec0_cmd;
  ttc_bgo_cmds_o.test_sync <= s_test_sync_cmd;

  local_timing_ref_o <= s_local_timing_ref;

  ttc_l1a_o       <= s_l1a_240;
  ttc_resync_o    <= s_resync_cmd;

  clk_40_bufg_o  <= s_clk_40;
  clk_120_bufg_o  <= s_clk_120;
  clk_240_bufg_o <= s_clk_240;

end ctp7_ttc_arch;
--============================================================================
--                                                            Architecture end
--============================================================================

