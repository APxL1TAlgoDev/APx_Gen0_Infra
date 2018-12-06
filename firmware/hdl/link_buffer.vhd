
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.link_align_pkg.all;
use work.ctp7_utils_pkg.all;
use work.link_buffer_pkg.all;
use work.ttc_pkg.all;

--============================================================================
--                                                          Entity declaration
--============================================================================
entity link_buffer is
  port (
    clk_240_i : in std_logic;

    rst_i : in std_logic;
    
    link_realign_i : in std_logic;

    link_aligned_data_i : in t_link_aligned_data;
    link_aligned_data_o : out t_link_aligned_data;

    link_buffer_ctrl_i   : in  t_link_buffer_ctrl;
    link_buffer_status_o : out t_link_buffer_status;

    local_timing_ref_i :  in t_timing_ref;

    BRAM_CTRL_CAP_RAM_addr : in  std_logic_vector (11 downto 0);
    BRAM_CTRL_CAP_RAM_clk  : in  std_logic;
    BRAM_CTRL_CAP_RAM_din  : in  std_logic_vector (31 downto 0);
    BRAM_CTRL_CAP_RAM_dout : out std_logic_vector (31 downto 0);
    BRAM_CTRL_CAP_RAM_en   : in  std_logic;
    BRAM_CTRL_CAP_RAM_rst  : in  std_logic;
    BRAM_CTRL_CAP_RAM_we   : in  std_logic
    );
end link_buffer;

--============================================================================
--                                                        Architecture section
--============================================================================
architecture link_buffer_arch of link_buffer is

--============================================================================
--                                                           Type declarations
--============================================================================
  type t_capture_state_type is (
    idle_state,
    ready_state,
    capture_state,
    done_state
    );

--============================================================================
--                                                      Component declarations
--============================================================================
  component capture_ram is
    port (
      --Port A
      RSTA  : in  std_logic;            
      ENA   : in  std_logic;           
      WEA   : in  std_logic_vector(0 downto 0);
      ADDRA : in  std_logic_vector(9 downto 0);
      DINA  : in  std_logic_vector(31 downto 0);
      DOUTA : out std_logic_vector(31 downto 0);
      CLKA  : in  std_logic;
      --Port B
      ENB   : in  std_logic;            
      WEB   : in  std_logic_vector(0 downto 0);
      ADDRB : in  std_logic_vector(9 downto 0);
      DINB  : in  std_logic_vector(31 downto 0);
      DOUTB : out std_logic_vector(31 downto 0);
      CLKB  : in  std_logic
      );
  end component;

--============================================================================
--                                                         Signal declarations
--============================================================================

  signal s_cap_en_cs : t_capture_state_type := idle_state;
  signal s_cap_en_ns : t_capture_state_type := idle_state;

  signal s_rst_sync : std_logic;

  signal s_capture_cycle  : unsigned(9 downto 0);
  signal s_capture_ram_we : std_logic;

  signal s_capture_arm_RE : std_logic;

  signal s_capture_arm_sync : std_logic;
  signal s_cap_trigger      : std_logic;

  signal s_data_in_dX : std_logic_vector(31 downto 0);
  signal s_data_out : std_logic_vector(31 downto 0);
  signal s_data_out_dX : std_logic_vector(31 downto 0);

  signal s_capture_done              : std_logic;
  signal s_capture_fsm_state         : std_logic_vector(1 downto 0);
  signal s_capture_start_local_BX_id : std_logic_vector(11 downto 0);
  signal s_capture_start_link_BX_id  : std_logic_vector(11 downto 0);

  signal s_ram_we : std_logic;
      signal s_ram_addr : std_logic_vector(9 downto 0);
      
        signal s_playback_cycle  : unsigned(10 downto 0);

  signal s_local_timing_ref_d1 :   t_timing_ref;
  signal s_local_timing_ref_d2 :   t_timing_ref;
  signal s_local_timing_ref_d3 :   t_timing_ref;
  signal s_local_timing_ref_d4 :   t_timing_ref;

signal s_link_realign_sync : std_logic;


signal pb_data_valid : std_logic := '0';

