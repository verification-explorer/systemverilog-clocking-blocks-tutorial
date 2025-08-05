### Slide Title: Summary — Clocking Blocks, Modports, and Best Practices

This tutorial covered the practical use of **SystemVerilog clocking blocks** and **modports** to build a robust, synchronized UVM testbench. Below is a summary of the key concepts and takeaways:

---

#### ✅ Clocking Blocks
- Define a set of signals synchronized to a **specific clock event** (e.g., `@ (posedge clk)`).
- Use **`clockvars`** (e.g., `drv_cb.push`) to control signal timing between the testbench and DUT.
- Provide **input/output skew** (e.g., `#1step`) to model realistic setup and hold behavior.
- Help avoid race conditions and timing issues, especially in **gate-level netlist simulations**.
- Testbench should synchronize on the **clocking block event**: `@(drv_cb);`

---

#### ✅ Simplified Alternatives
- Driving/sampling signals at the **negedge** can avoid race conditions with a posedge-triggered DUT.
- This can simplify the testbench structure but may introduce limitations at gate-level or in mixed-clock designs.

---

#### ✅ Modports
- Restrict direct access to interface signals and expose only what's necessary.
- Common use: 
  - `modport dut` – for DUT connection
  - `modport drv` – for driver (expose clocking block + async signals)
  - `modport mon` – for monitor (inputs only)
- Prevents misuse by limiting testbench access to **only clockvars and reset**, improving verification safety.

---

#### ✅ Integration Tips
- Define **`typedef` virtual interfaces** for modports in your agent package.
- Declare these pointers in the driver/monitor components.
- Connect them in the agent to provide proper scoped access.
- IDEs will enforce modport restrictions via autocomplete — a nice bonus!

---

#### 📌 Final Thought
Using **clocking blocks with modports** adds a bit of structural overhead, but the payoff is a cleaner, more robust, and timing-accurate testbench—especially critical when working with **SDF-annotated gate-level simulations**.

