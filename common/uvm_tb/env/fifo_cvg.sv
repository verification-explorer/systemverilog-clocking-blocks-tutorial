class fifo_cvg extends uvm_subscriber #(fifo_item);

    covergroup fifo_cg with function sample (bit pop, push, bit [4:0] count);
        option.name="fifo_cg";

        count_value: coverpoint count {
            bins zero = {5'b0};
            bins mid = {[5'b01:5'b01111]};
            bins full = {5'b10000};
            illegal_bins ilgl = {[5'b10001:$]};
        }

        pop_value: coverpoint pop;

        push_value: coverpoint push;

        combinations: cross count_value, pop_value, push_value {
            ignore_bins ignore = binsof (pop_value) intersect {0} && binsof (push_value) intersect {0};
        }

    endgroup

    `uvm_component_utils(fifo_cvg)

    function new (string name, uvm_component parent);
        super.new(name,parent);
        fifo_cg=new();
    endfunction

    function void write (fifo_item t);
        fifo_cg.sample(.pop(t.get_pop()), .push(t.get_push()), .count(t.get_count()));
    endfunction

    function void report_phase (uvm_phase phase);
        `uvm_info("CVG",$sformatf("fifo coverage: %0f",fifo_cg.get_coverage()),UVM_NONE)
    endfunction

endclass
