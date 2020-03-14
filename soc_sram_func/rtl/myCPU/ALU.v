`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/14 14:22:47
// Design Name: 
// Module Name: ALU
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


module ALU(
    input [31:0]aluA,
    input [31:0]aluB,
    input [4:0]ALUctr,
    output reg[31:0]result,
    output reg Overflow
    );

    parameter ADDU=5'b00000;
    parameter ADD=5'b00001;
    parameter OR=5'b00010;
    parameter AND=5'b00011;
    parameter SUBU=5'b00100;
    parameter SUB=5'b00101;
    parameter SLTU=5'b00110;
    parameter SLT=5'b00111;
    parameter MULTU=5'b01000;
    parameter MULT=5'b01001;
    parameter DIVU=5'b01010;
    parameter DIV=5'b01011;
    parameter NOR=5'b01100;
    parameter XOR=5'b01101;
    parameter SLL=5'b01110;
    parameter SRL=5'b01111;
    parameter SRA=5'b10000;
    parameter LUI=5'b10001;
    parameter MFHI=5'b10010;
    parameter MFLO=5'b10011;
    
    wire Overflow_add,Overflow_sub;
    wire [31:0]result_add,result_sub;

    always @(*)
    begin
        case(ALUctr)
            ADDU:
            begin
                result<=aluA+aluB;
                Overflow<=0;
            end
            ADD:
            begin
                result<=result_add;
                Overflow<=Overflow_add;
            end
            OR:
            begin
                result<=aluA|aluB;
                Overflow<=0;
            end
            AND:
            begin
                result<=aluA&aluB;
                Overflow<=0;
            end
            SUBU:
            begin
                result<=aluA-aluB;
                Overflow<=0;
            end
            SUB:
            begin
                result<=result_sub;
                Overflow<=Overflow_sub;
            end
            SLTU:
            begin
                result<=(aluA<aluB)?1:0;
                Overflow<=0;
            end
            SLT:
            begin
            result<=($signed(aluA)<$signed(aluB))?1:0;
            Overflow<=0;
            end
            NOR:
            begin
                result<=~(aluA|aluB);
                Overflow<=0;
            end
            XOR:
            begin
                result<=aluA^aluB;
                Overflow<=0;
            end
            SLL:
            begin
                result<=aluB<<aluA[4:0];
                Overflow<=0;
            end
            SRL:
            begin
                result<=aluB>>aluA[4:0];
                Overflow<=0;
            end
            SRA:
            begin
                result<=$signed(aluB)>>>aluA[4:0];
                Overflow<=0;
            end
            LUI:
            begin
                result<={aluB[15:0],16'b0};
                Overflow<=0;
            end
            MFHI:
            begin
                result<=aluA;
                Overflow<=0;
            end
            MFLO:
            begin
                result<=aluB;
                Overflow<=0;
            end
            default:
            begin
                result<=0;
                Overflow<=0;
            end
        endcase
    end
    
    assign result_add=$signed(aluA)+$signed(aluB);
    assign result_sub=$signed(aluA)-$signed(aluB);
    assign Overflow_add=(aluA[31]&aluB[31]&(~result_add[31]))|((~aluA[31])&(~aluB[31])&result_add[31]);
    assign Overflow_sub=(aluA[31]&(~aluB[31])&(~result_sub[31]))|((~aluA[31])&aluB[31]&result_sub[31]);
    
endmodule