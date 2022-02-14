module eprom(
    output [7:0] dr,
    input [3:0] ar,
    input clk,cs,rd
);

localparam in = 2'b00;
localparam out = 2'b01;
localparam sta = 2'b10;
localparam lda = 2'b11;

reg [7:0] buff;
reg [7:0] memory[2**4 - 1 : 0];

initial begin
    memory[0] <= {in,6'd0};
    memory[1] <= {sta,4'd5,2'd0};
    memory[2] <= {in,6'd0};
    memory[3] <= {sta,4'd10,2'd0};
    memory[4] <= {lda,4'd5,2'd0};
    memory[5] <= {out,6'd0};
    memory[6] <= {lda,4'd10,2'd0};
    memory[7] <= {out,6'd0};
end

assign dr = (cs & rd) ? buff : 'hz;

always @(posedge clk)
    buff <= memory[ar];
endmodule