

module fullAdder(a, b, c_in, s, c_out);
    input a, b, c_in;
    output s, c_out;

    wire [8:0]w;
    assign w[0] = c_in;
    assign w[1] = a;
    assign w[2] = b;

    //first xor gate for a and b
    assign w[3] = w[1] & ~w[2];
    assign w[4] = ~w[1] & w[2];
    assign w[5] = w[3] | w[4];
    
    // second xor gate for cin and output of first xor gate
    assign w[6] = w[0] & ~w[5];
    assign w[7] = ~w[0] & w[5];
    assign w[8] = w[7] | w[6];

    assign s = w[8];

    reg r;

    always@(*)
    begin
        case(w[5])
            1'b0: r = w[2];
            1'b1: r = w[0];
        endcase
    end

    assign c_out = r;
endmodule



module part1(a, b, c_in, s, c_out);
    input [3:0]a,b;
    input c_in;

    wire [3:1]c;

    output [3:0]s;
    output c_out;

    fullAdder FA1 (.a(a[0]), .b(b[0]), .c_in(c_in), .s(s[0]), .c_out(c[1]));
    fullAdder FA2 (.a(a[1]), .b(b[1]), .c_in(c[1]), .s(s[1]), .c_out(c[2]));
    fullAdder FA3 (.a(a[2]), .b(b[2]), .c_in(c[2]), .s(s[2]), .c_out(c[3]));
    fullAdder FA4 (.a(a[3]), .b(b[3]), .c_in(c[3]), .s(s[3]), .c_out(c_out));
endmodule