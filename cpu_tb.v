`timescale 1ns/100ps
`include "cpu.v"
`include "dmem_for_dcache.v"
`include "dcache.v"
`include "icache.v"
`include "imem_for_icache.v"
module cpu_tb;

    reg CLK, RESET;
    wire [31:0] PC;
    wire [31:0] INSTRUCTION;

    //Instruction cache and instruction imemory instatiation
    wire I_READ;
    wire [127:0] I_READINST;
    wire [5:0] I_ADDRESS;
    wire I_BUSYWAIT;
    wire BUSYWAIT_ICACHE,BUSYWAIT_DCACHE;

    icache i_cache (CLK,RESET,PC,INSTRUCTION,BUSYWAIT_ICACHE,I_READ,I_ADDRESS,I_READINST,I_BUSYWAIT);
    instruction_memory imem(CLK,I_READ,I_ADDRESS,I_READINST,I_BUSYWAIT);
    /* 
    -----
     CPU
    -----
    */
    wire WRITE,READ,BUSYWAIT,MEM_WRITE,MEM_READ,MEM_BUSYWAIT;
    wire [7:0] ADDRESS,WRITEDATA,READDATA;
    wire [5:0] MEM_ADDRESS;
    wire [31:0] MEM_WRITEDATA,MEM_READDATA;

    cpu Mycpu(PC, INSTRUCTION, CLK, RESET,BUSYWAIT,READ,WRITE,ADDRESS,READDATA,WRITEDATA);
    dcache cache (CLK,RESET,READ,WRITE,ADDRESS,WRITEDATA,READDATA,BUSYWAIT_DCACHE,
                MEM_READ,MEM_WRITE,MEM_ADDRESS,MEM_WRITEDATA,MEM_READDATA,MEM_BUSYWAIT);
    data_memory dmem(CLK,RESET,MEM_READ,MEM_WRITE,MEM_ADDRESS,MEM_WRITEDATA,MEM_READDATA,MEM_BUSYWAIT);
    or busywaitSelector(BUSYWAIT,BUSYWAIT_ICACHE,BUSYWAIT_DCACHE);


    initial
    begin
        CLK = 1'b0;
        
        // TODO: Reset the CPU (by giving a pulse to RESET signal) to start the program execution
        RESET = 1'b1;
        #5
        RESET = 1'b0;

        // finish simulation after some time
        #10000
        $finish;
        
    end
    
    // clock signal generation
    always
        #4 CLK = ~CLK;

    initial begin
        $dumpfile("cpu_wavedata.vcd");
		$dumpvars(0,cpu_tb);
    end
endmodule