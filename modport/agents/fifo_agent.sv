class fifo_agent extends uvm_agent;

    fifo_drv m_fifo_drv;
    fifo_sqr m_fifo_sqr;
    fifo_cfg m_fifo_cfg;
    fifo_mntr m_fifo_mntr;

    `uvm_component_utils(fifo_agent)

    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(fifo_cfg)::get(this,"","m_fifo_cfg",m_fifo_cfg))
            `uvm_fatal("NOCFG", "Failed to get fifo config object")
        m_fifo_mntr = fifo_mntr::type_id::create("m_fifo_mntr",this);
        m_fifo_mntr.sigs = m_fifo_cfg.m_fifo_if;
        if (m_fifo_cfg.get_is_active() == UVM_ACTIVE) begin
            m_fifo_drv = fifo_drv::type_id::create("m_fifo_drv",this);
            m_fifo_drv.sigs = m_fifo_cfg.m_fifo_if;
            m_fifo_sqr = fifo_sqr::type_id::create("m_fifo_sqr",this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (m_fifo_cfg.get_is_active() == UVM_ACTIVE) begin
            m_fifo_drv.seq_item_port.connect(m_fifo_sqr.seq_item_export);
        end
    endfunction

endclass