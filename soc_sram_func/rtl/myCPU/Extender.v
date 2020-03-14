`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/18 16:44:57
// Design Name: 
// Module Name: Extender
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


module Extender1
(
    input [4:0]in,
    output reg[31:0]out
    );
    always@(*)
        out<={27'b0,in};
endmodule

module Extender2
(
    input [15:0]in,
    input ExtOp,
    output reg[31:0]out
    );
    always@(*)
    if(ExtOp)
        out<={{16{in[15]}},in};
    else
        out<={16'b0,in};
endmodule
