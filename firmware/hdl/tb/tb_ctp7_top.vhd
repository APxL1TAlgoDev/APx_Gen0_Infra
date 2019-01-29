-- libraries
library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all; use ieee.std_logic_textio.all;
-- Standard textIO functions
library std; use std.textio.all;

entity tb_ctp7_top is
end tb_ctp7_top;

architecture behavior of tb_ctp7_top is
	signal clk_200_diff_in_clk_p : std_logic;
	signal clk_200_diff_in_clk_n : std_logic;
	signal clk_40_ttc_p_i : std_logic;
	signal clk_40_ttc_n_i : std_logic;
	signal ttc_data_p_i : std_logic;
	signal ttc_data_n_i : std_logic;
	signal refclk_F_0_p_i : std_logic_vector (3 downto 0);
	signal refclk_F_0_n_i : std_logic_vector (3 downto 0);
	signal refclk_F_1_p_i : std_logic_vector (3 downto 0);
	signal refclk_F_1_n_i : std_logic_vector (3 downto 0);
	signal refclk_B_0_p_i : std_logic_vector (3 downto 0);
	signal refclk_B_0_n_i : std_logic_vector (3 downto 0);
	signal refclk_B_1_p_i : std_logic_vector (3 downto 0);
	signal refclk_B_1_n_i : std_logic_vector (3 downto 0);
	signal axi_c2c_zynq_to_v7_clk : std_logic;
	signal axi_c2c_zynq_to_v7_data : std_logic_vector (16 downto 0);
	signal axi_c2c_zynq_to_v7_reset : std_logic;
	signal LEDs : std_logic_vector (1 downto 0);
	signal LED_GREEN_o : std_logic;
	signal LED_RED_o : std_logic;
	signal LED_BLUE_o : std_logic;
	signal axi_c2c_v7_to_zynq_data : std_logic_vector (16 downto 0);
	signal axi_c2c_v7_to_zynq_clk : std_logic;
	signal axi_c2c_v7_to_zynq_link_status : std_logic;

begin

