
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.link_align_pkg.all;

--============================================================================
--                                                          Entity declaration
--============================================================================
entity tx_packetizer is
  generic (
    g_LINK_ID : integer := 0
    );
  port (
   
  clk240_i       : in  std_logic;
  rst_i          : in  std_logic;
  
  link_data_i    : in t_link_aligned_data;
  data_valid_o : out std_logic;
  txdata_o       : out std_logic_vector(31 downto 0);
  txcharisk_o    : out std_logic_vector(3 downto 0)   
    );
end tx_packetizer;

--============================================================================
--                                                        Architecture section
--============================================================================
architecture tx_packetizer_arch  of tx_packetizer is

--============================================================================
--                                                         Signal declarations
--============================================================================

  signal s_txdata    : std_logic_vector (31 downto 0);
  signal s_txcharisk : std_logic_vector (3 downto 0);

  signal s_data_valid : std_logic;
  
--============================================================================
--                                                          Architecture begin
--============================================================================
  
begin

  p_data_valid : process(clk240_i) is
  begin
    if (rising_edge(clk240_i)) then
      data_valid_o <= s_data_valid;
      if (rst_i = '1') then
        s_data_valid <= '0';
      elsif (link_data_i.bc0 = '1') then
        s_data_valid <= '1';
      end if;
    end if;
  end process;


  p_output_asssign_and_register : process(clk240_i) is
  begin
    if (rising_edge(clk240_i)) then

      if (link_data_i.bc0 = '1') then
             s_txdata(7 downto 0)    <=  x"BC";
             s_txdata(31 downto 8)    <=  link_data_i.data(31 downto 8);
            s_txcharisk <= x"1";
      elsif (link_data_i.cyc = '1') then
             s_txdata(7 downto 0)    <=  x"3C";
             s_txdata(31 downto 8)    <=  link_data_i.data(31 downto 8);
            s_txcharisk <= x"1";
      else
          s_txdata(31 downto 0)    <=  link_data_i.data(31 downto 0);
         s_txcharisk <= x"0";
      end if;
    end if;
    
  end process;

  txdata_o    <= s_txdata;
  txcharisk_o <= s_txcharisk;

end tx_packetizer_arch;
--============================================================================
--                                                            Architecture end
--============================================================================

