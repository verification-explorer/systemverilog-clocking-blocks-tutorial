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
### Data Output Logic

This combinational block assigns the output data:

```verilog
data_out = data_fifo[op_count];
```

It continuously reads the value from the FIFO at the current read pointer (`op_count`).  
This ensures that `data_out` always reflects the next value to be popped from the FIFO.

```sv
  always @(*) begin
    data_out = data_fifo[op_count];
  end
```
### FIFO Empty Flag Logic

This combinational block sets the `fifo_empty` flag:

```systemverilog
fifo_empty = (count == 0);
```

It indicates that the FIFO is empty when the internal `count` is zero—i.e., there are no elements to read.

```sv
  always @(*) begin
    fifo_empty = (count == 0);
  end
```
### FIFO Full Flag Logic

This combinational block sets the `fifo_full` flag:

```systemverilog
fifo_full = (count == 5'd16);
```

It indicates that the FIFO is full when the internal `count` reaches 16, which is the maximum capacity of the FIFO buffer.

```sv
  always @(*) begin
    fifo_full = (count == 5'd16);
  end

endmodule

```
As mentioned earlier, this design was synthesized using **OpenLane** with the **Yosys synthesizer**.  
Below is a snapshot from the generated **gate-level netlist**.
```sv
  sky130_fd_sc_hd__a211o_2 _0522_ (
    .A1(\data_fifo[7][0] ),
    .A2(_0154_),
    .B1(_0162_),
    .C1(_0175_),
    .X(_0176_)
  );
  sky130_fd_sc_hd__nor4_2 _0523_ (
    .A(_0155_),
    .B(_0156_),
    .C(_0163_),
    .D(_0152_),
    .Y(_0177_)
  );
  sky130_fd_sc_hd__buf_1 _0524_ (
    .A(_0177_),
    .X(_0178_)
  );
```

To fully appreciate the benefits of using **clocking blocks**, we need to include the delays that naturally occur after the **place-and-route** stage.  
These delays—such as propagation and skew—are captured in a file called an **SDF (Standard Delay Format)** file.
Later we are going to see SDF skews in the waves plot

Below is a snapshot of the SDF file used in the simulation.

```code
 (CELL
  (CELLTYPE "sky130_fd_sc_hd__a211o_2")
  (INSTANCE _0522_)
  (DELAY
   (ABSOLUTE
    (IOPATH A1 X (0.106:0.106:0.106) (0.275:0.275:0.275))
    (IOPATH A2 X (0.152:0.152:0.152) (0.331:0.331:0.331))
    (IOPATH B1 X (0.082:0.083:0.083) (0.290:0.290:0.291))
    (IOPATH C1 X (0.077:0.079:0.080) (0.256:0.256:0.256))
   )
  )
 )
```
## UVM Environment Structure

In the next slide, we will examine the structure of the UVM environment used to simulate this project.
[UVM structure](04_uvm_tb_structure.md)

