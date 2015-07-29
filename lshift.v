
`timescale 1ns/100ps
module lshift (ip, op);

input [31:0] ip;
output [31:0] op;

reg [31:0] shift;

always @(ip) begin
 shift = ip << 2;
end

assign op = shift;

endmodule
