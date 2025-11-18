// ===========================================
// 2–Stage Pipelined CPU (IF → EX Pipeline)
// Stage 1 = Instruction Fetch
// Stage 2 = Decode + Execute
// ===========================================
module cpu(
    input clk,
    input reset,
    output reg [7:0] acc_out
);

    // ---------------------------------------
    // Registers
    // ---------------------------------------
    reg [7:0] pc;          // Program Counter
    reg [7:0] acc;         // Accumulator

    // PIPELINE REGISTER (EX stage instruction)
    reg [7:0] ir_exec;     // Instruction being executed this cycle

    // ---------------------------------------
    // Stage 1: Instruction Fetch wires
    // ---------------------------------------
    wire [7:0] ir_fetch;   // Fetched instruction (IF stage output)

    // ---------------------------------------
    // Instruction fields (from EX stage)
    // ---------------------------------------
    wire [3:0] opcode  = ir_exec[7:4];
    wire [3:0] operand = ir_exec[3:0];

    // ---------------------------------------
    // Control Unit outputs
    // ---------------------------------------
    wire alu_en;
    wire [2:0] alu_op;
    wire mem_read;
    wire mem_write;
    wire acc_write;
    wire pc_load;
    wire use_immed;

    // ---------------------------------------
    // ALU + Data Memory
    // ---------------------------------------
    wire [7:0] ram_data_out;
    wire [7:0] alu_operand;
    wire [7:0] alu_out;

    assign alu_operand = use_immed ? {4'b0000, operand} : ram_data_out;

    // ---------------------------------------
    // Instruction Memory (ROM)
    // ---------------------------------------
    instruction_memory instr_mem (
        .addr(pc),
        .instr(ir_fetch)
    );

    // ---------------------------------------
    // Control Unit
    // ---------------------------------------
    cu control_unit (
        .opcode(opcode),
        .alu_en(alu_en),
        .alu_op(alu_op),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .acc_write(acc_write),
        .pc_load(pc_load),
        .use_immed(use_immed)
    );

    // ---------------------------------------
    // Data Memory (RAM)
    // ---------------------------------------
    data_memory ram (
        .clk(clk),
        .address(operand),
        .acc(acc),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .data(ram_data_out)
    );

    // ---------------------------------------
    // ALU
    // ---------------------------------------
    alu alu_module (
        .alu_op(alu_op),
        .alu_en(alu_en),
        .acc(acc),
        .alu_operand(alu_operand),
        .result(alu_out)
    );

    // =======================================
    // PIPELINE + EXECUTION LOGIC
    // =======================================
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            // Full reset
            pc      <= 8'd0;
            acc     <= 8'd0;
            ir_exec <= 8'h00;   // NOP
            acc_out <= 8'd0;

        end else begin
            // =======================================
            // STAGE 1 → STAGE 2: Pipeline Register
            // =======================================
            if (pc_load)
                ir_exec <= 8'h00;     // Flush after JMP
            else
                ir_exec <= ir_fetch;  // Latch fetched instruction

            // =======================================
            // DEFAULT PC BEHAVIOR
            // =======================================
            pc <= pc + 1;

            // =======================================
            // EXECUTE STAGE (using ir_exec values)
            // =======================================
            if (acc_write) begin
                if (mem_read && !alu_en) begin
                    // LDA: direct memory read
                    acc <= ram_data_out;
                    acc_out <= ram_data_out;
                end else begin
                    // ALU operations
                    acc <= alu_out;
                    acc_out <= alu_out;
                end

            end else if (pc_load) begin
                // JMP: override PC
                pc <= {4'b0000, operand};
            end

            // NOP or STA: nothing changes except PC increment above
        end
    end

endmodule
