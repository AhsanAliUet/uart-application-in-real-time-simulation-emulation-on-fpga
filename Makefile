
RTL_FILE1 = baud_rate_generator
RTL_FILE2 = uart
RTL_FILE3 = rx
RTL_FILE4 = tx

TB_FILE1  = tb_uart
TB_PATH   = verif/
RTL_PATH  = rtl/
EXT       = sv                 # system verilog

compile:
	vlog -work work -vopt -sv -stats=none $(TB_PATH)$(TB_FILE1).$(EXT) $(RTL_PATH)$(RTL_FILE1).$(EXT) $(RTL_PATH)$(RTL_FILE2).$(EXT) $(RTL_PATH)$(RTL_FILE3).$(EXT) $(RTL_PATH)$(RTL_FILE4).$(EXT)

simulate:
	vsim -c -voptargs="+acc" work.$(TB_FILE1) -do "run -all; quit -sim; quit;"

run:   # both compile and then simulate
	make compile
	make simulate