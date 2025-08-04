# Use of Clocking Block in UVM TB
## Defining the Interface with Clocking Blocks

We’ll begin our clocking block-based testbench by defining the interface. This interface contains two clocking blocks:

1. **`drv_cb` (Driver Clocking Block)** – Configured with:
   - `input` signals: from the DUT to the testbench
   - `output` signals: from the testbench to the DUT

2. **`mon_cb` (Monitor Clocking Block)** – All signals are declared as `input`, since the monitor's role is purely observational and should not drive any values.

This separation allows for clean, directional control and ensures proper synchronization between the DUT and testbench components.

```systemverilog
interface fifo_if(input clk, rstn);
    logic push;
    logic pop;
    logic [7:0] data_in;
    logic fifo_empty;
    logic fifo_full;
    logic[4:0] count;
    logic[7:0] data_out;

    default clocking drv_cb @ (posedge clk);
        default input #1step output #1;
        // From DUT
        input data_out, count, fifo_full, fifo_empty;
        // To DUT
        output push, pop, data_in;
    endclocking

    clocking mntr_cb @(posedge clk);
        default input #1step output #1;
        input data_out, count, fifo_full, fifo_empty, push, pop, data_in;
    endclocking

endinterface
```
