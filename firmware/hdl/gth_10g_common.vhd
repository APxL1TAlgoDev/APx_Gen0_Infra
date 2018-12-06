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
entity gth_10gbps_buf_cc_common is
  generic
    (
      -- Simulation attributes
      g_GT_SIM_GTRESET_SPEEDUP : string  := "TRUE";  -- Set to "true" to speed up sim reset 
      g_STABLE_CLOCK_PERIOD    : integer := 20  -- Period of the stable clock driving this state-machine, unit is [ns]

      );
  port
    (

      clk_stable_i     : in  std_logic;
      gth_common_clk_i : in  std_logic;
      gth_common_clk_o : out t_gth_common_clk_out;

      gth_common_ctrl_i   : in  t_gth_common_ctrl;
      gth_common_status_o : out t_gth_common_status;

      gth_common_drp_i : in  t_gth_common_drp_in;
      gth_common_drp_o : out t_gth_common_drp_out
      );

end gth_10gbps_buf_cc_common;

--============================================================================
--                                                        Architecture section
--============================================================================
architecture gth_10gbps_buf_cc_common_arch of gth_10gbps_buf_cc_common is

--*************************Logic to set Attribute QPLL_FB_DIV*****************************
  impure function conv_qpll_fbdiv_top (qpllfbdiv_top : in integer) return bit_vector is
    begin
       if (qpllfbdiv_top = 16) then
         return "0000100000";
       elsif (qpllfbdiv_top = 20) then
         return "0000110000" ;
       elsif (qpllfbdiv_top = 32) then
         return "0001100000" ;
       elsif (qpllfbdiv_top = 40) then
         return "0010000000" ;
       elsif (qpllfbdiv_top = 64) then
         return "0011100000" ;
       elsif (qpllfbdiv_top = 66) then
         return "0101000000" ;
       elsif (qpllfbdiv_top = 80) then
         return "0100100000" ;
       elsif (qpllfbdiv_top = 100) then
         return "0101110000" ;
       else 
         return "0000000000" ;
       end if;
    end function;

    impure function conv_qpll_fbdiv_ratio (qpllfbdiv_top : in integer) return bit is
    begin
       if (qpllfbdiv_top = 16) then
         return '1';
       elsif (qpllfbdiv_top = 20) then
         return '1' ;
       elsif (qpllfbdiv_top = 32) then
         return '1' ;
       elsif (qpllfbdiv_top = 40) then
         return '1' ;
       elsif (qpllfbdiv_top = 64) then
         return '1' ;
       elsif (qpllfbdiv_top = 66) then
         return '0' ;
       elsif (qpllfbdiv_top = 80) then
         return '1' ;
       elsif (qpllfbdiv_top = 100) then
         return '1' ;
       else 
         return '1' ;
       end if;
    end function;

  --============================================================================
--                                                      Constants declarations
--============================================================================
  --constant QPLL_FBDIV_TOP   : integer                := 80; -- 8 Gbps
  --constant QPLL_FBDIV_TOP   : integer                := 100; -- 10 Gbps
  constant QPLL_FBDIV_TOP   : integer                := 40; -- 10 Gbps
  
  constant QPLL_FBDIV_IN    : bit_vector(9 downto 0) := conv_qpll_fbdiv_top(QPLL_FBDIV_TOP);
  constant QPLL_FBDIV_RATIO : bit                    := conv_qpll_fbdiv_ratio(QPLL_FBDIV_TOP);

  constant C_STARTUP_DELAY : integer := 500;  --AR43482: Transceiver needs to wait for 500 ns after configuration
  constant C_WAIT_CYCLES   : integer := C_STARTUP_DELAY / g_STABLE_CLOCK_PERIOD;  -- Number of Clock-Cycles to wait after configuration
  constant C_WAIT_MAX      : integer := C_WAIT_CYCLES + 10;  -- 500 ns plus some additional margin

--============================================================================
--                                                         Signal declarations
--============================================================================
  signal s_init_wait_count    : unsigned(7 downto 0) := (others => '0');
  signal s_init_wait_done     : std_logic            := '0';
  signal s_startup_auto_reset : std_logic;

  signal s_qpll_reset : std_logic;

