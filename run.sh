iverilog -o final_cut_tb.vvp cpu.v
vvp final_cut_tb.vvp
gtkwave final_cut_tb.vcd