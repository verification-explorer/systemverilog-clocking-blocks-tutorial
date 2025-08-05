class fifo_debug_test extends fifo_base_test;

    fifo_debug_seq seq;

    `uvm_component_utils(fifo_debug_test)

    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        seq = fifo_debug_seq::type_id::create("seq",this);
    endfunction: start_of_simulation_phase
    

    task run_phase (uvm_phase phase);
        super.run_phase(phase);
        phase.raise_objection(this);
        phase.phase_done.set_drain_time(phase, 500);
        seq.start(m_fifo_base_env.m_fifo_agent.m_fifo_sqr);
        phase.drop_objection(this);
    endtask

endclass