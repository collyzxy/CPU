`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/08/09 15:00:41
// Design Name: 
// Module Name: Write
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


module Write(
    input MemtoReg,
    input [2:0]LSOp_wr,
    input [31:0]result,
    input [31:0]data,
    input [1:0]Addr_wr,
    output [31:0]dataW
    );
    
    parameter LB=3'b000;
    parameter LBU=3'b001;
    parameter LH=3'b010;
    parameter LHU=3'b011;
    parameter LW=3'b100;
    
    reg [31:0]Do;
    
//read
    always@(*)
    begin
        case(LSOp_wr)
            LB:
            begin
                case(Addr_wr[1:0])
                    2'b00:
                    begin
                        Do<={{24{data[7]}},data[7:0]};
                    end
                    2'b01:
                    begin
                        Do<={{24{data[15]}},data[15:8]};
                    end
                    2'b10:
                    begin
                        Do<={{24{data[23]}},data[23:16]};
                    end
                    2'b11:
                    begin
                        Do<={{24{data[31]}},data[31:24]};
                    end
                endcase
            end
            LBU:
            begin
                case(Addr_wr[1:0])
                    2'b00:
                    begin
                        Do<={24'b0,data[7:0]};
                    end
                    2'b01:
                    begin
                        Do<={24'b0,data[15:8]};
                    end
                    2'b10:
                    begin
                        Do<={24'b0,data[23:16]};
                    end
                    2'b11:
                    begin
                        Do<={24'b0,data[31:24]};
                    end
                endcase
            end
            LH:
            begin
                case(Addr_wr[1])
                    1'b0:
                    begin
                        Do<={{16{data[15]}},data[15:0]};
                    end
                    1'b1:
                    begin
                        Do<={{16{data[31]}},data[31:16]};
                    end
                endcase
            end
            LHU:
            begin
                case(Addr_wr[1])
                    1'b0:
                    begin
                        Do<={16'b0,data[15:0]};
                    end
                    1'b1:
                    begin
                        Do<={16'b0,data[31:16]};
                    end
                endcase
            end
            LW:
            begin
                Do<=data;
            end
            default:
            begin
                Do<=0;
            end
        endcase
    end
    
    mux2to1#(32) mux(.V(result),
                    .W(Do),
                    .Selm(MemtoReg),
                    .F(dataW));

endmodule
