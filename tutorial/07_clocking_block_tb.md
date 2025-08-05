## Defining the Interface with Clocking Blocks

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

![clocking block waveforms](/figures/clocking_tb_waveform.png)






























