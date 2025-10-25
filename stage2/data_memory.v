// Stores the data (RAM) and can be fetched from or write to memory
module data_memory(
    input clk, 
    input wire [3:0] address, // Takes in an address (operand part of instruction)
    input wire [7:0] acc, // Used for STA instruction to store the current ACC value into specified memory address
    input wire mem_read, // comes from cpu.v and will be used locally to decide if we need to fetch from memory or not
    input wire mem_write,      // Memory write signal (from CPU)
    output wire [7:0] data // Data that it has fetched from specified memory address goes back out to cpu.v and then ALU/ACC (for instructions like ADD, SUB, OR etc.)
    );

    reg [7:0] ram [0:15]; // Creates a register file containing 16 memory addresses (each location holds 8 bits, ascending order i.e ram[0] is first)

    // RAM setup values (for all locations, 0 to 15)
    integer i;
    initial begin
        for (i=0; i < 15; i = i+1) begin
            ram[i] = i;
        end
    end

    always @(posedge clk) begin 
        if (mem_write) // Synchronous write 
            ram[address] <= acc ; // Used only for STA (stores entire ACC in the specified memory address )
    end 

    // Combinational read - INSTANT access (async read)
    assign data = mem_read ? ram[address] : 8'd0;

endmodule
