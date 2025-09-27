// File used for storing all the instructions - it fetches from prog.mem and keeps in its own memory (rom)
module instruction_memory (
    input  wire [7:0] addr,
    output wire [7:0] instr
);
    reg [7:0] rom [0:255]; // Creates a register file with 256 8 bit locations

    initial begin
        $readmemb("prog.mem", rom); // Loads entire prog.mem file into local ROM
    end

    assign instr = rom[addr]; // update the instruction to match the PC value (each time it will obvs point to a new one)
endmodule
