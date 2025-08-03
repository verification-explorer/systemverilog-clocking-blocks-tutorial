### Standard Simulation Flow

In the standard scenario, we will simulate the design twice: once using the RTL and once using the gate-level netlist.

### Slide Title: Simple FIFO Interface for Case Study

For this case study, we will use a simple interface that represents the inputs and outputs of a synchronous FIFO. Notice that all signals are declared as `logic` types. This is intentional, as `logic` is a 4-state variable capable of holding values like `1'bX` (unknown) or `1'bZ` (high impedance). Using `logic` helps us catch undesirable conditions such as X-propagation during simulation.

```systemverilog
interface fifo_if(input clk, rstn);
    logic push;
    logic pop;
    logic [7:0] data_in;
    logic fifo_empty;
    logic fifo_full;
    logic [4:0] count;
    logic [7:0] data_out;
endinterface


