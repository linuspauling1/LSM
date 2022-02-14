module sram(
    input clk,cs,rd,wr,
    input [3:0] ar,
    inout [7:0] dr
);

reg [7:0] memory[2**4 - 1 : 0];
reg [7:0] buff;

assign dr = (cs & rd & !wr) ? buff : 'hz;

always @(posedge clk) begin
    if(rd)
        buff <= memory[ar];
    else if(wr)
        memory[ar] <= dr;
end

endmodule