--============================================================================
--                                                          Architecture begin
--============================================================================
begin


  process(clk_240_i) is
  begin
    if (rising_edge(clk_240_i)) then
       if (s_link_realign_sync = '1') then
           pb_data_valid <= '0';
       elsif (s_local_timing_ref_d2.bcid = x"000" and s_local_timing_ref_d2.sub_bcid = "000") then
                  pb_data_valid <= '1';
       end if;
    end if;
  end process;

  i_realign_sync : synchronizer
    generic map (
      N_STAGES => 2
      )
    port map(
      async_i => link_realign_i,
      clk_i   => clk_240_i,
      sync_o  => s_link_realign_sync
      );
      
  i_capture_arm_sync : synchronizer
    generic map (
      N_STAGES => 2
      )
    port map(
      async_i => link_buffer_ctrl_i.arm,
      clk_i   => clk_240_i,
      sync_o  => s_capture_arm_sync
      );

  i_capture_arm_edge : edge_detect
    port map(
      clk  => clk_240_i,
      sig  => s_capture_arm_sync,
      edge => s_capture_arm_RE
      );

  i_rst_sync : synchronizer
    generic map (
      N_STAGES => 2
      )
    port map(
      clk_i   => clk_240_i,
      async_i => rst_i,
      sync_o  => s_rst_sync
      );

  process(clk_240_i) is
  begin
    if (rising_edge(clk_240_i)) then

      if(link_aligned_data_i.sub_BX_id = "000") then

        if (link_buffer_ctrl_i.mode = "00" and link_aligned_data_i.BX_id = link_buffer_ctrl_i.start_bcid) then
          s_cap_trigger <= '1';
        elsif (link_buffer_ctrl_i.mode = "01" and local_timing_ref_i.bcid = link_buffer_ctrl_i.start_bcid) then
          s_cap_trigger <= '1';
        else
          s_cap_trigger <= '0';
        end if;
      end if;
    end if;
  end process;

  p_fsm_capture_current_state : process(clk_240_i) is
  begin
    if (rising_edge(clk_240_i)) then
      if (s_rst_sync = '1') then
        s_cap_en_cs <= idle_state;
      else
        s_cap_en_cs <= s_cap_en_ns;
      end if;
    end if;
  end process;

  p_fsm_capture_next_state : process(s_cap_en_cs, s_capture_arm_RE, s_capture_cycle,
                                     s_cap_trigger, s_cap_trigger) is
  begin

    s_cap_en_ns <= s_cap_en_cs;

    case s_cap_en_cs is

      when idle_state =>
        if (s_capture_arm_RE = '1') then
          s_cap_en_ns <= ready_state;
        end if;

      when ready_state =>
        if (s_cap_trigger = '1') then
          s_cap_en_ns <= capture_state;
        end if;

      when capture_state =>
        if (s_capture_cycle = 1023) then
          s_cap_en_ns <= done_state;
        end if;

      when done_state =>
        if (s_capture_arm_RE = '1') then
          s_cap_en_ns <= ready_state;
        end if;

      when others =>
        s_cap_en_ns <= idle_state;

    end case;
  end process;



  link_buffer_status_o.capture_started_at_local_bx_id <= s_capture_start_local_BX_id;
  link_buffer_status_o.capture_started_at_link_bx_id  <= s_capture_start_link_BX_id;
  link_buffer_status_o.fsm_state                      <= s_capture_fsm_state;
  link_buffer_status_o.done                           <= s_capture_done;

