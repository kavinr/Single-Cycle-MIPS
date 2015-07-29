`timescale 1ns/100ps
module tb_mips ();
reg          clock = 0;
reg          reset;

reg   [31:0] Inst;              // Instruction selected by PC
reg   [31:0] Dout;              // Data Memory Data out (load instruction)
wire  [31:0] PC;
wire         MemRead;           // Data Memory Read Enable
wire         MemWrite;          // Data Memory Write Enable
wire  [31:0] Addr;              // Address of Data Memory
wire  [31:0] Din;               // Data Memory Data in  (store instruction)

wire  [31:0] mem_addr;

reg   [31:0] InstMem [0:255];
reg   [31:0] DataMem [0:255];

processor P (.clock          (clock),
             .reset          (reset),
             .PC             (PC),
             .Inst           (Inst),
             .MemRead        (MemRead),
             .MemWrite       (MemWrite),
             .Addr           (Addr),
             .Din            (Din),
             .Dout           (Dout)  );

// clock
always #5 clock = ~clock;

// Instruction Moemory

always @(reset or PC) begin
   if (reset) begin
      InstMem[0]  = 32'h0;
      InstMem[1]  = 32'h20030007;       // addi   r3, r0, 7
      InstMem[2]  = 32'h00602024;       // and    r4, r3, r0
      InstMem[3]  = 32'h00032880;       // sll    r5, r3, 2
      InstMem[4]  = 32'h20060004;       // addi   r6, r0, 4
      InstMem[5]  = 32'h200c0007;       // addi   r12,r0, 7
      InstMem[6]  = 32'h200a0001;       // addi   r10,r0, 1
      InstMem[7]  = 32'h20090000;       // addi   r9, r0, 0
      InstMem[8]  = 32'h8d210004;       // lw     r1, 4($r9)
      InstMem[9]  = 32'h8d220008;       // lw     r2, 8($r9)
      InstMem[10] = 32'h0022582a;       // slt    r11,r1, r2
      InstMem[11] = 32'had210008;       // sw     r1, 8($r9)
      InstMem[12] = 32'had220004;       // sw     r2, 4($r9)
      InstMem[13] = 32'h154b0002;       // bne    r10,r11,2
      InstMem[14] = 32'had210004;       // sw     r1, 4($r9)
      InstMem[15] = 32'had220008;       // sw     r2, 8($r9)
      InstMem[16] = 32'h21290004;       // addi   r9, r9, 4
      InstMem[17] = 32'h1525fff6;       // bne    r9, r5, -10   (jump to Inst[8])
      InstMem[18] = 32'h20840001;       // addi   r4, r4, 1
      InstMem[19] = 32'h00a62822;       // sub    r5, r5, r6
      InstMem[20] = 32'h10640001;       // beq    r4, r3, 1
      InstMem[21] = 32'h01800008;       // jr     r12           (jump to Inst[7])
      InstMem[22] = 32'h0;
      InstMem[23] = 32'h0;

      Inst = 0;
   end
   else begin
      Inst = InstMem[PC>>2];
   end
end

// Data Memory
assign mem_addr = Addr >> 2;
always@(posedge clock or posedge reset) begin
  if (reset) begin
    DataMem[0]  = 32'h0;
    DataMem[1]  = 32'h00000008;
    DataMem[2]  = 32'h00000009;
    DataMem[3]  = 32'h00000007;
    DataMem[4]  = 32'h0000000a;
    DataMem[5]  = 32'h00000006;
    DataMem[6]  = 32'h00000004;
    DataMem[7]  = 32'h0000000e;
    DataMem[8]  = 32'h00000005;
    DataMem[9]  = 32'h0000000a;
    DataMem[10] = 32'h00000002;
    DataMem[11] = 32'h0000000d;
    DataMem[12] = 32'h0000000c;
    DataMem[13] = 32'h0000000b;
    DataMem[14] = 32'h0000000f;
    DataMem[15] = 32'h00000003;
    DataMem[16] = 32'h00000002;
    DataMem[17] = 32'h00000001;
  end
  else begin
    if(MemWrite) begin
      DataMem[mem_addr] = Din;
    end
  end
end
always@(*) begin
      if (MemRead) begin
         Dout = DataMem[mem_addr];
      end
end

initial begin
   #5  reset = 1;
   #10 reset = 0;
   #5500;
   #100 $finish;
end

/* display function //
always @(clock)
   $display ("time = %t, DataMemory_input = %d", $time, Din);
*/

// dumping waveform file //
initial begin
   $dumpfile("mips.vcd");
   $dumpvars(0, tb_mips);
end

endmodule
