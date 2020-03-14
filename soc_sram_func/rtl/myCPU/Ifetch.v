`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/14 10:16:26
// Design Name: 
// Module Name: ifetch
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


module Ifetch(
	input clk,
	input reset,
	input stall_lu,
    input Branch_zero,
    input Jump,
    input Eret,
    input [31:0]PC_2,
    input [31:0]PC_3,
    input [31:0]PC_4,
    input Int_mem,
    input Int_wr,
    input Exc_id,
    input Exc_ex,
    input Exc_mem,
    input Exc_wr,
    output reg Exc_out,
    output reg[31:0]BadVAddr_out,
    output reg[31:0]Status_out,
    output reg[30:0]Cause_out,
    output [31:0]PC_1,
    output reg[31:0]PC
    );
    
    wire [31:0]NewPC;
    wire YorN;
    reg [2:0]sel;
    
    parameter ADEL=5'h4;

    always@(*)
    if(Exc_mem)
        sel<=3'd3;
    else if(Exc_wr)
        sel<=3'd7;
    else if(Int_mem)
        sel<=3'd3;
    else if(Int_wr)
        sel<=3'd7;
    else
    begin
        case({Branch_zero,Jump,Eret})
            3'b000:begin sel<=3'd7;end
            3'b100:begin sel<=3'd6;end
            3'b010:begin sel<=3'd5;end
            3'b001:begin sel<=3'd4;end
            default:begin sel<=3'd7;end
        endcase
    end

    always@(posedge clk)
        if(reset)
            PC<=32'hbfc00000;
        else if(stall_lu)
            PC<=PC;
        else
            PC<=NewPC;
    
    assign PC_1=PC+4;
    mux5to1#(32) mux(
                    .A(PC_1),
                    .B(PC_2),
                    .C(PC_3),
                    .D(PC_4),
                    .E(32'hbfc00380),
                    .ctr(sel),
                    .out(NewPC));
    
    assign YorN=((PC[1:0]^2'b00)&&(!Exc_id))&&((!Exc_ex)&&(!Exc_mem));
    always@(*)
        if(YorN)
        begin
            Exc_out<=1;
            BadVAddr_out<=PC;
            Status_out<={9'b0,1'b1,20'b0,1'b1,1'b0};
            Cause_out[30:0]<={24'b0,ADEL,2'b0};
        end
        else
        begin
            Exc_out<=0;
            BadVAddr_out<=0;
            Status_out<=0;
            Cause_out[30:0]<=0;
        end

endmodule