--p_fsm_capture_outputs: process(s_cap_en_cs,s_cap_trigger) is
  p_fsm_capture_outputs : process(clk_240_i) is
  begin

    if rising_edge(clk_240_i) then
      s_capture_cycle  <= (others => '0');
      s_capture_ram_we <= '0';
      s_capture_done   <= '0';

      s_capture_start_local_BX_id <= s_capture_start_local_BX_id;
      s_capture_start_link_BX_id  <= s_capture_start_link_BX_id;

      case s_cap_en_cs is

        when idle_state =>
          s_capture_fsm_state <= "00";

        when ready_state =>
          s_capture_fsm_state <= "01";
          if (s_cap_trigger = '1') then
            s_capture_ram_we            <= '1';
            s_capture_start_local_BX_id <= local_timing_ref_i.bcid;
            s_capture_start_link_BX_id  <= link_aligned_data_i.BX_id;
          else
            s_capture_start_local_BX_id <= x"FFF";
            s_capture_start_link_BX_id  <= x"FFF";
          end if;

        when capture_state =>
          s_capture_fsm_state <= "10";
          s_capture_ram_we    <= '1';
          s_capture_cycle     <= s_capture_cycle + 1;
          if (s_capture_cycle = 1023) then
            s_capture_ram_we <= '0';
          end if;

        when done_state =>
          s_capture_fsm_state <= "11";
          s_capture_done      <= '1';

        when others =>
          s_capture_fsm_state <= "00";

      end case;
    end if;
  end process;


  i_rx_data_delay_line : delay_line
    generic map (
      G_DELAY      => 3,
      G_DATA_WIDTH => 32,
      G_SRL_STYLE  => "register"
      )
    port map (
      clk      => clk_240_i,
      data_in  => link_aligned_data_i.data,
      data_out => s_data_in_dX
      );

  process(clk_240_i) is
  begin
    if (rising_edge(clk_240_i)) then

      if(local_timing_ref_i.bcid = x"000" and local_timing_ref_i.sub_bcid = "000") then
           s_playback_cycle <= (others => '0');
      elsif (s_playback_cycle > 1023 ) then
           s_playback_cycle <= "10000000000";
      else
         s_playback_cycle <= s_playback_cycle + 1; 
      end if;
  end if;
end process;

  p_link_buffer_ram_ctrl : process(clk_240_i) is
      begin
        if rising_edge(clk_240_i) then
            if (link_buffer_ctrl_i.CAP_nPB = '1') then
               s_ram_we <= s_capture_ram_we;
               s_ram_addr <= std_logic_vector(s_capture_cycle);
            else
                s_ram_we <= '0';
                s_ram_addr <= std_logic_vector(s_playback_cycle(9 downto 0));
            end if;
        end if;
   end process;
   
 

   
  i_capture_ram : capture_ram
    port map (
      --Port A
      RSTA   => BRAM_CTRL_CAP_RAM_rst,
      ENA    => BRAM_CTRL_CAP_RAM_en,
      WEA(0) => BRAM_CTRL_CAP_RAM_we,
      ADDRA  => BRAM_CTRL_CAP_RAM_addr(11 downto 2),
      DINA   => BRAM_CTRL_CAP_RAM_din,
      DOUTA  => BRAM_CTRL_CAP_RAM_dout,
      CLKA   => BRAM_CTRL_CAP_RAM_clk,
      --Port B
      ENB    => '1',
      WEB(0) => s_ram_we,
      ADDRB  => s_ram_addr,
      DINB   => s_data_in_dX,
      DOUTB  => s_data_out,
      CLKB   => clk_240_i
      );


      
  p_link_align_output_switch : process(clk_240_i) is
      begin
        if rising_edge(clk_240_i) then
        s_local_timing_ref_d1 <= local_timing_ref_i;
        s_local_timing_ref_d2 <= s_local_timing_ref_d1;
        s_local_timing_ref_d3 <= s_local_timing_ref_d2;
        s_local_timing_ref_d4 <= s_local_timing_ref_d3;

            if (link_buffer_ctrl_i.CAP_nPB = '1') then
                 link_aligned_data_o <= link_aligned_data_i;
            else
                if (s_playback_cycle < 1025) then
                    link_aligned_data_o.data <= s_data_out;
                else
                    link_aligned_data_o.data <= x"00000000";
                end if;
                
                link_aligned_data_o.kchar0 <= '0';
                link_aligned_data_o.data_valid <= pb_data_valid;
                link_aligned_data_o.rxnotintable <= '0';
                link_aligned_data_o.rxdisperr <= '0';
                link_aligned_data_o.BX_id <= s_local_timing_ref_d3.bcid;
                link_aligned_data_o.sub_BX_id <= s_local_timing_ref_d3.sub_bcid;

            end if;    
        end if;
   end process;

end link_buffer_arch;
--============================================================================
--                                                            Architecture end
--============================================================================

