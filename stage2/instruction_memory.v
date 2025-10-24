// NO CHANGES MADE HERE - ADDED FOR COHESION ONLY!
// File used for storing all the instructions - it fetches from prog.mem and keeps in its own memory (rom) (
module instruction_memory (
    input wire [7:0] addr, // this is the program counter input (constantly driven by PC)
    output wire [7:0] instr // output the actual 8 bit instruction back to CPU 
);
    reg [7:0] rom [0:255]; // Creates a register file with 256 8 bit locations (first address has index 0)

    initial begin
        $readmemb("prog.mem", rom); // Loads entire prog.mem file into local ROM (first line is at location 0, second at 1 etc)
    end

    assign instr = rom[addr]; // update the instruction to match the PC value (each time it will obvs point to a new one)
endmodule
