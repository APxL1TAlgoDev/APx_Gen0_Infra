library IEEE;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.gth_pkg.all;

--============================================================================
--                                                               Package Start
--============================================================================

package ctp7_v7_build_cfg_pkg is

    constant C_BCFG_FW_VERSION_MAJOR : std_logic_vector(7 downto 0) := X"01";
    constant C_BCFG_FW_VERSION_MINOR : std_logic_vector(7 downto 0) := X"07";
    constant C_BCFG_FW_VERSION_PATCH : std_logic_vector(7 downto 0) := X"01";
    
    constant C_BCFG_FW_PROJECT_CODE : std_logic_vector(31 downto 0) := x"B1050171"; -- BIOS LT 1 (link test 1)
    
    constant C_NUM_OF_GTH_GTs     : integer                        := 64;
    constant C_NUM_OF_GTH_COMMONs : integer                        := 16;

    type t_gth_config_arr is array (0 to C_NUM_OF_GTH_GTs-1) of t_gth_config;

    constant c_gth_config_arr : t_gth_config_arr := (
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_MASTER),                  -- GTH FW Ch 0
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 1
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 2
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 3
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 4
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 5
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 6
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 7
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 8
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 9
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 10
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 11
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 12
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 13
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 14
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 15
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 16
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 17
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 18
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 19
        
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 20
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 21
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 22
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 23
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 24
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 25
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 26
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 27
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 28
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 29
        
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 30
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 31
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 32
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 33
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 34
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 35
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 36
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 37
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 38
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 39
        
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 40
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 41
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 42
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 43
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 44
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 45
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 46
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 47
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 48
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 49
        
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 50
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 51
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 52
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 53
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 54
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 55
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 56
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 57
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 58
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 59
        
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 60
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 61
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE),                   -- GTH FW Ch 62
        (C_GTH_10P0G_8B10B_BUF, C_GTH_10P0G_8B10B_BUF, C_GTH_TXCLK_ASYNC_SLAVE)                    -- GTH FW Ch 63
    );  
    
    function is_gth_enabled(index: integer) return boolean;
    function is_qpll_enabled(index: integer) return boolean;
    
end package ctp7_v7_build_cfg_pkg;

--============================================================================
--                                                            Package Body 
--============================================================================
package body ctp7_v7_build_cfg_pkg is

    function is_gth_enabled(index: integer) return boolean is
    begin
        return c_gth_config_arr(index).tx_config.enable or c_gth_config_arr(index).rx_config.enable;
    end function is_gth_enabled;
    
    function is_qpll_enabled(index: integer) return boolean is
        variable en : boolean := false;
    begin
        for I in 0 to 3 loop
            en := en or ((c_gth_config_arr(index*4+i).tx_config.enable and c_gth_config_arr(index*4+i).tx_config.qpll_used) or 
                         (c_gth_config_arr(index*4+i).rx_config.enable and c_gth_config_arr(index*4+i).rx_config.qpll_used));
        end loop;
        return en;
    end function is_qpll_enabled;

end ctp7_v7_build_cfg_pkg;
