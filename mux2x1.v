`timescale 1ns/100ps
module mux2x1(
    input input1, 
    input input2, 
    input select, 
    output out
);
    wire c1, c2, c3;

    not n1(c1, select);
    and a1(c2, c1, input1);
    and a2(c3, select, input2);
    or o1(out, c2, c3);
endmodule