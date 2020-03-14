`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/14 10:22:15
// Design Name: 
// Module Name: datamem
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


module Mem(
    input [31:0]PC,
    input Branch_wr,
    input Jump_wr,
    input MultDiv_ex,
    input MultDiv_mem,
    input MultDiv_wr,
    input isHILO_id,
    input RegWr_mem,
    input RegWr_wr,
    input [1:0]HIorLO_id,
    input [1:0]HIorLO_ex,
    input [1:0]HIorLO_mem,
    input [1:0]HIorLO_wr,
    input [2:0]LSOp_mem,
    input [4:0]rs_id,
    input [4:0]rt_id,
    input [4:0]rs_ex,
    input [4:0]rt_ex,
    input [4:0]rw_mem,
    input [4:0]rw_wr,
    input [31:0]result,
    input [31:0]dataD,
    input Exc_in,
    input [31:0]BadVAddr_in,
    input [31:0]Status_in,
    input [30:0]Cause_in,
    output reg Exc_out,
    output reg [31:0]BadVAddr_out,
    output reg [31:0]Status_out,
    output reg [31:0]Cause_out,
    output reg [31:0]EPC_out,
    output RsSel,
    output RtSel,
    output reg[1:0]ALUASel,
    output reg[1:0]ALUBSel,
    output reg[1:0]HISel,
    output reg[1:0]LOSel,
    output reg[3:0]wen,
    output reg[31:0]Di,
    output [31:0]dataAddr
    );

    wire C1_A;
    wire C2_A;
    wire C1_B;
    wire C2_B;
    wire C1_HI;
    wire C2_HI;
    wire C3_HI;
    wire C1_LO;
    wire C2_LO;
    wire C3_LO;
    wire YorN_1;
    wire YorN_2;
    wire [1:0]YorN;
    
    parameter SB=3'b101;
    parameter SH=3'b110;
    parameter SW=3'b111;
    parameter LB=3'b000;
    parameter LBU=3'b001;
    parameter LH=3'b010;
    parameter LHU=3'b011;
    parameter LW=3'b100;
    
    assign dataAddr={3'b0,result[28:0]};

//write
    always@(*)
        if(Exc_out)
        begin
            wen<=4'b0000;
            Di<=0;
        end
        else
        begin
            case(LSOp_mem)
                SB:
            begin
                case(result[1:0])
                    2'b00:
                    begin
                        wen<=4'b0001;
                        Di<={24'b0,dataD[7:0]};
                    end
                    2'b01:
                    begin
                        wen<=4'b0010;
                        Di<={16'b0,dataD[7:0],8'b0};
                    end
                    2'b10:
                    begin
                        wen<=4'b0100;
                        Di<={8'b0,dataD[7:0],16'b0};
                    end
                    2'b11:
                    begin
                        wen<=4'b1000;
                        Di<={dataD[7:0],24'b0};
                    end
                endcase
                end
            SH:
                begin
                case(result[1])
                    1'b0:
                    begin
                        wen<=4'b0011;
                        Di<={16'b0,dataD[15:0]};
                    end
                    1'b1:
                    begin
                        wen<=4'b1100;
                        Di<={dataD[15:0],16'b0};
                    end
                endcase
                end
            SW:
            begin
                wen<=4'b1111;
                Di<=dataD;
            end
            default:
            begin
                wen<=4'b0000;
                Di<=0;
            end
            endcase
        end

    assign C1_A=RegWr_mem&&(rw_mem^5'b0)&&(!(rw_mem^rs_ex));
    assign C1_B=RegWr_mem&&(rw_mem^5'b0)&&(!(rw_mem^rt_ex));
    assign C2_A=RegWr_wr&&(rw_wr^5'b0)&&(!(rw_wr^rs_ex));
    assign C2_B=RegWr_wr&&(rw_wr^5'b0)&&(!(rw_wr^rt_ex));
    assign RsSel=RegWr_wr&&(rw_wr^5'b0)&&(!(rw_wr^rs_id));
    assign RtSel=RegWr_wr&&(rw_wr^5'b0)&&(!(rw_wr^rt_id));
    assign C1_HI=(HIorLO_id[1]&&HIorLO_ex[1])&&(MultDiv_ex&&isHILO_id);
    assign C2_HI=(HIorLO_id[1]&&HIorLO_mem[1])&&(MultDiv_mem&&isHILO_id);
    assign C3_HI=(HIorLO_id[1]&&HIorLO_wr[1])&&(MultDiv_wr&&isHILO_id);
    assign C1_LO=(HIorLO_id[0]&&HIorLO_ex[0])&&(MultDiv_ex&&isHILO_id);
    assign C2_LO=(HIorLO_id[0]&&HIorLO_mem[0])&&(MultDiv_mem&&isHILO_id);
    assign C3_LO=(HIorLO_id[0]&&HIorLO_wr[0])&&(MultDiv_wr&&isHILO_id);
    assign YorN_1=((!(LSOp_mem^SH))&&(result[0]^1'b0))
        ||((!(LSOp_mem^SW))&&(result[1:0]^2'b00));
    assign YorN_2=(((!(LSOp_mem^LH))||(!(LSOp_mem^LHU)))&&(result[0]^1'b0))
        ||((!(LSOp_mem^LW))&&(result[1:0]^2'b00));
    assign YorN={YorN_1,YorN_2};
    
    always @(*)
    begin
        if(C1_A)
            ALUASel<=2'b01;
        else if(C2_A)
            ALUASel<=2'b10;
        else
            ALUASel<=2'b00;
        if(C1_B)
            ALUBSel<=2'b01;
        else if(C2_B)
            ALUBSel<=2'b10;
        else
            ALUBSel<=2'b00;
        if(C1_HI)
            HISel<=2'b01;
        else if(C2_HI)
            HISel<=2'b10;
        else if(C3_HI)
            HISel<=2'b11;
        else
            HISel<=2'b00;
        if(C1_LO)
            LOSel<=2'b01;
        else if(C2_LO)
            LOSel<=2'b10;
        else if(C3_LO)
            LOSel<=2'b11;
        else
            LOSel<=2'b00;
    end

    parameter ADES=5'h5;
    parameter ADEL=5'h4;
    always@(*)
    begin
        if(Branch_wr|Jump_wr)
            EPC_out<=PC-4;
        else
            EPC_out<=PC;
    end
    always@(*)
        if(Exc_in)
        begin
            Exc_out<=Exc_in;
            BadVAddr_out<=BadVAddr_in;
            Status_out<=Status_in;
            Cause_out<={(Branch_wr|Jump_wr),Cause_in};
        end
        else
        begin
        case(YorN)
        2'b10:
        begin
            Exc_out<=1;
            BadVAddr_out<=result;
            Status_out<={9'b0,1'b1,20'b0,1'b1,1'b0};
            Cause_out<={(Branch_wr|Jump_wr),24'b0,ADES,2'b0};
        end
        2'b01:
        begin
            Exc_out<=1;
            BadVAddr_out<=result;
            Status_out<={9'b0,1'b1,20'b0,1'b1,1'b0};
            Cause_out<={(Branch_wr|Jump_wr),24'b0,ADEL,2'b0};
        end
        default:
        begin
            Exc_out<=0;
            BadVAddr_out<=0;
            Status_out<=0;
            Cause_out<=0;
        end
        endcase
        end

endmodule