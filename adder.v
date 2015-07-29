
`timescale 1ns/100ps
module adder (ip1, ip2, out);

//input clk, rst;
input [31:0] ip1, ip2;
output [31:0] out;

reg [31:0] add;

always @(ip1 or ip2) begin
 add <= ip1 + ip2;
end
assign out = add;

endmodule
