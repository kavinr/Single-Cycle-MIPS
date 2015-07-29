`timescale 1ns/100ps
`include "file.f"
module processor (clock, reset, PC, Inst, MemRead, MemWrite, Addr, Din, Dout);

input clock, reset;
input [31:0] Inst, Dout;
output MemRead, MemWrite;
output [31:0] PC, Addr, Din;

//Register Declarations

//Wire Declarations
wire [25:0] Inst_25_0;
wire [4:0] Inst_25_21;
wire [4:0] Inst_20_16;
wire [4:0] Inst_15_11;
wire [15:0] Inst_15_0;
wire [31:0] shamt; //Shift Amount for SLL and SRL
wire [31:0] pc;        //Program Counter
wire [5:0] opcode;
wire [5:0] funct;
wire bcond;
wire RegDest;
wire ALUSrc;
wire MemtoReg;
wire RegWrite; 
wire MemRead;
wire MemWrite;
wire PCSrc1;
wire PCSrc2;
wire PCSrc3;
wire [3:0] ALU_Control;
wire [31:0] ALU_Result;
wire [31:0] ALU_datain2_src0;
wire [31:0] ALU_datain2;
wire [4:0] gpr_wr_addr;
wire [4:0] gpr_rd_addr1;
wire [4:0] gpr_wr_addr0;
wire [31:0] gpr_wr_data;
wire [31:0] gpr_rd_data1;
wire [31:0] gpr_rd_data2;
wire [31:0] mem_alu_data_out;
wire [31:0] pc_plus_8;        //PC + 8 to be written to GPR[31] on JAL
wire isJAL;    //Set when Instruction is JAL
wire isSLL_SRL;//Set when Instruction is SLL or SRL
wire [31:0] Inst_15_0_signext; 
wire [31:0] br_signext_sl2;

assign opcode = Inst[31:26];
assign funct  = Inst[5:0];
assign Inst_25_0   = Inst[25:0];
assign Inst_25_21  = Inst[25:21];
assign Inst_20_16  = Inst[20:16];
assign Inst_15_11  = Inst[15:11];
assign Inst_15_0   = Inst[15:0];
assign shamt       = {27'd0,Inst[10:6]};


//Sign extension for Instruction[15:0] for
//*branch address calculation
//*Alu source
signext signext_u0(.ip(Inst_15_0        ),
                   .op(Inst_15_0_signext)
                   );

//Left shift for branch address calculation
lshift br_lshift (.ip(Inst_15_0_signext),
                  .op(br_signext_sl2   )
                 );


//Program Counter Module with PCSrc Mux
pc pc_u0 (.clk           (clock         ),
          .rst           (reset         ), 
          .br_signext_sl2(br_signext_sl2), 
          .Inst_25_0     (Inst_25_0     ),
          .gpr_rd_data1  (gpr_rd_data1  ), 
          .jump          (PCSrc1        ), 
          .branch        (PCSrc2        ),
          .jump_reg      (PCSrc3        ),
          .pc            (pc            ),
          .pc_plus_8     (pc_plus_8     )
         );

// Control Unit
control_unit control_unit_u0(.opcode     (opcode     ),
                             .funct      (funct      ),
                             .bcond      (bcond      ),
                             .RegDest    (RegDest    ),
                             .ALUSrc     (ALUSrc     ),
                             .MemtoReg   (MemtoReg   ),
                             .RegWrite   (RegWrite   ),
                             .MemRead    (MemRead    ),
                             .MemWrite   (MemWrite   ),
                             .PCSrc1     (PCSrc1     ),
                             .PCSrc2     (PCSrc2     ),
                             .PCSrc3     (PCSrc3     ),
                             .isJAL      (isJAL      ),
                             .isSLL_SRL  (isSLL_SRL  ),
                             .ALU_Control(ALU_Control)
                            );
//Multiplexer to select write address of GPR
mux_2x1 #(.DATA_WIDTH(5)
         ) mux_2x1_u0(.ip1(Inst_15_11 ), //When Instruction is R-type
                      .ip0(Inst_20_16 ), //When Instruction is J-type 
                      .sel(RegDest    ), //1-Inst[15:0];0-Inst[20:16]
                      .out(gpr_wr_addr0)
                     );

mux_2x1 #(.DATA_WIDTH(5)
         ) mux_2x1_u1(.ip1(5'd31       ), //When JAL write PC+8 to gpr[31] 
                      .ip0(gpr_wr_addr0), 
                      .sel(isJAL       ),
                      .out(gpr_wr_addr )
                     );
                          
//Multiplexer to select write back to GPR from ALU or MEM
//Another multiplexer selects this data and JAL address(PC+8)
mux_2x1 #(.DATA_WIDTH(32)
         )mux_2x1_u2(.ip1(Dout            ), // Dout -> read data from Data memory
                     .ip0(ALU_Result      ),
                     .sel(MemtoReg        ),
                     .out(mem_alu_data_out)
                    );

mux_2x1 #(.DATA_WIDTH(32)
         )mux_2x1_u3(.ip1(pc_plus_8),
                     .ip0(mem_alu_data_out),
                     .sel(isJAL),
                     .out(gpr_wr_data)
                    );
//Read register 1 address for SLL and SRL alone is to be taken from
//Inst[20:16](Rt); others from Inst[25:21] (Rs)
mux_2x1 #(.DATA_WIDTH(5)
         )mux_2x1_u4(.ip1(Inst_20_16),
                     .ip0(Inst_25_21),
                     .sel(isSLL_SRL),
                     .out(gpr_rd_addr1)
                    );

gpr gpr_u0(.clk     (clock       ),
           .RegWrite(RegWrite    ),
           .rd_addr1(gpr_rd_addr1),
           .rd_addr2(Inst_20_16  ),
           .wr_addr (gpr_wr_addr ),
           .wr_data (gpr_wr_data ),
           .rd_data1(gpr_rd_data1),
           .rd_data2(gpr_rd_data2)
          );

//ALU operand source Mux
//Need an additional mux to input SHAMT(shift amount) for SLL and SRL
mux_2x1 #(.DATA_WIDTH(32)
         )mux_2x1_u5(.ip1(Inst_15_0_signext), 
                     .ip0(gpr_rd_data2     ), 
                     .sel(ALUSrc           ), 
                     .out(ALU_datain2_src0 )
                    );
//Mux used to take case of SLL and SRL instructions
mux_2x1 #(.DATA_WIDTH(32)
         )mux_2x1_u6 (.ip1(shamt            ), 
                      .ip0(ALU_datain2_src0 ), 
                      .sel(isSLL_SRL        ), 
                      .out(ALU_datain2      )
                     );
//ALU module
alu alu_u0(
	  .r1     (gpr_rd_data1),
	  .r2     (ALU_datain2 ),
	  .control(ALU_Control ),
	  .result (ALU_Result  ),
	  .bcond  (bcond       )
         );

assign PC = pc;
assign Din = gpr_rd_data2;
assign Addr = ALU_Result;

endmodule

