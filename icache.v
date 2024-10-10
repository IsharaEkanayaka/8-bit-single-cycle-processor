// CO224 - Lab 6 - Part 3
// Group 17
`timescale 1ns/100ps
module icache (
    clock,reset,pc,instruction,busywait,
    i_read,i_address,i_readdata,i_busywait
    );
    input clock,reset;
    input [31:0] pc;
    output reg [31:0] instruction;
    output reg busywait;
    output reg i_read;
    output reg [5:0] i_address;
    input [127:0] i_readdata;
    input i_busywait;

    //Cache Memory
    reg [127:0] cache_data[7:0]; // 8 blocks, each with 16 bytes
    reg [2:0] cache_tag[7:0];   // Tag for each block
    reg cache_valid[7:0];       // Valid bit for each block

    //Splitting the address in to tag,index,offset
    /*since pc is multiple of 4, pc[1:0] will always be 00.
      Therefore, pc[9:2] is splitted in to offset,index and tag
    */
    wire [2:0] index = pc[6:4];
    wire [2:0] tag = pc[9:7];
    wire [1:0] offset = pc[3:2];

    // Internal signals
    wire  [127:0] block_data; //block of 4 instructions for the given index in pc.
    wire [2:0] block_tag; //stored tag for the given index in pc
    wire valid; //valid bit for the given index in pc
    wire hit; //hit or miss

    /*
    Combinational part for indexing, tag comparison for hit deciding, etc.*/
    assign #1 {block_tag,block_data,valid} = {cache_tag[index],cache_data[index],cache_valid[index]}; //indexing with #1 delay
    assign #0.9 hit = (valid && (block_tag == tag)); //latency for tag comparison and hit deciding


    always @(*) begin //combinational part for selecting the instruction by offset
        #1
        case (offset)
                2'b00: instruction = cache_data[index][31:0];
                2'b01: instruction = cache_data[index][63:32];
                2'b10: instruction = cache_data[index][95:64];
                2'b11: instruction = cache_data[index][127:96];
        endcase
    end
    
    always @(*) 
    begin
        if(hit)begin
            busywait = 0;

        end else begin
            busywait = 1;
        end
    end

    /* Cache Controller FSM Start */

    parameter IDLE = 1'b0,I_READ = 1'b1;
    reg state, next_state;

    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:begin
                if(!hit)     //if it is a miss, next_state is I_READ
                    next_state = I_READ;
                else        //if it is a hit, next_state is IDLE
                    next_state = IDLE;
            end
            I_READ:begin
                if (!i_busywait)      //when data read in instruction memory is done, next_state is IDLE
                    next_state = IDLE;
                else                 //when data read in instruction memory is not done, remain in I_READ
                    next_state = I_READ;
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
                i_read = 0;//don't read from instruction memory
                i_address = 6'dx;
                busywait = 0; //in this state icache is not busy
            end
         
            I_READ: 
            begin
                i_read = 1; //signal to read from instruction memory
                i_address = {tag, index};//concatenate tag and index to make the address to be read from instruction memory
                busywait = 1; //in this state icache is busy

                #1 if(i_busywait==0) begin
                    //updating the cache entry with new data
                    cache_data[index]  = i_readdata ;
                    cache_valid[index] = 1 ;
                    cache_tag[index] = tag ;
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
            for(i = 0 ; i<8 ;i = i+1) begin
                cache_valid[i] = 0 ; //set valid bit to 0 in valid bit array of icache
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
			$dumpvars(1,cache_data[i],cache_valid[i],cache_tag[i]); //dump the icache content
	    end
endmodule
