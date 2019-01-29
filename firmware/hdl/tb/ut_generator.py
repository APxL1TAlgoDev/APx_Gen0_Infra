import sys
from collections import OrderedDict

time_elapsed = 0.0
t_step = float(sys.argv[1])			#time step for each iteration
duration = int(sys.argv[2]) + 2		#the number of iterations generated									#total time = t_step * duration (in ns)

input_vars = OrderedDict() # stores all the variables from the design

# keep the variables in the same order as the design file
input_vars['clk_200_diff_in_clk_p'] 	= 0
input_vars['clk_200_diff_in_clk_n'] 	= 1

input_vars['clk_40_ttc_p_i'] 			= 0  #-- TTC backplane clock signals
input_vars['clk_40_ttc_n_i'] 			= 1
input_vars['ttc_data_p_i'] 				= 0
input_vars['ttc_data_n_i'] 				= 1

input_vars['refclk_F_0_p_i'] 			= '0000'
input_vars['refclk_F_0_n_i'] 			= '1111'

input_vars['refclk_F_1_p_i'] 			= '0000'
input_vars['refclk_F_1_n_i'] 			= '1111'

input_vars['refclk_B_0_p_i'] 			= '0000'
input_vars['refclk_B_0_n_i'] 			= '1111'

input_vars['refclk_B_1_p_i'] 			= '0000'
input_vars['refclk_B_1_n_i'] 			= '1111'

input_vars['axi_c2c_zynq_to_v7_clk'] 	= 0
input_vars['axi_c2c_zynq_to_v7_data'] 	= '00000000000000000'
input_vars['axi_c2c_zynq_to_v7_reset'] 	= 0

# stores output variables for the top file
# make sure that they are stored in order as the top file
# enter std_logic variables as strings
# and std_logic_vectors as tuples where the first argument is the variable name and the second is the number of bits 
output_vars = [
	("LEDs", 2), "LED_GREEN_o", "LED_RED_o", "LED_BLUE_o",
	("axi_c2c_v7_to_zynq_data", 17), "axi_c2c_v7_to_zynq_clk", "axi_c2c_v7_to_zynq_link_status"
]

# function used to flip a bit value in a vector
def flip_vector_bit(vector, msb, value):
	# vector name (str)
	# the bit number (first bit is leftmost) (int)
	# the new value to flip to
	vector_str = input_vars[vector]
	new_vector = vector_str[:msb-1] + str(value) + vector_str[msb:]
	return new_vector

# create the new line using the current states of the variables
def create_new_line():
	# add a case for python 3
	new_line = "{} ns".format(time_elapsed)
	for variable, val in input_vars.iteritems():
		new_line = new_line + "  {}".format(val)

	new_line = new_line + '\n'

	return new_line

# creates the input text file
with open('input_text.txt', 'w') as f:

	c_200MHZ_CLK = 0.0 #clock counter
	c_40MHZ_CLK = 0.0 #clock counter
	c_156MHZ_CLK = 0.0 #clock counter

	for i in range(1, duration):
		time_elapsed = round((t_step * i) - t_step, 4)

		new_line = create_new_line()
		f.write(new_line)

		#Reset is on for 10 ns
		if time_elapsed >= 10.0:
			input_vars['axi_c2c_zynq_to_v7_reset'] = 0
		else:
			input_vars['axi_c2c_zynq_to_v7_reset'] = 1

		#200MHz clock
		if c_200MHZ_CLK + t_step > 5.0/2:
			c_200MHZ_CLK = 0
			tmp = input_vars['clk_200_diff_in_clk_p'] #flip clk's
			input_vars['clk_200_diff_in_clk_p'] = input_vars['clk_200_diff_in_clk_n']
			input_vars['clk_200_diff_in_clk_n'] = tmp
			input_vars['axi_c2c_zynq_to_v7_clk'] = ~input_vars['axi_c2c_zynq_to_v7_clk'] # may use a  different clock
		else:
			c_200MHZ_CLK += t_step

		#40MHz clock
		if c_40MHZ_CLK > 25.0:
			c_40MHZ_CLK = t_step
			tmp = input_vars['clk_40_ttc_p_i'] #flip clk's
			input_vars['clk_40_ttc_p_i'] = input_vars['clk_40_ttc_n_i']
			input_vars['clk_40_ttc_n_i'] = tmp
		else:
			c_40MHZ_CLK += t_step

		#156.25MHz clock
		if c_156MHZ_CLK > 3.200000:
			c_156MHZ_CLK = t_step
			input_vars['refclk_F_0_p_i'] = ~input_vars['refclk_F_0_p_i']
			input_vars['refclk_F_0_n_i'] = ~input_vars['refclk_F_0_n_i']
			input_vars['refclk_F_1_p_i'] = ~input_vars['refclk_F_1_p_i']
			input_vars['refclk_F_1_n_i'] = ~input_vars['refclk_F_1_n_i']
			input_vars['refclk_B_0_p_i'] = ~input_vars['refclk_B_0_p_i']
			input_vars['refclk_B_0_n_i'] = ~input_vars['refclk_B_0_n_i']
			input_vars['refclk_B_1_p_i'] = ~input_vars['refclk_B_1_p_i']
			input_vars['refclk_B_1_n_i'] = ~input_vars['refclk_B_1_n_i']
		else:
			c_156MHZ_CLK += t_step

		# change will be effective in the next iteration

		# if time_elapsed == 10.0:
		# 	input_vars['USB_UART_TX'] = 1
		# 	input_vars['DDR4_C1_DQ'] = flip_vector_bit('DDR4_C1_DQ', 1, 'U')
	f.close()

