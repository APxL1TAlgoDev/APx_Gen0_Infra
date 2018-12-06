
library IEEE;
use IEEE.STD_LOGIC_1164.all;

--============================================================================
--                                                          Entity declaration
--============================================================================
entity edge_detect is
  generic
    (
      EDGE_DETECT_TYPE : string := "RISE"
      );
  port
    (
      clk  : in  std_logic;
      sig  : in  std_logic;
      edge : out std_logic
      );
end edge_detect;

--============================================================================
--                                                        Architecture section
--============================================================================
architecture edge_detect_arch of edge_detect is
--============================================================================
-- Signal declarations
--============================================================================

  -- input data delayed for 1 clock cycle
  signal sig_d1 : std_logic;

--============================================================================
--                                                          Architecture begin
--============================================================================  
begin

  sig_d1 <= sig when rising_edge(clk);

  gen_rising_edge : if EDGE_DETECT_TYPE = "RISE" generate
    edge <= sig and not sig_d1;
  end generate;

  gen_falling_edge : if EDGE_DETECT_TYPE = "FALL" generate
    edge <= sig_d1 and not sig;
  end generate;

end edge_detect_arch;
--============================================================================
--                                                            Architecture end
--============================================================================
