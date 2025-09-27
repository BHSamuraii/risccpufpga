`timescale 1ns/10ps

module cpu_tb;
    reg clk, reset;

    // Instantiate CPU
    cpu uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generator: 10ns period (100 MHz)
    always #5 clk = ~clk;

    initial begin
        // Open waveform dump (for GTKWave, optional if using Vivado)
        $dumpvars(0, cpu_tb);

        // Initialize
        clk = 0;
        reset = 1; // Reset at t=0 - to ensure pc/acc goes to 0 
        #10
        reset = 0; // Start execution - this is where proper line by line execution of prog.mem begins unless obvs jmp/reset 
        // Run for 20 cycles (200ns) 
        #70;
        $finish;
    end

    // Monitor signals each cycle
    initial begin
        $display("Time | PC | Instruction | ACC");
        $monitor("%4t | %2d | %08b | %d", 
                 $time, uut.pc, uut.instr, uut.acc);
    end
endmodule