# create a testbench
with open('tb_top.vhd', 'w') as f:

	# header
	f.write("-- libraries\n")
	f.write("library ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all; use ieee.std_logic_textio.all;\n")
	f.write("-- Standard textIO functions\n")
	f.write("library std; use std.textio.all;\n")
	f.write("\nentity tb_top is\nend tb_top;\n")

	# testbench architecture
	f.write("\narchitecture behavior of tb_top is\n")
	for key, val in input_vars.iteritems():
		if isinstance(val, basestring):
			f.write("	signal {} : std_logic_vector ({} downto 0);\n".format(key, len(val) - 1))
		else:
			f.write("	signal {} : std_logic;\n".format(key))

	for output_var in output_vars:
		if isinstance(output_var, basestring):
			if output_var not in input_vars:
				f.write("	signal {} : std_logic;\n".format(output_var))
		else:
			if output_var[0] not in input_vars:
				f.write("	signal {} : std_logic_vector ({} downto 0);\n".format(output_var[0], output_var[1] - 1))

	# architecture body begins
	f.write("\nbegin\n")
	f.write("\n-- Instantiate the Unit Under Test (UUT)\n")
	f.write("	uut : entity work.top port map (\n")

	lines = []
	for input_var in input_vars:
		line = "		{} => {}".format(input_var,input_var)
		lines.append(line)

	for output_var in output_vars:
		if isinstance(output_var, basestring):
			if output_var not in input_vars:
				line = "		{} => {}".format(output_var,output_var)
				lines.append(line)
		else:
			if output_var[0] not in input_vars:
				line = "		{} => {}".format(output_var[0],output_var[0])
				lines.append(line)

	f.write(",\n".join(lines))

	# Stimulus process write up
	f.write("\n	);\n\n	-- Stimulus process\n")
	f.write("	stim_proc : process\n")
	f.write('		file InF: TEXT open READ_MODE is "../../../../../../framework/hdl/tb/vcu118/input_text.txt";\n')
	f.write('		file OutF: TEXT open WRITE_MODE is "../../../../../../framework/hdl/tb/vcu118/output_text.txt";\n')
	f.write('		variable ILine: LINE; variable OLine: LINE; variable TimeWhen: TIME;\n')
	bit_variables = []
	vector_variables = []
	for input_var, val in input_vars.iteritems():
		if isinstance(val, int):
			bit_variables.append(input_var)
		else:
			vector_variables.append(input_var)

	f.write("		variable textio_{}: bit_vector(0 downto 0);\n".format(",textio_".join(bit_variables)))
	for variable in vector_variables:
		f.write("		variable textio_{}: bit_vector({} downto 0);\n".format(variable, len(input_vars[variable]) - 1))

	#Stimulus body begins
	f.write("\n	begin\n")
	f.write("		while not ENDFILE(InF) loop\n")
	f.write("			READLINE (InF, ILine); -- Read individual lines from input file.\n")
	f.write("			-- Read from line.\n")
	f.write("			READ (ILine, TimeWhen);\n")
	for input_var in input_vars:
		f.write("			READ (ILine, textio_{});\n".format(input_var))

	# Stimulus starts here.
	f.write("\n		-- insert stimulus here\n")
	f.write("			wait for TimeWhen - NOW; -- Wait until one time step\n\n")
	for input_var, val in input_vars.iteritems():
		if isinstance(val, int):
			f.write("			{} <= to_stdlogicvector(textio_{})(0);\n".format(input_var, input_var))
		else:
			f.write("			{} <= to_stdlogicvector(textio_{})({} downto 0);\n".format(input_var, input_var, len(val) - 1))

	#Export output state to file starts here
	f.write("\n			-- Export output state to file.\n")
	f.write("			write (OLine, TimeWhen);\n")
	for output_var in output_vars:
		f.write('			write (OLine, string\'("  "));\n')
		if isinstance(output_var, basestring):
			f.write("			write (OLine, {});\n".format(output_var))
		else:
			f.write("			write (OLine, {}({} downto 0));\n".format(output_var[0], output_var[1] - 1))

	f.write("\n			writeline (OutF, OLine); -- write all output variables in file\n")
	f.write("\n		end loop;\n")
	f.write("\n		wait for 10 NS;\n		file_close(InF);\n		file_close(OutF);\n		wait;\n	end process;")
	f.write("\nend behavior;\n")

	f.close()

