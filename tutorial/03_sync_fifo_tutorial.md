### Design Overview

For this tutorial, I chose a **synchronous FIFO RTL design** from the [Verification Academy](https://verificationacademy.com/) tutorials.

Since **clocking blocks** are particularly beneficial in **gate-level simulations**, I synthesized the design using **OpenLane** (an [Efabless](https://efabless.com/) project) with the **Sky130 Process Design Kit (PDK)**.

Let's walk through the design and understand how it works.

### FIFO Port Descriptions

| Port Name    | Direction | Width    | Description |
|--------------|-----------|----------|-------------|
| `clk`        | Input     | 1 bit    | Clock signal used to synchronize all FIFO operations. |
| `rstn`       | Input     | 1 bit    | Active-low reset signal. When low, the FIFO is reset to its initial state. |
| `push`       | Input     | 1 bit    | Push signal. When high, the input data (`data_in`) is written into the FIFO on the rising edge of the clock, if the FIFO is not full. |
| `pop`        | Input     | 1 bit    | Pop signal. When high, the oldest data in the FIFO is read and output through `data_out` on the rising edge of the clock, if the FIFO is not empty. |
| `data_in`    | Input     | 8 bits   | Data to be written into the FIFO when `push` is asserted. |
| `fifo_empty` | Output    | 1 bit    | Indicates that the FIFO is empty (no data to read). |
| `fifo_full`  | Output    | 1 bit    | Indicates that the FIFO is full (no space to write new data). |
| `count`      | Output    | 5 bits   | The number of valid data elements currently stored in the FIFO. |
| `data_out`   | Output    | 8 bits   | The data read from the FIFO when `pop` is asserted. |

```sv
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
```
### Internal Signal Descriptions

| Signal Name     | Type        | Width    | Description |
|------------------|-------------|----------|-------------|
| `ip_count`       | `reg`       | 4 bits   | Input pointer: tracks the next write location in the FIFO memory (`data_fifo`). Incremented when `push` is asserted. |
| `op_count`       | `reg`       | 4 bits   | Output pointer: tracks the next read location from the FIFO memory. Incremented when `pop` is asserted. |
| `data_fifo[0:15]`| `reg` array | 16 x 8 bits | The actual FIFO memory: a 16-entry array where each entry holds 8-bit data. This stores the pushed data and serves as the source for `data_out`. |

```sv
  reg [3:0] ip_count;
  reg [3:0] op_count;
  reg [7:0] data_fifo [0:15]; // 16-entry FIFO
```
### Main Control Logic

This block implements the core logic of the FIFO:

- On **reset (`~rstn`)**, it clears the counters:
  - `count` – number of stored elements
  - `ip_count` – input/write pointer
  - `op_count` – output/read pointer

- On each **clock edge**, it performs one of the following based on `push` and `pop` signals:
  - `push = 0`, `pop = 1`: Read (pop) data from the FIFO if it's not empty.
  - `push = 1`, `pop = 0`: Write (push) data to the FIFO if it's not full.
  - `push = 1`, `pop = 1`: Simultaneous write and read.

This logic updates the pointers and element count to reflect the FIFO state.

```sv
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
```
```sv
  always @(*) begin
    data_out = data_fifo[op_count];
  end
```
```sv
  always @(*) begin
    fifo_empty = (count == 0);
  end
```
```sv
  always @(*) begin
    fifo_full = (count == 5'd16);
  end

endmodule

```
