`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/14 10:20:47
// Design Name: 
// Module Name: Trans
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


module Trans(
    input [31:0]ins,
    input MemRead_ex,
    input [4:0]rw_ex,
    input [31:0]PC_1,
    input Exc_in,
    input Exc_ex,
    input Exc_mem,
    input [31:0]BadVAddr_in,
    input [31:0]Status_in,
    input [30:0]Cause_in,
    output reg Exc_out,
    output reg [31:0]BadVAddr_out,
    output reg [31:0]Status_out,
    output reg [30:0]Cause_out,
    output Branch,
    output Jump,
    output RegDst,
    output ALUSrcA,
    output ALUSrcB,
    output isHILO,
    output MemtoReg,
    output MultDiv,
    output RegWr,
    output ExtOp,
    output MemWr,
    output MemRead,
    output Eret,
    output isCP0,
    output CP0Wr,
    output [4:0]ALUOp,
    output reg[2:0]BranchOp,
    output [1:0]JumpOp,
    output [1:0]HIorLO,
    output reg[2:0]LSOp,
    output [4:0]rs,
    output [4:0]rt,
    output [4:0]rd,
    output [4:0]sa,
    output [15:0]imm16,
    output [31:0]PC_2,
    output [31:0]PC_31,
    output stall
    );
    
    wire [5:0]op;
    wire [5:0]func;
    wire [31:0]Y;
    wire [1:0]YorN;
    wire YorN_1;
    wire YorN_2;
    wire YorN_3;
    wire def;
    wire R_type;
    wire [4:0]ALUctr_R;
    wire [4:0]ALUctr_NR;

    assign op=ins[31:26];
    assign func=ins[5:0];
    assign rs=ins[25:21];
    assign rt=ins[20:16];
    assign rd=ins[15:11];
    assign sa=ins[10:6];
    assign imm16=ins[15:0];
    assign Y={{14{imm16[15]}},imm16,2'b00};
    assign PC_2=PC_1+Y;
    assign PC_31={PC_1[31:28],ins[25:0],2'b00};
    assign stall=MemRead_ex&&(((!ALUSrcA)&&(!(rw_ex^rs)))||((!ALUSrcB)&&(!(rw_ex^rt))));
    assign YorN_1=((op==6'b000000)&&(func==6'b001100))&&((!Exc_ex)&&(!Exc_mem));
    assign YorN_2=((op==6'b000000)&&(func==6'b001101))&&((!Exc_ex)&&(!Exc_mem));
    assign YorN_3=!(def||Exc_ex||Exc_mem);
    assign YorN[0]=YorN_1|YorN_3;
    assign YorN[1]=YorN_2|YorN_3;

    assign R_type=~((op[5]|op[4])|(op[3]|op[2])|(op[1]|op[0]));
    assign Branch=~((op[5]|op[4])|(op[3]|R_type))&(op[2]|(~op[1]&op[0]));
    assign ExtOp=~(R_type|op[4])&(op[5]|~op[2]);
    assign RegDst=R_type;
    assign ALUSrcA=(R_type&~func[5])&(~func[4]&~func[3])&~func[2];
    assign ALUSrcB=~(R_type|op[4])&(op[5]|op[3]);
    assign RegWr=(R_type&~((~func[5]&~func[4]&func[3])&(func[2]|(~func[2]&~func[0]))))|(~R_type&((op[3]&~op[5])|(op[5]&~op[3]&~op[1])|(~(op[3]|op[2])&(op[1]&op[0]))|(~((op[5]|op[4])|(op[3]|op[2])|op[1])&op[0]&((rt[4]&~rt[3])&(~rt[2]&~rt[1])))|((~op[5]&op[4])&(~op[3]&~op[2])&(~op[1]&~op[0])&~((rs[4]|rs[3])|(rs[2]|rs[1])|rs[0]))));
    assign MemWr=~R_type&op[5]&~op[4]&op[3];
    assign Jump=((R_type&~func[5])&(~func[4]&func[3])&(~func[2]&~func[1]))|((~R_type&~op[5])&(~op[4]&~op[3])&(~op[2]&op[1]));
    assign JumpOp={R_type,(R_type&func[0])|(~R_type&op[0])};
    assign MemtoReg=(~R_type&op[5])&(~op[4]&~op[3]);
    assign isHILO=(R_type&~func[5])&(func[4]&~func[3])&(~func[2]&~op[0]);
    assign MemRead=(~R_type&op[5])&(~op[4]&~op[3]);
    assign MultDiv=R_type&(((~func[5]&func[4])&(func[3]&~func[2]))|((~func[5]&func[4])&(~func[3]&~func[2])&func[0]));
    assign Eret=(ins==32'h42000018);
    assign isCP0=(op==6'b010000)&&(rs==5'b00000);
    assign CP0Wr=(op==6'b010000)&&(rs==5'b00100);
    assign def=(R_type&((func[5]&~func[4]&(~func[3]|(func[3]&~func[2]&func[1])))|(~func[5]&func[4]&~func[2])|((~func[5]&~func[4])&(func[3]^func[1]))|~((func[5]&func[4])&(func[3]&func[2])&(func[1]&func[0]))))|
                (~R_type&((~op[5]&~op[4]&op[3])|((~op[5]&~op[4])&~op[3]&(op[2]|(~op[2]&op[1])))|((op[5]&~op[4])&(~op[3]&~op[1]))|((~op[5]&op[4])&(~op[3]&~op[2])&(~op[1]&~op[0]))|((op[5]&~op[4])&(((~op[3]&~op[2])&(op[1]&op[0]))|((op[3]&~op[2])&~(op[1]&~op[0]))))|((~op[5]&~op[4])&(~op[3]&~op[2])&(~op[1]&op[0]))));
    assign HIorLO={((~func[5]&func[4])&(func[3]&~func[2]))|((~func[5]&func[4])&(~func[3]&~func[2])&~func[1]),
                    ((~func[5]&func[4])&(func[3]&~func[2]))|((~func[5]&func[4])&(~func[3]&~func[2])&func[1])};
    assign ALUctr_R={((~func[5]&~func[4])&(~func[3]&func[1])&func[0])|((~func[5]&func[4])&(~func[3]&~func[2])),
                     ((~func[5]&~func[4])&(~func[3]&~func[0]))|(~func[5]&func[4]&func[3])|((func[5]&~func[4])&(~func[3]&func[2])&func[1]),
                     ((~func[5]&~func[4])&(~func[3]&~func[0]))|((~func[5]&func[4])&(~func[3]&~func[2])&func[0])|((func[5]&~func[4])&(~func[3]&func[1]))|((func[5]&~func[4])&(func[3]&~func[2])&func[1]),
                     ((~func[5]&~func[4])&(~func[3]&~func[0]))|((~func[5]&func[4])&(~func[3]&~func[2])&~func[0])|((~func[5]&func[4])&(func[3]&~func[2])&func[1])|((func[5]&~func[4])&(~func[3]&func[2])&~func[1])|((func[5]&~func[4])&(func[3]&~func[2])&func[1]),
                     ((~func[5]&~func[4])&(~func[3]&func[1])&~func[0])|((~func[5]&func[4])&(~func[3]&~func[2])&func[1])|((~func[5]&func[4])&(func[3]&~func[2])&~func[0])|((func[5]&~func[4])&(~func[3]&~func[0]))|((func[5]&~func[4])&(func[3]&~func[2])&(func[1]&~func[0]))};
    assign ALUctr_NR={(~op[5]&~op[4])&(op[3]&op[2])&(op[1]&op[0]),
                      (~op[5]&~op[4])&(op[3]&op[2])&(op[1]&~op[0]),
                      (~op[5]&~op[4])&(op[3]&op[1])&~(op[2]&op[0]),
                      (~op[5]&~op[4])&op[3]&((~op[2]&op[1])|(op[2]&~op[1])),
                      (~op[5]&~op[4])&op[3]&(~op[0]|(op[2]&op[1]&op[0]))};
    mux2to1#(5) mux(.V(ALUctr_NR),
                    .W(ALUctr_R),
                    .Selm(R_type),
                    .F(ALUOp));
    
    parameter BEQ=3'b000;
    parameter BNE=3'b001;
    parameter BGEZ=3'b010;
    parameter BGTZ=3'b011;
    parameter BLEZ=3'b100;
    parameter BLTZ=3'b101;
    parameter BGEZAL=3'b110;
    parameter BLTZAL=3'b111;
    always@(*)
    begin
        if(Branch==1)
        begin
            case(op)
                6'b000100:BranchOp<=BEQ;
                6'b000101:BranchOp<=BNE;
                6'b000111:BranchOp<=BGTZ;
                6'b000110:BranchOp<=BLEZ;
                6'b000001:
                begin
                    case(rt)
                        5'b00000:BranchOp<=BLTZ;
                        5'b00001:BranchOp<=BGEZ;
                        5'b10000:BranchOp<=BLTZAL;
                        5'b10001:BranchOp<=BGEZAL;
                        default:BranchOp<=3'b000;
                    endcase
                end
                default:BranchOp<=3'b000;
            endcase
        end
        else
            BranchOp<=3'b000;
    end
    
    parameter LB=3'b000;
    parameter LBU=3'b001;
    parameter LH=3'b010;
    parameter LHU=3'b011;
    parameter LW=3'b100;
    parameter SB=3'b101;
    parameter SH=3'b110;
    parameter SW=3'b111;
    always@(*)
    begin
        case(op)
            6'b100000:LSOp<=LB;
            6'b100100:LSOp<=LBU;
            6'b100001:LSOp<=LH;
            6'b100101:LSOp<=LHU;
            6'b100011:LSOp<=LW;
            6'b101000:LSOp<=SB;
            6'b101001:LSOp<=SH;
            6'b101011:LSOp<=SW;
            default:LSOp<=3'b000;
        endcase
    end

    parameter SYS=5'h8;
    parameter BP=5'h9;
    parameter RI=5'ha;
    
    always@(*)
        if(Exc_in)
        begin
            Exc_out<=Exc_in;
            BadVAddr_out<=BadVAddr_in;
            Status_out<=Status_in;
            Cause_out<=Cause_in;
        end
        else 
        begin
        case(YorN)
        2'b01:
        begin
            Exc_out<=1;
            BadVAddr_out<=32'b0;
            Status_out<={9'b0,1'b1,20'b0,1'b1,1'b0};
            Cause_out<={24'b0,SYS,2'b0};
        end
        2'b10:
        begin
            Exc_out<=1;
            BadVAddr_out<=32'b0;
            Status_out<={9'b0,1'b1,20'b0,1'b1,1'b0};
            Cause_out<={24'b0,BP,2'b0};
        end
        2'b11:
        begin
            Exc_out<=1;
            BadVAddr_out<=32'b0;
            Status_out<={9'b0,1'b1,20'b0,1'b1,1'b0};
            Cause_out<={24'b0,RI,2'b0};
        end
        2'b00:
        begin
            Exc_out<=0;
            BadVAddr_out<=0;
            Status_out<=0;
            Cause_out<=0;
        end
        endcase
        end
endmodule
