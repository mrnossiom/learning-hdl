proc add_signals {signals format translator} {
	gtkwave::addSignalsFromList $signals
    gtkwave::highlightSignalsFromList $signals
    gtkwave::/Edit/Data_Format/$format
    if {$translator != ""} {
		set proc_id [gtkwave::setCurrentTranslateProc $translator]
    	gtkwave::installProcFilter $proc_id
    }
    gtkwave::/Edit/UnHighlight_All
}

add_signals [list \
    top.cpu_tb.clk \
    top.cpu_tb.reset \
    top.cpu_tb.uut.pc \
    top.cpu_tb.uut.next_pc \
] "Binary" ""

add_signals [list top.cpu_tb.uut.instr] "Hex" ./disassembler.rs

add_signals [list \
    top.cpu_tb.uut.data_bus \
    top.cpu_tb.uut.accumulator.acc_value \
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
] "Binary" ""

# gtkwave::/Time/Zoom/Zoom_Full
