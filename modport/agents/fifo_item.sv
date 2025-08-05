class fifo_item extends uvm_sequence_item;

    rand bit push;
    rand bit pop;
    rand bit [7:0] data_in;

    logic [7:0] data_out;
    logic       fifo_empty;
    logic       fifo_full;
    logic [4:0] count;

    `uvm_object_utils_begin(fifo_item)
        `uvm_field_int(push, UVM_DEFAULT)
        `uvm_field_int(pop, UVM_DEFAULT)
        `uvm_field_int(data_in, UVM_DEFAULT)
        `uvm_field_int(data_out, UVM_DEFAULT)
        `uvm_field_int(fifo_empty, UVM_DEFAULT)
        `uvm_field_int(fifo_full, UVM_DEFAULT)
        `uvm_field_int(count, UVM_DEFAULT)
    `uvm_object_utils_end

    function new (string name="");
        super.new(name);
    endfunction

    function string convert2string();
        string s="";
        $sformat(s,"%s push: %0b, pop: %0b, data_in: %0h, data_out: %0h, fifo_empty: %0b, fifo_full: %0b, count: %0d\n",
            s,push,pop,data_in,data_out,fifo_empty,fifo_full,count);
        return s;
    endfunction

    // Get fifo_empty
    function bit get_fifo_empty();
        return fifo_empty;
    endfunction : get_fifo_empty

    // Set fifo_empty
    function void set_fifo_empty(bit fifo_empty);
        this.fifo_empty = fifo_empty;
    endfunction : set_fifo_empty

    // Get data_in
    function bit[7:0] get_data_in();
        return data_in;
    endfunction : get_data_in

    // Set data_in
    function void set_data_in(bit[7:0] data_in);
        this.data_in = data_in;
    endfunction : set_data_in

    // Get push
    function bit get_push();
        return push;
    endfunction : get_push

    // Set push
    function void set_push(bit push);
        this.push = push;
    endfunction : set_push

    // Get fifo_full
    function bit get_fifo_full();
        return fifo_full;
    endfunction : get_fifo_full

    // Set fifo_full
    function void set_fifo_full(bit fifo_full);
        this.fifo_full = fifo_full;
    endfunction : set_fifo_full

    // Get data_out
    function bit[7:0] get_data_out();
        return data_out;
    endfunction : get_data_out

    // Set data_out
    function void set_data_out(bit[7:0] data_out);
        this.data_out = data_out;
    endfunction : set_data_out

    // Get pop
    function bit get_pop();
        return pop;
    endfunction : get_pop

    // Set pop
    function void set_pop(bit pop);
        this.pop = pop;
    endfunction : set_pop

    // Get count
    function logic[4:0] get_count();
        return count;
    endfunction : get_count

    // Set count
    function void set_count(logic[4:0] count);
        this.count = count;
    endfunction : set_count

endclass