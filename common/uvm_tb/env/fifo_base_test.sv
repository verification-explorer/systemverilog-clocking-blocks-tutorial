class fifo_base_test extends uvm_test;

    fifo_cfg m_fifo_cfg;
    fifo_base_env m_fifo_base_env;

    `uvm_component_utils(fifo_base_test)

    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);

        // Get fifo virtual interface and set fifo cfg object to dB
        m_fifo_cfg=fifo_cfg::type_id::create("m_fifo_cfg",this);
        if(!uvm_config_db#(virtual fifo_if)::get(this,"","m_fifo_if",m_fifo_cfg.m_fifo_if))
            `uvm_fatal("NOVIF","Failed to get fifo virtual interface")
        uvm_config_db#(fifo_cfg)::set(this,"m_fifo_base_env.m_fifo_agent*","m_fifo_cfg",m_fifo_cfg);

        // Build env
        m_fifo_base_env = fifo_base_env::type_id::create("m_fifo_base_env",this);
        
    endfunction

endclass