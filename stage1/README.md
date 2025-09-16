**Stage 1: Simple 8-bit RISC CPU (5 instructions)**

For the first stage, I built a super simple 8-bit RISC CPU in Verilog. I wanted to keep things minimal to really nail down the basics before diving into the fancy stuff like pipelining or VGA output in later stages.

This CPU is designed with a Harvard architecture, meaning it has separate memory for instructions and data (at this stage the data memory purely just the accumulator). It’s got a basic accumulator (ACC) for processing, a program counter (PC) to keep track of what’s running, and a simple ALU to handle the math and logic. I also threw in a jump instruction to mix things up a bit. 

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

I kept the instruction set small to make sure I got the basics right before adding more complex stuff later.
Jump Instruction (JMP)
I added a JMP instruction to let the CPU skip around in the program instead of just running straight through. It loads the PC with whatever address you give it, so you can loop or jump to different parts of the code. Pretty cool for a basic CPU!

**File Structure
Here’s how I organized the project:**

cpu.v: The top-level module that ties everything together—PC, ACC, ALU, and instruction memory.

alu.v: This is where the ALU lives, handling all the arithmetic and logic operations.

instruction_memory.v: Loads the program from prog.mem into memory - uses $readmemb to read the binary instructions from the file.

prog.mem: Just a text file with the binary machine code. You can edit this to change what the CPU does.

cpu_tb.v: The testbench for simulating the CPU as at this stage the FPGA board was not needed.
