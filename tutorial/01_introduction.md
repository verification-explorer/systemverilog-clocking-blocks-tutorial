# Why do we need to learn systemverilog clocking blocks  #
![clocking blocks neccessity](/figures/dave_rich_refer_clocking_blocks_necessity.png "clocking blocks neccessity")

# Synchronous timimg RTL states [1] #
1. a clock event defines a moment is simulated time
2. at that moment in time, we sample the values of the various storage elements
3. and at the same moment in time, we update the storage elements to thier new values

How can inputs and outputs can be sampled and updated at the same time?

lets take a simple flop with adder in front of it and analyze how the simulator works



