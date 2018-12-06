--============================================================================
--                                                                   Libraries
--============================================================================

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

--============================================================================
-- Entity declaration
--============================================================================
entity pulse_delay is
  generic (
    DELAY_CNT_LENGTH : integer := 8
    );
  port (
    clk_i    : in  std_logic;
    delay_i  : in  std_logic_vector (DELAY_CNT_LENGTH-1 downto 0);
    signal_i : in  std_logic;
    signal_o : out std_logic
    );
end pulse_delay;

--============================================================================
-- Architecture section
--============================================================================
architecture pulse_delay_arch of pulse_delay is

--============================================================================
-- Signal declarations
--============================================================================
  signal s_count_down_cnt : unsigned(DELAY_CNT_LENGTH-1 downto 0);
  signal s_signal_d       : std_logic;

--============================================================================
-- Architecture begin
--============================================================================  
begin

  process(clk_i) is
  begin
    if rising_edge(clk_i) then
      if signal_i = '1' then
        s_count_down_cnt <= unsigned(delay_i);
      elsif s_count_down_cnt = to_unsigned(0, DELAY_CNT_LENGTH) then
        s_count_down_cnt <= to_unsigned(0, DELAY_CNT_LENGTH);
      else
        s_count_down_cnt <= s_count_down_cnt - 1;
      end if;
    end if;
  end process;

  process(clk_i) is
  begin
    if rising_edge(clk_i) then
      if s_count_down_cnt = 1 then
        s_signal_d <= '1';
      else
        s_signal_d <= '0';
      end if;
    end if;
  end process;

  signal_o <= signal_i when unsigned(delay_i) = 0 else s_signal_d;

end pulse_delay_arch;
--============================================================================
-- Architecture end
--============================================================================

