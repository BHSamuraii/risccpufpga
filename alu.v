module alu (
    input  [3:0] opcode,
    input  [7:0] acc,      // current accumulator value
    input  [3:0] operand,  // 4-bit immediate
    output reg [7:0] result
);
    always @(*) begin
        case (opcode)
            4'b0000: result = acc + operand;   // ADD
            4'b0001: result = acc - operand;   // SUB
            4'b0010: result = acc & operand;   // AND
            4'b0011: result = acc | operand;   // OR
            default: result = acc;
        endcase
    end
endmodule
