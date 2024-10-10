//Lab 6 - part 2 - Group 17
`timescale 1ns/100ps
`include "alu.v"
`include "reg_file.v"
`include "pc.v"
`include "mux2x1.v"

module cpu(PC, INSTRUCTION, CLK, RESET,BUSYWAIT,READ,WRITE,ADDRESS,READDATA,WRITEDATA);
    input CLK,RESET;
    output [31:0] PC;
    input [31:0] INSTRUCTION;

    //additonal ports for data memory
    input BUSYWAIT;
    output READ,WRITE;
    output [7:0] ADDRESS,WRITEDATA;
    input [7:0] READDATA;

    wire [7:0] OPCODE,IMMEDIATE;
    wire [2:0] READREG1,READREG2,WRITEREG;

    wire WRITEENABLE,ALUSRC,NEGATE;
    wire [2:0] ALUOP;

    wire [7:0] ALURESULT,REGOUT1,REGOUT2;
    wire [7:0] twosCompREGOUT2;

    wire [7:0] mux1OUT,mux2OUT;

    //for jump and branch instruction
    wire [31:0] selOFFSET;
    wire isBraching,JUMP,BRANCH,ZERO,G1_OUTPUT;

    //wires for register write
    wire REGSRC;
    wire [7:0] REGIN;

    xor x1(G1_OUTPUT,BRANCH,JUMP);
    assign isBraching = (~ZERO)&JUMP | ZERO & G1_OUTPUT;

    pc_unit pc(CLK,RESET,PC,selOFFSET,isBraching,BUSYWAIT);
    //CombinationalLogicUnit splits the instruction in to 4 parts and the calculates the sign extended Left Shift OFFSET
    CombinationalLogicUnit CombLogic(INSTRUCTION,OPCODE,IMMEDIATE,READREG1,READREG2,WRITEREG,selOFFSET);
    //ControlUnit checks the OPCODE and generates necessary control signals
    ControlUnit Control(OPCODE,ALUOP,ALUSRC,NEGATE,WRITEENABLE,JUMP,BRANCH,BUSYWAIT,READ,WRITE,REGSRC);
    reg_file regf(REGIN,REGOUT1,REGOUT2,WRITEREG,READREG1,READREG2, WRITEENABLE, CLK, RESET,BUSYWAIT);
    //Negates the second output of reg file
    TwosComp negat(REGOUT2,twosCompREGOUT2);
    //Selects the mux1OUT by checking NEGATE
    mux mux1(REGOUT2,twosCompREGOUT2,NEGATE,mux1OUT);
    //selects the DATA2 of ALU by checking the ALUSRC
    mux mux2(IMMEDIATE,mux1OUT,ALUSRC,mux2OUT);
    alu Alu(REGOUT1,mux2OUT,ALURESULT,ALUOP,ZERO);//ZERO was additionally added to check whether result is ZERO after sub operation.
    //mux used to select the data to be written to the reg_file
    mux RegSrcSelect(ALURESULT,READDATA,REGSRC,REGIN);

    //address for the data memory is ALURESULT
    assign ADDRESS = ALURESULT;
    //data to be written to the data memory is REGOUT1
    assign WRITEDATA = REGOUT1;
endmodule

module CombinationalLogicUnit(INSTRUCTION,OPCODE,IMMEDIATE,READREG1,READREG2,WRITEREG,selOFFSET);
    input [31:0] INSTRUCTION;
    output reg [7:0] OPCODE,IMMEDIATE;
    output reg [2:0] READREG1,READREG2,WRITEREG;

    //for jump and branch instructions
    output reg [31:0] selOFFSET;
    reg [7:0] OFFSET;

    always @(INSTRUCTION) begin
        OPCODE = INSTRUCTION[31:24];
        WRITEREG = INSTRUCTION[23:16];
        READREG1 = INSTRUCTION[15:8];
        READREG2 = INSTRUCTION[7:0];
        IMMEDIATE = INSTRUCTION[7:0]; 
        OFFSET = INSTRUCTION[23:16];     //OFFSET is the number of jumps from PC+4 which is used in jump,beq instructions.
        //no.of jumps can either be negative or positive. So consider 2's complement to understand.
        selOFFSET = {{22{OFFSET[7]}},OFFSET,2'b00};//Sign extends the OFFSET to 32 bits and left shift by 2
    end
endmodule

module ControlUnit(OPCODE,ALUOP,ALUSRC,NEGATE,WRITEENABLE,JUMP,BRANCH,BUSYWAIT,READ,WRITE,REGSRC);
    input [7:0] OPCODE;
    input BUSYWAIT;
    output reg READ,WRITE,REGSRC;

    output reg WRITEENABLE,ALUSRC,NEGATE,JUMP,BRANCH;
    output reg [2:0] ALUOP;
 
//   always @(BUSYWAIT) begin
//     //The follwng if statement is to enable running of (lwi and lwd or swd and swi) instructions one after the other
//     if (BUSYWAIT == 1'b0) begin
//       READ = 1'b0;
//       WRITE = 1'b0;
//     end
//   end


    always @(OPCODE) begin
        #1  // decoding delay
    case(OPCODE)

    8'b00000000:
        // Loadi: Load Immediate
        // ALU function: Forward
        // forward DATA2 into RESULT
        // select immediate for DATA2
        begin 
            {ALUOP,WRITEENABLE,ALUSRC,JUMP,BRANCH,REGSRC,READ,WRITE} = 10'b000_1_0_0_0_0_0_0;
            //NEGATE = 1'b0; //No need to assign a value to NEGATE.
        end

    8'b00000001:
        // mov 
        // ALU function: Forward
        // Forward DATA2 into RESULT
        begin
            {ALUOP,WRITEENABLE,NEGATE,ALUSRC,JUMP,BRANCH,REGSRC,READ,WRITE} = 11'b000_1_0_1_0_0_0_0_0;
        end

    8'b00000010:
        // add
        // ALU function: Add
        // adds DATA1 and DATA2
        begin
            {ALUOP,WRITEENABLE,NEGATE,ALUSRC,JUMP,BRANCH,REGSRC,READ,WRITE} = 11'b001_1_0_1_0_0_0_0_0;
        end
    
    8'b00000011:
        // sub
        // ALU function: Add
        // adds -DATA2 and DATA1
        begin
            {ALUOP,WRITEENABLE,NEGATE,ALUSRC,JUMP,BRANCH,REGSRC,READ,WRITE} = 11'b001_1_1_1_0_0_0_0_0;
        end

    8'b00000100:
        // and
        // ALU function: and
        begin
            {ALUOP,WRITEENABLE,NEGATE,ALUSRC,JUMP,BRANCH,REGSRC,READ,WRITE} = 11'b010_1_0_1_0_0_0_0_0;
        end

    8'b00000101:
        // or
        // ALU function: or
        begin
            {ALUOP,WRITEENABLE,NEGATE,ALUSRC,JUMP,BRANCH,REGSRC,READ,WRITE} = 11'b011_1_0_1_0_0_0_0_0;
        end
    //it is important to set WRITEENABLE = 0 in either jump or beq instructions
    8'b00000110:
        // jump
        // ALU function: x
        begin
            {WRITEENABLE,JUMP,BRANCH,READ,WRITE} = 5'b0_1_0_0_0;
            //in jump instruction we don't use ALU. so it is not needed to assign values to them.only taking care of WRITEENABLE is necessary.
        end
    //ALU should execute sub operation in beq instruction since ZERO is evaluated by subtracting operands 
    8'b00000111:
        // beq
        // ALU function: sub
        begin
            {ALUOP,WRITEENABLE,NEGATE,ALUSRC,JUMP,BRANCH,READ,WRITE} = 10'b001_0_1_1_0_1_0_0;
        end
    8'b00001000:
        // mlt
        // ALU function: mlt
        begin
            {ALUOP,WRITEENABLE,NEGATE,ALUSRC,JUMP,BRANCH,REGSRC,READ,WRITE} = 11'b100_1_0_1_0_0_0_0_0;
        end
    8'b00001001:
        // bne
        // ALU function: sub
        begin
            {ALUOP,WRITEENABLE,NEGATE,ALUSRC,JUMP,BRANCH,READ,WRITE} = 10'b001_0_1_1_1_1_0_0;
        end
    8'b00001010:
        // ror
        // ALU function: Ror
        begin
            {ALUOP,WRITEENABLE,ALUSRC,JUMP,BRANCH,REGSRC,READ,WRITE} = 10'b111_1_0_0_0_0_0_0;
        end
    8'b00001011:
        // sra
        // ALU function: Sra
        begin
            {ALUOP,WRITEENABLE,ALUSRC,JUMP,BRANCH,REGSRC,READ,WRITE} = 10'b110_1_0_0_0_0_0_0;
        end
    8'b00001100:
        // sll
        // ALU function: shiftLogical
        begin
            {ALUOP,WRITEENABLE,ALUSRC,JUMP,BRANCH,REGSRC,READ,WRITE} = 10'b101_1_0_0_0_0_0_0;
        end
    8'b00001101:
        // srl
        // ALU function: shiftLogical
        begin
            {ALUOP,WRITEENABLE,ALUSRC,JUMP,BRANCH,REGSRC,READ,WRITE} = 10'b101_1_0_0_0_0_0_0;
        end
    8'b00001110:
        // lwd
        // ALU function: Forward
        begin
            {ALUOP,NEGATE,ALUSRC,JUMP,BRANCH,REGSRC,READ,WRITE} = 11'b000_0_1_0_0_1_1_0;
            WRITEENABLE = 1'b1; 
        end
    8'b00001111:
        // lwi
        // ALU function: Forward
        begin
            {ALUOP,NEGATE,ALUSRC,JUMP,BRANCH,REGSRC,READ,WRITE} = 11'b000_0_0_0_0_1_1_0;
            WRITEENABLE = 1'b1; 
        end
    8'b00010000:
        // swd
        // ALU function: Forward
        begin
            {ALUOP,WRITEENABLE,NEGATE,ALUSRC,JUMP,BRANCH,READ,WRITE} = 11'b000_0_0_1_0_0_0_1;
        end
    8'b00010001:
        // swi
        // ALU function: Forward
        begin
            {ALUOP,WRITEENABLE,NEGATE,ALUSRC,JUMP,BRANCH,READ,WRITE} = 11'b000_0_0_0_0_0_0_1;
        end
    endcase
    end
endmodule

module TwosComp(INPUT,OUTPUT);
    input [7:0] INPUT;
    output [7:0] OUTPUT;
    assign #1 OUTPUT = ~INPUT + 8'd1;//2's Complement of the INPUT is set to OUTPUT
endmodule

module mux(OPTION1,OPTION2,SELECT,OUT);//This mux is selecting its 8bits inputs to a particular wire.This is a general one which is used to mux1,mux2
    input [7:0] OPTION1,OPTION2;
    input SELECT;
    output reg [7:0] OUT;
    always @(SELECT,OPTION1,OPTION2) begin
        case(SELECT)
            1'd0 : OUT = OPTION1;
            1'd1 : OUT = OPTION2;
        endcase
    end
endmodule