# Combining `modport` and Clocking Blocks — Why and When?

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