--============================================================================
--                                                          Architecture begin
--============================================================================
begin

  process(clk_stable_i)
  begin
    if rising_edge(clk_stable_i) then
      -- The counter starts running when configuration has finished and 
      -- the clock is stable. When its maximum count-value has been reached,
      -- the 500 ns from Answer Record 43482 have been passed.
      if s_init_wait_count = C_WAIT_MAX then
        s_init_wait_done <= '1';
      else
        s_init_wait_count <= s_init_wait_count + 1;
      end if;
    end if;
  end process;

  s_startup_auto_reset <= not s_init_wait_done;

  s_qpll_reset <= (gth_common_ctrl_i.QPLLRESET and s_init_wait_done) or s_startup_auto_reset;

  --_________________________________________________________________________
  --_________________________________________________________________________
  --_________________________GTXE2_COMMON____________________________________

  inst_gthe2_common : GTHE2_COMMON
    generic map
    (
        -- Simulation attributes
        SIM_RESET_SPEEDUP    => g_GT_SIM_GTRESET_SPEEDUP,
        SIM_QPLLREFCLK_SEL   => ("001"),
        SIM_VERSION          => "2.0",
        
        ------------------COMMON BLOCK Attributes---------------
        BIAS_CFG                                =>     (x"0000040000001050"),
        COMMON_CFG                              =>     (x"0000001C"),
        QPLL_CFG                                =>     (x"04801C7"),
        QPLL_CLKOUT_CFG                         =>     ("1111"),
        QPLL_COARSE_FREQ_OVRD                   =>     ("010000"),
        QPLL_COARSE_FREQ_OVRD_EN                =>     ('0'),
        QPLL_CP                                 =>     ("0000011111"),
        QPLL_CP_MONITOR_EN                      =>     ('0'),
        QPLL_DMONITOR_SEL                       =>     ('0'),
        QPLL_FBDIV                              =>     (QPLL_FBDIV_IN),
        QPLL_FBDIV_MONITOR_EN                   =>     ('0'),
        QPLL_FBDIV_RATIO                        =>     (QPLL_FBDIV_RATIO),
        QPLL_INIT_CFG                           =>     (x"000006"),
        QPLL_LOCK_CFG                           =>     (x"05E8"),
        QPLL_LPF                                =>     ("1111"),
        QPLL_REFCLK_DIV                         =>     (1),
        RSVD_ATTR0                              =>     (x"0000"),
        RSVD_ATTR1                              =>     (x"0000"),
        QPLL_RP_COMP                            =>     ('0'),
        QPLL_VTRL_RESET                         =>     ("00"),
        RCAL_CFG                                =>     ("00")


      )
    port map
    (
      ------------- Common Block  - Dynamic Reconfiguration Port (DRP) -----------
      DRPADDR          => gth_common_drp_i.DRPADDR,
      DRPCLK           => gth_common_drp_i.DRPCLK,
      DRPDI            => gth_common_drp_i.DRPDI,
      DRPDO            => gth_common_drp_o.DRPDO,
      DRPEN            => gth_common_drp_i.DRPEN,
      DRPRDY           => gth_common_drp_o.DRPRDY,
      DRPWE            => gth_common_drp_i.DRPWE,
      ---------------------- Common Block  - Ref Clock Ports ---------------------
      -- From Xilinx UG476
      -- The QPLLREFCLKSEL port is required when multiple reference clock sources are 
      -- connected to this multiplexer. A single reference clock is most commonly used. 
      -- In this case, the QPLLREFCLKSEL port can be tied to 3'b001, and the Xilinx software 
      -- tools handle the complexity of the multiplexers and associated routing.
      GTGREFCLK        => '0',
      GTNORTHREFCLK0   => '0',
      GTNORTHREFCLK1   => '0',
      GTREFCLK0        => gth_common_clk_i,
      GTREFCLK1        => '0',
      GTSOUTHREFCLK0   => '0',
      GTSOUTHREFCLK1   => '0',
      ------------------------- Common Block -  QPLL Ports -----------------------
      QPLLDMONITOR     => open,
      ----------------------- Common Block - Clocking Ports ----------------------
      QPLLOUTCLK       => gth_common_clk_o.QPLLOUTCLK,
      QPLLOUTREFCLK    => gth_common_clk_o.QPLLOUTREFCLK,
      REFCLKOUTMONITOR => open,
      ------------------------- Common Block - QPLL Ports ------------------------
      BGRCALOVRDENB    => '1',
      PMARSVDOUT       => open,
      QPLLFBCLKLOST    => gth_common_status_o.QPLLFBCLKLOST,
      QPLLLOCK         => gth_common_status_o.QPLLLOCK,
      QPLLLOCKDETCLK   => clk_stable_i,
      QPLLLOCKEN       => '1',
      QPLLOUTRESET     => '0',
      QPLLPD           => gth_common_ctrl_i.QPLLPD,
      QPLLREFCLKLOST   => gth_common_status_o.QPLLREFCLKLOST,
      QPLLREFCLKSEL    => "001",
      QPLLRESET        => s_qpll_reset,
      QPLLRSVD1        => "0000000000000000",
      QPLLRSVD2        => "11111",
      --------------------------------- QPLL Ports -------------------------------
      BGBYPASSB        => '1',
      BGMONITORENB     => '1',
      BGPDB            => '1',
      BGRCALOVRD       => "11111",
      PMARSVD          => "00000000",
      RCALENB          => '1'

      );
end gth_10gbps_buf_cc_common_arch;
--============================================================================
--                                                            Architecture end
--============================================================================

