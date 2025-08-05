class fifo_scb extends uvm_subscriber #(fifo_item);

    fifo_item fifo[$];

    int match, mismatch;
    bit pop, push;

    `uvm_component_utils(fifo_scb)

    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    function void write (fifo_item t);
        fifo_item item;
        bit push, pop;
        bit [4:0] count;
        $cast(item,t.clone);

        `uvm_info(get_name(),$sformatf("%s",item.convert2string()),UVM_DEBUG)

        push = item.get_push(); pop = item.get_pop(); count = item.get_count();

        case({push,pop})
            2'b01: begin
                if (count>0) begin
                    fifo_item comparar = fifo.pop_front();
                    compare(comparar, item);
                end
            end
            2'b10: begin
                if(count <= 5'hf) begin
                    fifo.push_back(item);
                end
            end
            2'b11: begin
                if (count>0) begin
                    fifo.push_back(item);
                    begin
                        fifo_item comparar = fifo.pop_front();
                        compare(comparar, item);
                    end
                end
            end
        endcase

    endfunction

    function void compare(fifo_item comparar, item);
        if (comparar.get_data_in() != item.get_data_out()) begin
            `uvm_error(
                "MISMATCH",
                $sformatf("comparer: %0h != received: %0h",
                    comparar.get_data_in(),item.get_data_out())
            )
            mismatch++;
        end else begin
            match++;
            `uvm_info(
                "MATCH",
                $sformatf("comparer: %0h == received: %0h",
                    comparar.get_data_in(),item.get_data_out()),
                UVM_DEBUG
            )
        end
    endfunction

    function void report_phase (uvm_phase phase);
        `uvm_info("RPT",$sformatf("matchs: %0d, mismatches: %0d",match,mismatch),UVM_MEDIUM)
    endfunction

endclass
