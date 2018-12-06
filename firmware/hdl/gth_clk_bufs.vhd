
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library UNISIM;
use UNISIM.VCOMPONENTS.all;

library work;
use work.gth_pkg.all;
use work.ctp7_v7_build_cfg_pkg.all;

--============================================================================
--                                                          Entity declaration
--============================================================================
entity gth_clk_bufs is
  port (

    refclk_F_0_p_i : in std_logic_vector (3 downto 0);
    refclk_F_0_n_i : in std_logic_vector (3 downto 0);
    refclk_F_1_p_i : in std_logic_vector (3 downto 0);
    refclk_F_1_n_i : in std_logic_vector (3 downto 0);
    refclk_B_0_p_i : in std_logic_vector (3 downto 0);
    refclk_B_0_n_i : in std_logic_vector (3 downto 0);
    refclk_B_1_p_i : in std_logic_vector (3 downto 0);
    refclk_B_1_n_i : in std_logic_vector (3 downto 0);

    refclk_common_arr_o : out std_logic_vector (19 downto 0);
    refclk_gt_arr_o : out std_logic_vector (19 downto 0);

    gth_gt_clk_out_arr_i : in t_gth_gt_clk_out_arr(C_NUM_OF_GTH_GTs-1 downto 0);
    clk_ttc_120_i : std_logic;
    clk_ttc_240_i : std_logic;

    clk_gth_tx_usrclk_arr_o : out std_logic_vector(C_NUM_OF_GTH_GTs-1 downto 0);
    clk_gth_rx_usrclk_arr_o : out std_logic_vector(C_NUM_OF_GTH_GTs-1 downto 0)

    );
end gth_clk_bufs;

--============================================================================
architecture gth_clk_bufs_arch of gth_clk_bufs is

--============================================================================
--                                                         Signal declarations
--============================================================================

  signal s_refclk_F_0 : std_logic_vector (3 downto 0);
  signal s_refclk_F_1 : std_logic_vector (3 downto 0);
  signal s_refclk_B_0 : std_logic_vector (3 downto 0);
  signal s_refclk_B_1 : std_logic_vector (3 downto 0);
  
  signal s_gth_txusrclk : std_logic_vector (C_NUM_OF_GTH_GTs-1 downto 0);
  
  attribute syn_noclockbuf : boolean;
  attribute syn_noclockbuf of s_refclk_F_0 : signal is true;
  attribute syn_noclockbuf of s_refclk_B_0 : signal is true;
  attribute syn_noclockbuf of s_refclk_F_1 : signal is true;
  attribute syn_noclockbuf of s_refclk_B_1 : signal is true;
  
  --attribute keep       : boolean;
      
  --attribute keep of s_gth_txusrclk : signal is true;
  
  component gth_tx_clk_div
  port
   (-- Clock in ports
    clk_in1           : in     std_logic;
    -- Clock out ports
    clk_out1          : out    std_logic;
    -- Status and control signals
    reset             : in     std_logic;
    locked            : out    std_logic
   );
  end component;
  
--============================================================================
--                                                          Architecture begin
--============================================================================

begin

--============================================================================

  gen_ibufds_F_clk_gte2 : for i in 0 to 3 generate
    i_ibufds_F_0 : IBUFDS_GTE2
      port map
      (
        O     => s_refclk_F_0(i),
        ODIV2 => open,
        CEB   => '0',
        I     => refclk_F_0_p_i(i),
        IB    => refclk_F_0_n_i(i)
        );

    i_ibufds_F_1 : IBUFDS_GTE2
      port map
      (
        O     => s_refclk_F_1(i),
        ODIV2 => open,
        CEB   => '0',
        I     => refclk_F_1_p_i(i),
        IB    => refclk_F_1_n_i(i)
        );
  end generate;

  gen_ibufds_B_clk_gte2 : for i in 0 to 3 generate
    i_ibufds_B_0 : IBUFDS_GTE2
      port map
      (
        O     => s_refclk_B_0(i),
        ODIV2 => open,
        CEB   => '0',
        I     => refclk_B_0_p_i(i),
        IB    => refclk_B_0_n_i(i)
        );

    i_ibufds_B_1 : IBUFDS_GTE2
      port map
      (
        O     => s_refclk_B_1(i),
        ODIV2 => open,
        CEB   => '0',
        I     => refclk_B_1_p_i(i),
        IB    => refclk_B_1_n_i(i)
        );
  end generate;

