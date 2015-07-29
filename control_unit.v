
`timescale 1ns/100ps
module control_unit(opcode,funct,bcond,RegDest,ALUSrc,MemtoReg,RegWrite,MemRead,MemWrite,PCSrc1,PCSrc2,PCSrc3,isJAL,isSLL_SRL,ALU_Control);
input [5:0] opcode;       //Instr[31:26]
input [5:0] funct;        //Defines operation when Instructyion in R type
input bcond;              //1 when opcode is BEQ and BNE
output RegDest;           //Write Destination register location
                          //RegDest = 1 -> R-type - Instr[15:11]
                          //RegDest = 0 -> I-type - Instr[21:16]
output [1:0] ALUSrc;      //When Instructions is SLL or SRL, indiacated by isSLL_SRL,
                          //2nd input to ALU is SHAMT ie.,Inst[10:6]
                          //else 
                          //2nd input to ALU; ALUSrc=0-> Read data 2; ALUSrc=1->Immediate
output MemtoReg;          //Steer ALU(0)/Load memory(1) output to GPR write port
output RegWrite;          //GPR wite Disabled(0)/Enabled(1)
output MemRead;           //Read from Data memory(LW/LB=1)
output MemWrite;          //Write to Data memory(SW/SB=1)
output PCSrc1;            //PCSrc1(1)-> Next PC is Jump address
                          //PCSrc1(0)-> Next PC based on PCSrc2
output PCSrc2;            //When PCSrc1=0-->
                          //if PCSrc2=1-> Next PC based on Immediate address
                          //if PCSrc2=0-> Next PC is PC+4
output PCSrc3;            //if PCSrc3=1-> Next PC is GPR[rs]
output isJAL;             // Instruction is JAL
output isSLL_SRL;         //Set when Instruction is SLL or SRL
output [3:0] ALU_Control; //Defines the ALU operation 

`define ADD  6'b100000
`define AND  6'b100100 
`define JR   6'b001000
`define NOP  6'b000000
`define OR   6'b100101 
`define SLL  6'b000000
`define SLT  6'b101010
`define SRL  6'b000010
`define SUB  6'b100010
`define XOR  6'b100110 

`define ADDI 6'b001000
`define ANDI 6'b001100
`define BEQ  6'b000100
`define BNE  6'b000101
`define LB   6'b100000
`define LW   6'b100011
`define SB   6'b101000
`define SW   6'b101011
`define SLTI 6'b001010 
`define ORI  6'b001101
`define XORI 6'b001110

`define J    6'b000010
`define JAL  6'b000011

reg [3:0] alu_ctrl;

assign RegDest   = (opcode==6'b0);

assign ALUSrc    = (opcode!=6'b0) && (opcode!=`BEQ) && (opcode!=`BNE);

assign MemtoReg  = (opcode==`LW) || (opcode==`LB);

assign RegWrite  = (opcode!=`SW)   &&  (opcode!=`SB)  &&  
                   (opcode!=`BEQ)  &&  (opcode!=`BNE) && 
                   (opcode!=`J)    &&  
                   (!((opcode==6'd0) &&  (funct==`JR)));

assign MemRead   = (opcode==`LW)  || (opcode==`LB);

assign MemWrite  = (opcode==`SW)  || (opcode==`SB);

assign PCSrc1    = (opcode==`J)   || (opcode==`JAL);

assign PCSrc2    = ((opcode==`BEQ) || (opcode==`BNE)) && (bcond==1'b1);

assign PCSrc3    = (opcode==6'd0) && (funct==`JR); 

always@(*) begin
  casex({opcode,funct})
    {6'd0 ,`ADD},{`ADDI,6'dx},
    {`LB  ,6'dx},{`LW  ,6'dx},
    {`SB  ,6'dx},{`SW  ,6'dx} : alu_ctrl = 4'd0;
    {6'd0 ,`AND},{`ANDI,6'dx} : alu_ctrl = 4'd1;
    {6'd0 ,`OR} ,{`ORI ,6'dx} : alu_ctrl = 4'd2;
    {6'd0 ,`SLL}              : alu_ctrl = 4'd3;
    {6'd0 ,`SLT},{`SLTI,6'dx} : alu_ctrl = 4'd4;
    {6'd0 ,`SRL}              : alu_ctrl = 4'd5;
    {6'd0 ,`SUB}              : alu_ctrl = 4'd6;
    {6'd0 ,`XOR},{`XORI,6'dx} : alu_ctrl = 4'd7;
    {`BEQ ,6'dx}              : alu_ctrl = 4'd8;
    {`BNE ,6'dx}              : alu_ctrl = 4'd9;
    default                   : alu_ctrl = 4'd15;
  endcase
end

assign isJAL     = (opcode==`JAL);
assign isSLL_SRL = (opcode==6'b0) && ((funct==`SLL)||(funct==`SRL));
 
assign ALU_Control = alu_ctrl;
   
endmodule
