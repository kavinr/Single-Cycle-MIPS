
`timescale 1ns/100ps
module pc(clk, rst, br_signext_sl2, Inst_25_0,gpr_rd_data1, jump, branch, jump_reg, pc,pc_plus_8);

input clk, rst;
input [31:0] br_signext_sl2;
input [25:0] Inst_25_0;
input [31:0] gpr_rd_data1;
input jump;
input branch;
input jump_reg;
output [31:0] pc;
output [31:0] pc_plus_8;

parameter TD = 1;

reg  [31:0] pc_val;
wire [31:0] br_loc, pc_plus_4;



//adder next(pc_val, 32'd4, pc_plus_4);             //Adder to calculate next instruction(+4)
//adder jal (pc_val, 32'd8, pc_plus_8);             //Adder to calculate PC+8--to be 
//                                                  //written to GPR[31] on JAL
//adder br(pc_plus_4, br_signext_sl2, br_loc);      //Adder to calculate branch target

assign pc_plus_4 = pc_val + 32'd4;             // Next PC (PC+4) when the instruction  is not brach
assign pc_plus_8 = pc_val + 32'd8;             // To calculate PC+8 to be written to GPR[31] 
                                               // on JAL instruction
assign br_loc    = pc_plus_4 + br_signext_sl2; // To calculate branch target

always @ (posedge clk or posedge rst)             //PCSrc Mux
begin
  if (rst==1'b1) begin
    pc_val <= #TD 31'd0;
  end 
  else if (jump==1'b1) begin
    pc_val <= #TD {pc_plus_4[31:28],Inst_25_0,2'b00};
  end 
  else if (branch==1'b1) begin
    pc_val <= #TD br_loc;
  end
  else if(jump_reg==1'b1) begin
    pc_val <= #TD gpr_rd_data1;
  end 
  else begin
    pc_val <= #TD pc_plus_4;
  end
end


assign pc = pc_val;

endmodule
