
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.std_logic_misc.all;

library work;
use work.ctp7_utils_pkg.all;
use work.gth_pkg.all;
use work.link_align_pkg.all;

--============================================================================
--                                                          Entity declaration
--============================================================================
entity rx_depad_cdc_align is
  port (
    clk_250_i : in std_logic;
    clk_240_i : in std_logic;

    gth_rx_data_i : in t_gth_rx_data;

    link_8b10b_err_rst_i : in std_logic;

    realign_i             : in  std_logic;
    start_fifo_read_i     : in  std_logic;
    link_aligned_data_o   : out t_link_aligned_data;
    link_aligned_status_o : out t_link_aligned_status

    );
end rx_depad_cdc_align;

--============================================================================
--                                                        Architecture section
--============================================================================
architecture rx_depad_cdc_align_arch of rx_depad_cdc_align is

--============================================================================
--                                                           Type declarations
--============================================================================
  type t_align_fsm_state is
    (
      st_reset,
      st_wait_for_link_bc0,
      st_idle
      );

--============================================================================
--                                                      Component declarations
--============================================================================
  component rx_cdc_alignment_fifo
    port (
      rst       : in  std_logic;
      wr_clk    : in  std_logic;
      rd_clk    : in  std_logic;
      din       : in  std_logic_vector(34 downto 0);
      wr_en     : in  std_logic;
      rd_en     : in  std_logic;
      dout      : out std_logic_vector(34 downto 0);
      full      : out std_logic;
      overflow  : out std_logic;
      empty     : out std_logic;
      underflow : out std_logic
      );
  end component rx_cdc_alignment_fifo;

--============================================================================
--                                                         Signal declarations
--============================================================================
  signal s_data_fifo_in    : std_logic_vector(34 downto 0);
  signal s_data_fifo_in_dX : std_logic_vector(34 downto 0);
  signal s_data_fifo_out   : std_logic_vector(34 downto 0);

  signal s_kchar_d1 : std_logic_vector(3 downto 0);

  signal s_data_valid    : std_logic;
  signal s_data_valid_d1 : std_logic;

  signal s_cdc_align_fifo_write : std_logic;

  signal s_realign_sync_at_clk_250 : std_logic;

  signal s_link_BX_id     : unsigned(11 downto 0);
  signal s_link_sub_BX_id : unsigned(2 downto 0);

  signal s_align_fsm_cs : t_align_fsm_state;
  signal s_align_fsm_ns : t_align_fsm_state;

  signal s_alignment_marker_found : std_logic;

  signal s_rxdata_byte0_d1 : std_logic_vector(7 downto 0);

  signal s_cdc_fifo_rst_d1 : std_logic;
  signal s_cdc_fifo_rst_d2 : std_logic;

  signal s_link_bc0_marker : std_logic;

  signal s_rx_not_in_table_aggr : std_logic;
  signal s_rx_disp_err_aggr     : std_logic;
  signal s_rx_link_err_aggr     : std_logic;

  signal s_rx_link_ok_extended : std_logic;
  signal s_rx_link_err_latched : std_logic;

  signal s_rxlinkerr_down_cnt : unsigned(7 downto 0) := (others => '1');

  signal s_link_bc0 : std_logic;

  signal s_link_8b10b_err_cnt : std_logic_vector(31 downto 0);

--============================================================================
--                                                          Architecture begin
--============================================================================
begin

  s_rx_not_in_table_aggr <= or_reduce(gth_rx_data_i.rxnotintable);
  s_rx_disp_err_aggr     <= or_reduce(gth_rx_data_i.rxdisperr);

  s_rx_link_err_aggr <= s_rx_not_in_table_aggr or s_rx_disp_err_aggr when rising_edge(clk_250_i);

