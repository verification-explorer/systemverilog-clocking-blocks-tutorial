# Synchronizing Testbench and DUT 

The diagram below, based on the work of Bromley and Johnston, illustrates how signals to and from the DUT are sampled and driven in sync with the clock event. 

- Signals **from the DUT to the testbench** are sampled slightly **before** the rising edge of the clock (by `tSU`, the setup time).
- Signals **from the testbench to the DUT** are driven shortly **after** the rising edge (by `tCO`, the clock-to-output delay).

In our earlier gate-level simulation of the standard testbench use case, we observed that `data_in` was driven exactly at the clock’s rising edge. Due to clock skew between the DUT and testbench, this caused a glitch at the input of the `ip_count` flip-flop—leading to incorrect behavior.

By following this sample/drive timing scheme, we can properly align the communication between the testbench and the DUT. This is precisely what SystemVerilog **clocking blocks** are designed to achieve.
![Synchronous sampling and driving](/figures/synchronous_sampling_and_driving.png)

### Structure of a SystemVerilog Clocking Block

The following SystemVerilog code defines a typical clocking block and explains how it facilitates synchronized communication between the testbench and DUT:

1. `@ (posedge clk)` specifies the **clocking event**. All inputs and outputs within the clocking block are synchronized relative to this clock edge.
2. Signals declared as `input` and `output` are **clocking signals**. The clocking block samples inputs from the DUT and drives outputs to the DUT using controlled timing.
3. `default input #1step output #1;` sets the **default clocking skews**:
   - Inputs (from DUT to TB) are sampled **1 simulation timestep before** the clock edge.
   - Outputs (from TB to DUT) are driven **1 timestep after** the clock edge.

```systemverilog
default clocking drv_cb @ (posedge clk);
    default input #1step output #1;
    
    // Inputs from DUT
    input data_out, count, fifo_full, fifo_empty;
    
    // Outputs to DUT
    output push, pop, data_in;
endclocking

While clocking blocks also allow you to specify individual timing controls for each signal and offer additional configuration options, we’ll keep things simple in this tutorial. 

If you're interested in exploring the full range of clocking block capabilities, including advanced timing specifications, you're encouraged to consult the SystemVerilog LRM or other trusted resources.

