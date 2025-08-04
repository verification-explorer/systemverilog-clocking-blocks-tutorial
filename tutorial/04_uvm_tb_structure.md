# UVM Environment Overview

The UVM test used for this simulation is `fifo_base_test`, which instantiates the main environment component: `fifo_base_env`. A configuration object (`fifo_cfg`) is passed into the environment to control test-specific parameters.

## Environment Components

The `fifo_base_env` contains the following sub-components:

- **`fifo_agent`**  
  This UVM agent is responsible for generating and driving sequence items. Depending on the test scenario (e.g., push only, pop only, or simultaneous operations), it sends different variations of read/write transactions to the DUT. These variations are designed to exercise specific behaviors related to the **clocking block use cases**.

- **`fifo_scb` (Scoreboard)**  
  The scoreboard collects sequence items during write operations and stores them in a queue or model. When data is read from the FIFO, the scoreboard compares it against the expected data to ensure functional correctness.

- **`fifo_cvg` (Coverage Collector)**  
  This component collects functional coverage based on the observed sequence items. It helps evaluate how thoroughly the FIFO design has been exercised during simulation.

## Monitor Connections

The monitor within the agent broadcasts transaction-level data through an **analysis port**, which is **connected to both the scoreboard and the coverage collector**. This allows both components to receive real-time updates about all bus activity, enabling accurate checking and coverage collection.

---

![uvm test bench](/figures/uvm_components_of_fifo_debug_test.png "uvm test bench")

## Comparing RTL and Gate-Level Simulations

In the next slide, we will simulate both the RTL and the gate-level netlist. We'll observe how the results differ due to internal clock skews introduced in the gate-level netlist.
[standard tb](05_standard_rtl_tb.md)

