-- ttc_decoder
--
-- Takes the TTC bistream, outputs L1A and broadcast commands
-- Modified from Mr Wu's original by Dave, June 2013
--
-------------------------------------------------------------------------------
-- Company: EDF Boston University
-- Engineer: Shouxiang Wu
--
-- Create Date:    14:53:20 05/24/2010
-- Design Name:
-- Module Name:    TTC_decoder - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- TTC Hamming encoding
-- hmg[0] = d[0]^d[1]^d[2]^d[3];
-- hmg[1] = d[0]^d[4]^d[5]^d[6];
-- hmg[2] = d[1]^d[2]^d[4]^d[5]^d[7];
-- hmg[3] = d[1]^d[3]^d[4]^d[6]^d[7];
-- hmg[4] = d[0]^d[2]^d[3]^d[5]^d[6]^d[7];
--
-- As no detailed timing of TTCrx chip is available, L1A may need to add
-- several clocks of delay pending test results -- May 27 2010
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.std_logic_misc.all;

library UNISIM;
use UNISIM.VComponents.all;

entity ttc_decoder is
  port(
    ttc_clk   : in  std_logic;
    ttc_data  : in  std_logic_vector(1 downto 0);
    l1accept  : out std_logic;
    brcststr  : out std_logic;
    brcst     : out std_logic_vector(7 downto 0);
    sinerrstr : out std_logic;
    dberrstr  : out std_logic
    );

end ttc_decoder;

architecture Behavioral of TTC_decoder is

  signal L1A        : std_logic                     := '0';
  signal sr         : std_logic_vector(12 downto 0) := (others => '0');
  signal rec_cntr   : std_logic_vector(5 downto 0)  := (others => '0');
  signal rec_cmd    : std_logic                     := '0';
  signal FMT        : std_logic                     := '0';
  signal brcst_str  : std_logic_vector(3 downto 0)  := (others => '0');
  signal brcst_data : std_logic_vector(7 downto 0)  := (others => '0');
  signal brcst_syn  : std_logic_vector(4 downto 0)  := (others => '0');
  signal brcst_i    : std_logic_vector(7 downto 0)  := (others => '0');
  signal frame_err  : std_logic                     := '0';
  signal single_err : std_logic                     := '0';
  signal double_err : std_logic                     := '0';

begin

  Brcst    <= Brcst_i;
  l1accept <= l1a;

  process(TTC_CLK)
  begin
    if(TTC_CLK'event and TTC_CLK = '1')then

      L1A <= TTC_data(0);

      if(rec_cmd = '0')then
        rec_cntr <= (others => '0');
      else
        rec_cntr <= rec_cntr + 1;
      end if;

      if(rec_cntr(5 downto 3) = "101" or (FMT = '0' and rec_cntr(3 downto 0) = x"d"))then
        rec_cmd <= '0';
      elsif(TTC_data(1) = '0')then
        rec_cmd <= '1';
      end if;

      if(or_reduce(rec_cntr) = '0')then
        FMT <= TTC_data(1);
      end if;

      sr <= sr(11 downto 0) & TTC_data(1);

      if(FMT = '0' and rec_cntr(3 downto 0) = x"e")then
        brcst_data   <= sr(12 downto 5);
        brcst_syn(0) <= sr(0) xor sr(5) xor sr(6) xor sr(7) xor sr(8);
        brcst_syn(1) <= sr(1) xor sr(5) xor sr(9) xor sr(10) xor sr(11);
        brcst_syn(2) <= sr(2) xor sr(6) xor sr(7) xor sr(9) xor sr(10) xor sr(12);
        brcst_syn(3) <= sr(3) xor sr(6) xor sr(8) xor sr(9) xor sr(11) xor sr(12);
        brcst_syn(4) <= xor_reduce(sr);
        frame_err    <= not TTC_data(1);
        brcst_str(0) <= '1';
      else
        brcst_str(0) <= '0';
      end if;

      single_err <= xor_reduce(brcst_syn) and not frame_err;

      if((or_reduce(brcst_syn) = '1' and xor_reduce(brcst_syn) = '0') or frame_err = '1')then
        double_err <= '1';
      else
        double_err <= '0';
      end if;

      SinErrStr    <= single_err and brcst_str(1);
      DbErrStr     <= double_err and brcst_str(1);
      brcst_str(2) <= brcst_str(1) and not double_err;

      if(brcst_syn(3 downto 0) = x"c")then
        Brcst_i(7) <= not brcst_data(7);
      else
        Brcst_i(7) <= brcst_data(7);
      end if;

      if(brcst_syn(3 downto 0) = x"a")then
        Brcst_i(6) <= not brcst_data(6);
      else
        Brcst_i(6) <= brcst_data(6);
      end if;

      if(brcst_syn(3 downto 0) = x"6")then
        Brcst_i(5) <= not brcst_data(5);
      else
        Brcst_i(5) <= brcst_data(5);
      end if;

      if(brcst_syn(3 downto 0) = x"e")then
        Brcst_i(4) <= not brcst_data(4);
      else
        Brcst_i(4) <= brcst_data(4);
      end if;

      if(brcst_syn(3 downto 0) = x"9")then
        Brcst_i(3) <= not brcst_data(3);
      else
        Brcst_i(3) <= brcst_data(3);
      end if;

      if(brcst_syn(3 downto 0) = x"5")then
        Brcst_i(2) <= not brcst_data(2);
      else
        Brcst_i(2) <= brcst_data(2);
      end if;

      if(brcst_syn(3 downto 0) = x"d")then
        brcst_i(1) <= not brcst_data(1);
      else
        brcst_i(1) <= brcst_data(1);
      end if;

      if(brcst_syn(3 downto 0) = x"3")then
        brcst_i(0) <= not brcst_data(0);
      else
        brcst_i(0) <= brcst_data(0);
      end if;

      BrcstStr <= brcst_str(2) and or_reduce(Brcst_i);

    end if;
  end process;

  i_brcst_str1 : SRL16E
    port map (
      Q   => brcst_str(1),              -- SRL data output
      A0  => '0',                       -- Select[0] input
      A1  => '1',                       -- Select[1] input
      A2  => '0',                       -- Select[2] input
      A3  => '0',                       -- Select[3] input
      CE  => '1',                       -- Clock enable input
      CLK => TTC_CLK,                   -- Clock input
      D   => brcst_str(0)               -- SRL data input
      );

end Behavioral;
