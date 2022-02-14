`include "eprom.v"
`include "sram.v"

module cpu(
    input clk,rst,
    inout [7:0] dr,
    output reg [4:0] ar,
    output reg rd,wr,
    input [7:0] buf_in,
    output reg [7:0 ] buf_out
);

localparam if1 = 2'b00;
localparam if2 = 2'b01;
localparam id = 2'b10;
localparam ex_mem = 2'b11;

reg [1:0] st;
reg [1:0] st_nxt;

reg [1:0] ir;
reg [3:0] pc;
reg [7:0] acc;
reg [7:0] buff;

assign dr = (wr & !rd) ? buff : 'hz;

initial begin
    pc = 4'd0;
    st = 2'd0;
end

always @ * begin
    case(st)
        if1:
            st_nxt = if2;        
        if2:
            st_nxt = id;
        id:
            st_nxt = ex_mem;
        ex_mem:
            st_nxt = if1;
    endcase
end

always @ (st) begin
    case(st)
        if1:
            begin
                ar[3:0] <= pc;
                ar[4] <= 1'b1;
                rd <= 1'b1;
                wr <= 1'b0;
            end
        if2:
            begin
                pc <= pc + 1;
                ir <= dr[7:6];
                ar <= {1'b0,dr[5:2]};
                rd <= 1'b0;
            end
        id:
            if(ir == 2'b00)
                acc <= buf_in;
            else if(ir == 2'b01)
                buf_out <= acc;
            //else if(ir == 2'b10 || ir == 2'b11)
             //   ar <= {1'b0,dr[5:2]}; 
        ex_mem:
            begin
                buff <= acc;
                if(ir == 2'b10)
                    wr <= 1'b1;
                else if(ir == 2'b11)
                    rd <= 1'b1;
            end
    endcase
end

always @(posedge clk or posedge rst) begin
    if(rst)
        pc <= 4'd0;
    else
        st <= st_nxt;
end

endmodule

//top
module final_cut(
    input clk, rst,
    input [7:0] buf_in,
    output [7:0] buf_out
);

wire w_rd,w_wr;
wire [4:0] w_ar;
wire [7:0] w_dr;

eprom i_eprom(
    .clk(clk),
    .dr(w_dr),
    .ar(w_ar[3:0]),
    .cs(w_ar[4]),
    .rd(w_rd)
);

sram i_sram(
    .clk(clk),
    .dr(w_dr),
    .ar(w_ar[3:0]),
    .cs(~w_ar[4]),
    .rd(w_rd),
    .wr(w_wr)
);

cpu i_cpu(
    .clk(clk),
    .rst(rst),
    .dr(w_dr),
    .ar(w_ar),
    .rd(w_rd),
    .wr(w_wr),
    .buf_in(buf_in),
    .buf_out(buf_out)
);

endmodule

//tb
module final_cut_tb;

output reg clk, rst;
output reg [7:0] buf_in;
wire [7:0] buf_out;

final_cut i(
    .clk(clk),.rst(rst),
    .buf_in(buf_in),
    .buf_out(buf_out)
);

initial begin
    $dumpfile("final_cut_tb.vcd");
    $dumpvars(0,final_cut_tb);
end

initial begin
    clk = 1'b0;
    repeat (2*4*10)
    #50 clk = ~clk;
end

initial begin
    rst = 1'b1;
    #80 rst = 1'b0;
end

initial begin
    buf_in = 8'd7;
    #880 buf_in = 8'd9;
end

endmodule