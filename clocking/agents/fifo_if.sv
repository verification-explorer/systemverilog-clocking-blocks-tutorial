interface fifo_if(input clk, rstn);
    logic push;
    logic pop;
    logic [7:0] data_in;
    logic fifo_empty;
    logic fifo_full;
    logic[4:0] count;
    logic[7:0] data_out;

    default clocking drv_cb @ (posedge clk);
        default input #1step output #1;
        // From DUT
        input data_out, count, fifo_full, fifo_empty;
        // To DUT
        output push, pop, data_in;
    endclocking

    clocking mntr_cb @(posedge clk);
        default input #1step output #1;
        input data_out, count, fifo_full, fifo_empty, push, pop, data_in;
    endclocking

endinterface