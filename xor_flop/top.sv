module xor_flop (
        input  logic clk,    // Clock signal
        input  logic rst_n,  // Active-low reset
        input  logic in,     // Data input
        output logic out     // Data output
    );

    wire logic xor_out = out ^ in;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out <= 1'b0;
        end else begin
            out <= xor_out;
        end
    end

endmodule

module top;

    logic clk;
    logic rst_n;
    logic in, out;

    xor_flop DUT(.clk(clk),.rst_n(rst_n),.in(in),.out(out));

    initial begin
        clk <= 0;
        forever #5 clk = !clk;
    end

    initial begin
        rst_n = 0;
        @ (posedge clk);
        @ (negedge clk);
        rst_n = 1;
    end

    initial begin
        in = 0;
        repeat(2) @(negedge clk);
        in = 1;
        @(negedge clk);
        in = 0;
        @(negedge clk);
        in = 1;
        repeat(2) @(negedge clk);
        $finish;
    end

    // always begin
    //     @(negedge clk);
    //     $display("@%0t a: %0b, b: %0b, result: %0b, carry: %0b",$realtime,a,b,result,carry);
    // end



endmodule