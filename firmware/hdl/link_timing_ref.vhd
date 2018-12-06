
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.ttc_pkg.all;

--============================================================================
--                                                          Entity declaration
--============================================================================
entity link_timing_ref_gen is
generic 
(
   g_bcid_rst     : unsigned(11 downto 0) := x"000";
   g_sub_bcid_rst : unsigned(2 downto 0) := "000";
   g_bc0_rst      : std_logic := '1';
   g_cyc_rst      : std_logic := '1'
);
  port (
    clk_240_i    : in  std_logic;
    rst_i : in std_logic;
    timing_ref_o : out t_timing_ref
    );
end link_timing_ref_gen;

--============================================================================
--                                                        Architecture section
--============================================================================
architecture link_timing_ref_gen_arch of link_timing_ref_gen is

--============================================================================
--                                                       Constant declarations
--============================================================================  

  constant C_BCID_MAX    : integer := 3564;
  constant C_SUB_BCID_MAX    : integer := 6;

--============================================================================
--                                                         Signal declarations
--============================================================================  

  signal s_bcid     : unsigned(11 downto 0);
  signal s_sub_bcid : unsigned(2 downto 0);
  signal s_bc0      : std_logic;
  signal s_cyc      : std_logic;


--============================================================================
--                                                          Architecture begin
--============================================================================  
begin


  process(clk_240_i) is
  begin
    if rising_edge(clk_240_i) then
      if (rst_i = '1') then
        s_bcid     <= g_bcid_rst;
        s_sub_bcid <= g_sub_bcid_rst;
        s_cyc      <= g_cyc_rst;
        s_bc0      <= g_bc0_rst;

      else

        s_sub_bcid <= s_sub_bcid + 1;

        if (s_sub_bcid = "101") then
          s_sub_bcid <= "000";
          s_cyc      <= '1';
          s_bcid     <= s_bcid + 1;

          if (s_bcid = x"DEB") then
            s_bcid <= x"000";
            s_bc0  <= '1';
          end if;
        else
          s_bc0 <= '0';
          s_cyc <= '0';
        end if;

      end if;

    end if;
  end process;

  timing_ref_o.bcid     <= std_logic_vector(s_bcid);
  timing_ref_o.sub_bcid <= std_logic_vector(s_sub_bcid);
  timing_ref_o.bc0      <= s_bc0;
  timing_ref_o.cyc      <= s_cyc;

end link_timing_ref_gen_arch;
--============================================================================
--                                                            Architecture end
--============================================================================
