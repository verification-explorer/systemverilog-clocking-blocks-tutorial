class fifo_base_seq extends uvm_sequence # (fifo_item);

    `uvm_object_utils(fifo_base_seq)

    function new (string name="");
        super.new(name);
    endfunction

endclass

class fifo_debug_seq extends fifo_base_seq;

    int runs_num = 400;

    `uvm_object_utils(fifo_debug_seq)

    function new (string name="");
        super.new(name);
    endfunction

    task body();

        repeat (runs_num) begin
            req = fifo_item::type_id::create("rand_req");
            start_item(req);
            assert(req.randomize() with {{pop,push}!=2'b00;});
            `uvm_info("FIFO_RND",$sformatf("%s",req.convert2string()),UVM_FULL)
            finish_item(req);
        end

    endtask

endclass

