proc add_signals {signals config} {
	gtkwave::addSignalsFromList $signals
    gtkwave::highlightSignalsFromList $signals
    if {[dict exists $config format]} {
	    gtkwave::/Edit/Data_Format/[dict get $config format]
    }
    if {[dict exists $config translator]} {
		set proc_id [gtkwave::setCurrentTranslateProc [dict get $config translator]]
    	gtkwave::installProcFilter $proc_id
    }
    if {[dict exists $config group]} {
		gtkwave::/Edit/Create_Group [dict get $config group]
    }
    gtkwave::/Edit/UnHighlight_All
}

add_signals [list \
    top.cpu_tb.clk \
    top.cpu_tb.reset \
    top.cpu_tb.uut.pc \
    top.cpu_tb.uut.next_pc \
] [dict create format "Binary"]

add_signals [list top.cpu_tb.uut.instr] [dict create format "Hex" translator ./disassembler.rs]

add_signals [list \
    top.cpu_tb.uut.accumulator.acc_value \
    top.cpu_tb.uut.data_bus \
    top.cpu_tb.uut.alu.result \
    top.cpu_tb.uut.alu_carry \
] [dict create format "Binary"]

add_signals [list \
    top.cpu_tb.uut.regfile.regs\[0\] \
    top.cpu_tb.uut.regfile.regs\[1\] \
    top.cpu_tb.uut.regfile.regs\[2\] \
    top.cpu_tb.uut.regfile.regs\[3\] \
    top.cpu_tb.uut.regfile.regs\[4\] \
    top.cpu_tb.uut.regfile.regs\[5\] \
    top.cpu_tb.uut.regfile.regs\[6\] \
    top.cpu_tb.uut.regfile.regs\[7\] \
    top.cpu_tb.uut.regfile.regs\[8\] \
    top.cpu_tb.uut.regfile.regs\[9\] \
    top.cpu_tb.uut.regfile.regs\[10\] \
    top.cpu_tb.uut.regfile.regs\[11\] \
    top.cpu_tb.uut.regfile.regs\[12\] \
    top.cpu_tb.uut.regfile.regs\[13\] \
    top.cpu_tb.uut.regfile.regs\[14\] \
    top.cpu_tb.uut.regfile.regs\[15\] \
] [dict create format "Binary" group "Registers"]

add_signals [list \
    top.cpu_tb.uut.acc_read_en \
    top.cpu_tb.uut.reg_read_en \
    top.cpu_tb.uut.acc_sel_alu \
    top.cpu_tb.uut.acc_write_en \
    top.cpu_tb.uut.reg_write_en \
] [dict create group "R/W Signals"]

# skip the reset
gtkwave::setFromEntry "10ns"

# gtkwave::/Time/Zoom/Zoom_Full