--============================================================================

    refclk_common_arr_o(0)  <= s_refclk_F_1(3);
    refclk_common_arr_o(1)  <= s_refclk_F_1(3);
    refclk_common_arr_o(2)  <= s_refclk_F_1(2);
    refclk_common_arr_o(3)  <= s_refclk_F_1(2);
    refclk_common_arr_o(4)  <= s_refclk_F_1(2);
    refclk_common_arr_o(5)  <= s_refclk_F_1(1);
    refclk_common_arr_o(6)  <= s_refclk_F_1(1);
    refclk_common_arr_o(7)  <= s_refclk_F_1(1);
    refclk_common_arr_o(8)  <= s_refclk_F_1(0);
    refclk_common_arr_o(9)  <= s_refclk_F_1(0);
    refclk_common_arr_o(10) <= s_refclk_B_1(3);
    refclk_common_arr_o(11) <= s_refclk_B_1(3);
    refclk_common_arr_o(12) <= s_refclk_B_1(2);
    refclk_common_arr_o(13) <= s_refclk_B_1(2);
    refclk_common_arr_o(14) <= s_refclk_B_1(2);
    refclk_common_arr_o(15) <= s_refclk_B_1(1);
    refclk_common_arr_o(16) <= s_refclk_B_1(1);
    refclk_common_arr_o(17) <= s_refclk_B_1(1);
    refclk_common_arr_o(18) <= s_refclk_B_1(0);
    refclk_common_arr_o(19) <= s_refclk_B_1(0);
    
    refclk_gt_arr_o(0)  <= s_refclk_F_0(3);
    refclk_gt_arr_o(1)  <= s_refclk_F_0(3);
    refclk_gt_arr_o(2)  <= s_refclk_F_0(2);
    refclk_gt_arr_o(3)  <= s_refclk_F_0(2);
    refclk_gt_arr_o(4)  <= s_refclk_F_0(2);
    refclk_gt_arr_o(5)  <= s_refclk_F_0(1);
    refclk_gt_arr_o(6)  <= s_refclk_F_0(1);
    refclk_gt_arr_o(7)  <= s_refclk_F_0(1);
    refclk_gt_arr_o(8)  <= s_refclk_F_0(0);
    refclk_gt_arr_o(9)  <= s_refclk_F_0(0);
    refclk_gt_arr_o(10) <= s_refclk_B_0(3);
    refclk_gt_arr_o(11) <= s_refclk_B_0(3);
    refclk_gt_arr_o(12) <= s_refclk_B_0(2);
    refclk_gt_arr_o(13) <= s_refclk_B_0(2);
    refclk_gt_arr_o(14) <= s_refclk_B_0(2);
    refclk_gt_arr_o(15) <= s_refclk_B_0(1);
    refclk_gt_arr_o(16) <= s_refclk_B_0(1);
    refclk_gt_arr_o(17) <= s_refclk_B_0(1);
    refclk_gt_arr_o(18) <= s_refclk_B_0(0);
    refclk_gt_arr_o(19) <= s_refclk_B_0(0);

