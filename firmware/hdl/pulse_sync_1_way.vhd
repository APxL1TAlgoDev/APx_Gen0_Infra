library IEEE;
use IEEE.STD_LOGIC_1164.all;

use work.ctp7_utils_pkg.all;

--============================================================================
-- Entity declaration for pulse_sync_1_way
--============================================================================
entity pulse_sync_1_way is
  generic (
    N_STAGES : integer := 2
    );    
  port (
    clk1_i           : in  std_logic;
    pulse_in_clk1_i  : in  std_logic;
    clk2_i           : in  std_logic;
    pulse_out_clk2_o : out std_logic
    );
end pulse_sync_1_way;

--============================================================================
-- Architecture section
--============================================================================
architecture pulse_sync_1_way_arch of pulse_sync_1_way is
--============================================================================
-- Signal declarations
--============================================================================
  signal s_toggle_P : std_logic :='0';
  signal s_toggle_N : std_logic :='0';
  signal s_mux_out  : std_logic :='0';

  signal s_resync1 : std_logic :='0';
  signal s_resync2 : std_logic :='0';

begin
--============================================================================
-- Architecture begin
--============================================================================
  s_mux_out <= s_toggle_P when pulse_in_clk1_i = '0' else s_toggle_N;

  process(clk1_i) is
  begin
    if rising_edge(clk1_i) then
      s_toggle_P <= s_mux_out;
    end if;
  end process;

  s_toggle_N <= not s_toggle_P;

  cmp_synchronizer : synchronizer
    generic map (
      N_STAGES => N_STAGES
      )
    port map(
      async_i => s_toggle_P,
      clk_i  => clk2_i,
      sync_o  => s_resync1
      );

  s_resync2 <= s_resync1 when rising_edge(clk2_i);

  pulse_out_clk2_o <= s_resync1 xor s_resync2;
  
end pulse_sync_1_way_arch;

--============================================================================
-- Architecture end
--============================================================================
