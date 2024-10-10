`timescale 1ns/100ps
`include "extraModules/Mult.v"
`include "extraModules/Ror.v"
`include "extraModules/Sra.v"
`include "extraModules/shiftLLogical.v"
module alu(DATA1,DATA2,RESULT,SELECT,ZERO);
    input [7:0] DATA1,DATA2;
    input [2:0] SELECT;
    output reg [7:0] RESULT;
    wire [7:0] TEMP [7:0];
    output ZERO;
    
    parameter Forward = 3'b000,
              Add = 3'b001, //sub,beq,bne
              And = 3'b010,
              Or = 3'b011,
              Mult = 3'b100,
              Sll = 3'b101, //Srl
              Sra = 3'b110,
              Ror = 3'b111;

    //instantiate the subunits
    forwardUnit forward_Unit(DATA2,TEMP[0]);
    addUnit add_Unit(DATA1,DATA2,TEMP[1]);
    andUnit and_Unit(DATA1,DATA2,TEMP[2]);
    orUnit or_Unit(DATA1,DATA2,TEMP[3]);
    multUnit multiply(DATA1,DATA2,TEMP[4]);
    Ror ror(DATA1,DATA2,TEMP[5]);
    Sra sra(DATA1,DATA2,TEMP[6]);
    shiftLogical logicalShift(DATA1,DATA2,TEMP[7]);

    always @(TEMP[0],TEMP[1],TEMP[2],TEMP[3],TEMP[4],TEMP[5],TEMP[6],TEMP[7]) 
    begin
    case(SELECT)
        Forward : RESULT = TEMP[0];
        Add : RESULT = TEMP[1];
        And : RESULT = TEMP[2];
        Or : RESULT = TEMP[3];
        Mult : RESULT = TEMP[4];
        Ror : RESULT = TEMP[5];
        Sra : RESULT = TEMP[6];
        Sll : RESULT = TEMP[7];
    endcase
    end

    //zero signal (whether ALURESULT is 0)
    assign ZERO = (RESULT == 8'd0);
    
endmodule

module andUnit(DATA1,DATA2,AND_RESULT); //input and output ports are 8 bits
    input [7:0] DATA1,DATA2;
    output [7:0] AND_RESULT;
    assign #1 AND_RESULT = DATA1 & DATA2; //continous assignment with 1 time unit delay
endmodule

module addUnit(DATA1,DATA2,ADD_RESULT); //input and output ports are 8 bits
    input [7:0] DATA1,DATA2;
    output [7:0] ADD_RESULT;
    assign #2 ADD_RESULT = DATA1 + DATA2; //continous assignment with 2 time unit delay
endmodule

module forwardUnit(DATA2,FORWARD_RESULT); //input and output ports are 8 bits
    input [7:0] DATA2;
    output [7:0] FORWARD_RESULT;
    assign #1 FORWARD_RESULT = DATA2; //continous assignment with 1 time unit delay
endmodule

module orUnit(DATA1,DATA2,OR_RESULT); //input and output ports are 8 bits
    input [7:0] DATA1,DATA2;
    output [7:0] OR_RESULT;
    assign #1 OR_RESULT = DATA1 | DATA2; //continous assignment with 1 time unit delay
endmodule

