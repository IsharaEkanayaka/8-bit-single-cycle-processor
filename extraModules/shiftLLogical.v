`timescale 1ns/100ps
module shiftLogical(data,amount,out);
    input  [7:0] data;
    input  [7:0] amount;
    output [7:0] out;

    wire rs;    // Control signal: 0 for left shift, 1 for right shift

    wire [7:0] stage0;
    wire [7:0] stage1;
    wire [7:0] stage2;

    wire [2:0] shamt;
    assign shamt = amount[2:0];

    assign rs = amount[7];

    // Intermediate wires for stage0
    wire s0_0, s0_1, s0_2, s0_3, s0_4, s0_5, s0_6, s0_7;
    mux2x1 mux_s0_0 (1'b0, data[1], rs, s0_0);
    mux2x1 mux_s0_1 (data[0], data[2], rs, s0_1);
    mux2x1 mux_s0_2 (data[1], data[3], rs, s0_2);
    mux2x1 mux_s0_3 (data[2], data[4], rs, s0_3);
    mux2x1 mux_s0_4 (data[3], data[5], rs, s0_4);
    mux2x1 mux_s0_5 (data[4], data[6], rs, s0_5);
    mux2x1 mux_s0_6 (data[5], data[7], rs, s0_6);
    mux2x1 mux_s0_7 (data[6], 1'b0, rs, s0_7);

    // Instantiate mux2x1es for Stage 0, shift 0 or 1 bit
    mux2x1 mux2x10_0 (data[0], s0_0, shamt[0], stage0[0]);
    mux2x1 mux2x10_1 (data[1], s0_1, shamt[0], stage0[1]);
    mux2x1 mux2x10_2 (data[2], s0_2, shamt[0], stage0[2]);
    mux2x1 mux2x10_3 (data[3], s0_3, shamt[0], stage0[3]);
    mux2x1 mux2x10_4 (data[4], s0_4, shamt[0], stage0[4]);
    mux2x1 mux2x10_5 (data[5], s0_5, shamt[0], stage0[5]);
    mux2x1 mux2x10_6 (data[6], s0_6, shamt[0], stage0[6]);
    mux2x1 mux2x10_7 (data[7], s0_7, shamt[0], stage0[7]);

    // Intermediate wires for stage1
    wire s1_0, s1_1, s1_2, s1_3, s1_4, s1_5, s1_6, s1_7;
    mux2x1 mux_s1_0 (1'b0, stage0[2], rs, s1_0);
    mux2x1 mux_s1_1 (1'b0, stage0[3], rs, s1_1);
    mux2x1 mux_s1_2 (stage0[0], stage0[4], rs, s1_2);
    mux2x1 mux_s1_3 (stage0[1], stage0[5], rs, s1_3);
    mux2x1 mux_s1_4 (stage0[2], stage0[6], rs, s1_4);
    mux2x1 mux_s1_5 (stage0[3], stage0[7], rs, s1_5);
    mux2x1 mux_s1_6 (stage0[4], 1'b0, rs, s1_6);
    mux2x1 mux_s1_7 (stage0[5], 1'b0, rs, s1_7);

    // Instantiate mux2x1es for Stage 1, shift 0 or 2 bits
    mux2x1 mux2x11_0 (stage0[0], s1_0, shamt[1], stage1[0]);
    mux2x1 mux2x11_1 (stage0[1], s1_1, shamt[1], stage1[1]);
    mux2x1 mux2x11_2 (stage0[2], s1_2, shamt[1], stage1[2]);
    mux2x1 mux2x11_3 (stage0[3], s1_3, shamt[1], stage1[3]);
    mux2x1 mux2x11_4 (stage0[4], s1_4, shamt[1], stage1[4]);
    mux2x1 mux2x11_5 (stage0[5], s1_5, shamt[1], stage1[5]);
    mux2x1 mux2x11_6 (stage0[6], s1_6, shamt[1], stage1[6]);
    mux2x1 mux2x11_7 (stage0[7], s1_7, shamt[1], stage1[7]);

    // Intermediate wires for stage2
    wire s2_0, s2_1, s2_2, s2_3, s2_4, s2_5, s2_6, s2_7;
    mux2x1 mux_s2_0 (1'b0, stage1[3], rs, s2_0);
    mux2x1 mux_s2_1 (1'b0, stage1[2], rs, s2_1);
    mux2x1 mux_s2_2 (1'b0, stage1[1], rs, s2_2);
    mux2x1 mux_s2_3 (1'b0, stage1[0], rs, s2_3);
    mux2x1 mux_s2_4 (stage1[0], 1'b0, rs, s2_4);
    mux2x1 mux_s2_5 (stage1[1], 1'b0, rs, s2_5);
    mux2x1 mux_s2_6 (stage1[2], 1'b0, rs, s2_6);
    mux2x1 mux_s2_7 (stage1[3], 1'b0, rs, s2_7);

    // Instantiate mux2x1es for Stage 2, shift 0 or 4 bits
    mux2x1 mux2x12_0 (stage1[0], s2_0, shamt[2], stage2[0]);
    mux2x1 mux2x12_1 (stage1[1], s2_1, shamt[2], stage2[1]);
    mux2x1 mux2x12_2 (stage1[2], s2_2, shamt[2], stage2[2]);
    mux2x1 mux2x12_3 (stage1[3], s2_3, shamt[2], stage2[3]);
    mux2x1 mux2x12_4 (stage1[4], s2_4, shamt[2], stage2[4]);
    mux2x1 mux2x12_5 (stage1[5], s2_5, shamt[2], stage2[5]);
    mux2x1 mux2x12_6 (stage1[6], s2_6, shamt[2], stage2[6]);
    mux2x1 mux2x12_7 (stage1[7], s2_7, shamt[2], stage2[7]);

    assign #2 out = stage2;
endmodule