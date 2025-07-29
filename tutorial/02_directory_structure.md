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
