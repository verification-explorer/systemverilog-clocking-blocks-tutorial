class fifo_drv extends uvm_driver #(fifo_item);

    virtual fifo_if m_fifo_if;

    `uvm_component_utils(fifo_drv)

    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    task run_phase (uvm_phase phase);
        wait_reset();
        forever begin
            seq_item_port.get_next_item(req);
            drive(req);
            seq_item_port.item_done();
        end
    endtask

    task wait_reset();
        wait(m_fifo_if.rstn);
        m_fifo_if.pop = 0;
        m_fifo_if.push = 0;
        m_fifo_if.data_in = 0;
    endtask

    task drive(fifo_item req);
        @(posedge m_fifo_if.clk);
        m_fifo_if.pop <= req.get_pop();
        m_fifo_if.push <= req.get_push();
        m_fifo_if.data_in <= req.get_data_in();
    endtask

endclass