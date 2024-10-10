`timescale 1ns/100ps
module Ror(
    input  [7:0] data,
    input  [7:0] amount,
    output [7:0] out
);

    wire [7:0] stage0;
    wire [7:0] stage1;
    wire [7:0] stage2;

    wire [2:0] amt;
    assign amt = amount[2:0];


    // Instantiate mux2x1es for Stage 0, shift 0 or 1 bit
    mux2x1 mux2x10_0 (data[0], data[1], amt[0], stage0[0]);
    mux2x1 mux2x10_1 (data[1], data[2], amt[0], stage0[1]);
    mux2x1 mux2x10_2 (data[2], data[3], amt[0], stage0[2]);
    mux2x1 mux2x10_3 (data[3], data[4], amt[0], stage0[3]);
    mux2x1 mux2x10_4 (data[4], data[5], amt[0], stage0[4]);
    mux2x1 mux2x10_5 (data[5], data[6], amt[0], stage0[5]);
    mux2x1 mux2x10_6 (data[6], data[7], amt[0], stage0[6]);
    mux2x1 mux2x10_7 (data[7], data[0], amt[0], stage0[7]);

    // Instantiate mux2x1es for Stage 1, shift 0 or 2 bits
    mux2x1 mux2x11_0 (stage0[0], stage0[2], amt[1], stage1[0]);
    mux2x1 mux2x11_1 (stage0[1], stage0[3], amt[1], stage1[1]);
    mux2x1 mux2x11_2 (stage0[2], stage0[4], amt[1], stage1[2]);
    mux2x1 mux2x11_3 (stage0[3], stage0[5], amt[1], stage1[3]);
    mux2x1 mux2x11_4 (stage0[4], stage0[6], amt[1], stage1[4]);
    mux2x1 mux2x11_5 (stage0[5], stage0[7], amt[1], stage1[5]);
    mux2x1 mux2x11_6 (stage0[6], stage0[0], amt[1], stage1[6]);
    mux2x1 mux2x11_7 (stage0[7], stage0[1], amt[1], stage1[7]);

    // Instantiate mux2x1es for Stage 2, shift 0 or 4 bits
    mux2x1 mux2x12_0 (stage1[0], stage1[4], amt[2], stage2[0]);
    mux2x1 mux2x12_1 (stage1[1], stage1[5], amt[2], stage2[1]);
    mux2x1 mux2x12_2 (stage1[2], stage1[6], amt[2], stage2[2]);
    mux2x1 mux2x12_3 (stage1[3], stage1[7], amt[2], stage2[3]);
    mux2x1 mux2x12_4 (stage1[4], stage1[0], amt[2], stage2[4]);
    mux2x1 mux2x12_5 (stage1[5], stage1[1], amt[2], stage2[5]);
    mux2x1 mux2x12_6 (stage1[6], stage1[2], amt[2], stage2[6]);
    mux2x1 mux2x12_7 (stage1[7], stage1[3], amt[2], stage2[7]);

    assign #2 out = stage2;

endmodule


