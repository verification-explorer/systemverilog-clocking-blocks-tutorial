# Combining `modport` (module ports) and Clocking Blocks

According to the **IEEE 1800-2017 SystemVerilog LRM**, `modport` declarations are used within an interface to **restrict access** to signals in specific directions, depending on the role (e.g., master or slave). For example:

```systemverilog
interface i2;
    wire a, b, c, d;
    modport master (input a, b, output c, d);
    modport slave  (output a, b, input c, d);
endinterface
```
Can modport and Clocking Blocks Work Together?
Yes — clocking blocks and modports can be used together, but doing so adds structural complexity to the interface and its usage within UVM components like drivers and monitors.

So why use them together?

✅ Key Benefit:
When a component accesses the interface through a modport, it cannot directly access the raw interface signals—it can only interact via the clocking block’s clockvars.
This restriction prevents accidental misuse, such as bypassing the timing safeguards provided by the clocking block.

🛑 Example of What Modports Prevent
In an earlier chapter, we had the following code which waits on the interface signal directly:

```systemverilog
task wait_reset();
    wait(m_fifo_if.rstn == 1);
endtask
```
This approach bypasses the clocking block and may lead to race conditions or timing mismatches.
By using a modport that exposes only the clocking block, such direct access is disallowed—forcing safer, synchronized interaction through the clockvars.

## Best Practice from Bromley & Johnston — Modport + Clocking Block

One of the key guidelines from the Bromley and Johnston paper is:

> *"Declare your clocking block inside an interface. Expose the clocking block, along with any asynchronous signals related to it, through a modport. Then, in your verification components, declare a `virtual interface` typed to reference that modport."*

This slide demonstrates how to follow that guideline in practice.  
It’s up to you to decide whether the **additional structure and complexity** are justified by the **benefits in clarity, encapsulation, and safety**.

## Defining the Interface Structure with Modports

Let’s begin by outlining the interface structure. Building on the clocking block we introduced earlier, we now add **three modports**:

1. **DUT modport** – Used to connect the interface to the DUT.
2. **Driver modport** – Used by the driver to drive and sample signals via the clocking block.
3. **Monitor modport** – Used by the monitor to sample signals via the clocking block.

Each modport also includes any required **asynchronous signals**—in our case, only the **reset** signal (`rstn`) is needed.

This structure enforces controlled access and prepares the interface for clean integration with both the DUT and UVM components.

```systemverilog
interface fifo_if(input clk, rstn);
    logic push;
    logic pop;
    logic [7:0] data_in;
    logic fifo_empty;
    logic fifo_full;
    logic[4:0] count;
    logic[7:0] data_out;

    default clocking fifo_drv_cb @ (posedge clk);
        default input #1step output #1;
        // From DUT
        input data_out, count, fifo_full, fifo_empty;
        // To DUT
        output push, pop, data_in;
    endclocking

    clocking fifo_mntr_cb @ (posedge clk);
        default input #1step output #1;
        input data_out, count, fifo_full, fifo_empty, push, pop, data_in;
    endclocking

    modport DUT (
        input push, pop, data_in, rstn, clk,
        output fifo_empty, fifo_full, count, data_out
    );

    modport DRV (clocking fifo_drv_cb, input rstn);

    modport MNTR (clocking fifo_mntr_cb, input rstn);

endinterface
```

