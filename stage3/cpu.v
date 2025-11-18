// Brain of operation - links all other modules together and home to registers like accumulator and program counter and current instruction register 
module cpu ( // Top Level Module (the parent to all other modules)

    // The 2 input signals come from testbench in sim or from board in real life
    input clk, 
    input reset,
    output reg [7:0] acc_out  // NEW: output to expose ACC for 7-seg display
);
    reg [7:0] pc;       // program counter (input to instruction_memory file)
    reg [7:0] acc;      // accumulator register
    reg [7:0] ir;       // Holds current instruction (that needs to be decoded and executed in current clk cycle)

    wire [7:0] instr;   // 8 bits used to hold next instruction (fetched from prog.mem via instruction_memory file - this wire changes ASAP when PC increments)
    wire [3:0] opcode = ir[7:4];   // opcode for instruction (add,sub etc)
    wire [3:0] operand = ir[3:0];  // operand for instruction (only will be used if use_immed is 1 for current instruction)
    wire [7:0] alu_out; // output of ALU module (assigned to ACC later on)

    wire [7:0] alu_operand; // Operand that the ALU sees (this will be the output of a 2:1 multiplexer with the selector being use_immed)
    wire [7:0] ram_data_out; // The data that the RAM sends us -> will be 8'b0 if mem_read is 0 (i.e using immediate value)
    // Control signals from CU
    wire alu_en;
    wire [2:0] alu_op;
    wire mem_read;
    wire mem_write;
    wire acc_write;
    wire pc_load;
    wire use_immed;
    
    // Instantiate Instruction Memory 
    instruction_memory im (.addr(pc), .instr(instr)); // Fetch instruction from ROM using PC address

  // Instantiate Control Unit (CU)
    cu control_unit (
        .opcode(opcode), 
        // All output signals below
        .alu_en(alu_en),
        .alu_op(alu_op), // 3 bits
        .mem_read(mem_read),
        .mem_write(mem_write),
        .acc_write(acc_write),
        .pc_load(pc_load),
        .use_immed(use_immed)
    );

    assign alu_operand = use_immed ? {4'b0, operand} : ram_data_out; // 2 to 1 multiplexer that selects the final value to be sent to ALU (either data or operand itself with 0000 infront)

    // Instantiate ALU 
    alu alu1 ( // execute instruction (will obvs decode to check which operation needs to be done and then will output the result)
        .alu_op(alu_op),   // input that tells the ALU which operation to perform (3 bits)
        .alu_en(alu_en),   // 1 bit input for alu.v file (enable/disable) 
        .acc(acc),         // input for alu.v file (8 bit)
        .alu_operand(alu_operand), // input for alu.v file (4 bit)
        .result(alu_out)   // alu.v file outputs result which is acc value following execution of instruction (this is then mapped to alu_out)
    );

    // Instantiate RAM 
    data_memory ram (
        .clk(clk),
        .address(operand),
        .acc(acc), // required for STA instruction only
        .mem_read(mem_read), // 1 bit signal that tells the RAM if we are reading from a location
        .mem_write(mem_write),  // 1 bit signal that tells the RAM if we are writing to it
        .data(ram_data_out) // The data that has been fetched from memory (8'd0 if we have not read anything)
    );

    // Main Execution Decisions (final steps)
    always @(posedge clk or negedge reset) begin
        if (!reset) begin // Asynchronous reset
            pc  <= 0;
            acc <= 0;
            acc_out <= 0;
            ir <= 8'h00; // Reset 'ir' to a NOP (opcode 0)
        
        end else begin // Normal operation
            
            // --- PIPELINE LOGIC ---
            if (pc_load) begin // If a JMP is executing RIGHT NOW...
                ir <= 8'h00; // ...FLUSH the pipe by forcing a NOP
            end else begin
                ir <= instr; // ...otherwise, load the next instruction
            end

            // --- EXECUTION LOGIC (STAGE 2) ---

            // Default PC action: increment to the next instruction.
            // This will be overridden by a JMP if needed.
            pc <= pc + 1;

            // Default ACC output: show the current value.
            acc_out <= acc;

            // Check control signals from the Control Unit (which is decoding 'ir')
            if (acc_write) begin
                // This branch handles LDA, ADD, SUB, etc.
                if (mem_read && !alu_en) begin // Special case for LDA
                    acc <= ram_data_out;
                    acc_out <= ram_data_out; 
                end else begin // For ALU operations (ADD, SUB, etc.)
                    acc <= alu_out; 
                    acc_out <= alu_out;
                end
            
            end else if (pc_load) begin // For JMP instruction
                // **PC OVERRIDE**: The JMP overrides the default pc <= pc + 1
                pc <= {4'b0000, operand};  
            end
            
            // If it's an STA (or NOP), nothing here matches.
            // 'acc' doesn't change, and 'pc' just increments (which is correct).
        end
    end
endmodule
