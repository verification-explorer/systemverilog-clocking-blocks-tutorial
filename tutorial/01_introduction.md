# Why do we need to learn systemverilog clocking blocks  #
![clocking blocks neccessity](/figures/dave_rich_refer_clocking_blocks_necessity.png "clocking blocks neccessity")

# Synchronous timimg RTL states [1] #
1. a clock event defines a moment is simulated time
2. at that moment in time, we sample the values of the various storage elements
3. and at the same moment in time, we update the storage elements to thier new values

How can inputs and outputs can be sampled and updated at the same time?

lets take a simple RTL code and analyze how the simulator works

# Simple samplled half adder in SystemVerilog

## Description
The `samp_half_adder` module implements a **half-adder** whose outputs are **sampled on the rising edge of the clock (`clk`)**. It adds two 1-bit inputs (`a` and `b`) and produces:
- `result`: The sum (exclusive OR of `a` and `b`).
- `carry`: The carry-out (AND of `a` and `b`).

An **active-low asynchronous reset (`rst_n`)** initializes both outputs (`result` and `carry`) to zero.

## SystemVerilog Code
```systemverilog
module samp_half_adder (
    input  logic clk,      // Clock signal
    input  logic rst_n,    // Active-low reset
    input  logic a,        // Data input
    input  logic b,        // Data input
    output logic result,   // Data output
    output logic carry   // Data output
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result <= 1'b0;
            carry <= 1'b0;
       end else begin
            result <= a ^ b;
            carry <= a & b;
       end
    end

endmodule


