//This module handles the operations handles on pc_unit
`timescale 1ns/100ps
module pc_unit(CLK,RESET,PC,selOFFSET,isBranching,busywait);
    input CLK,RESET,isBranching,busywait;
    wire [31:0] PC_4;
    output reg [31:0] PC;
    input [31:0] selOFFSET;

    wire [31:0] TargetAddress,PCNext;

    pc_adder add_pc(PC,PC_4);//this calculates the instruction which is after the current instruction. i.e PC+4
    JBAdder jbadder(PC_4,selOFFSET,TargetAddress);//this module calculates the jump address
    mux_32 nextpc_address(PC_4,TargetAddress,isBranching,PCNext);//selecting the next PC is TargetAdress or PC+4

    always @(posedge CLK) begin
        
            if(RESET) begin
                PC <= #1 0; //0 is taken and updated to PC after 1 time unit
            end
            else if(busywait == 1'b0) begin
                PC <= #1 PCNext; //Hold one time unit and update PC by PCNext
            end
        end 
endmodule

module pc_adder(PC,PC_4);
    input [31:0] PC;
    output reg [31:0] PC_4;
    always @(PC) begin
        #1 PC_4 = PC + 32'd4; //PC + 4 is calculated here. It updates after 1 sec when PC changes
    end
endmodule

module JBAdder(PC_4,selOFFSET,TargetAddress);
    input [31:0] PC_4,selOFFSET;
    output [31:0] TargetAddress;
    assign #2 TargetAddress = PC_4 + selOFFSET;//TargetAddress is the address calculated to jump in j and beq instructions
endmodule

module mux_32(OPTION1,OPTION2,SELECT,OUT);//This mux is used to select for PCNext from PC+4 and TargetAddress.inputs and output of this mux is 32 bits.
    input [31:0] OPTION1,OPTION2;
    input SELECT;
    output reg [31:0] OUT;
    always @(SELECT,OPTION1,OPTION2) begin
        case(SELECT)
            1'd0 : OUT = OPTION1;
            1'd1 : OUT = OPTION2;
        endcase
    end
endmodule