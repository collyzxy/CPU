`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/14 10:17:10
// Design Name: 
// Module Name: mux2to1
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


module mux2to1
#(parameter k=32)
(
      input [k-1:0]V,
      input [k-1:0]W,
      input Selm,
      output reg[k-1:0]F
);
  always @(*)
    if(Selm)
        F<=W;
    else
        F<=V;
endmodule
