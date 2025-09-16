`timescale 1ns / 10ps
module cpu (
    input clk,
    input reset
);
    reg [7:0] pc;       // program counter (input to instruction_memory file)
    reg [7:0] acc;      // accumulator register
    wire [7:0] instr;   // actual 8 bit instruction (fetched from prog.mem via instruction_memory file)

    wire [3:0] opcode = instr[7:4];   // opcode for instruction (add,sub etc)
    wire [3:0] operand = instr[3:0];  // operand for instruction (data/number)
    wire [7:0] alu_out;

    instruction_memory im (
        .addr(pc),
        .instr(instr)
    );

    alu alu1 (
        .opcode(opcode),   // input for alu.v file
        .acc(acc),         // input for alu.v file
        .operand(operand), // input for alu.v file
        .result(alu_out)   // alu.v file outputs alu_out which is basically acc value following execution of that instruction
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc  <= 0;
            acc <= 0;
        end else begin
            case (opcode)
                4'b0100: begin
                    // JMP: load PC with operand (zero-extended)
                    pc  <= {4'b0000, operand};
                    acc <= acc; // hold accumulator
                end
                default: begin
                    acc <= alu_out;   // always write back
                    pc  <= pc + 1;    // incremented to point to next instruction
                end
            endcase
        end
    end
endmodule
