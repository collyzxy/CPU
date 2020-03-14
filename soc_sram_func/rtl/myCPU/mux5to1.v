`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/08/04 11:15:11
// Design Name: 
// Module Name: mux5to1
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


module mux5to1
#(parameter k=32)
(
	input [k-1:0] A,
	input [k-1:0] B,
	input [k-1:0] C,
	input [k-1:0] D,
	input [k-1:0] E,
	input [2:0] ctr,
	output reg [k-1:0] out
);
	
always @(*)
begin
    case(ctr)
	3'b111:
		begin out<=A;end
	3'b110:
		begin out<=B;end
	3'b101:
		begin out<=C;end
    3'b100:
        begin out<=D;end
    3'b011:
        begin out<=E;end
    default:
        begin out<=A;end
    endcase
end
endmodule
