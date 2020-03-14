`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/14 10:20:09
// Design Name: 
// Module Name: registers
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


module Registers(
    input clk,
    input reset,
    input [5:0]int,
    input Branch_wr,
    input Jump_wr,
    input stall_Int,
    input RegWr,
    input isHILO,
    input isCP0,
    input CP0Wr,
    input MultDiv,
    input [1:0]HISel,
    input [1:0]LOSel,
    input [1:0]HIorLO,
    input RsSel,
    input RtSel,
    input [4:0]rs_id,
    input [4:0]rt_id,
    input [4:0]rd_id,
    input [4:0]rd_mem,
    input [4:0]rw,
    input [31:0]dataH_ex,
    input [31:0]dataL_ex,
    input [31:0]dataH_mem,
    input [31:0]dataL_mem,
    input [31:0]dataH_wr,
    input [31:0]dataL_wr,
    input [31:0]PC,
    input [31:0]dataW_wr,
    input [31:0]dataD,
    input Exc_mem,
    input [31:0]BadVAddr_mem,
    input [31:0]Status_mem,
    input [31:0]Cause_mem,
    input [31:0]EPC_mem,
    output [31:0]dataA,
    output [31:0]dataB,
    output [31:0]PC_4,
    output reg Int_mem
    );
    reg[31:0] registers[31:0];
    reg[31:0] CP0[31:0];
    reg[31:0] HI;
    reg[31:0] LO;
    reg[31:0] A;
    reg[31:0] B;
    wire[31:0] dataH;
    wire[31:0] dataL;
    wire[1:0]sel;
    wire YorN;
    
    parameter BADVADDR=5'd8;
    parameter STATUS=5'd12;
    parameter CAUSE=5'd13;
    parameter EPC=5'd14;
    parameter INT=5'd0;
    
    assign PC_4=CP0[EPC];
    assign sel={isHILO,isCP0};
    assign YorN=(((!Exc_mem)&&(!stall_Int))&&
        (!(CP0[STATUS][1:0]^2'b01)))&&((((CP0[STATUS][8]&CP0[CAUSE][8])||
        (CP0[STATUS][9]&CP0[CAUSE][9]))||((CP0[STATUS][10]&CP0[CAUSE][10])||
        (CP0[STATUS][11]&CP0[CAUSE][11])))||(((CP0[STATUS][12]&CP0[CAUSE][12])||
        (CP0[STATUS][13]&CP0[CAUSE][13]))||((CP0[STATUS][14]&CP0[CAUSE][14])||
        (CP0[STATUS][15]&CP0[CAUSE][15]))));
    
//write
always@(posedge clk)
begin
    if(reset)
    begin
        registers[0]<=0;
        registers[1]<=0;
        registers[2]<=0;
        registers[3]<=0;
        registers[4]<=0;
        registers[5]<=0;
        registers[6]<=0;
        registers[7]<=0;
        registers[8]<=0;
        registers[9]<=0;
        registers[10]<=0;
        registers[11]<=0;
        registers[12]<=0;
        registers[13]<=0;
        registers[14]<=0;
        registers[15]<=0;
        registers[16]<=0;
        registers[17]<=0;
        registers[18]<=0;
        registers[19]<=0;
        registers[20]<=0;
        registers[21]<=0;
        registers[22]<=0;
        registers[23]<=0;
        registers[24]<=0;
        registers[25]<=0;
        registers[26]<=0;
        registers[27]<=0;
        registers[28]<=0;
        registers[29]<=0;
        registers[30]<=0;
        registers[31]<=0;
        CP0[0]<=0;
        CP0[1]<=0;
        CP0[2]<=0;
        CP0[3]<=0;
        CP0[4]<=0;
        CP0[5]<=0;
        CP0[6]<=0;
        CP0[7]<=0;
        CP0[8]<=0;
        CP0[9]<=0;
        CP0[10]<=0;
        CP0[11]<=0;
        CP0[12]<=0;
        CP0[13]<=0;
        CP0[14]<=0;
        CP0[15]<=0;
        CP0[16]<=0;
        CP0[17]<=0;
        CP0[18]<=0;
        CP0[19]<=0;
        CP0[20]<=0;
        CP0[21]<=0;
        CP0[22]<=0;
        CP0[23]<=0;
        CP0[24]<=0;
        CP0[25]<=0;
        CP0[26]<=0;
        CP0[27]<=0;
        CP0[28]<=0;
        CP0[29]<=0;
        CP0[30]<=0;
        CP0[31]<=0;
        CP0[STATUS][22]<=1;
        HI<=0;
        LO<=0;
    end
    else
    begin
    if(MultDiv)
    begin
        if(HIorLO[1])
            HI<=dataH_wr;
        if(HIorLO[0])
            LO<=dataL_wr;
            end
        if(RegWr)
            registers[rw]<=dataW_wr;
        if(Exc_mem)
        begin
            CP0[BADVADDR]<=BadVAddr_mem;
            CP0[STATUS]<=Status_mem;
            CP0[CAUSE]<=Cause_mem;
            CP0[EPC]<=EPC_mem;
        end
        else
        begin
            CP0[CAUSE][15:10]<=int;
            if(CP0Wr)
            begin
                case(rd_mem)
                    STATUS:begin CP0[rd_mem]<={9'b0,1'b1,6'b0,dataD[15:8],7'b0,1'b1};end
                    CAUSE:begin CP0[rd_mem][9:8]<=dataD[9:8];end
                    default:begin CP0[rd_mem]<=dataD;end
                endcase
            end
            else if(YorN)
            begin
                Int_mem<=1;
                CP0[STATUS][1]<=1;
                CP0[CAUSE][31]<=Branch_wr|Jump_wr;
                CP0[CAUSE][6:2]<=INT;
                if(Branch_wr|Jump_wr)
                    CP0[EPC]<=PC-4;
                else
                    CP0[EPC]<=PC;
            end
            else
                Int_mem<=0;
        end
    end
end    
//read
always@(*)
begin
    case(sel)
    2'b10:
    begin
       A<=dataH;
       B<=dataL;
    end
    2'b01:
    begin
        A<=CP0[rd_id];
        B<=0;
    end
    default:
    begin
        A<=registers[rs_id];
        B<=registers[rt_id];
    end
    endcase
end

     mux2to1 mux1(.V(A),
                  .W(dataW_wr),
                  .Selm(RsSel),
                  .F(dataA));
     mux2to1 mux2(.V(B),
                  .W(dataW_wr),
                  .Selm(RtSel),
                  .F(dataB));
     mux4to1 mux3(.A(HI),
                  .B(dataH_ex),
                  .C(dataH_mem),
                  .D(dataH_wr),
                  .ctr(HISel),
                  .out(dataH));
     mux4to1 mux4(.A(LO),
                  .B(dataL_ex),
                  .C(dataL_mem),
                  .D(dataL_wr),
                  .ctr(LOSel),
                  .out(dataL));
     
endmodule

