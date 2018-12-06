
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.ctp7_utils_pkg.all;

use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity clock_measure is
    Generic (
        REFCLK_FREQ : integer := 50000000
    );
    Port ( REFCLK_IN : in STD_LOGIC;
           CLK_IN : in STD_LOGIC;
           FREQ_OUT : out STD_LOGIC_VECTOR (31 downto 0));
end clock_measure;

architecture Behavioral of clock_measure is
    signal refclk_async_reset_r, refclk_async_reset_i : std_logic;
    signal refclk_cntr_r : unsigned (25 downto 0);
    
    signal clk_cntr_r : unsigned (31 downto 0);
begin
    process (REFCLK_IN) begin
        if (REFCLK_IN'event and REFCLK_IN = '1') then
            if (refclk_cntr_r = REFCLK_FREQ-1) then
                refclk_cntr_r <= (others => '0');
                FREQ_OUT <= std_logic_vector(clk_cntr_r);
            else
                refclk_cntr_r <= refclk_cntr_r + 1;
            end if;
        end if;
    end process;
    
    refclk_async_reset_i <= '1' when refclk_cntr_r = 0 else '0';
    
    refclk_async_reset_r <= refclk_async_reset_i when CLK_IN'event and CLK_IN = '1';
    
    process (CLK_IN) begin
        if (CLK_IN'event and CLK_IN = '1') then
            if (refclk_async_reset_r = '1') then
                clk_cntr_r <= (others => '0');
            else
                clk_cntr_r <= clk_cntr_r + 1;
            end if;
        end if;
    end process;

end Behavioral;
