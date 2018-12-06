library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.gth_pkg.all;

--============================================================================
--                                                          Entity declaration
--============================================================================
entity drp_controller is
  port (

    BRAM_CTRL_DRP_en   : in  std_logic;
    BRAM_CTRL_DRP_dout : out std_logic_vector (31 downto 0);
    BRAM_CTRL_DRP_din  : in  std_logic_vector (31 downto 0);
    BRAM_CTRL_DRP_we   : in  std_logic_vector (3 downto 0);
    BRAM_CTRL_DRP_addr : in  std_logic_vector (15 downto 0);
    BRAM_CTRL_DRP_clk  : in  std_logic;
    BRAM_CTRL_DRP_rst  : in  std_logic;

    gth_common_drp_arr_o : out t_gth_common_drp_in_arr(15 downto 0);
    gth_common_drp_arr_i : in  t_gth_common_drp_out_arr(15 downto 0);

    gth_gt_drp_arr_o : out t_gth_gt_drp_in_arr(63 downto 0);
    gth_gt_drp_arr_i : in  t_gth_gt_drp_out_arr(63 downto 0)
    );
end drp_controller;

--============================================================================
--                                                        Architecture section
--============================================================================
architecture drp_controller_arch of drp_controller is

--============================================================================
--                                                           Functions section
--============================================================================
  function CE_decode(CE_bit, CE_width : integer) return std_logic_vector is
    variable v_tmp : std_logic_vector(CE_width-1 downto 0);
  begin
    v_tmp         := (others => '0');
    v_tmp(CE_bit) := '1';
    return v_tmp;
  end function CE_decode;

--============================================================================
--                                                           Type declarations
--============================================================================
  type t_drp_data is array(integer range <>) of std_logic_vector(15 downto 0);
  type t_gth_ch_drp_enable_reg is array(integer range <>) of std_logic;

--============================================================================
--                                                         Signal declarations
--============================================================================
  signal s_BRAM_CTRL_DRP_din_d1  : std_logic_vector (15 downto 0);
  signal s_BRAM_CTRL_DRP_we_d1   : std_logic;
  signal s_BRAM_CTRL_DRP_addr_d1 : std_logic_vector (15 downto 0);


  signal s_gth_ch_mem_space_hit  : std_logic;
  signal s_gth_ch_drp_enable     : std_logic_vector(63 downto 0);
  signal s_gth_ch_drp_data_reply : t_drp_data(63 downto 0);

  signal s_gth_common_mem_space_hit  : std_logic;
  signal s_gth_common_drp_enable     : std_logic_vector(15 downto 0);
  signal s_gth_common_drp_data_reply : t_drp_data(15 downto 0);

  signal s_gth_ch_drp_slave_select     : std_logic_vector (7 downto 0);
  signal s_gth_common_drp_slave_select : std_logic_vector (7 downto 0);


