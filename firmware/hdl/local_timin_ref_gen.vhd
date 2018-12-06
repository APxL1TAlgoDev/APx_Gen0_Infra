                                             --============================================================================
--                                                                   Libraries
--============================================================================
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.ctp7_utils_pkg.all;
use work.ttc_pkg.all;

--============================================================================
--                                                          Entity declaration
--============================================================================
entity local_timing_ref_gen is
  port (
    clk_240_i : in std_logic;
    bc0_i     : in std_logic;

    bc0_stat_rst_i : in  std_logic;
    bc0_stat_o     : out t_bc0_stat;

    local_timing_ref_o : out t_timing_ref
    );
end local_timing_ref_gen;

--============================================================================
--                                                        Architecture section
--============================================================================
architecture local_timing_ref_gen_arch of local_timing_ref_gen is

--============================================================================
--                                                         Signal declarations
--============================================================================ 
  signal s_bcid     : unsigned(11 downto 0):= x"DEB";
  signal s_sub_bcid : unsigned(2 downto 0) := "000";

  signal s_bc0, s_bc0_240_edge : std_logic;
  signal s_cyc                 : std_logic;

  signal s_bc0_udf : std_logic;
  signal s_bc0_ovf : std_logic;

  signal s_bc0_stat : t_bc0_stat;

begin
--============================================================================
--                                                          Architecture begin
--============================================================================

  i_edge_detect_bc0_240 : edge_detect

    generic map
    (
      EDGE_DETECT_TYPE => "RISE"
      )
    port map
    (
      clk  => clk_240_i,
      sig  => bc0_i,
      edge => s_bc0_240_edge
      );

  process(clk_240_i) is
  begin
    if rising_edge(clk_240_i) then

      s_bc0_udf <= '0';
      s_bc0_ovf <= '0';

      if (s_bc0_240_edge = '1') then
        s_bcid     <= x"000";
        s_sub_bcid <= "000";
        s_cyc      <= '1';
        s_bc0      <= '1';

        if ((s_sub_bcid = "101") and (s_bcid = x"DEB")) then
          s_bc0_udf <= '0';
        else
          s_bc0_udf <= '1';
        end if;

      else

        s_sub_bcid <= s_sub_bcid + 1;

        if (s_sub_bcid = "101") then
          s_sub_bcid <= "000";
          s_cyc      <= '1';
          s_bcid     <= s_bcid + 1;

          if (s_bcid = x"DEB") then
            s_bcid    <= x"000";
            s_bc0     <= '1';
            s_bc0_ovf <= '1';
          end if;
        else
          s_bc0 <= '0';
          s_cyc <= '0';
        end if;

      end if;

    end if;
  end process;

  process(clk_240_i) is
  begin
    if rising_edge(clk_240_i) then
      if (bc0_stat_rst_i = '1') then
        s_bc0_stat.udf_cnt <= (others => '0');
      elsif (s_bc0_udf = '1' and s_bc0_stat.udf_cnt /= x"FFFF") then
        s_bc0_stat.udf_cnt <= std_logic_vector(unsigned(s_bc0_stat.udf_cnt) + 1);
      end if;
    end if;
  end process;

  process(clk_240_i) is
  begin
    if rising_edge(clk_240_i) then
      if (bc0_stat_rst_i = '1') then
        s_bc0_stat.ovf_cnt <= (others => '0');
      elsif (s_bc0_ovf = '1' and s_bc0_stat.ovf_cnt /= x"FFFF") then
        s_bc0_stat.ovf_cnt <= std_logic_vector(unsigned(s_bc0_stat.ovf_cnt) + 1);
      end if;
    end if;
  end process;

  process(clk_240_i) is
  begin
    if rising_edge(clk_240_i) then
      if (bc0_stat_rst_i = '1') then
        s_bc0_stat.unlocked_cnt <= (others => '0');
      elsif ((s_bc0_ovf = '1' or s_bc0_udf = '1') and s_bc0_stat.unlocked_cnt /= x"FFFF") then
        s_bc0_stat.unlocked_cnt <= std_logic_vector(unsigned(s_bc0_stat.unlocked_cnt) + 1);
      end if;
    end if;
  end process;

  s_bc0_stat.locked <= '1' when (s_bc0_stat.udf_cnt = x"0000" and s_bc0_stat.ovf_cnt = x"0000") else '0';
  s_bc0_stat.err    <= not s_bc0_stat.locked;

  bc0_stat_o <= s_bc0_stat;

  local_timing_ref_o.bcid     <= std_logic_vector(s_bcid);
  local_timing_ref_o.sub_bcid <= std_logic_vector(s_sub_bcid);
  local_timing_ref_o.bc0      <= s_bc0;
  local_timing_ref_o.cyc      <= s_cyc;

end local_timing_ref_gen_arch;
--============================================================================
--                                                            Architecture end
--============================================================================

