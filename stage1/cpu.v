// Brain of operation - links all other files together and home to registers like accumulator and program counter and current instruction register
`timescale 1ns / 10ps
module cpu (
    input clk,
    input reset
);
    reg [7:0] pc;       // program counter (input to instruction_memory file)
    reg [7:0] acc;      // accumulator register
    wire [7:0] instr;   // actual 8 bit instruction (fetched from prog.mem via instruction_memory file)

    wire [3:0] opcode = instr[7:4];   // opcode for instruction (add,sub etc)
    wire [3:0] operand = instr[3:0];  // operand for instruction (data / address in stage 2)
    wire [7:0] alu_out; // output of ALU module (assigned to ACC later on)

    instruction_memory im ( // fetch the actual instruction from rom in instruction_memory.v
        .addr(pc), // connects the addr input port on instruction_memory.v file to the pc port (local to this file)
        .instr(instr) // the output (actual instruction) that the instruction_memory.v file gives us for the PC addr we gave it
    );

    // Instantiate ALU module
    alu alu1 ( // execute instruction (will obvs decode to check which operation needs to be done and then will output the result)
        .opcode(opcode),   // input for alu.v file (4 bit)
        .acc(acc),         // input for alu.v file (8 bit)
        .operand(operand), // input for alu.v file (4 bit)
        .result(alu_out)   // alu.v file outputs result which is acc value following execution of instruction (this is then mapped to alu_out)
    );

    always @(posedge clk or posedge reset) begin // at each positive edge of the clock or each time CPU cycle is reset
        if (reset) begin // if cycle is reset, reset values of registers PC and ACC (start from top of prog.mem)
            pc  <= 0;
            acc <= 0;
        end else begin // otherwise, check if its a JMP instruction 
            case (opcode)
                4'b0100: begin
                    // JMP: load PC with operand (zero-extended)
                    pc  <= {4'b0000, operand};
                    acc <= acc; // hold accumulator
                end
                default: begin // else if not JMP instruction 
                    acc <= alu_out;   // always write back (i.e ensure whatever ALU just performed, we send to accumulator)
                    pc  <= pc + 1;    // incremented to point to next instruction
                end
            endcase
        end
    end
endmodule
