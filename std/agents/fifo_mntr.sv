class fifo_mntr extends uvm_monitor;

    virtual fifo_if m_fifo_if;

    uvm_analysis_port#(fifo_item) fifo_port;

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
            @(posedge m_fifo_if.clk);
            item=fifo_item::type_id::create("item", this);
            item.push       = m_fifo_if.push;
            item.pop        = m_fifo_if.pop;
            item.data_in    = m_fifo_if.data_in;
            item.data_out   = m_fifo_if.data_out;
            item.fifo_empty = m_fifo_if.fifo_empty;
            item.fifo_full  = m_fifo_if.fifo_full;
            item.count      = m_fifo_if.count;
            fifo_port.write(item);
        end
    endtask

    task wait_reset();
        wait(m_fifo_if.rstn==1);
    endtask

endclass