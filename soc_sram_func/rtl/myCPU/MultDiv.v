`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/19 15:48:32
// Design Name: 
// Module Name: MultDiv
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


module MultDiv(
        input[31:0]A,
        input[31:0]B,
        input[4:0]ALUctr,
        output reg[31:0]HI,
        output reg[31:0]LO
    );
    parameter MULTU=5'b01000;
    parameter MULT=5'b01001;
    parameter DIVU=5'b01010;
    parameter DIV=5'b01011;
    parameter MTHI=5'b10100;
    parameter MTLO=5'b10101;
    
    always @(*)
    begin
        case(ALUctr)
            MULTU:
            begin
                {HI,LO}<=A*B;
            end
            MULT:
            begin
                {HI,LO}<=$signed(A)*$signed(B);
            end
            DIVU:
            begin
                HI<=A%B;
                LO<=A/B;
            end
            DIV:
            begin
                HI<=$signed(A)%$signed(B);
                LO<=$signed(A)/$signed(B);
            end
            MTHI:
            begin
                HI<=A;
                LO<=0;
            end
            MTLO:
            begin
                LO<=A;
                HI<=0;
            end
            default:
            begin
                HI<=0;
                LO<=0;
            end
        endcase
    end
endmodule
