## Defining the Interface with Clocking Blocks
:alien:
We’ll begin our clocking block-based testbench by defining the interface. This interface contains two clocking blocks:

1. **`drv_cb` (Driver Clocking Block)** – Configured with:
   - `input` signals: from the DUT to the testbench
   - `output` signals: from the testbench to the DUT

2. **`mntr_cb` (Monitor Clocking Block)** – All signals are declared as `input`, since the monitor's role is purely observational and should not drive any values.

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

in top module nothing special usual interface to DUT connection

```systemverilog
    fifo_if m_fifo_if(.clk(clk),.rstn(rstn));

    uart_tx_fifo i_uart_tx_fifo(
        .clk(clk),
        .rstn(m_fifo_if.rstn),
        .push(m_fifo_if.push),
        .pop(m_fifo_if.pop),
        .data_in(m_fifo_if.data_in),
        .fifo_empty(m_fifo_if.fifo_empty),
        .fifo_full(m_fifo_if.fifo_full),
        .count(m_fifo_if.count),
        .data_out(m_fifo_if.data_out)
        );
```

## Driving and Sampling Signals Using Clocking Block in the Driver and Monitor

As explained in the tutorial, the driver uses the **clocking block name** to synchronize signal assignments. The **clockvars** (signals defined within the clocking block) are driven with values taken from the sequence item, ensuring that all signal updates are correctly aligned with the clocking event.

```systemverilog
class fifo_drv extends uvm_driver #(fifo_item);

    virtual fifo_if m_fifo_if;

    `define tb_drv_if m_fifo_if.drv_cb

    ...

    task drive(fifo_item req);
        @(`tb_drv_if);
        `tb_drv_if.pop <= req.get_pop();
        ...
    endtask

endclass
```

```systemverilog
class fifo_mntr extends uvm_monitor;

    virtual fifo_if m_fifo_if;

    `define tb_mntr_if m_fifo_if.mntr_cb

    ...

    task run_phase(uvm_phase phase);
        ...
        forever begin
            @(`tb_mntr_if);
            item=fifo_item::type_id::create("item", this);
            item.push       = `tb_mntr_if.push;
            ...
        end
    endtask

endclass
```

## Verifying Clocking Block Effectiveness with Gate-Level Netlist

At this stage, we’ll examine the waveforms to observe how the use of clocking blocks successfully resolved the issues we encountered when running the UVM test with the gate-level netlist.

From the waveform, we can observe that the `push` signal rises **1ns after the testbench clock edge**, and `ip_count_0` updates **one full clock cycle later**. This confirms that the testbench and DUT are now properly synchronized.
 

![clocking block waveforms](/figures/clocking_tb_waveform.png)

## Clocking Block Output Skew vs. SDF Delay

In our case, the clocking block functions correctly because the **output skew** (1ns) is greater than the **SDF delay** (814ps). 

If the output skew had been set to a value **smaller than the SDF delay**, the signals might have arrived too early—leading to potential timing violations or incorrect behavior.

![clocking block skew waveforms](/figures/clocking_tb_waveform_sdf_skew.png)

## Using `negedge` for TB-DUT Synchronization ?

One tempting approach is to **drive DUT inputs and sample its outputs on the `negedge`** of the clock. 

This idea is appealing because, as testbench developers, we shift our activity **away from the `posedge`**, where most of the action takes place in both RTL and gate-level (SDF) simulations. By doing so, we avoid potential race conditions and significantly simplify the timing logic in the testbench.

However, this raises an important question:  
**Does this approach come with any risks or limitations?**

#### ✅ Potential Benefits:
- **Simplified timing**: If the DUT operates on the posedge and the testbench on the negedge, you naturally avoid race conditions. This separation creates a built-in timing margin.
- **No need for clocking blocks** in simple designs: You can avoid using clocking blocks or additional delays, especially in simpler or legacy testbenches.
- **Works well in purely synchronous RTL** where there are no additional timing effects like clock skew or SDF.

#### ⚠️ Potential Problems:
1. **Gate-level timing issues**: In post-synthesis or post-layout simulations (with SDF), the clock tree may introduce skew and delay. The negedge might **arrive too close** to the posedge at the flop, causing glitches or violating setup/hold requirements.
2. **Loss of generality**: Designing TB logic around negedge operation assumes all DUT flops are triggered on posedge. This breaks down if the DUT has mixed-edge or dual-edge logic.
3. **Reduced reusability**: A testbench designed for negedge synchronization may not be portable or reusable for other designs.

## Adapting the Clocking Block for `negedge` Operation

If you decide to operate your testbench on the **negedge** of the clock, you may find that **clocking blocks are no longer strictly necessary**, since you're naturally avoiding timing conflicts with the DUT.

However, if a clocking block is already in use, it can be easily modified to support negedge operation. Here's how you can adjust it:

```systemverilog
default clocking drv_cb @ (negedge clk);
    default input #1step output #1;
    ...
endclocking

### Slide Title: Customizing Clock Edge per Signal (Advanced Use)

If you want your clockvars to operate on the **posedge** by default but need a specific signal (e.g., `push`) to be driven on the **negedge**, you can override the edge for that individual signal using syntax like:

```systemverilog
output negedge push;
```
This causes only push to be driven on the falling edge, while the rest of the signals still follow the clocking block’s default edge (e.g., posedge).

However, this adds complexity—something we aim to avoid in this tutorial.
Keep in mind that clocking blocks are flexible and support advanced customization. For more details, refer to the SystemVerilog LRM or other comprehensive resources if you need additional functionality.

















