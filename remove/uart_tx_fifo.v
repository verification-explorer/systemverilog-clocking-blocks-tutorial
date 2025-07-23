
module uart_tx_fifo(
    input clk,
    input rstn,
    input push,
    input pop,
    input [7:0] data_in,
    output reg fifo_empty,
    output reg fifo_full,
    output reg [4:0] count,
    output reg [7:0] data_out
  );

  reg [3:0] ip_count;
  reg [3:0] op_count;
  reg [7:0] data_fifo [0:15]; // 16-entry FIFO

  always @(posedge clk) begin
    if (rstn == 0) begin
      count <= 5'd0;
      ip_count <= 4'd0;
      op_count <= 4'd0;
    end else begin
      case ({push, pop})
        2'b01: begin
          if (count > 0) begin
            op_count <= op_count + 1;
            count <= count - 1;
          end
        end
        2'b10: begin
          if (count <= 5'hf) begin
            data_fifo[ip_count] <= data_in;
            ip_count <= ip_count + 1;
            count <= count + 1;
          end
        end
        2'b11: begin
          data_fifo[ip_count] <= data_in;
          ip_count <= ip_count + 1;
          op_count <= op_count + 1;
        end
      endcase
    end
  end

  always @(*) begin
    data_out = data_fifo[op_count];
  end

  always @(*) begin
    fifo_empty = (count == 0);
  end

  always @(*) begin
    fifo_full = (count == 5'd16);
  end

endmodule
