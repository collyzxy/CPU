`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/07/14 10:15:06
// Design Name: 
// Module Name: CPU
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

//±¸×¢£º


module mycpu_top(
    input clk,
    input resetn,
    input [5:0]int,

    output reg inst_sram_en,
    output reg [3:0]inst_sram_wen,
    output reg [31:0]inst_sram_addr,
    output reg [31:0]inst_sram_wdata,
    input [31:0]inst_sram_rdata,

    output reg data_sram_en,
    output reg [3:0]data_sram_wen,
    output reg [31:0]data_sram_addr,
    output reg [31:0]data_sram_wdata,
    input [31:0]data_sram_rdata,

//debug
    output reg [31:0]debug_wb_pc,
    output reg [3:0]debug_wb_rf_wen,
    output reg [4:0]debug_wb_rf_wnum,
    output reg [31:0]debug_wb_rf_wdata
    );

    wire reset;
    wire flush_id_ex;
    wire flush_ex_mem;
    wire flush_mem_wr;
    wire stall_lu;
//IF    
    wire[31:0] PC_if;
    wire[31:0] PC_1_if;
//ID
    reg[31:0] ins_id;
    wire[31:0] PC_id;
    wire[31:0] PC_1_id;
    wire[31:0] PC_2_id;
    wire[31:0] PC_31_id;
    wire[31:0] PC_4_id;
    wire[4:0] rs_id;
    wire[4:0] rt_id;
    wire[4:0] rd_id;
    wire[4:0] sa_id;
    wire[15:0] imm16_id;
    wire Branch_id;
    wire Jump_id;
    wire RegDst_id;
    wire ALUSrcA_id;
    wire ALUSrcB_id;
    wire isHILO_id;
    wire MemtoReg_id;
    wire RegWr_id;
    wire ExtOp_id;
    wire MemWr_id;
    wire MultDiv_id;
    wire MemRead_id;
    wire Eret_id;
    wire isCP0_id;
    wire CP0Wr_id;
    wire[4:0] ALUOp_id;
    wire[2:0] BranchOp_id;
    wire[1:0] JumpOp_id;
    wire[1:0] HIorLO_id;
    wire[2:0] LSOp_id;
    wire RsSel;
    wire RtSel;
    wire[1:0] HISel;
    wire[1:0] LOSel;
    wire[31:0] dataA_id;
    wire[31:0] dataB_id;
//EX
    wire[31:0] PC_ex;
    wire[31:0] PC_2_ex;
    wire[31:0] PC_31_ex;
    wire[31:0] PC_3_ex;
    wire[4:0] rs_ex;
    wire[4:0] rt_ex;
    wire[4:0] rd_ex;
    wire[4:0] rw_ex;
    wire[4:0] sa_ex;
    wire[15:0] imm16_ex;
    wire Branch_ex;
    wire Jump_ex;
    wire RegDst_ex;
    wire ALUSrcA_ex;
    wire ALUSrcB_ex;
    wire MemtoReg_ex;
    wire RegWr_ex;
    wire ExtOp_ex;
    wire MemWr_ex;
    wire Eret_ex;
    wire MemRead_ex;
    wire Branch_zero_ex;
    wire isCP0_ex;
    wire CP0Wr_ex;
    wire MultDiv_ex;
    wire[4:0] ALUOp_ex;
    wire[2:0] BranchOp_ex;
    wire[1:0] JumpOp_ex;
    wire[1:0] HIorLO_ex;
    wire[2:0] LSOp_ex;
    wire[1:0] ALUASel;
    wire[1:0] ALUBSel;
    wire[31:0] dataA_ex;
    wire[31:0] dataB_ex;
    wire[31:0] dataD_ex;
    wire[31:0] result_ex;
    wire[31:0] dataH_ex;
    wire[31:0] dataL_ex;
//MEM
    wire[31:0] PC_mem;
    wire CP0Wr_mem;
    wire MemtoReg_mem;
    wire MemWr_mem;
    wire MultDiv_mem;
    wire RegWr_mem;
    wire Branch_mem;
    wire Branch_zero_mem;
    wire Jump_mem;
    wire[1:0] HIorLO_mem;
    wire[2:0] LSOp_mem;
    wire[31:0] dataD_mem;
    wire[31:0] dataH_mem;
    wire[31:0] dataL_mem;
    wire[3:0] wen_mem;
    wire[31:0] Di_mem;
    wire[31:0] dataAddr_mem;
    wire[31:0] result_mem;
    wire[4:0] rw_mem;
    wire[4:0] rd_mem;
//WR
    wire[31:0] PC_wr;
    wire MultDiv_wr;
    wire RegWr_wr;
    wire Branch_wr;
    wire Jump_wr;
    wire MemtoReg_wr;
    wire[31:0] dataW_wr;
    wire[31:0] dataH_wr;
    wire[31:0] dataL_wr;
    wire[1:0] HIorLO_wr;
    wire[2:0] LSOp_wr;
    wire[31:0] result_wr;
    reg [31:0] Data_wr;
    wire[4:0] rw_wr;
//exception-interrupt
    wire Exc_id_in;
    wire Exc_ex_in;
    wire Exc_mem_in;
    wire Exc_if_out;
    wire Exc_id_out;
    wire Exc_ex_out;
    wire Exc_mem_out;
    wire Exc_wr_out;
    wire Int_mem;
    wire Int_wr;
    reg stall_Int;
    wire[31:0] BadVAddr_id_in;
    wire[31:0] BadVAddr_ex_in;
    wire[31:0] BadVAddr_mem_in;
    wire[31:0] BadVAddr_if_out;
    wire[31:0] BadVAddr_id_out;
    wire[31:0] BadVAddr_ex_out;
    wire[31:0] BadVAddr_mem_out;
    wire[31:0] Status_id_in;
    wire[31:0] Status_ex_in;
    wire[31:0] Status_mem_in;
    wire[31:0] Status_if_out;
    wire[31:0] Status_id_out;
    wire[31:0] Status_ex_out;
    wire[31:0] Status_mem_out;
    wire[31:0] Cause_id_in;
    wire[31:0] Cause_ex_in;
    wire[31:0] Cause_mem_in;
    wire[31:0] Cause_if_out;
    wire[31:0] Cause_id_out;
    wire[31:0] Cause_ex_out;
    wire[31:0] Cause_mem_out;
    wire[31:0] EPC_mem_out;
    
    reg[159:0] IF_ID_reg;
    reg[320:0] ID_EX_reg;
    reg[278:0] EX_Mem_reg;
    reg[142:0] Mem_Wr_reg;
    reg[1:0] Exc_Int_reg;
    
    assign {PC_id,PC_1_id,Exc_id_in,BadVAddr_id_in,Status_id_in,Cause_id_in[30:0]}=IF_ID_reg;
    assign {PC_ex,PC_2_ex,PC_31_ex,rs_ex,rt_ex,rd_ex,sa_ex,imm16_ex,ALUSrcA_ex,ALUSrcB_ex,Eret_ex,MemtoReg_ex,RegWr_ex,ExtOp_ex,MemWr_ex,RegDst_ex,MultDiv_ex,MemRead_ex,Branch_ex,Jump_ex,isCP0_ex,CP0Wr_ex,ALUOp_ex,BranchOp_ex,JumpOp_ex,LSOp_ex,HIorLO_ex,dataA_ex,dataB_ex,Exc_ex_in,BadVAddr_ex_in,Status_ex_in,Cause_ex_in[30:0]}=ID_EX_reg;
    assign {PC_mem,Branch_mem,Jump_mem,MemtoReg_mem,RegWr_mem,CP0Wr_mem,MultDiv_mem,MemWr_mem,Branch_zero_mem,LSOp_mem,HIorLO_mem,rw_mem,rd_mem,dataD_mem,result_mem,dataH_mem,dataL_mem,Exc_mem_in,BadVAddr_mem_in,Status_mem_in,Cause_mem_in[30:0]}=EX_Mem_reg;
    assign {PC_wr,Branch_wr,Jump_wr,RegWr_wr,MultDiv_wr,MemtoReg_wr,LSOp_wr,HIorLO_wr,rw_wr,result_wr,dataH_wr,dataL_wr}=Mem_Wr_reg;
    assign {Exc_wr_out,Int_wr}=Exc_Int_reg;
    
    always@(*)
    begin
        inst_sram_en<=~(stall_lu);
        inst_sram_wen<=4'b0;
        inst_sram_addr<={3'b0,PC_if[28:0]};
        inst_sram_wdata<=32'b0;
        data_sram_en<=(MemtoReg_mem|MemWr_mem);
        data_sram_wen<=wen_mem;
        data_sram_addr<=dataAddr_mem;
        data_sram_wdata<=Di_mem;
        debug_wb_pc<=PC_wr;
        debug_wb_rf_wen<={4{RegWr_wr}};
        debug_wb_rf_wnum<=rw_wr;
        debug_wb_rf_wdata<=dataW_wr;
        ins_id<=inst_sram_rdata;
        Data_wr<=data_sram_rdata;
    end
    
    assign reset=~resetn;
    assign flush_id_ex=((reset||stall_lu)||(Eret_ex||Branch_zero_mem))||((Jump_mem
        ||Exc_mem_out))||((Exc_wr_out||Int_mem)||Int_wr);
    assign flush_ex_mem=reset||Exc_mem_out||Int_mem;
    assign flush_mem_wr=Exc_mem_out||Int_mem;
    
    always@(posedge clk)
    begin
    if(reset)
        IF_ID_reg<=160'b0;
    else if(stall_lu)
        IF_ID_reg<=IF_ID_reg;
    else
        IF_ID_reg<={PC_if,PC_1_if,Exc_if_out,BadVAddr_if_out,Status_if_out,Cause_if_out[30:0]};
    if(flush_id_ex)
        ID_EX_reg<=321'b0;
    else
        ID_EX_reg<={PC_id,PC_2_id,PC_31_id,rs_id,rt_id,rd_id,sa_id,imm16_id,ALUSrcA_id,ALUSrcB_id,Eret_id,MemtoReg_id,RegWr_id,ExtOp_id,MemWr_id,RegDst_id,MultDiv_id,MemRead_id,Branch_id,Jump_id,isCP0_id,CP0Wr_id,ALUOp_id,BranchOp_id,JumpOp_id,LSOp_id,HIorLO_id,dataA_id,dataB_id,Exc_id_out,BadVAddr_id_out,Status_id_out,Cause_id_out[30:0]};
    if(flush_ex_mem)
        EX_Mem_reg<=279'b0;
    else
        EX_Mem_reg<={PC_ex,Branch_ex,Jump_ex,MemtoReg_ex,RegWr_ex,CP0Wr_ex,MultDiv_ex,MemWr_ex,Branch_zero_ex,LSOp_ex,HIorLO_ex,rw_ex,rd_ex,dataD_ex,result_ex,dataH_ex,dataL_ex,Exc_ex_out,BadVAddr_ex_out,Status_ex_out,Cause_ex_out[30:0]};
    if(flush_mem_wr)
        Mem_Wr_reg<=143'b0;
    else
        Mem_Wr_reg<={PC_mem,Branch_mem,Jump_mem,RegWr_mem,MultDiv_mem,MemtoReg_mem,LSOp_mem,HIorLO_mem,rw_mem,result_mem,dataH_mem,dataL_mem};
    if(reset)
        Exc_Int_reg<=2'b0;
    else
        Exc_Int_reg<={Exc_mem_out,Int_mem};
    if(reset||Exc_wr_out)
        stall_Int<=0;
    else if(Eret_id)
        stall_Int<=0;
    else if(stall_Int)
        stall_Int<=1;
    else
        stall_Int<=Int_mem;
    end
    
    Ifetch IF_(
    //input
        .clk(clk),
        .reset(reset),
        .stall_lu(stall_lu),
        .Branch_zero(Branch_zero_ex),
        .Jump(Jump_ex),
        .Eret(Eret_id),
        .PC_2(PC_2_ex),
        .PC_3(PC_3_ex),
        .PC_4(PC_4_id),
    //interrupt_in
        .Int_mem(Int_mem),
        .Int_wr(Int_wr),
    //exception-in
        .Exc_id(Exc_id_out),
        .Exc_ex(Exc_ex_out),
        .Exc_mem(Exc_mem_out),
        .Exc_wr(Exc_wr_out),
    //exception-out
        .Exc_out(Exc_if_out),
        .BadVAddr_out(BadVAddr_if_out),
        .Status_out(Status_if_out),
        .Cause_out(Cause_if_out[30:0]),
    //output
        .PC_1(PC_1_if),
        .PC(PC_if)
    );

    Trans Trans(
    //input
        .ins(ins_id),
        .MemRead_ex(MemRead_ex),
        .rw_ex(rw_ex),
        .PC_1(PC_1_id),
    //exception-in
        .Exc_in(Exc_id_in),
        .Exc_ex(Exc_ex_out),
        .Exc_mem(Exc_mem_out),
        .BadVAddr_in(BadVAddr_id_in),
        .Status_in(Status_id_in),
        .Cause_in(Cause_id_in[30:0]),
    //exception-out
        .Exc_out(Exc_id_out),
        .BadVAddr_out(BadVAddr_id_out),
        .Status_out(Status_id_out),
        .Cause_out(Cause_id_out[30:0]),
    //output
        .Branch(Branch_id),
        .Jump(Jump_id),
        .RegDst(RegDst_id),
        .ALUSrcA(ALUSrcA_id),
        .ALUSrcB(ALUSrcB_id),
        .isHILO(isHILO_id),
        .MemtoReg(MemtoReg_id),
        .MultDiv(MultDiv_id),
        .RegWr(RegWr_id),
        .ExtOp(ExtOp_id),
        .MemWr(MemWr_id),
        .MemRead(MemRead_id),
        .Eret(Eret_id),
        .isCP0(isCP0_id),
        .CP0Wr(CP0Wr_id),
        .ALUOp(ALUOp_id),
        .BranchOp(BranchOp_id),
        .JumpOp(JumpOp_id),
        .HIorLO(HIorLO_id),
        .LSOp(LSOp_id),
        .rs(rs_id),
        .rt(rt_id),
        .rd(rd_id),
        .sa(sa_id),
        .imm16(imm16_id),
        .PC_2(PC_2_id),
        .PC_31(PC_31_id),
        .stall(stall_lu)
    );

    Registers Registers(
    //input
        .clk(clk),
        .reset(reset),
        .int(int),
        .Branch_wr(Branch_wr),
        .Jump_wr(Jump_wr),
        .stall_Int(stall_Int),
        .RegWr(RegWr_wr),
        .isHILO(isHILO_id),
        .isCP0(isCP0_id),
        .CP0Wr(CP0Wr_mem),
        .MultDiv(MultDiv_wr),
        .HISel(HISel),
        .LOSel(LOSel),
        .HIorLO(HIorLO_wr),
        .RsSel(RsSel),
        .RtSel(RtSel),
        .rs_id(rs_id),
        .rt_id(rt_id),
        .rd_id(rd_id),
        .rd_mem(rd_mem),
        .rw(rw_wr),
        .dataH_ex(dataH_ex),
        .dataL_ex(dataL_ex),
        .dataH_mem(dataH_mem),
        .dataL_mem(dataL_mem),
        .dataH_wr(dataH_wr),
        .dataL_wr(dataL_wr),
        .PC(PC_mem),
        .dataW_wr(dataW_wr),
        .dataD(dataD_mem),
    //exception-in
        .Exc_mem(Exc_mem_out),
        .BadVAddr_mem(BadVAddr_mem_out),
        .Status_mem(Status_mem_out),
        .Cause_mem(Cause_mem_out),
        .EPC_mem(EPC_mem_out),
    //output
        .dataA(dataA_id),
        .dataB(dataB_id),
        .PC_4(PC_4_id),
        .Int_mem(Int_mem)
    );

    Exec EX(
    //input
        .PC(PC_ex),
        .PC_31(PC_31_ex),
        .dataA(dataA_ex),
        .dataB(dataB_ex),
        .result_mem(result_mem),
        .dataW_wr(dataW_wr),
        .imm16(imm16_ex),
        .Branch(Branch_ex),
        .Jump(Jump_ex),
        .ExtOp(ExtOp_ex),
        .RegDst(RegDst_ex),
        .isCP0(isCP0_ex),
        .ALUSrcA(ALUSrcA_ex),
        .ALUSrcB(ALUSrcB_ex),
        .ALUASel(ALUASel),
        .ALUBSel(ALUBSel),
        .ALUOp(ALUOp_ex),
        .BranchOp(BranchOp_ex),
        .JumpOp(JumpOp_ex),
        .rd(rd_ex),
        .rt(rt_ex),
        .sa(sa_ex),
    //exception-in
        .Exc_in(Exc_ex_in),
        .Exc_mem(Exc_mem_out),
        .BadVAddr_in(BadVAddr_ex_in),
        .Status_in(Status_ex_in),
        .Cause_in(Cause_ex_in[30:0]),
    //exception-out
        .Exc_out(Exc_ex_out),
        .BadVAddr_out(BadVAddr_ex_out),
        .Status_out(Status_ex_out),
        .Cause_out(Cause_ex_out[30:0]),
    //output
        .Branch_zero(Branch_zero_ex),
        .rw(rw_ex),
        .result(result_ex),
        .dataH(dataH_ex),
        .dataL(dataL_ex),
        .D(dataD_ex),
        .PC_3(PC_3_ex)
    );

    Mem Mem(
    //input
        .PC(PC_mem),
        .Branch_wr(Branch_wr),
        .Jump_wr(Jump_wr),
        .MultDiv_ex(MultDiv_ex),
        .MultDiv_mem(MultDiv_mem),
        .MultDiv_wr(MultDiv_wr),
        .isHILO_id(isHILO_id),
        .RegWr_mem(RegWr_mem),
        .RegWr_wr(RegWr_wr),
        .HIorLO_id(HIorLO_id),
        .HIorLO_ex(HIorLO_ex),
        .HIorLO_mem(HIorLO_mem),
        .HIorLO_wr(HIorLO_wr),
        .LSOp_mem(LSOp_mem),
        .rs_id(rs_id),
        .rt_id(rt_id),
        .rs_ex(rs_ex),
        .rt_ex(rt_ex),
        .rw_mem(rw_mem),
        .rw_wr(rw_wr),
        .result(result_mem),
        .dataD(dataD_mem),
    //exception-in
        .Exc_in(Exc_mem_in),
        .BadVAddr_in(BadVAddr_mem_in),
        .Status_in(Status_mem_in),
        .Cause_in(Cause_mem_in[30:0]),
    //exception-out
        .Exc_out(Exc_mem_out),
        .BadVAddr_out(BadVAddr_mem_out),
        .Status_out(Status_mem_out),
        .Cause_out(Cause_mem_out),
        .EPC_out(EPC_mem_out),
    //output
        .RsSel(RsSel),
        .RtSel(RtSel),
        .ALUASel(ALUASel),
        .ALUBSel(ALUBSel),
        .HISel(HISel),
        .LOSel(LOSel),
        .wen(wen_mem),
        .Di(Di_mem),
        .dataAddr(dataAddr_mem)
    );

    Write Wr(
    //input
        .MemtoReg(MemtoReg_wr),
        .LSOp_wr(LSOp_wr),
        .result(result_wr),
        .data(Data_wr),
        .Addr_wr(result_wr[1:0]),
    //output
        .dataW(dataW_wr)
    );
    
endmodule
