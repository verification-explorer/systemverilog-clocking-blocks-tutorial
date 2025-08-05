class fifo_mntr extends uvm_monitor;

    uvm_analysis_port#(fifo_item) fifo_port;

    cb_mntr_modport sigs;

    fifo_item item;

    `uvm_component_utils(fifo_mntr)

    function new (string name, uvm_component phase);
        super.new(name, phase);
        fifo_port=new("fifo_port",this);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        wait_reset();
        forever begin
            @(sigs.fifo_mntr_cb);
            item=fifo_item::type_id::create("item", this);
            item.push       = sigs.fifo_mntr_cb.push;
            item.pop        = sigs.fifo_mntr_cb.pop;
            item.data_in    = sigs.fifo_mntr_cb.data_in;
            item.data_out   = sigs.fifo_mntr_cb.data_out;
            item.fifo_empty = sigs.fifo_mntr_cb.fifo_empty;
            item.fifo_full  = sigs.fifo_mntr_cb.fifo_full;
            item.count      = sigs.fifo_mntr_cb.count;
            fifo_port.write(item);
        end
    endtask

    task wait_reset();
        wait(sigs.rstn == 1'b1);
    endtask

endclass