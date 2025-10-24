
# **Stage 2: 8-bit RISC CPU (11 instructions + permanent data storage)**

For the second stage, I added RAM (16 addresses - each location having 8 bits of data). I also added a lot more instructions as a result (i.e now some instructions require memory fetch instead of only being immediate)

### **Features (Stage 2)**

The new file (RAM) was called **data_memory.v**. It also connected directly to the top level module **cpu.v**, allowimg fetches/reads to be performed. A new module for the Control Unit was also created - it's goal was to send signals back to the top level module informing it of what the current instruction does and what steps need to be taken to execute it properly.

**Accumulator (ACC)**

This was used as the only data storage - role is to hold the current value (RAM will be added in next stage!)

**Program Counter (PC)**

This register is what keeps track of which instruction needs to be executed next - it normally just increments by one to move to the next instruction, but it can also jump to a specific address if we use the JMP instruction

**Arithmetic Logic Unit (ALU was changed to also accomodate non-immediate instructions)**

The ALU (in alu.v) is the workhorse of the CPU. For this first stage, it supports four instructions (the JMP instruction is part of the cpu.v file - will be part of Control Unit in the next stage):

ADD/ADDI: Adds an immediate value to whatever’s in the ACC / Adds the 

SUB: Subtracts an immediate value from the ACC.

AND: Does a bitwise AND between the ACC and an immediate value.

OR: Does a bitwise OR.

**Jump Instruction (JMP)**

I added a JMP instruction to let the CPU jump around in the program instead of just running straight through the instructions in the prog.mem file - it loads the PC with whatever address you give it, so you can loop or jump to other instructions (breaking the otherwise sequential pattern)

### **File Structure (2 more files added):**

cpu.v: The top-level module that ties everything together—PC, ACC, ALU, and instruction memory.

alu.v: This is where the ALU lives, handling all the arithmetic and logic operations.

instruction_memory.v: Loads the program from prog.mem into memory - uses $readmemb to read the binary instructions from the file.

prog.mem: Just a text file with the binary machine code. You can edit this to change what the CPU does.

cpu_tb.v: The testbench for simulating the CPU as at this stage the FPGA board was not needed.

cu.v: Control Unit responsible for decoding the instruction and converting it into signals

instruction_memory.v: This is where the RAM resides (storage of all data)