--============================================================================

  gen_clock_network : for n in 0 to C_NUM_OF_GTH_GTs-1 generate
    gen_gth_txusrclk_async : if c_gth_config_arr(n).tx_config.enable = true and
                                c_gth_config_arr(n).tx_config.clk_source = gth_clk_self and
                                c_gth_config_arr(n).txclk_master = C_GTH_TXCLK_ASYNC_MASTER generate
      
      gen_if_link_4: if n >= 8 generate
      
      gth_tx_clk_div_i : gth_tx_clk_div
      port map
      (
          clk_out1                        =>      s_gth_txusrclk(n),
          clk_in1                         =>      gth_gt_clk_out_arr_i(n).txoutclk,
          locked                          =>      open,
          reset                           =>      '0'
      );
      
      else generate
      
      i_bufg_tx_outclk : BUFG
      port map (
        I => gth_gt_clk_out_arr_i(n).txoutclk,
        O => s_gth_txusrclk(n)
      );
      
      end generate gen_if_link_4;
      
      gen_gth_loop_slaves : for k in 0 to C_NUM_OF_GTH_GTs-1 generate
        gen_gth_assing_txusrclk : if c_gth_config_arr(k).tx_config.enable = true and
                                     c_gth_config_arr(k).tx_config.link_rate  = c_gth_config_arr(n).tx_config.link_rate and
                                     c_gth_config_arr(k).tx_config.data_width = c_gth_config_arr(n).tx_config.data_width and
                                     c_gth_config_arr(k).tx_config.clk_source = gth_clk_self generate
          clk_gth_tx_usrclk_arr_o(k) <= s_gth_txusrclk(n);
        end generate gen_gth_assing_txusrclk;
        
        gen_gth_assing_rxusrclk : if c_gth_config_arr(k).rx_config.enable = true and
                                     c_gth_config_arr(k).rx_config.link_rate  = c_gth_config_arr(n).tx_config.link_rate and
                                     c_gth_config_arr(k).rx_config.data_width = c_gth_config_arr(n).tx_config.data_width and
                                     c_gth_config_arr(k).rx_config.clk_source = gth_clk_self and
                                     c_gth_config_arr(k).rx_config.buffer_enabled = true generate
          clk_gth_rx_usrclk_arr_o(k) <= s_gth_txusrclk(n);
        end generate gen_gth_assing_rxusrclk;
      end generate gen_gth_loop_slaves;
    end generate gen_gth_txusrclk_async;
    
    gen_gth_txusrclk_sync120 : if c_gth_config_arr(n).tx_config.enable = true and
                                  c_gth_config_arr(n).tx_config.clk_source = gth_clk_ttc_120 generate
      clk_gth_tx_usrclk_arr_o(n) <= clk_ttc_120_i;
    end generate;
    
    gen_gth_txusrclk_sync240 : if c_gth_config_arr(n).tx_config.enable = true and
                                  c_gth_config_arr(n).tx_config.clk_source = gth_clk_ttc_240 generate
      clk_gth_tx_usrclk_arr_o(n) <= clk_ttc_240_i;
    end generate;
    
    gen_gth_rxusrclk_nobuf : if c_gth_config_arr(n).rx_config.enable = true and
                                c_gth_config_arr(n).rx_config.buffer_enabled = false generate
      i_bufh_rx_outclk : BUFH
      port map (
        I => gth_gt_clk_out_arr_i(n).rxoutclk,
        O => clk_gth_rx_usrclk_arr_o(n)
      );
    end generate gen_gth_rxusrclk_nobuf;
    
    gen_gth_rxusrclk_sync120 : if c_gth_config_arr(n).rx_config.enable = true and
                                  c_gth_config_arr(n).rx_config.buffer_enabled = true and
                                  c_gth_config_arr(n).rx_config.clk_source = gth_clk_ttc_120 generate
      clk_gth_rx_usrclk_arr_o(n) <= clk_ttc_120_i;
    end generate gen_gth_rxusrclk_sync120;
    
    gen_gth_rxusrclk_sync240 : if c_gth_config_arr(n).rx_config.enable = true and
                                  c_gth_config_arr(n).rx_config.buffer_enabled = true and
                                  c_gth_config_arr(n).rx_config.clk_source = gth_clk_ttc_240 generate
      clk_gth_rx_usrclk_arr_o(n) <= clk_ttc_240_i;
    end generate gen_gth_rxusrclk_sync240;
    
  end generate gen_clock_network;

end gth_clk_bufs_arch;
--============================================================================
--                                                            Architecture end
--============================================================================
