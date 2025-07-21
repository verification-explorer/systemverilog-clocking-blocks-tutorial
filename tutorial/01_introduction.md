# Why do we need to learn systemverilog clocking blocks  #
![clocking blocks neccessity](/figures/dave_rich_refer_clocking_blocks_necessity.png "clocking blocks neccessity")

# Synchronous timimg RTL states [1] #
1. a clock event defines a moment is simulated time
2. at that moment in time, we sample the values of the various storage elements
3. and at the same moment in time, we update the storage elements to thier new values

How can inputs and outputs can be sampled and updated at the same time?

lets take a simple RTL code and analyze how the simulator works

# XOR Flip-Flop in SystemVerilog

## Description
The `xor_flop` module defines a **sequential XOR-based flip-flop**. On every rising edge of the clock (`clk`), the output `out` is updated by performing a **bitwise XOR** between the **current output (`out`)** and the **input (`in`)**.

An **active-low asynchronous reset (`rst_n`)** initializes `out` to zero.

## SystemVerilog Code
```systemverilog
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

This is hardware represantation of the xor_flop
![xor flop](/figures/xor_flop.png "xor flop")

