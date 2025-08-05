package fifo_uvm_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import fifo_pkg::*;

    `include "env/fifo_scb.sv"
    `include "env/fifo_cvg.sv"
    `include "env/fifo_base_env.sv"
    `include "env/fifo_base_test.sv"
    `include "tests/fifo_debug_test.sv"
endpackage