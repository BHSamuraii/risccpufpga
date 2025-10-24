// Carries out all of the arithmetic operations (if alu_en is 1 for that instruction!)
module alu (
    input wire [2:0] alu_op, // 3 bit alu operation signal (comes from cu.v -> cpu.v --> here)
    input wire alu_en, // Checks if ALU should perform the operation or not
    input wire [7:0] acc,      // current accumulator value
    input wire [7:0] alu_operand,  // 4-bit immediate/data value (if data then its the data stored at memory address that instruction operand points)
    output reg [7:0] result // 8 bit output that will be copied to ACC later (via alu_out)
);
    always @(*) begin // Runs whenever the inputs to this module change (either ACC, Operand or Alu_Op)
        if (alu_en) begin
            case (alu_op) // IF Statement (performs the operation depending on alu_op)
                3'b001: result = acc + alu_operand;  // ADD as well as ADDI
                3'b010: result = acc - alu_operand;  // SUB as well as SUBI
                3'b011: result = acc & alu_operand;  // AND as well as ANDI
                3'b100: result = acc | alu_operand;  // OR as well as ORI
                default: result = acc;               // Safety (should not hit)
            endcase
        end else begin
            result = acc;  // Hold value when disabled
        end
    end
endmodule
