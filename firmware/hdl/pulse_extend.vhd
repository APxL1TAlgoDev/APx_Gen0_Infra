-------------------------------------------------------------------------------
--                                                                            
--       Unit Name: pulse_extend                                            
--                                                                            
--     Description: 
--
--                                                                            
-------------------------------------------------------------------------------
--                                                                            
--           Notes: pulse_i should come as a pulse (e.g. after edge detector)                                                          
--                                                                            
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

--============================================================================
-- Entity declaration
--============================================================================
entity pulse_extend is
  generic (
    DELAY_CNT_LENGTH : integer := 8
    );
  port (
    clk_i          : in  std_logic;
    rst_i          : in  std_logic;
    pulse_length_i : in  std_logic_vector (DELAY_CNT_LENGTH-1 downto 0);
    pulse_i        : in  std_logic;
    pulse_o        : out std_logic
    );
end pulse_extend;

--============================================================================
-- Architecture section
--============================================================================
architecture pulse_extend_arch of pulse_extend is

--============================================================================
-- Signal declarations
--============================================================================
  signal s_count_down_cnt : unsigned(DELAY_CNT_LENGTH-1 downto 0);

--============================================================================
-- Architecture begin
--============================================================================
begin

  process(clk_i) is
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        s_count_down_cnt <= to_unsigned(0, DELAY_CNT_LENGTH);
      elsif pulse_i = '1' then
        s_count_down_cnt <= unsigned(pulse_length_i);
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
      if s_count_down_cnt /= 0 then
        pulse_o <= '1';
      else
        pulse_o <= '0';
      end if;
    end if;
  end process;

end pulse_extend_arch;
--============================================================================
-- Architecture end
--============================================================================
