**Stage 1: Simple 8-bit RISC CPU (5 instructions)**

For the first stage, I built a super simple 8-bit RISC CPU in Verilog. I wanted to keep things minimal to really nail down the basics before diving into the complex stuff like pipelining or VGA output in later stages.

**Features (Stage 1)**

I went with a Harvard-style setup, so the program memory (handled by instruction_memory.v) is totally separate from the data path. The instructions get loaded from a text file called prog.mem using Verilog’s $readmemb function. This makes it easy to swap out programs without messing with the hardware design.

Accumulator (ACC)
This was used as data storage to hold the current value.

Program Counter (PC)
This register is what keeps track of which instruction needs to be executed next - it normally just increments by one to move to the next instruction, but it can also jump to a specific address if we use the JMP instruction

Arithmetic Logic Unit (ALU)
The ALU (in alu.v) is the workhorse of the CPU. For this first stage, it supports four instructions (the JMP instruction is part of the cpu.v file - will be part of Control Unit in the next stage):

ADD: Adds an immediate value to whatever’s in the ACC.
SUB: Subtracts an immediate value from the ACC.
AND: Does a bitwise AND between the ACC and an immediate value.
OR: Does a bitwise OR.

Jump Instruction (JMP)
I added a JMP instruction to let the CPU jump around in the program instead of just running straight through the instructions in the prog.mem file - it loads the PC with whatever address you give it, so you can loop or jump to other instructions (breaking the otherwise sequential pattern)

**File Structure
Here’s how I organized the project:**

cpu.v: The top-level module that ties everything together—PC, ACC, ALU, and instruction memory.

alu.v: This is where the ALU lives, handling all the arithmetic and logic operations.

instruction_memory.v: Loads the program from prog.mem into memory - uses $readmemb to read the binary instructions from the file.

prog.mem: Just a text file with the binary machine code. You can edit this to change what the CPU does.

cpu_tb.v: The testbench for simulating the CPU as at this stage the FPGA board was not needed.
