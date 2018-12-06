--============================================================================
--                                                                   Libraries
--============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.all;

--============================================================================
--                                                         Package declaration
--============================================================================
package ttc_pkg is

  type t_ttc_mmcm_ctrl is record
    reset       : std_logic;
    phase_shift : std_logic;
  end record;

  type t_ttc_mmcm_stat is record
    locked : std_logic;
  end record;

  type t_timing_ref is record
    bcid     : std_logic_vector(11 downto 0);
    sub_bcid : std_logic_vector(2 downto 0);
    bc0      : std_logic;
    cyc      : std_logic;
  end record;

  type t_ttc_bgo_cmds is record
    bc0       : std_logic;
    resync    : std_logic;
    start     : std_logic;
    stop      : std_logic;
    ec0       : std_logic;
    test_sync : std_logic;
  end record;

  type t_ttc_ctrl is record
    bc0_cmd       : std_logic_vector(7 downto 0);
    ec0_cmd       : std_logic_vector(7 downto 0);
    resync_cmd    : std_logic_vector(7 downto 0);
    oc0_cmd       : std_logic_vector(7 downto 0);
    test_sync_cmd : std_logic_vector(7 downto 0);
    start_cmd     : std_logic_vector(7 downto 0);
    stop_cmd      : std_logic_vector(7 downto 0);

    orbit_delay   : std_logic_vector(7 downto 0);
    l1a_enable    : std_logic;

    stat_reset : std_logic;
  end record;

  type t_bc0_stat is record
    unlocked_cnt : std_logic_vector(15 downto 0);
    udf_cnt      : std_logic_vector(15 downto 0);
    ovf_cnt      : std_logic_vector(15 downto 0);
    locked       : std_logic;
    err          : std_logic;
  end record;

  type t_ttc_stat is record
    bc0_stat   : t_bc0_stat;
    single_err : std_logic_vector(15 downto 0);
    double_err : std_logic_vector(15 downto 0);
  end record;

  type t_ttc_diag_cntrs is record
    l1a       : std_logic_vector(31 downto 0);
    bc0       : std_logic_vector(31 downto 0);
    ec0       : std_logic_vector(31 downto 0);
    resync    : std_logic_vector(31 downto 0);
    oc0       : std_logic_vector(31 downto 0);
    test_sync : std_logic_vector(31 downto 0);
    start     : std_logic_vector(31 downto 0);
    stop      : std_logic_vector(31 downto 0);

    l1a_cyc_0 : std_logic_vector(31 downto 0);
    l1a_cyc_1 : std_logic_vector(31 downto 0);
    l1a_cyc_2 : std_logic_vector(31 downto 0);
    l1a_cyc_3 : std_logic_vector(31 downto 0);
    l1a_cyc_4 : std_logic_vector(31 downto 0);
    l1a_cyc_5 : std_logic_vector(31 downto 0);
  end record;

  type t_ttc_daq_cntrs is record
    L1ID  : std_logic_vector(31 downto 0);
    orbit : std_logic_vector(31 downto 0);
  end record;

  constant C_TTC_BGO_BC0       : std_logic_vector(7 downto 0) := X"01";
  constant C_TTC_BGO_EC0       : std_logic_vector(7 downto 0) := X"02";
  constant C_TTC_BGO_RESYNC    : std_logic_vector(7 downto 0) := X"04";
  constant C_TTC_BGO_OC0       : std_logic_vector(7 downto 0) := X"08";
  constant C_TTC_BGO_TEST_SYNC : std_logic_vector(7 downto 0) := X"0C";
  constant C_TTC_BGO_START     : std_logic_vector(7 downto 0) := X"10";
  constant C_TTC_BGO_STOP      : std_logic_vector(7 downto 0) := X"14";

  type t_link_timing_ref_arr is array(integer range <>) of t_timing_ref;

end ttc_pkg;
--============================================================================
--                                                                 Package end
--============================================================================

