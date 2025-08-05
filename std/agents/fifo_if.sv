interface fifo_if(input clk, rstn);
    logic push;
    logic pop;
    logic [7:0] data_in;
    logic fifo_empty;
    logic fifo_full;
    logic [4:0] count;
    logic [7:0] data_out;
endinterface