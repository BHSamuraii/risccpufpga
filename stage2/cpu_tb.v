`timescale 1ns/10ps

module cpu_tb;
    reg clk = 0;
    reg reset = 0;

    // Instantiate CPU
    cpu uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generator (10 ns period)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("cpu_wave.vcd");
        $dumpvars(0, cpu_tb);

        $display("=== Starting Simulation ===");
        reset = 1;
        #10;
        reset = 0;
        #60;
        $finish;
    end

    // STROBE: prints at end of clock edge timestep, reflecting updated signals
    always @(posedge clk) begin
        if (!reset) begin
            $strobe("=== CLOCK EDGE at t=%0t ===", $time);
            $strobe("PC: %2d, Instr: %02h, Opcode: %01h, Operand: %01h", 
                    uut.pc, uut.instr, uut.opcode, uut.operand);
            $strobe("Control: alu_en=%b, alu_op=%03b, mem_read=%b, mem_write=%b, acc_write=%b, use_immed=%b",
                    uut.alu_en, uut.alu_op, uut.mem_read, uut.mem_write, uut.acc_write, uut.use_immed);
            $strobe("Data: ACC=%2d, alu_out=%2d, ram_data_out=%2d, alu_operand=%2d\n",
                    uut.acc, uut.alu_out, uut.ram_data_out, uut.alu_operand);
        end 
    end

endmodule
