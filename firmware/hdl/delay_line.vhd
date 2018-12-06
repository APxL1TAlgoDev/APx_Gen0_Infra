-------------------------------------------------------------------------------
--                                                                            
--       Unit Name: delay_line                                      
--                                                                            
--          Author: Ales Svetek                                                                                                                        
--
--            Date:                                 
--                                                                            
--         Version: 1.0                                                
--                                                                            
--     Description: Delay Line Circuit. The depth and width of the delay line
--                  can be specified by the generic parameters. The circuit is
--                  coded specifically without the reset signal so that the
--                  synthesiser tool can infer SRL16 macros. These macros can
--                  map up to 16 flip-flops in 1 slice. This reset-less circuit
--                  is used in situations where the power-on or reset sequence
--                  is not critical. The delay line can be "reset" by simply
--                  shifting out 1 full cycle. This limitation is compensated by
--                  the required slice reduction of 1:16.
--
-- attribute SRL_STYLE : string;
--  SRL_STYLE tells the synthesis tool how to infer SRLs that are 
--  found in the design. Accepted values are:
--
--  "register" :        The tool does not infer an SRL, but instead only uses registers.
--  "srl" :             The tool infers an SRL without any registers before or after.
--  "srl_reg" : The tool infers an SRL and leaves one register after the SRL.
--  "reg_srl" : The tool infers an SRL and leaves one register before the SRL.
--  "reg_srl_reg" :     The tool infers an SRL and leaves one register before and one register after the SRL.
--
--
--      References:                                                
--                                                                            
-------------------------------------------------------------------------------
--                                                                            
--    Last Changes:                                                           
--                                                                            
-------------------------------------------------------------------------------
--                                                                            
--            TODO:                                                           
--                                                                            
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

use work.ctp7_utils_pkg.all;

--============================================================================
-- Entity declaration for 
--============================================================================
entity delay_line is
  generic (
    G_DELAY      : integer;
    G_DATA_WIDTH : integer;
    G_SRL_STYLE  : string
    );
  port (
    clk      : in  std_logic;
    data_in  : in  std_logic_vector (G_DATA_WIDTH - 1 downto 0);
    data_out : out std_logic_vector (G_DATA_WIDTH - 1 downto 0));
end delay_line;

--============================================================================
-- Architecture section
--============================================================================
architecture delay_line_arch of delay_line is

--============================================================================
-- Custom Type declarations
--============================================================================   
  subtype elements is std_logic_vector(G_DATA_WIDTH-1 downto 0);
  type reg_array is array (G_DELAY-1 downto 0) of elements;

--============================================================================
-- Signal declarations
--============================================================================  

  signal tmp_reg : reg_array;

  attribute SRL_STYLE            : string;
  attribute SRL_STYLE of tmp_reg : signal is G_SRL_STYLE;

begin
--============================================================================
-- Architecture begin
--============================================================================

  process (clk)
  begin
    if rising_edge(clk) then
      for i in G_DELAY-1 downto 1 loop
        tmp_reg(i) <= tmp_reg(i-1);
      end loop;
      tmp_reg(0) <= data_in;
    end if;
  end process;

  data_out <= tmp_reg(G_DELAY-1);

end delay_line_arch;
--============================================================================
-- Architecture end
--============================================================================
