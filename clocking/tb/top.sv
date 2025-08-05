module top;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import fifo_uvm_pkg::*;

    bit clk;
    bit rstn;

    fifo_if m_fifo_if(.clk(clk),.rstn(rstn));

    uart_tx_fifo i_uart_tx_fifo(
        .clk(clk),
        .rstn(m_fifo_if.rstn),
        .push(m_fifo_if.push),
        .pop(m_fifo_if.pop),
        .data_in(m_fifo_if.data_in),
        .fifo_empty(m_fifo_if.fifo_empty),
        .fifo_full(m_fifo_if.fifo_full),
        .count(m_fifo_if.count),
        .data_out(m_fifo_if.data_out)
        );

    initial begin
        clk <= 0;
        forever #5 clk = !clk;
    end

    initial begin
        rstn = 0;
        repeat(2) @(negedge clk);
        rstn = 1'b1;
    end

    initial begin
        uvm_config_db#(virtual fifo_if)::set(null,"uvm_test_top","m_fifo_if",m_fifo_if);
        run_test("fifo_debug_test");
    end

endmodule