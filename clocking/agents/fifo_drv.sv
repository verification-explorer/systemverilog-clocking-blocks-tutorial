class fifo_drv extends uvm_driver #(fifo_item);

    virtual fifo_if m_fifo_if;

    `define tb_drv_if m_fifo_if.drv_cb

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
        `tb_drv_if.pop <= 0;
        `tb_drv_if.push <= 0;
        `tb_drv_if.data_in <= 0;
    endtask

    task wait_reset();
        wait(m_fifo_if.rstn == 1);
    endtask

    task drive(fifo_item req);
        @(`tb_drv_if);
        `tb_drv_if.pop <= req.get_pop();
        `tb_drv_if.push <= req.get_push();
        `tb_drv_if.data_in <= req.get_data_in();
    endtask

endclass