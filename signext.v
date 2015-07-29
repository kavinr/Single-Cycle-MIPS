
`timescale 1ns/100ps
module signext(ip, op);

input [15:0] ip;
output [31:0] op;
reg [31:0] ext;

always @(*) begin
 ext [15:0]  = ip;
 ext [31:16] = {16{ip[15]}};
end

assign op = ext;
endmodule
