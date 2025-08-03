### Standard Simulation Flow

In the standard scenario, we will simulate the design twice: once using the RTL and once using the gate-level netlist.

#### Simple FIFO Interface for Case Study

For this case study, we will use a simple interface that represents the inputs and outputs of a synchronous FIFO. Notice that all signals are declared as `logic` types. This is intentional, as `logic` is a 4-state variable capable of holding values like `1'bX` (unknown) or `1'bZ` (high impedance). Using `logic` helps us catch undesirable conditions such as X-propagation during simulation.

```systemverilog
interface fifo_if(input clk, rstn);
    logic push;
    logic pop;
    logic [7:0] data_in;
    logic fifo_empty;
    logic fifo_full;
    logic [4:0] count;
    logic [7:0] data_out;
endinterface
```

#### Connecting Interface to DUT in the Top Module

In the top (**put link here**)module, we instantiate a single instance of the FIFO interface and connect its signals directly to the DUT ports.

```systemverilog
    fifo_if m_fifo_if(.clk(clk), .rstn(rstn));

    uart_tx_fifo i_uart_tx_fifo(
        .clk(clk),
        .rstn(rstn),
        .push(m_fifo_if.push),
        .pop(m_fifo_if.pop),
        .data_in(m_fifo_if.data_in),
        .fifo_empty(m_fifo_if.fifo_empty),
        .fifo_full(m_fifo_if.fifo_full),
        .count(m_fifo_if.count),
        .data_out(m_fifo_if.data_out)
    );
```

#### Driving Inputs from Sequence Item

In the driver (**put link here**), we receive a sequence item and assign its values to the interface inputs. The assignments are synchronized to the positive edge of the clock to ensure correct timing behavior.

```systemverilog
    task drive(fifo_item req);
        @(posedge m_fifo_if.clk);
        m_fifo_if.pop      <= req.get_pop();
        m_fifo_if.push     <= req.get_push();
        m_fifo_if.data_in  <= req.get_data_in();
    endtask
```
please refer to (**put link here**) sequence item class to learn its properties.


