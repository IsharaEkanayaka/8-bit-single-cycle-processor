`timescale 1ns/100ps
module FullAdder (A, B, Cin, Sum, Cout);
    input A,B,Cin;
    output Sum,Cout;

    wire s1,c1,c2;

    xor x1(s1,A,B);
    xor x2(Sum,s1,Cin);

    and a1(c1,s1,Cin);
    and a2(c2,B,A);

    or o1(Cout,c1,c2);
endmodule

module multUnit(
    input [7:0] X,
    input [7:0] Y,
    output [7:0] RESULT // Note: 8-bit output for lower part of 8x8 multiplication
);

    wire [7:0] MULT;

    // Intermediate sums and carries
    wire C1;
    wire [1:0] C2;
    wire [2:0] C3;
    wire [3:0] C4;
    wire [4:0] C5;
    wire [5:0] C6;
    wire [6:0] C7;
    wire S2;
    wire [1:0] S3;
    wire [2:0] S4;
    wire [3:0] S5;
    wire [4:0] S6;
    wire [5:0] S7;

    // Calculate each bit of the product
    assign MULT[0] = X[0] & Y[0];

    // Column 1
    FullAdder col1_0 (X[1] & Y[0], X[0] & Y[1], 1'b0, MULT[1], C1);

    // Column 2
    FullAdder col2_0 (X[2] & Y[0], X[1] & Y[1], C1, S2, C2[0]);
    FullAdder col2_1 (S2, X[0] & Y[2], 1'b0, MULT[2], C2[1]);

    // Column 3
    FullAdder col3_0 (X[3] & Y[0], X[2] & Y[1], C2[0], S3[0], C3[0]);
    FullAdder col3_1 (S3[0], X[1] & Y[2], C2[1], S3[1], C3[1]);
    FullAdder col3_2 (S3[1], X[0] & Y[3], 1'b0, MULT[3], C3[2]);

    // Column 4
    FullAdder col4_0 (X[4] & Y[0], X[3] & Y[1], C3[0], S4[0], C4[0]);
    FullAdder col4_1 (S4[0], X[2] & Y[2], C3[1], S4[1], C4[1]);
    FullAdder col4_2 (S4[1], X[1] & Y[3], C3[2], S4[2], C4[2]);
    FullAdder col4_3 (S4[2], X[0] & Y[4], 1'b0, MULT[4], C4[3]);

    // Column 5
    FullAdder col5_0 (X[5] & Y[0], X[4] & Y[1], C4[0], S5[0], C5[0]);
    FullAdder col5_1 (S5[0], X[3] & Y[2], C4[1], S5[1], C5[1]);
    FullAdder col5_2 (S5[1], X[2] & Y[3], C4[2], S5[2], C5[2]);
    FullAdder col5_3 (S5[2], X[1] & Y[4], C4[3], S5[3], C5[3]);
    FullAdder col5_4 (S5[3], X[0] & Y[5], 1'b0, MULT[5], C5[4]);

    // Column 6
    FullAdder col6_0 (X[6] & Y[0], X[5] & Y[1], C5[0], S6[0], C6[0]);
    FullAdder col6_1 (S6[0], X[4] & Y[2], C5[1], S6[1], C6[1]);
    FullAdder col6_2 (S6[1], X[3] & Y[3], C5[2], S6[2], C6[2]);
    FullAdder col6_3 (S6[2], X[2] & Y[4], C5[3], S6[3], C6[3]);
    FullAdder col6_4 (S6[3], X[1] & Y[5], C5[4], S6[4], C6[4]);
    FullAdder col6_5 (S6[4], X[0] & Y[6], 1'b0, MULT[6], C6[5]);

    // Column 7
    FullAdder col7_0 (X[7] & Y[0], X[6] & Y[1], C6[0], S7[0], C7[0]);
    FullAdder col7_1 (S7[0], X[5] & Y[2], C6[1], S7[1], C7[1]);
    FullAdder col7_2 (S7[1], X[4] & Y[3], C6[2], S7[2], C7[2]);
    FullAdder col7_3 (S7[2], X[3] & Y[4], C6[3], S7[3], C7[3]);
    FullAdder col7_4 (S7[3], X[2] & Y[5], C6[4], S7[4], C7[4]);
    FullAdder col7_5 (S7[4], X[1] & Y[6], C6[5], S7[5], C7[5]);
    FullAdder col7_6 (S7[5], X[0] & Y[7], 1'b0, MULT[7], C7[6]);

    //assigning the result to output after #3 time units
    assign #3 RESULT = MULT;
endmodule


// `timescale 1ns / 1ps

// module mult_tb;
//     // Inputs
//     reg [7:0] X;
//     reg [7:0] Y;

//     // Outputs
//     wire [7:0] MULT;

//     // Instantiate the multiplier
//     mult uut (
//         .X(X),
//         .Y(Y),
//         .RESULT(MULT)
//     );

//     // Monitor changes and display results
//     initial begin
//         $monitor("Time = %0d ns, X = %b, Y = %b, MULT = %b", $time, X, Y, MULT);
//     end

//     // Test vectors
//     initial begin
//         // Initialize inputs
//         X = 8'b00000000; Y = 8'b00000000;
//         #10; // Wait for 10 time units

//         // Test case 1
//         X = 8'b00000001; Y = 8'b00000001;
//         #10; // Wait for 10 time units

//         // Test case 2
//         X = 8'b00000011; Y = 8'b00000010;
//         #10; // Wait for 10 time units

//         // Test case 3
//         X = 8'b00000101; Y = 8'b00000101;
//         #10; // Wait for 10 time units

//         // Test case 4
//         X = 8'b00001111; Y = 8'b00000011;
//         #10; // Wait for 10 time units

//         // Test case 5
//         X = 8'b11111111; Y = 8'b00000001;
//         #10; // Wait for 10 time units

//         // Test case 6
//         X = 8'b11111111; Y = 8'b11111111;
//         #10; // Wait for 10 time units

//         // Add more test cases as needed
//         // End of test
//         $finish;
//     end
// endmodule
