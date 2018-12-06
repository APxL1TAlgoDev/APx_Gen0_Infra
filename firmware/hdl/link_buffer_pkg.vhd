-------------------------------------------------------------------------------
--                                                                            
--       Unit Name: link_buffer_pkg                                          
--                                                                            
--          Author: Ales Svetek 
--                                                                            
--         Version: 1.0                                                
--                                                                            
--     Description: 
--
--      References:                                               
--                                                                            
-------------------------------------------------------------------------------
--                                                                            
--    Last Changes:                                                           
--                                                                            
-------------------------------------------------------------------------------
--                                                                            
--           Notes:                                                           
--                                                                            
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

--============================================================================
--                                                               Package Start
--============================================================================
package link_buffer_pkg is

  type t_link_buffer_ctrl is record
    arm        : std_logic;
    CAP_nPB     : std_logic;
    mode       : std_logic_vector(1 downto 0);
    start_bcid : std_logic_vector(11 downto 0);
  end record;

  constant C_link_buffer_ctrl_PB : t_link_buffer_ctrl := (
    arm         => '0',
    CAP_nPB       => '0',
    mode   => (others => '0'),
    start_bcid => (others => '0')
    );

  constant C_link_buffer_ctrl_CAP : t_link_buffer_ctrl := (
    arm         => '0',
    CAP_nPB       => '1',
    mode   => (others => '0'),
    start_bcid => (others => '0')
    );

  type t_link_buffer_status is record
    done                           : std_logic;
    fsm_state                      : std_logic_vector(1 downto 0);
    capture_started_at_local_bx_id : std_logic_vector(11 downto 0);
    capture_started_at_link_bx_id  : std_logic_vector(11 downto 0);
  end record;

  type t_link_buffer_ctrl_arr is array(integer range <>) of t_link_buffer_ctrl;
  type t_link_buffer_status_arr is array(integer range <>) of t_link_buffer_status;

end package link_buffer_pkg;
--============================================================================
--                                                            Package Body End
--============================================================================

