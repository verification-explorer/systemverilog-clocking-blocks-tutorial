class fifo_drv extends uvm_driver #(fifo_item);

    cb_drv_modport sigs;
   
    `uvm_component_utils(fifo_drv)

    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    task run_phase (uvm_phase phase);
        set_inputs();
        wait_reset();
        forever begin
            seq_item_port.get_next_item(req);
            drive(req);
            seq_item_port.item_done();
        end
    endtask

    task set_inputs();
        sigs.fifo_drv_cb.pop <= 0;
        sigs.fifo_drv_cb.push <= 0;
        sigs.fifo_drv_cb.data_in <= 0;
    endtask

    task wait_reset();
        wait(sigs.rstn == 1'b1);
    endtask

    task drive(fifo_item req);
        @(sigs.fifo_drv_cb);
        sigs.fifo_drv_cb.pop <= req.get_pop();
        sigs.fifo_drv_cb.push <= req.get_push();
        sigs.fifo_drv_cb.data_in <= req.get_data_in();
    endtask

endclass