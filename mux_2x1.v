
`timescale 1ns/100ps
module mux_2x1 #(parameter DATA_WIDTH = 32) (ip1, ip0, sel, out);

input [DATA_WIDTH-1:0] ip1;
input [DATA_WIDTH-1:0] ip0;
input sel;
output reg [DATA_WIDTH-1:0] out;

always@(*) begin
  if (sel==1'b1) begin
   out = ip1;
  end 
  else begin 
   out = ip0;
  end
end

endmodule