--============================================================================
--                                                          Architecture begin
--============================================================================  
begin

  gen_gth_ch_clk : for i in 0 to 63 generate
    gth_gt_drp_arr_o(i).DRPCLK <= BRAM_CTRL_DRP_clk;
  end generate;


  gen_gth_common_clk : for i in 0 to 15 generate
    gth_common_drp_arr_o(i).DRPCLK <= BRAM_CTRL_DRP_clk;
  end generate;

  process (BRAM_CTRL_DRP_clk)
  begin
    if(rising_edge(BRAM_CTRL_DRP_clk)) then

      s_BRAM_CTRL_DRP_din_d1  <= BRAM_CTRL_DRP_din(15 downto 0);
      s_BRAM_CTRL_DRP_addr_d1 <= BRAM_CTRL_DRP_addr;

      if (BRAM_CTRL_DRP_we = "1111") then
        s_BRAM_CTRL_DRP_we_d1 <= '1';
      else
        s_BRAM_CTRL_DRP_we_d1 <= '0';
      end if;

    end if;
  end process;

  process (BRAM_CTRL_DRP_clk)
  begin
    if(rising_edge(BRAM_CTRL_DRP_clk)) then

      loop_gth_drp_assign : for i in 0 to 63 loop
        gth_gt_drp_arr_o(i).DRPADDR <= s_BRAM_CTRL_DRP_addr_d1(10 downto 2);
        gth_gt_drp_arr_o(i).DRPDI   <= s_BRAM_CTRL_DRP_din_d1;
        gth_gt_drp_arr_o(i).DRPWE   <= s_BRAM_CTRL_DRP_we_d1;
        gth_gt_drp_arr_o(i).DRPEN   <= s_gth_ch_mem_space_hit and s_gth_ch_drp_enable(i);
      end loop;

      loop_gth_common_assign : for i in 0 to 15 loop
        gth_common_drp_arr_o(i).DRPADDR <= s_BRAM_CTRL_DRP_addr_d1(9 downto 2);
        gth_common_drp_arr_o(i).DRPDI   <= s_BRAM_CTRL_DRP_din_d1;
        gth_common_drp_arr_o(i).DRPWE   <= s_BRAM_CTRL_DRP_we_d1;
        gth_common_drp_arr_o(i).DRPEN   <= s_gth_common_mem_space_hit and s_gth_common_drp_enable(i);
      end loop;

    end if;
  end process;


  process (BRAM_CTRL_DRP_clk)
  begin
    if(rising_edge(BRAM_CTRL_DRP_clk)) then
      if(BRAM_CTRL_DRP_en = '1') then

        if (unsigned(BRAM_CTRL_DRP_addr) < x"0800") then
          s_gth_ch_mem_space_hit <= '1';
        end if;

        if ((unsigned(BRAM_CTRL_DRP_addr) >= x"1000") and
            (unsigned(BRAM_CTRL_DRP_addr) < x"1800")) then
          s_gth_common_mem_space_hit <= '1';
        end if;
      else
        s_gth_ch_mem_space_hit     <= '0';
        s_gth_common_mem_space_hit <= '0';
      end if;

    end if;
  end process;

  process (BRAM_CTRL_DRP_clk)
  begin
    if(rising_edge(BRAM_CTRL_DRP_clk)) then

      loop_gth_ch_drpdo : for i in 0 to 63 loop
        if(gth_gt_drp_arr_i(i).DRPRDY = '1') then
          s_gth_ch_drp_data_reply(i) <= gth_gt_drp_arr_i(i).DRPDO;
        end if;
      end loop;

      loop_gth_common_drpdo : for i in 0 to 15 loop
        if(gth_common_drp_arr_i(i).DRPRDY = '1') then
          s_gth_common_drp_data_reply(i) <= gth_common_drp_arr_i(i).DRPDO;
        end if;
      end loop;

    end if;
  end process;


  process(BRAM_CTRL_DRP_clk)is
  begin
    if (rising_edge(BRAM_CTRL_DRP_clk)) then
      if (s_gth_ch_drp_slave_select = x"FF") then
        s_gth_ch_drp_enable <= (others => '1');
      else
        s_gth_ch_drp_enable <= CE_decode(to_integer(unsigned(s_gth_ch_drp_slave_select)), 64);
      end if;
    end if;
  end process;

  process(BRAM_CTRL_DRP_clk)is
  begin
    if (rising_edge(BRAM_CTRL_DRP_clk)) then
      if (s_gth_common_drp_slave_select = x"FF") then
        s_gth_common_drp_enable <= (others => '1');
      else
        s_gth_common_drp_enable <= CE_decode(to_integer(unsigned(s_gth_common_drp_slave_select)), 16);
      end if;
    end if;
  end process;

  process (BRAM_CTRL_DRP_clk)
  begin
    if(rising_edge(BRAM_CTRL_DRP_clk)) then
      if(BRAM_CTRL_DRP_en = '1' and BRAM_CTRL_DRP_we = "1111") then
        case (BRAM_CTRL_DRP_addr) is

--============================================================================
-- GTH Channel DRP Write Register Interface                                                  
--============================================================================  
          when x"0800" => s_gth_ch_drp_slave_select <= BRAM_CTRL_DRP_din(7 downto 0);

