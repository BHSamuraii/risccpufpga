module alu (
    input  [3:0] opcode,   // 4-bit operation
    input  [7:0] acc,      // current accumulator value
    input  [3:0] operand,  // 4-bit immediate value
    output reg [7:0] result
);
    always @(*) begin
        case (opcode)
            4'b0000: result = acc + operand;   // ADD (directly to accumulator)
            4'b0001: result = acc - operand;   // SUB (directly to accumulator)
            4'b0010: result = acc & operand;   // AND (bitwise)
            4'b0011: result = acc | operand;   // OR (bitwise)
            default: result = acc;
        endcase
    end
endmodule
