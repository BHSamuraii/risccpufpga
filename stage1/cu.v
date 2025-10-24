// NEW in STAGE 2!
// Control Unit (decodes instructions based on opcode and outputs respective signals to CPU - informing it what to do next!)
module cu (
    input [3:0] opcode,       // 4-bit opcode input from the instruction
    output reg alu_en,        // ALU Enable signal (1 if needed, 0 if not)
    output reg [2:0] alu_op,  // ALU Operation signal (3 bits currently - 000 when alu_en is also 0, 001 for adding, 010 for subtraction, 011 for bitwise AND, 100 for bitwise OR)
    output reg mem_read,      // Memory Read signal (1 if reading, 0 if not)
    output reg mem_write,     // Memory Write signal (1 when writing, 0 if not)
    output reg acc_write,     // ACC Write signal (1 if writing to acc, 0 else)
    output reg pc_load,       // PC Load signal 
    output reg use_immed      // Immediate value signal (1 if operand is data, 0 if its an address - thus mem_read/mem_write will be 1!)
    );

    always @(opcode) begin // Execute whenever opcode changes (if 2 consecutive instructions are same then its fine as CU signal values will remain same )
    
        case (opcode) // Check each opcode and decode it (assign the respective values to all control signals)
            4'b0000,4'b0001: begin // ADD , ADDI
                alu_en = 1;
                alu_op = 3'b001;  
                use_immed = (opcode == 4'b0001); // use_immed is 1 if its ADDI else its 0 for AND
                mem_read = ~use_immed; // mem_read is 0 if we aren't using immediate value for this instruction and 1 if we are
                mem_write = 0;
                acc_write = 1;
                pc_load = 0;
            end

            4'b0010, 4'b0011: begin // SUB , SUBI
                alu_en = 1;
                alu_op = 3'b010;  
                use_immed = (opcode == 4'b0011); // use_immed is 1 if its SUBI else its 0 for SUB
                mem_read = ~use_immed; // mem_read is 0 if we aren't using immediate value for this instruction and 1 if we are
                mem_write = 0;
                acc_write = 1;
                pc_load = 0;
            end

            4'b0100: begin // STA (store the accumulator value at the operand which is just a memory address in RAM)
                alu_en = 0;
                alu_op = 3'b000;  
                use_immed = 0;
                mem_read = 0;
                mem_write = 1;
                acc_write = 0;
                pc_load = 0;
            end

            4'b0101: begin // JMP (jump to instruction pointed by operand which relates to a line in prog.mem)
                alu_en = 0;
                alu_op = 3'b000;  
                use_immed = 1;
                mem_read = 0;
                mem_write = 0;
                acc_write = 0;
                pc_load = 1;
            end


            4'b0110: begin // LDA (load the value that the operand points to in memory into the accumulator)
                alu_en = 0;
                alu_op = 3'b000;  
                use_immed = 0;
                mem_read = 1;
                mem_write = 0;
                acc_write = 1;
                pc_load = 0;
            end

            4'b0111, 4'b1000: begin // OR , ORI 
                alu_en = 1;
                alu_op = 3'b100;  
                use_immed = (opcode == 4'b1000);
                mem_read = ~use_immed;
                mem_write = 0;
                acc_write = 1;
                pc_load = 0;
            end


            4'b1001, 4'b1010: begin // AND , ANDI
                alu_en = 1;
                alu_op = 3'b011;  
                use_immed = (opcode == 4'b1010);
                mem_read = ~use_immed;
                mem_write = 0;
                acc_write = 1;
                pc_load = 0;
            end

            default: begin
                alu_en = 0;
                alu_op = 3'b000;
                mem_read = 0;
                mem_write = 0;
                acc_write = 0;
                pc_load = 0;
                use_immed = 0;
            end
        endcase
    end
endmodule