--============================================================================
-- GTH Common (QPLL) DRP Write Register Interface                                                  
--============================================================================   
          when x"1800" => s_gth_common_drp_slave_select <= BRAM_CTRL_DRP_din(7 downto 0);

          when others => null;
        end case;
      end if;

      case (BRAM_CTRL_DRP_addr) is

--============================================================================
-- GTH Channel DRP Read Register Interface                                                  
--============================================================================          
        when x"0800" => BRAM_CTRL_DRP_dout <= x"000000" & s_gth_ch_drp_slave_select;

        when x"0900" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(0);
        when x"0904" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(1);
        when x"0908" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(2);
        when x"090C" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(3);
        when x"0910" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(4);
        when x"0914" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(5);
        when x"0918" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(6);
        when x"091C" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(7);
        when x"0920" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(8);
        when x"0924" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(9);
        when x"0928" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(10);
        when x"092C" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(11);
        when x"0930" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(12);
        when x"0934" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(13);
        when x"0938" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(14);
        when x"093C" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(15);
        when x"0940" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(16);
        when x"0944" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(17);
        when x"0948" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(18);
        when x"094C" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(19);
        when x"0950" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(20);
        when x"0954" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(21);
        when x"0958" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(22);
        when x"095C" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(23);
        when x"0960" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(24);
        when x"0964" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(25);
        when x"0968" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(26);
        when x"096C" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(27);
        when x"0970" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(28);
        when x"0974" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(29);
        when x"0978" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(30);
        when x"097C" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(31);
        when x"0980" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(32);
        when x"0984" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(33);
        when x"0988" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(34);
        when x"098C" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(35);
        when x"0990" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(36);
        when x"0994" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(37);
        when x"0998" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(38);
        when x"099C" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(39);
        when x"09A0" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(40);
        when x"09A4" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(41);
        when x"09A8" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(42);
        when x"09AC" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(43);
        when x"09B0" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(44);
        when x"09B4" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(45);
        when x"09B8" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(46);
        when x"09BC" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(47);
        when x"09C0" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(48);
        when x"09C4" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(49);
        when x"09C8" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(50);
        when x"09CC" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(51);
        when x"09D0" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(52);
        when x"09D4" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(53);
        when x"09D8" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(54);
        when x"09DC" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(55);
        when x"09E0" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(56);
        when x"09E4" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(57);
        when x"09E8" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(58);
        when x"09EC" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(59);
        when x"09F0" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(60);
        when x"09F4" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(61);
        when x"09F8" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(62);
        when x"09FC" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_ch_drp_data_reply(63);

--============================================================================
-- GTH Common (QPLL) DRP Read Register Interface                                                  
--============================================================================   
        when x"1800" => BRAM_CTRL_DRP_dout <= x"000000" & s_gth_common_drp_slave_select;

        when x"1900" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_common_drp_data_reply(0);
        when x"1904" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_common_drp_data_reply(1);
        when x"1908" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_common_drp_data_reply(2);
        when x"190C" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_common_drp_data_reply(3);
        when x"1910" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_common_drp_data_reply(4);
        when x"1914" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_common_drp_data_reply(5);
        when x"1918" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_common_drp_data_reply(6);
        when x"191C" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_common_drp_data_reply(7);
        when x"1920" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_common_drp_data_reply(8);
        when x"1924" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_common_drp_data_reply(9);
        when x"1928" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_common_drp_data_reply(10);
        when x"192c" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_common_drp_data_reply(11);
        when x"1930" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_common_drp_data_reply(12);
        when x"1934" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_common_drp_data_reply(13);
        when x"1938" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_common_drp_data_reply(14);
        when x"193C" => BRAM_CTRL_DRP_dout <= x"0000" & s_gth_common_drp_data_reply(15);

        when others => BRAM_CTRL_DRP_dout <= x"00000000";
      end case;

    end if;
  end process;

end drp_controller_arch;
--============================================================================
--                                                            Architecture end
--============================================================================

