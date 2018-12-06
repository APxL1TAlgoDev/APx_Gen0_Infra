-------------------------------------------------------------------------------
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
entity link_align_ctrl is
  generic (
    G_NUM_OF_LINKs : integer := 36
    );
  port (
    clk_240_i        : in std_logic;
    link_align_req_i : in std_logic;
    bx0_at_240_i     : in std_logic;

    link_align_o     : out std_logic;
    link_fifo_read_o : out std_logic;

    link_latency_ctrl_i : in  std_logic_vector(15 downto 0);
    link_latency_err_o  : out std_logic;

    link_mask_ctrl_i : in std_logic_vector(G_NUM_OF_LINKs-1 downto 0);

    link_aligned_status_arr_i      : in  t_link_aligned_status_arr(G_NUM_OF_LINKs-1 downto 0);
    link_aligned_diagnostics_arr_o : out t_link_aligned_diagnostics_arr(G_NUM_OF_LINKs-1 downto 0)


    );
end link_align_ctrl;

--============================================================================
--                                                        Architecture section
--============================================================================
architecture link_align_ctrl_arch of link_align_ctrl is

--============================================================================
--                                                           Type declarations
--============================================================================
  type t_align_fsm_state is
    (
      st_alignment_pending,
      st_reset_link_alignment,
      st_wait_for_links,
      st_wait_for_latency_control,
      st_links_aligned,
      st_links_align_err
      );

--============================================================================
--                                                         Signal declarations
--============================================================================
  signal s_link_ready                 : std_logic_vector(G_NUM_OF_LINKs-1 downto 0);
  signal s_link_aligned_fifo_empty_dX : std_logic_vector(G_NUM_OF_LINKs-1 downto 0);

  signal s_link_master_ready : std_logic;

  signal s_link_align_req_sync : std_logic;
  signal s_link_align_req_re   : std_logic;

  signal s_align_fsm_cs : t_align_fsm_state := st_alignment_pending;
  signal s_align_fsm_ns : t_align_fsm_state := st_alignment_pending;

  signal s_link_fifo_read : std_logic;
  signal s_link_align     : std_logic;

  signal s_link_latency_countdown_cnt     : unsigned(15 downto 0);
  signal s_link_latency_countdown_reached : std_logic;
  signal s_link_latency_countdown_rst     : std_logic;
  signal s_link_latency_countdown_inc     : std_logic;

  signal s_ctp7_bx_id_at_240 : unsigned(15 downto 0);

  signal s_link_aligned_diagnostics_arr       : t_link_aligned_diagnostics_arr(G_NUM_OF_LINKs-1 downto 0);
  signal s_link_bc0_sync_at_240 : std_logic_vector(G_NUM_OF_LINKs-1 downto 0);
  signal s_link_bc0_edge_at_240 : std_logic_vector(G_NUM_OF_LINKs-1 downto 0);


--============================================================================
--                                                          Architecture begin
--============================================================================
begin

  process(clk_240_i) is
  begin
    if rising_edge(clk_240_i) then
      if (bx0_at_240_i = '1') then

        s_ctp7_bx_id_at_240 <= x"0000";
      else
        s_ctp7_bx_id_at_240 <= s_ctp7_bx_id_at_240 + 1;

      end if;

    end if;
  end process;

  i_link_align_req_sync : synchronizer
    generic map (
      N_STAGES => 2
      )
    port map(
      async_i => link_align_req_i,
      clk_i   => clk_240_i,
      sync_o  => s_link_align_req_sync
      );

  i_align_req_edge : edge_detect
    generic map (
      EDGE_DETECT_TYPE => "RISE"
      )
    port map(
      clk  => clk_240_i,
      sig  => s_link_align_req_sync,
      edge => s_link_align_req_re
      );

