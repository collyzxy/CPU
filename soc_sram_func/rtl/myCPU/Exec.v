`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/14 10:21:39
// Design Name: 
// Module Name: Exec
// Project Name: 
// Target Devices: 
// Tool Versions:
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Exec(
    input [31:0] PC,
    input [31:0] PC_31,
    input [31:0] dataA,
    input [31:0] dataB,
    input [31:0] result_mem,
    input [31:0] dataW_wr,
    input [15:0] imm16,
    input Branch,
    input Jump,
    input ExtOp,
    input RegDst,
    input isCP0,
    input ALUSrcA,
    input ALUSrcB,
    input [1:0] ALUASel,
    input [1:0] ALUBSel,
    input [4:0] ALUOp,
    input [2:0] BranchOp,
    input [1:0] JumpOp,
    input [4:0] rd,
    input [4:0] rt,
    input [4:0] sa,
    input Exc_in,
    input Exc_mem,
    input [31:0]BadVAddr_in,
    input [31:0]Status_in,
    input [30:0]Cause_in,
    output reg Exc_out,
    output reg [31:0]BadVAddr_out,
    output reg [31:0]Status_out,
    output reg [30:0]Cause_out,
    output Branch_zero,
    output reg[4:0] rw,
    output reg[31:0] result,
    output [31:0] dataH,
    output [31:0] dataL,
    output [31:0] D,
    output [31:0] PC_3
    );
    
    wire [31:0]A;
    wire [31:0]B;
    wire [31:0]C;
    wire [31:0]X;
    wire [31:0]Y;
    wire [31:0]R;
    reg zero;
    wire overflow;
    wire YorN1;
    wire YorN2;
    wire YorN3;
    
    parameter ADD=5'b00001;
    parameter SUB=5'b00101;
    parameter BEQ=3'b000;
    parameter BNE=3'b001;
    parameter BGEZ=3'b010;
    parameter BGTZ=3'b011;
    parameter BLEZ=3'b100;
    parameter BLTZ=3'b101;
    parameter BGEZAL=3'b110;
    parameter BLTZAL=3'b111;
    parameter JAL=2'b01;
    parameter JALR=2'b11;
    
    assign YorN1=(Branch&&((!(BranchOp^BGEZAL))||(!(BranchOp^BLTZAL))))||(Jump&&(!(JumpOp^JAL)));
    assign YorN2=Jump&&(!(JumpOp^JALR));
    assign YorN3=((overflow)&&(!Exc_mem))&&((!(ALUOp^ADD))||(!(ALUOp^SUB)));
    
    Extender1 ex1(.in(sa),
                  .out(X));
    Extender2 ex2(.in(imm16),
                  .ExtOp(ExtOp),
                  .out(Y));
    mux3to1#(32) mux4(.A(dataA),
                      .B(result_mem),
                      .C(dataW_wr),
                      .ctr(ALUASel),
                      .out(C));
    mux3to1#(32) mux5(.A(dataB),
                      .B(result_mem),
                      .C(dataW_wr),
                      .ctr(ALUBSel),
                      .out(D));
    mux2to1#(32) mux2(.V(C),
                      .W(X),
                      .Selm(ALUSrcA),
                      .F(A));
    mux2to1#(32) mux3(.V(D),
                      .W(Y),
                      .Selm(ALUSrcB),
                      .F(B));
    ALU alu(.aluA(A),
            .aluB(B),
            .ALUctr(ALUOp),
            .result(R),
            .Overflow(overflow));
    MultDiv md(.A(A),
               .B(B),
               .ALUctr(ALUOp),
               .HI(dataH),
               .LO(dataL));
    mux2to1#(32) mux6(.V(PC_31),
                      .W(C),
                      .Selm(JumpOp[1]),
                      .F(PC_3));

    always@(*)
    begin
       case(BranchOp)
           BEQ:begin zero<=(((A[31:24]==B[31:24])&&(A[23:16]==B[23:16]))&&((A[15:8]==B[15:8])&&(A[7:0]==B[7:0])));end
           BNE:begin zero<=(((A[31:24]!=B[31:24])||(A[23:16]!=B[23:16]))||((A[15:8]!=B[15:8])||(A[7:0]!=B[7:0])));end
           BGEZ:begin zero<=($signed(A)>=0);end
           BGTZ:begin zero<=($signed(A)>0);end
           BLEZ:begin zero<=($signed(A)<=0);end
           BLTZ:begin zero<=A[31];end
           BGEZAL:begin zero<=($signed(A)>=0);end
           BLTZAL:begin zero<=A[31];end
       endcase
    end
    assign Branch_zero=Branch&zero;

    always@(*)
    begin
        if(YorN1)
        begin
            result<=PC+8;
            rw<=5'b11111;
        end
        else if(YorN2)
        begin
            result<=PC+8;
            rw<=rd;
        end
        else if(isCP0)
        begin
            result<=A;
            rw<=rt;
        end
        else if(RegDst)
        begin    
            result<=R;
            rw<=rd;
        end
        else
        begin
            result<=R;
            rw<=rt;
        end
    end

    parameter OV=5'hc;
    always@(*)
          if(Exc_in)
          begin
              Exc_out<=Exc_in;
              BadVAddr_out<=BadVAddr_in;
              Status_out<=Status_in;
              Cause_out<=Cause_in;
          end
          else if(YorN3)
          begin
              Exc_out<=1;
              BadVAddr_out<=32'b0;
              Status_out<={9'b0,1'b1,20'b0,1'b1,1'b0};
              Cause_out<={24'b0,OV,2'b0};
          end
          else
          begin
              Exc_out<=0;
              BadVAddr_out<=0;
              Status_out<=0;
              Cause_out<=0;
          end

endmodule