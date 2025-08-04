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

#### Sampling DUT Signals in the Monitor

In the monitor, we sample the DUT's inputs and outputs on every positive clock edge. At each cycle, a new sequence item is created, populated with the current interface signal values, and then written to the analysis port for further processing.

```systemverilog
task run_phase(uvm_phase phase);
    super.run_phase(phase);
    wait_reset();
    forever begin
        @(posedge m_fifo_if.clk);
        item = fifo_item::type_id::create("item", this);
        item.push       = m_fifo_if.push;
        item.pop        = m_fifo_if.pop;
        item.data_in    = m_fifo_if.data_in;
        item.data_out   = m_fifo_if.data_out;
        item.fifo_empty = m_fifo_if.fifo_empty;
        item.fifo_full  = m_fifo_if.fifo_full;
        item.count      = m_fifo_if.count;
        fifo_port.write(item);
    end
endtask
```


#### Scoreboard Report After Simulation

Once the simulation completes, the scoreboard prints the final results during the `report_phase`. As expected, the simulation passes successfully with all transactions matching and no mismatches reported.
```code
UVM_INFO ../../common/uvm_tb/env/fifo_scb.sv(69) @ 6150: uvm_test_top.m_fifo_base_env.m_fifo_scb [RPT] matchs: 33, mismatches: 0
```

#### Gate-Level Simulation and Scoreboard Check

The next step is to repeat the simulation using the gate-level netlist. This allows us to check for any discrepancies or issues that may arise in the scoreboard results compared to the RTL simulation.
We observe that the simulation produces multiple mismatches. Let’s analyze the root cause and understand why these discrepancies occur.
```code
UVM_INFO ../../common/uvm_tb/env/fifo_scb.sv(69) @ 615000: uvm_test_top.m_fifo_base_env.m_fifo_scb [RPT] matchs: 0, mismatches: 31
UVM_ERROR :   31
```

#### Analyzing the First Mismatch Error

The first error reported by the scoreboard appears as follows:
```code
UVM_ERROR ../../common/uvm_tb/env/fifo_scb.sv(55) @ 45000: uvm_test_top.m_fifo_base_env.m_fifo_scb [MISMATCH] comparer: d8 != received: d
```

This indicates that at simulation time 45,000ps (or 45ns), the FIFO received a read (`pop`) request. However, the data output from the FIFO (`d`) did not match the expected value (`d8`) stored internally in the scoreboard.

![uvm_first_reported_error](/figures/uvm_first_error_wave_1.png)

#### Inspecting `ip_counter` for Debugging

To begin debugging this issue, we first examine `ip_counter`—an internal design variable responsible for determining the storage location of incoming data when the `push` signal is asserted.
We observe that the `push` signal is asserted on the positive edge of the clock, but `ip_count_0` changes immediately afterward within the same cycle. This behavior is incorrect, as `ip_count` is a sampled (sequential) signal and should only update on the **next** clock cycle—not during the current one.


![ip_counter_error](/figures/gate_level_ip_counter_error.png)












































