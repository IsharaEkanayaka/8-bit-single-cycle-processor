`timescale 1ns/100ps
module reg_file(IN,OUT1,OUT2,INADDRESS,OUT1ADDRESS,OUT2ADDRESS, WRITE, CLK, RESET,BUSYWAIT);
    input signed [7:0] IN;
    input [2:0] INADDRESS,OUT1ADDRESS,OUT2ADDRESS;
    input WRITE, CLK, RESET,BUSYWAIT;
    output signed [7:0] OUT1,OUT2; 
    
    //declaring the register file
    reg signed [7:0] registers [7:0];

    assign #2 OUT1 = registers[OUT1ADDRESS];
    assign #2 OUT2 = registers[OUT2ADDRESS];
    
    always @(posedge CLK)
    begin
        if (RESET) begin
            for (integer count = 0; count < 8; count = count + 1) begin
                registers[count] <= #1 8'd0; 
            end
        end

        if (!BUSYWAIT) begin
            if(WRITE) begin
            #1 registers[INADDRESS] = IN; //Hold one time unit before accessing the value in IN and assigning to the particular register
            end
        end
    end

    initial
    begin
        //monitor changes in reg file content and print (used to check whether the CPU is running properly)
        #5;
		$display("\n\t\t\t==================================================");
        $display("\t\t\t Change of Register Content Starting from Time #5");
        $display("\t\t\t==================================================\n");
        $display("\t\ttime\treg0\treg1\treg2\treg3\treg4\treg5\treg6\treg7");
        $display("\t\t-----------------------------------------------------------------");
		$monitor($time, "\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d", registers[0], registers[1], registers[2], registers[3], registers[4], registers[5], registers[6], registers[7]);
    end

    initial
    begin
        $dumpfile("cpu_wavedata.vcd");
        for(integer i=0;i<8;i++)
            $dumpvars(1,registers[i]);
    end
endmodule