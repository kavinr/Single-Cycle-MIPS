
`timescale 1ns/100ps
module gpr(clk,RegWrite,rd_addr1,rd_addr2,wr_addr,wr_data,rd_data1,rd_data2);

input clk;
input RegWrite;
input  [4:0] rd_addr1;
input  [4:0] rd_addr2;
input  [4:0] wr_addr;
input  [31:0] wr_data;
output [31:0] rd_data1;
output [31:0] rd_data2;

parameter TD = 1;

reg  [31:0] gpr [1:31]; 

always@(posedge clk) begin
  if((RegWrite==1'b1) && (wr_addr!=5'd0)) begin
    gpr[wr_addr] <= #TD wr_data;
  end
end
    
assign rd_data1 = (rd_addr1==5'd0) ? 32'd0 : gpr[rd_addr1];   
assign rd_data2 = (rd_addr2==5'd0) ? 32'd0 : gpr[rd_addr2];

endmodule

