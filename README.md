# SystemVerilog Clocking Blocks & Modports Tutorial

This repository is a hands-on tutorial for understanding and applying **SystemVerilog clocking blocks** and **modports** in a UVM-based testbench environment.

It demonstrates how to:
- Synchronize testbench-to-DUT communication
- Avoid race conditions and timing issues
- Build a cleaner, more robust simulation setup — especially at the **gate-level**

---

## 🔧 What You'll Learn

### ✅ Clocking Blocks
- How to define and use a clocking block in your interface
- Use of `#1step` skew for realistic input sampling (`tSU`)
- How to drive DUT inputs and sample outputs using `clockvars` like `drv_cb.push`
- Synchronizing using `@(clocking_block_name)` instead of `@(posedge clk)`
- Behavior at RTL vs. gate-level (SDF) simulations

### ✅ Skew Handling
- How clocking blocks resolve DUT-TB synchronization mismatches at gate level

### ✅ Modports
- How to define modports for DUT, driver, and monitor
- Exposing only required signals (e.g., reset and clockvars)
- Preventing direct access to interface signals from testbench components
- Enforcing clean access patterns through virtual interfaces

### ✅ Clean UVM Integration
- Defining `typedef` virtual interfaces for each modport in the agent package
- Declaring and assigning modport-specific interface pointers in the driver and monitor

---

## 📁 Repository Structure
```text
.
├── clocking // top and agent that include clocking block structure
│   ├── agents
│   ├── sim
│   └── tb
├── common // directory that include common files that serves all clocking and non clocking block variations
│   ├── gl // gate level netlist
│   ├── rtl // verilog 2005 RTL code
│   ├── sdf // Standard Delay Format files
│   ├── skywater-pdk-libs-sky130_fd_sc_hd // 130nm Openlave (efabless) proccess design kit
│   │   ├── cells
│   │   ├── models
│   │   ├── tech
│   │   └── timing
│   └── uvm_tb // UVM test bench
│       ├── env
│       └── tests
├── modport // top and agent that include clocking block and modports structures
│   ├── agents
│   ├── sim
│   └── tb
├── std // top and agent that include standard (non clocking block) structures
│   ├── agents
│   ├── sim
│   └── tb
├── tutorial // markdown tutorial files
└── xor_flop // xor flop use for subject introduction
```
## 📚 References

- **IEEE 1800-2017 SystemVerilog Language Reference Manual (LRM)**  
  The official standard for SystemVerilog syntax, semantics, and simulation behavior.

- **Jonathan Bromley and Keven Johnston, "Taming Testbench Timing: Time's Up for Clocking Block Confusions," SNUG (Synopsys Users Group) 2012 (Austin, TX).**  
  A foundational paper discussing best practices for synchronizing testbenches with DUTs using interfaces and clocking blocks.

- **Clifford E. Cummings, "Applying Stimulus & Sampling Outputs ‐ UVM Verification Testing Techniques"**
  A concise guide on best practices for driving inputs and sampling outputs in UVM testbenches using SystemVerilog timing constructs.

- **David Rich, "The missing link: the testbench to DUT connection"**
  paper focuses on several methodologies used in practice to connect the testbench to the DUT

- **Greg Stitt, "Race Conditions: The Root of All Verilog Evil"**
   clear explanation of the concepts behind race conditions, how they arise in Verilog and SystemVerilog, and practical strategies for avoiding them

- [**UVM scheduling and the need for Clocking Blocks**](https://verificationacademy.com/forums/t/uvm-scheduling-and-the-need-for-clocking-blocks/40325)


