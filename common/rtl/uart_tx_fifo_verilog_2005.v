//----------------------------------------------------------------------
//   Copyright 2011 Mentor Graphics Corporation
//   All Rights Reserved Worldwide
//
// Modifications:
// - Converted from SystemVerilog to Verilog-2005 for synthesis compatibility
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//----------------------------------------------------------------------

//
// This is a 16 deep 8 bit wide FIFO
// that keeps track of its size
//
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

  always @(posedge clk or negedge rstn) begin
    if (~rstn) begin
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

