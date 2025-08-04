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