-- Instantiate the Unit Under Test (UUT)
	uut : entity work.ctp7_top port map (
		clk_200_diff_in_clk_p => clk_200_diff_in_clk_p,
		clk_200_diff_in_clk_n => clk_200_diff_in_clk_n,
		clk_40_ttc_p_i => clk_40_ttc_p_i,
		clk_40_ttc_n_i => clk_40_ttc_n_i,
		ttc_data_p_i => ttc_data_p_i,
		ttc_data_n_i => ttc_data_n_i,
		refclk_F_0_p_i => refclk_F_0_p_i,
		refclk_F_0_n_i => refclk_F_0_n_i,
		refclk_F_1_p_i => refclk_F_1_p_i,
		refclk_F_1_n_i => refclk_F_1_n_i,
		refclk_B_0_p_i => refclk_B_0_p_i,
		refclk_B_0_n_i => refclk_B_0_n_i,
		refclk_B_1_p_i => refclk_B_1_p_i,
		refclk_B_1_n_i => refclk_B_1_n_i,
		axi_c2c_zynq_to_v7_clk => axi_c2c_zynq_to_v7_clk,
		axi_c2c_zynq_to_v7_data => axi_c2c_zynq_to_v7_data,
		axi_c2c_zynq_to_v7_reset => axi_c2c_zynq_to_v7_reset,
		LEDs => LEDs,
		LED_GREEN_o => LED_GREEN_o,
		LED_RED_o => LED_RED_o,
		LED_BLUE_o => LED_BLUE_o,
		axi_c2c_v7_to_zynq_data => axi_c2c_v7_to_zynq_data,
		axi_c2c_v7_to_zynq_clk => axi_c2c_v7_to_zynq_clk,
		axi_c2c_v7_to_zynq_link_status => axi_c2c_v7_to_zynq_link_status
	);

	-- Stimulus process
	stim_proc : process
		file InF: TEXT open READ_MODE is "../../../../../../firmware/hdl/tb/input_text.txt";
		file OutF: TEXT open WRITE_MODE is "../../../../../../firmware/hdl/tb/output_text.txt";
		variable ILine: LINE; variable OLine: LINE; variable TimeWhen: TIME;
		variable textio_clk_200_diff_in_clk_p,textio_clk_200_diff_in_clk_n,textio_clk_40_ttc_p_i,textio_clk_40_ttc_n_i,textio_ttc_data_p_i,textio_ttc_data_n_i,textio_axi_c2c_zynq_to_v7_clk,textio_axi_c2c_zynq_to_v7_reset: bit_vector(0 downto 0);
		variable textio_refclk_F_0_p_i: bit_vector(3 downto 0);
		variable textio_refclk_F_0_n_i: bit_vector(3 downto 0);
		variable textio_refclk_F_1_p_i: bit_vector(3 downto 0);
		variable textio_refclk_F_1_n_i: bit_vector(3 downto 0);
		variable textio_refclk_B_0_p_i: bit_vector(3 downto 0);
		variable textio_refclk_B_0_n_i: bit_vector(3 downto 0);
		variable textio_refclk_B_1_p_i: bit_vector(3 downto 0);
		variable textio_refclk_B_1_n_i: bit_vector(3 downto 0);
		variable textio_axi_c2c_zynq_to_v7_data: bit_vector(16 downto 0);

	begin
		while not ENDFILE(InF) loop
			READLINE (InF, ILine); -- Read individual lines from input file.
			-- Read from line.
			READ (ILine, TimeWhen);
			READ (ILine, textio_clk_200_diff_in_clk_p);
			READ (ILine, textio_clk_200_diff_in_clk_n);
			READ (ILine, textio_clk_40_ttc_p_i);
			READ (ILine, textio_clk_40_ttc_n_i);
			READ (ILine, textio_ttc_data_p_i);
			READ (ILine, textio_ttc_data_n_i);
			READ (ILine, textio_refclk_F_0_p_i);
			READ (ILine, textio_refclk_F_0_n_i);
			READ (ILine, textio_refclk_F_1_p_i);
			READ (ILine, textio_refclk_F_1_n_i);
			READ (ILine, textio_refclk_B_0_p_i);
			READ (ILine, textio_refclk_B_0_n_i);
			READ (ILine, textio_refclk_B_1_p_i);
			READ (ILine, textio_refclk_B_1_n_i);
			READ (ILine, textio_axi_c2c_zynq_to_v7_clk);
			READ (ILine, textio_axi_c2c_zynq_to_v7_data);
			READ (ILine, textio_axi_c2c_zynq_to_v7_reset);

		-- insert stimulus here
			wait for TimeWhen - NOW; -- Wait until one time step

			clk_200_diff_in_clk_p <= to_stdlogicvector(textio_clk_200_diff_in_clk_p)(0);
			clk_200_diff_in_clk_n <= to_stdlogicvector(textio_clk_200_diff_in_clk_n)(0);
			clk_40_ttc_p_i <= to_stdlogicvector(textio_clk_40_ttc_p_i)(0);
			clk_40_ttc_n_i <= to_stdlogicvector(textio_clk_40_ttc_n_i)(0);
			ttc_data_p_i <= to_stdlogicvector(textio_ttc_data_p_i)(0);
			ttc_data_n_i <= to_stdlogicvector(textio_ttc_data_n_i)(0);
			refclk_F_0_p_i <= to_stdlogicvector(textio_refclk_F_0_p_i)(3 downto 0);
			refclk_F_0_n_i <= to_stdlogicvector(textio_refclk_F_0_n_i)(3 downto 0);
			refclk_F_1_p_i <= to_stdlogicvector(textio_refclk_F_1_p_i)(3 downto 0);
			refclk_F_1_n_i <= to_stdlogicvector(textio_refclk_F_1_n_i)(3 downto 0);
			refclk_B_0_p_i <= to_stdlogicvector(textio_refclk_B_0_p_i)(3 downto 0);
			refclk_B_0_n_i <= to_stdlogicvector(textio_refclk_B_0_n_i)(3 downto 0);
			refclk_B_1_p_i <= to_stdlogicvector(textio_refclk_B_1_p_i)(3 downto 0);
			refclk_B_1_n_i <= to_stdlogicvector(textio_refclk_B_1_n_i)(3 downto 0);
			axi_c2c_zynq_to_v7_clk <= to_stdlogicvector(textio_axi_c2c_zynq_to_v7_clk)(0);
			axi_c2c_zynq_to_v7_data <= to_stdlogicvector(textio_axi_c2c_zynq_to_v7_data)(16 downto 0);
			axi_c2c_zynq_to_v7_reset <= to_stdlogicvector(textio_axi_c2c_zynq_to_v7_reset)(0);

			-- Export output state to file.
			write (OLine, TimeWhen);
			write (OLine, string'("  "));
			write (OLine, LEDs(1 downto 0));
			write (OLine, string'("  "));
			write (OLine, LED_GREEN_o);
			write (OLine, string'("  "));
			write (OLine, LED_RED_o);
			write (OLine, string'("  "));
			write (OLine, LED_BLUE_o);
			write (OLine, string'("  "));
			write (OLine, axi_c2c_v7_to_zynq_data(16 downto 0));
			write (OLine, string'("  "));
			write (OLine, axi_c2c_v7_to_zynq_clk);
			write (OLine, string'("  "));
			write (OLine, axi_c2c_v7_to_zynq_link_status);

			writeline (OutF, OLine); -- write all output variables in file

		end loop;

		wait for 10 NS;
		file_close(InF);
		file_close(OutF);
		wait;
	end process;
end behavior;
