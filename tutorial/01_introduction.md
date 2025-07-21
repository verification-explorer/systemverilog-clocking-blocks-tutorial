# Why do we need to learn systemverilog clocking blocks  #
![clocking blocks neccessity](/figures/dave_rich_refer_clocking_blocks_necessity.png "clocking blocks neccessity")

# Synchronous timimg RTL states [1] #
1. a clock event defines a moment is simulated time
2. at that moment in time, we sample the values of the various storage elements
3. and at the same moment in time, we update the storage elements to thier new values

How can inputs and outputs can be sampled and updated at the same time?

lets take a simple flop with adder in front of it and analyze how the simulator works

# Simple D Flip-Flop in SystemVerilog

## Description
A D flip-flop captures the value of the input `d` on the rising edge of the clock (`clk`). If reset (`rst_n`) is active low, the output `q` is reset to `0`.

## SystemVerilog Code
```systemverilog
module d_flip_flop (
    input  logic clk,      // Clock signal
    input  logic rst_n,    // Active-low reset
    input  logic d,        // Data input
    output logic q         // Data output
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            q <= 1'b0;
        else
            q <= d;
    end

endmodule