------

  process(clk_240_i) is
  begin
    if rising_edge(clk_240_i) then
      if (s_link_align_req_sync = '1') then
        s_align_fsm_cs <= st_alignment_pending;
      else
        s_align_fsm_cs <= s_align_fsm_ns;
      end if;
    end if;
  end process;


  p_fsm_next_state : process(s_align_fsm_cs,
                             bx0_at_240_i,
                             s_link_master_ready,
                             s_link_latency_countdown_reached
                             ) is
  begin

    s_align_fsm_ns <= s_align_fsm_cs;

    case s_align_fsm_cs is

      when st_alignment_pending =>
        if (bx0_at_240_i = '1') then
          s_align_fsm_ns <= st_reset_link_alignment;
        end if;

      when st_reset_link_alignment =>
        if (bx0_at_240_i = '1') then
          s_align_fsm_ns <= st_wait_for_links;
        end if;

      when st_wait_for_links =>
        if (s_link_master_ready = '1') then
          s_align_fsm_ns <= st_wait_for_latency_control;
        elsif (s_link_latency_countdown_reached = '1') then
          s_align_fsm_ns <= st_links_align_err;
        end if;

      when st_wait_for_latency_control =>
        if (s_link_latency_countdown_reached = '1') then
          s_align_fsm_ns <= st_links_aligned;
        end if;

      when st_links_aligned =>
        null;

      when st_links_align_err =>
        null;

      when others =>
        null;

    end case;

  end process;


  process(clk_240_i) is
  begin
    if rising_edge(clk_240_i) then

      if (s_link_latency_countdown_rst = '1') then
        s_link_latency_countdown_cnt     <= (others => '0');
        s_link_latency_countdown_reached <= '0';
      elsif (s_link_latency_countdown_inc = '1') then
        s_link_latency_countdown_cnt <= s_link_latency_countdown_cnt + 1;
        if (s_link_latency_countdown_cnt > unsigned(link_latency_ctrl_i)) then
          s_link_latency_countdown_reached <= '1';
          s_link_latency_countdown_cnt     <= unsigned(link_latency_ctrl_i);
        end if;
      end if;

    end if;

  end process;


  process(clk_240_i) is
  begin
    if rising_edge(clk_240_i) then

      s_link_fifo_read   <= '0';
      s_link_align       <= '0';
      link_latency_err_o <= '0';

      s_link_latency_countdown_rst <= '0';
      s_link_latency_countdown_inc <= '0';

      case s_align_fsm_cs is

        when st_alignment_pending =>
          s_link_align <= '1';

        when st_reset_link_alignment =>
          s_link_align                 <= '1';
          s_link_latency_countdown_rst <= '1';

        when st_wait_for_links =>
          s_link_latency_countdown_inc <= '1';

        when st_wait_for_latency_control =>
          s_link_latency_countdown_inc <= '1';

        when st_links_aligned =>
          s_link_fifo_read <= '1';

        when st_links_align_err =>
          link_latency_err_o <= '1';

        when others =>

      end case;

    end if;
  end process;
----


  gen_link_ready : for i in 0 to G_NUM_OF_LINKs-1 generate

    i_fifo_empty_delay_line : delay_line
      generic map (
        G_DELAY      => 2,
        G_DATA_WIDTH => 1,
        G_SRL_STYLE  => "register"
        )
      port map (
        clk         => clk_240_i,
        data_in(0)  => link_aligned_status_arr_i(i).fifo_empty,
        data_out(0) => s_link_aligned_fifo_empty_dX(i)
        );

    s_link_ready(i) <= (link_mask_ctrl_i(i) or (not s_link_aligned_fifo_empty_dX(i))) when rising_edge(clk_240_i);
  end generate;

  s_link_master_ready <= and_reduce(s_link_ready) when rising_edge(clk_240_i);

  i_link_fifo_read_delay_line : delay_line
    generic map (
      G_DELAY      => 2,
      G_DATA_WIDTH => 1,
      G_SRL_STYLE  => "register"
      )
    port map (
      clk         => clk_240_i,
      data_in(0)  => s_link_fifo_read,
      data_out(0) => link_fifo_read_o
      );

  i_link_align_delay_line : delay_line
    generic map (
      G_DELAY      => 2,
      G_DATA_WIDTH => 1,
      G_SRL_STYLE  => "register"
      )
    port map (
      clk         => clk_240_i,
      data_in(0)  => s_link_align,
      data_out(0) => link_align_o
      );

  link_aligned_diagnostics_arr_o <= s_link_aligned_diagnostics_arr;

  gen_link_diagnostics : for i in 0 to G_NUM_OF_LINKs-1 generate

    i_link_bc0_marker_found_sync : synchronizer
      generic map (
        N_STAGES => 2
        )
      port map(
        async_i => link_aligned_status_arr_i(i).link_bc0_marker,
        clk_i   => clk_240_i,
        sync_o  => s_link_bc0_sync_at_240(i)
        );

    i_link_bc0_marker_found_edge : edge_detect
      generic map (
        EDGE_DETECT_TYPE => "RISE"
        )
      port map(
        clk  => clk_240_i,
        sig  => s_link_bc0_sync_at_240(i),
        edge => s_link_bc0_edge_at_240(i)
        );

    process(clk_240_i) is
    begin
      if rising_edge(clk_240_i) then
        if (s_link_align = '1') then

          s_link_aligned_diagnostics_arr(i).bx_id_at_marker <= x"FFFF";
        elsif(s_link_bc0_edge_at_240(i) = '1') then
          s_link_aligned_diagnostics_arr(i).bx_id_at_marker <= std_logic_vector(s_ctp7_bx_id_at_240);
        end if;

      end if;
    end process;

    process(clk_240_i) is
    begin
      if rising_edge(clk_240_i) then

        if (s_link_align = '1') then
          s_link_aligned_diagnostics_arr(i).fifo_error <= '0';
        elsif(link_aligned_status_arr_i(i).fifo_undrf = '1' or
              link_aligned_status_arr_i(i).fifo_ovrf = '1') then
          s_link_aligned_diagnostics_arr(i).fifo_error <= '1';
        end if;

      end if;
    end process;

    s_link_aligned_diagnostics_arr(i).alignment_marker_found <= link_aligned_status_arr_i(i).alignment_marker_found;
    s_link_aligned_diagnostics_arr(i).fifo_not_empty         <= not link_aligned_status_arr_i(i).fifo_empty;

  end generate;

end link_align_ctrl_arch;
--============================================================================
--                                                            Architecture end
--============================================================================
