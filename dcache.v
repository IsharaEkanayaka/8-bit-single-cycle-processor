/*

Module  : Data Cache 
Author  : Isuru Nawinne, Kisaru Liyanage
Date    : 25/05/2020

Description	:

This file presents a skeleton implementation of the cache controller using a Finite State Machine model.
*/
`timescale 1ns/100ps
module dcache (
    clock,reset,read,write,address,writedata,readdata,busywait,
    mem_read,mem_write,mem_address,mem_writedata,mem_readdata,mem_busywait
    );
    input read,write,clock,reset;
    input [7:0] address,writedata;
    output reg [7:0] readdata;
    output reg busywait;
    output reg mem_read, mem_write;
    output reg [5:0] mem_address;
    output reg [31:0] mem_writedata;
    input [31:0] mem_readdata;
    input mem_busywait;

    //Cache Memory
    reg [31:0] cache_data[7:0]; // 8 blocks, each with 4 bytes
    reg [2:0] cache_tag[7:0];   // Tag for each block
    reg cache_valid[7:0];       // Valid bit for each block
    reg cache_dirty[7:0];       // Dirty bit for each block

    //Splitting the address in to tag,index,offset
    wire [2:0] index = address[4:2];
    wire [2:0] tag = address[7:5];
    wire [1:0] offset = address[1:0];

    // Internal signals
    wire  [31:0] block_data;
    wire [2:0] block_tag;
    wire valid;
    wire dirty;
    wire hit;

    /*
    Combinational part for indexing, tag comparison for hit deciding, etc.*/
    assign #1 {block_tag,block_data,valid,dirty} = {cache_tag[index],cache_data[index],cache_valid[index],cache_dirty[index]};
    assign #0.9 hit = (valid && (block_tag == tag));


    always @(*) begin //combinational part for selecting the word by offset
        #1
        case (offset)
                2'b00: readdata = cache_data[index][7:0];
                2'b01: readdata = cache_data[index][15:8];
                2'b10: readdata = cache_data[index][23:16];
                2'b11: readdata = cache_data[index][31:24];
        endcase
    end
    

    always @(*) 
    begin
        if(hit)begin              
            if (read || write) begin //if it is a hit and read or write then it is a write/read hit. then required operation can be done
                busywait = 0;
                
            end 
        end else if (read || write) begin //if it is read/write miss the should interact with data memory
            busywait = 1;
        end
    end

    //write hit
    always @(posedge clock)
    begin
        if(hit) begin
            if (write) begin //writing to the correct word by offset
                #1
                case (offset)
                    2'b00: cache_data[index][7:0] = writedata;
                    2'b01: cache_data[index][15:8] = writedata;
                    2'b10: cache_data[index][23:16] = writedata;
                    2'b11: cache_data[index][31:24] = writedata;
                endcase
                cache_dirty[index] = 1; //if paticular word is updated in the dcache memory and dcache are not consistent. Therefore dirty bit is set to 1
            end
        end
    end

    /* Cache Controller FSM Start */

    parameter IDLE = 3'b000,MEM_READ = 3'b001, MEM_WRITE = 3'b010;
    reg [2:0] state, next_state;

    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:begin
                if((read || write) && !dirty && !hit)
                    next_state = MEM_READ;
                else if ((read || write) && dirty && !hit)
                    next_state = MEM_WRITE;
                else
                    next_state = IDLE;
            end
            MEM_READ:begin
                if (!mem_busywait)
                    next_state = IDLE;
                else    
                    next_state = MEM_READ;
            end
            MEM_WRITE:begin
                if (!mem_busywait)
                    next_state = MEM_READ;
                else    
                    next_state = MEM_WRITE;
            end
            default: next_state = IDLE;
        endcase
    end

    // combinational output logic
    always @(*)
    begin
        case(state)
            IDLE:
            begin
                mem_read = 0;
                mem_write = 0;
                mem_address = 8'dx;
                mem_writedata = 8'dx;
                busywait = 0;
            end
         
            MEM_READ: 
            begin
                mem_read = 1;
                mem_write = 0;
                mem_address = {tag, index};
                mem_writedata = 32'dx;
                busywait = 1;

                #1 if(mem_busywait==0) begin
                    //update the dcache
                    cache_data[index]  = mem_readdata ;
                    cache_valid[index] = 1 ;
                    cache_tag[index] = tag ;
                end
            end

            MEM_WRITE: 
            begin
                mem_read = 0;
                mem_write = 1;
                mem_address = {block_tag, index};
                mem_writedata = cache_data[index];
                busywait = 1; // Cache is waiting for memory write

                if(mem_busywait==0) begin
                    cache_dirty[index] = 0;//after writing the block in the cache to memory. memory and dcache is consistent. Therefore, not dirty
                end
            end
            
        endcase
    end

    // sequential logic for state transitioning
	integer i;
    always @(posedge clock or posedge reset)
    begin
        if(reset) begin
            state <= IDLE; //make current state IDLE
            for(i = 0 ; i<8 ;i = i+1) begin //if reset set dirty bit to 0 and valid bit to 0
                cache_dirty[i] <= 0 ;
                cache_valid[i] <= 0 ;
            end
        end
        else begin
            state <= next_state; //make current state as next_state
        end

    end

    /* Cache Controller FSM End */

    initial
	    begin 
		$dumpfile("cpu_wavedata.vcd");
		for(i=0;i<8;i++)
			$dumpvars(1,cache_data[i]);
           

	    end


endmodule
