

library IEEE;
use IEEE.STD_LOGIC_1164.all;


--============================================================================
--                                                               Package Start
--============================================================================
package timing_ref_pkg is

  type t_timing_ref is record
    bcid : std_logic_vector(11 downto 0);
    sub_bcid : std_logic_vector(2 downto 0);
    bc0  : std_logic;
    cyc  : std_logic;
  end record;
  
end package;
--============================================================================
--                                                            Package Body End
--============================================================================


