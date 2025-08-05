package fifo_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    typedef virtual fifo_if.DRV cb_drv_modport;
    typedef virtual fifo_if.MNTR cb_mntr_modport;

    `include "fifo_item.sv"
    `include "fifo_cfg.sv"
    typedef uvm_sequencer#(fifo_item) fifo_sqr;
    `include "fifo_drv.sv"
    `include "fifo_mntr.sv"
    `include "fifo_agent.sv"
    `include "fifo_seq_lib.sv"


endpackage