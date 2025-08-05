class fifo_base_env extends uvm_env;

    fifo_agent m_fifo_agent;
    fifo_scb   m_fifo_scb;
    fifo_cvg   m_fifo_cvg;

    `uvm_component_utils(fifo_base_env)

    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        m_fifo_agent=fifo_agent::type_id::create("m_fifo_agent",this);
        m_fifo_scb=fifo_scb::type_id::create("m_fifo_scb",this);
        m_fifo_cvg=fifo_cvg::type_id::create("m_fifo_cvg",this);
    endfunction

    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        m_fifo_agent.m_fifo_mntr.fifo_port.connect(m_fifo_scb.analysis_export);
        m_fifo_agent.m_fifo_mntr.fifo_port.connect(m_fifo_cvg.analysis_export);
    endfunction

endclass