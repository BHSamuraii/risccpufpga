module instruction_memory (
    input  [7:0] addr,
    output [7:0] instr
);
    reg [7:0] rom [0:255];

    initial begin
        $readmemb("prog.mem", rom);
    end

    assign instr = rom[addr];
endmodule
