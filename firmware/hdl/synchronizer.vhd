library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library UNISIM;
use UNISIM.VComponents.all;

--============================================================================
--                                                          Entity declaration
--============================================================================
entity synchronizer is
  generic (
    N_STAGES : integer := 2
    );
  port (
    async_i : in  std_logic;
    clk_i   : in  std_logic;
    sync_o  : out std_logic
    );
end synchronizer;

--============================================================================
--                                                        Architecture section
--============================================================================
architecture synchronizer_arch of synchronizer is

--============================================================================
--                                                         Signal declarations
--============================================================================  
  signal s_resync : std_logic_vector(N_STAGES downto 0) := (others => '0');

  attribute ASYNC_REG  : string;
  attribute DONT_TOUCH : string;

  attribute ASYNC_REG of s_resync  : signal is "TRUE";
  attribute DONT_TOUCH of s_resync : signal is "TRUE";

--============================================================================
--                                                          Architecture begin
--============================================================================
begin

  s_resync(0) <= async_i;

  gen_FDE_series : for i in 0 to N_STAGES-1 generate

    -- place the flops next to each other along the X-axis
    attribute RLOC             : string;
    constant rloc_str          : string := "X" & integer'image(i) & "Y0";
    attribute RLOC of FDE_INST : label is rloc_str;
  begin
    FDE_INST : FDE
      port map (
        D  => s_resync(i),
        Q  => s_resync(i+1),
        CE => '1',
        C  => clk_i
        );
  end generate gen_FDE_series;

  sync_o <= s_resync(N_STAGES);

end synchronizer_arch;
--============================================================================
--                                                            Architecture end
--============================================================================