--  process (clk_250_i)
--  begin
--    if(rising_edge(clk_250_i)) then
--      if (link_8b10b_err_rst_i = '1') then
--        s_link_8b10b_err_cnt <= (others => '0');
--      elsif (s_rx_link_err_aggr = '1' and s_link_8b10b_err_cnt /= x"FFFFFFFF") then
--        s_link_8b10b_err_cnt <= std_logic_vector(unsigned(s_link_8b10b_err_cnt) + 1);
--      end if;
--    end if;
--  end process;

  process(clk_250_i) is
  begin
    if rising_edge(clk_250_i) then
      if (s_rx_link_err_aggr = '1') then
        s_rxlinkerr_down_cnt  <= x"FF";
        s_rx_link_ok_extended <= '0';
      elsif (s_rxlinkerr_down_cnt = x"00") then
        s_rxlinkerr_down_cnt  <= x"00";
        s_rx_link_ok_extended <= '1';
      else
        s_rxlinkerr_down_cnt  <= s_rxlinkerr_down_cnt - 1;
        s_rx_link_ok_extended <= '0';
      end if;
    end if;
  end process;

  process(clk_250_i) is
  begin
    if rising_edge(clk_250_i) then
      if (s_realign_sync_at_clk_250 = '1') then
        s_rx_link_err_latched <= '0';
      elsif (s_rx_link_err_aggr = '1') then
        s_rx_link_err_latched <= '1';
      end if;
    end if;
  end process;

  s_link_bc0 <= '1' when s_rxdata_byte0_d1 = x"BC" and s_kchar_d1(0) = '1' and s_rx_link_ok_extended = '1' else '0';

  s_data_fifo_in(31 downto 0) <= gth_rx_data_i.rxdata(31 downto 0);
  s_data_fifo_in(32)          <= gth_rx_data_i.rxcharisk(0);
  s_data_fifo_in(33)          <= s_rx_not_in_table_aggr;
  s_data_fifo_in(34)          <= s_rx_disp_err_aggr;

  s_rxdata_byte0_d1 <= gth_rx_data_i.rxdata(7 downto 0) when rising_edge(clk_250_i);
  s_kchar_d1        <= gth_rx_data_i.rxcharisk          when rising_edge(clk_250_i);


  i_rx_data_delay_line : delay_line
    generic map (
      G_DELAY      => 4,
      G_DATA_WIDTH => s_data_fifo_in'length,
      G_SRL_STYLE  => "reg_srl_reg"
      )
    port map (
      clk      => clk_250_i,
      data_in  => s_data_fifo_in,
      data_out => s_data_fifo_in_dX
      );

  i_realign_sync_at_clk_250 : synchronizer
    generic map (
      N_STAGES => 2
      )
    port map(
      async_i => realign_i,
      clk_i   => clk_250_i,
      sync_o  => s_realign_sync_at_clk_250
      );

  process(clk_250_i) is
  begin
    if rising_edge(clk_250_i) then

      if (s_kchar_d1 = x"F") then
        s_data_valid <= '0';
      else
        s_data_valid <= '1';
      end if;

      s_data_valid_d1 <= s_data_valid;

    end if;
  end process;

  process(clk_250_i) is
  begin
    if rising_edge(clk_250_i) then
      if (s_realign_sync_at_clk_250 = '1') then
        s_align_fsm_cs <= st_reset;
      else
        s_align_fsm_cs <= s_align_fsm_ns;
      end if;
    end if;
  end process;


  p_fsm_next_state : process(s_align_fsm_cs, s_link_bc0) is
  begin

    s_align_fsm_ns <= s_align_fsm_cs;

    case s_align_fsm_cs is

      when st_reset =>
        s_align_fsm_ns <= st_wait_for_link_bc0;

      when st_wait_for_link_bc0 =>
        if (s_link_bc0 = '1') then
          s_align_fsm_ns <= st_idle;
        end if;

      when st_idle =>
        null;

      when others =>
        s_align_fsm_ns <= st_reset;

    end case;

  end process;

  process(clk_250_i) is
  begin
    if rising_edge(clk_250_i) then
      if (s_link_bc0 = '1') then
        s_link_bc0_marker <= '1';
      else
        s_link_bc0_marker <= '0';
      end if;
    end if;
  end process;

  process(clk_250_i) is
  begin
    if rising_edge(clk_250_i) then

      s_alignment_marker_found <= '0';

      case s_align_fsm_cs is

        when st_reset =>
          null;
        when st_wait_for_link_bc0 =>
          null;
        when st_idle =>
          s_alignment_marker_found <= '1';
        when others =>
          null;
      end case;

    end if;
  end process;

  process(clk_250_i) is
  begin
    if rising_edge(clk_250_i) then

      if (realign_i = '1') then
        s_cdc_align_fifo_write <= '0';
      elsif (s_alignment_marker_found = '1' and s_data_valid_d1 = '1') then
        s_cdc_align_fifo_write <= '1';
      else
        s_cdc_align_fifo_write <= '0';
      end if;

    end if;
  end process;

  s_cdc_fifo_rst_d1 <= realign_i         when rising_edge(clk_250_i);
  s_cdc_fifo_rst_d2 <= s_cdc_fifo_rst_d1 when rising_edge(clk_250_i);

  i_rx_cdc_alignment_fifo : rx_cdc_alignment_fifo
    port map (
      wr_clk    => clk_250_i,
      rd_clk    => clk_240_i,
      rst       => s_cdc_fifo_rst_d2,
      wr_en     => s_cdc_align_fifo_write,
      rd_en     => start_fifo_read_i,
      din       => s_data_fifo_in_dX,
      dout      => s_data_fifo_out,
      full      => link_aligned_status_o.fifo_full,
      overflow  => link_aligned_status_o.fifo_ovrf,
      empty     => link_aligned_status_o.fifo_empty,
      underflow => link_aligned_status_o.fifo_undrf
      );

  process(clk_240_i)
  begin
    if rising_edge(clk_240_i) then

      if (realign_i = '1') then
        s_link_BX_id     <= to_unsigned(0, s_link_BX_id'length);
        s_link_sub_BX_id <= to_unsigned(0, s_link_sub_BX_id'length);
      elsif (start_fifo_read_i = '1') then
        s_link_sub_BX_id <= s_link_sub_BX_id + 1;
        if (s_link_sub_BX_id = 5) then
          s_link_sub_BX_id <= to_unsigned(0, s_link_sub_BX_id'length);
          if (s_link_BX_id = 3563) then
            s_link_BX_id <= to_unsigned(0, s_link_BX_id'length);
          else
            s_link_BX_id <= s_link_BX_id + 1;
          end if;
        end if;
      end if;

    end if;
  end process;

  link_aligned_data_o.data         <= s_data_fifo_out(31 downto 0);
  link_aligned_data_o.kchar0       <= s_data_fifo_out(32);
  link_aligned_data_o.rxnotintable <= s_data_fifo_out(33);
  link_aligned_data_o.rxdisperr    <= s_data_fifo_out(34);
  link_aligned_data_o.BX_id        <= std_logic_vector(s_link_BX_id);
  link_aligned_data_o.sub_BX_id    <= std_logic_vector(s_link_sub_BX_id);
  link_aligned_data_o.data_valid   <= start_fifo_read_i;

  link_aligned_status_o.alignment_marker_found <= s_alignment_marker_found;
  link_aligned_status_o.link_bc0_marker        <= s_link_bc0_marker;
  link_aligned_status_o.link_OK_extended       <= s_rx_link_ok_extended;
  link_aligned_status_o.link_ERR_latched       <= s_rx_link_err_latched;
  link_aligned_status_o.link_8b10b_err_cnt     <= s_link_8b10b_err_cnt;

end rx_depad_cdc_align_arch;

--============================================================================
--                                                            Architecture end
--============================================================================

