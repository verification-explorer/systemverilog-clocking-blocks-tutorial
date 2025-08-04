# Synchronizing Testbench and DUT 

The diagram below, based on the work of Bromley and Johnston, illustrates how signals to and from the DUT are sampled and driven in sync with the clock event. 

- Signals **from the DUT to the testbench** are sampled slightly **before** the rising edge of the clock (by `tSU`, the setup time).
- Signals **from the testbench to the DUT** are driven shortly **after** the rising edge (by `tCO`, the clock-to-output delay).

In our earlier gate-level simulation of the standard testbench use case, we observed that `data_in` was driven exactly at the clock’s rising edge. Due to clock skew between the DUT and testbench, this caused a glitch at the input of the `ip_count` flip-flop—leading to incorrect behavior.

By following this sample/drive timing scheme, we can properly align the communication between the testbench and the DUT. This is precisely what SystemVerilog **clocking blocks** are designed to achieve.
![Synchronous sampling and driving](/figures/Synchronous_sampling_and_driving.png)

