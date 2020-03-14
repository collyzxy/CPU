`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/14 14:34:17
// Design Name: 
// Module Name: mux3to1
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


module mux3to1
#(parameter k=32)
(
	input [k-1:0] A,
	input [k-1:0] B,
	input [k-1:0] C,
	input [1:0] ctr,
	output reg [k-1:0] out
);
	
always @(*)
begin
	case(ctr)
	2'b00:
		begin out<=A;end
	2'b01:
		begin out<=B;end
	2'b10:
		begin out<=C;end
    default:
        begin out<=A;end
    endcase
end
	
endmodule
