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

## Defining Virtual Interface Types in the Agent Package

Next, within the agent package, we use SystemVerilog `typedef` to define:

- A **virtual interface pointer** to the **driver modport** (for use in the driver).
- A **virtual interface pointer** to the **monitor modport** (for use in the monitor).

```systemverilog
package fifo_pkg;
    ...
    typedef virtual fifo_if.DRV cb_drv_modport;
    typedef virtual fifo_if.MNTR cb_mntr_modport;
    ...
endpackage
```

## Declaring Modport Pointers in Driver and Monitor

In the driver and monitor components, we will declare **virtual interface pointers** corresponding to the modport types defined in the agent package.

These pointers will allow each component to interact with the interface in a **modport-specific**, controlled manner.

```systemverilog
class fifo_drv extends uvm_driver #(fifo_item);
    cb_drv_modport sigs;
    ...
endclass
```

```systemverilog
class fifo_mntr extends uvm_monitor;
    cb_mntr_modport sigs;
    ...
endclass
```

## Connecting the Interface to Modport Typedefs in the Agent

Within the agent (build phase), we will assign the interface instance to the corresponding **modport typedefs** defined earlier. 

```systemverilog
m_fifo_mntr.sigs = m_fifo_cfg.m_fifo_if;
```

```systemverilog
m_fifo_drv.sigs = m_fifo_cfg.m_fifo_if;
```

## Modport Enforcement in IDE Autocompletion

It's reassuring to see that my IDE’s auto-completion reflects the intended restrictions:  
I’m only able to access the **reset signal** and the **clocking block structure**—not the raw interface signals.

This behavior confirms that the use of **modports** is working as intended: it **prevents direct access** to interface signals, enforcing clean and controlled interaction through the designated clocking block.

![modport restriction](clocking_modport_restriction.png)




