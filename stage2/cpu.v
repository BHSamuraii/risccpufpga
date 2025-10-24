// Brain of operation - links all other files together and home to registers like accumulator and program counter and current instruction register 
`timescale 1ns / 10ps
module cpu ( // Top Level Module (the parent to all other modules)
    // Signals come from testbench in sim or from board in real exec
    input clk, 
    input reset
);
    reg [7:0] pc;       // program counter (input to instruction_memory file)
    reg [7:0] acc;      // accumulator register

    wire [7:0] instr;   // actual 8 bit instruction (fetched from prog.mem via instruction_memory file - this wire changes ASAP when PC changes)
    wire [3:0] opcode = instr[7:4];   // opcode for instruction (add,sub etc)
    wire [3:0] operand = instr[3:0];  // operand for instruction (only will be used if use_immed is 1 for current instruction)
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
    always @(posedge clk or posedge reset) begin // at each positive edge of the clock or each time CPU cycle is reset
        if (reset) begin // if cycle is reset, reset values of registers PC and ACC (start from top of prog.mem)
            pc  <= 0;
            acc <= 0;
        end else begin // Final checks of CU signals before executing instruction
            if (acc_write) begin
                if (mem_read && !alu_en) begin
                    acc <= ram_data_out;
                end else begin 
                    acc <= alu_out;
                    pc <= pc + 1;
                end
            end else if (pc_load) begin // JMP instruction
                pc <= {4'b0000, operand};  
            end else begin
                acc <= acc;
                pc = pc +1;
            end
        end
    end
endmodule
