`include "eprom.v"
`include "sram.v"

module cpu(
    input clk, rst,
    inout [7:0] data_bus,
    output [4:0] adr_bus,
    input [7:0] buff_in,
    output [7:0] buff_out,
    output reg wr,rd
);

localparam s1 = 3'd0;
localparam s2 = 3'd1;
localparam s3 = 3'd2;
localparam s4 = 3'd3;
localparam s5 = 3'd4;
localparam s6 = 3'd5;
localparam s7 = 3'd6;
localparam s8 = 3'd7;

reg [7:0] acc;
reg [7:0] dr;
reg [4:0] ar;
reg [3:0] pc;
reg [1:0] ir;

assign adr_bus = ar;
assign data_bus = (wr & !rd) ? dr : 'hz;

reg [2:0] st;
reg [2:0] st_nxt;

always @(st) begin
    case(st)
        s1:
            begin
                ar[3:0] <= pc;
                ar[4] <= 1'b1;
                wr <= 1'b0;
            end
        s2:
            begin
                rd <= 1'b1;
                pc <= pc + 1;
            end
        s3:
            begin
                dr <= data_bus;
            end
        s4:
            begin
                rd <= 1'b0;
                ir <= dr[7:6];
            end
        s5:
            begin
                if(ir == 2'b00)
                    acc <= buff_in;
                else if(ir == 2'b01)
                   buf_out <= acc;
                else
                    begin
                        ar[4] <= 1'b0;
                        ar[3:0] <= dr[5:2];
                    end
            end
        s6:
            begin
                if(ir == 2'b10)
                    dr <= acc;
                else if(ir == 2'b11)
                    rd <= 1'b1;
            end
        s7:
            begin
                if(ir == 2'b10)
                    wr <= 1'b1;
                else if(ir == 2'b11)
                    dr <= data_bus;
            end
        s8:
            begin
                if(ir == 2'b11)
                    acc <= dr;
            end
    endcase    
end

always @* begin
    if(st != s8)
        st_nxt = st + 1;
    else
        st_nxt = s1;
end

always (posedge clk, posedge rst) begin
    if(rst)
        st <= s1;
    else
        st <= st_nxt;
end

endmodule;

module top_cpu(
    input clk, rst,
    input [7:0] buff_in,
    output [7:0] buff_out
);

wire [4:0] w_ab;
wire [7:0] w_db;
wire w_rd,w_wr;

cpu i_cpu(
    .clk(clk),
    .rst(rst),
    .data_buss(w_db),
    .adr_bus(w_ab),
    .buff_in(buff_in),
    .buff_out(buff_out),
    .rd(w_rd),
    .wr(w_wr)
);

eprom i_eprom(
    .clk(clk),
    .cs(w_ab[4]),
    .rd(w_rd),
    .dr(data_bus),
    .ar(w_ab)      
);

sram i_sram(
    .clk(clk),
    .cs(~w_ab[4]),
    .rd(w_rd),
    .wr(w_wr),
    .ar(w_ab),
    .dr(w_db)
);

endmodule

module tb;

output reg clk, rst;
output reg [7:0] buff_in;
wire buff_out;

top_cpu i(
    .clk(clk),.rst(rst),
    .buff_in(buff_in),
    .buff_out(buff_out)
);

initial begin
    clk = 1'b0;
    repeat(9*2*8)
    #5 clk = ~clk;
end

initial begin
    rst = 1'b1;
    #8 rst = 1'b0;
end

initial begin
    buff_in = 8'd7;
    #192 buff_in = 8'd9;//3*2*8*5 - 5
end

endmodule;