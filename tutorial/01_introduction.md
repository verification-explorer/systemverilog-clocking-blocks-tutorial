# Why do we need to learn systemverilog clocking blocks  #
![clocking blocks neccessity](/figures/dave_rich_refer_clocking_blocks_necessity.png "clocking blocks neccessity")

# References (**TODO**)

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
```
## This is hardware represantation of the xor_flop ##
![xor flop](/figures/xor_ff.png "xor flop")

## The following plot shows the behaviour of the signals at rise edge of clk ##
![xor flop_plot](/figures/xor_ff_plot.png "xor flop plot")
Lets anlayze what happens step by step
1. before rising edge of clk input = 1'b1 and output = 1'b0 which lead to xor_out = 1'b1
2. at rising edge output changes output = 1'b0 which lead to xor_out changes xor_out = 1'b0

But wait whats going on here?
flop output changes xor output which changes flop input at the same time isn't it race condition?
How the simulator can solve this condition?
The answer to this question lies in how the Verilog event scheduler operates, lets review and understand this.

![verilog event scheduler](/figures/verilog_event_scheduler.png "verilog event scheduler")

Following is a plot from analog simulation of the xor flop
In this plot we can see the flop output is changing 47ps after rise of clock (tCQ) and the xor output which is also flop input
chnages 33ps after flop output changes (tProp). so we can see that unlike digital plot, flop input and output are not changing at the same time.

![xor flop_analog_plot](/figures/xor_ff_analog_plot.png "xor flop analog_plot")

## Project Directory Structure Overview

In the next slide, we will walk through the structure of the project directory and explain the purpose of each component.
[project directory structure](02_directory_structure.md)




