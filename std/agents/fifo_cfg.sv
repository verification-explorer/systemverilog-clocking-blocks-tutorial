class fifo_cfg extends uvm_object;

    virtual fifo_if m_fifo_if;
    uvm_active_passive_enum is_active = UVM_ACTIVE;

    `uvm_object_utils(fifo_cfg)

    function new (string name="");
        super.new(name);
    endfunction

    // Get is_active
    function uvm_active_passive_enum get_is_active();
        return is_active;
    endfunction : get_is_active

    // Set is_active
    function void set_is_active(uvm_active_passive_enum is_active);
        this.is_active = is_active;
    endfunction : set_is_active

endclass