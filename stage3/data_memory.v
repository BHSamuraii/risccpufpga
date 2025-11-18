module data_memory(
    input clk,              // Clock input
    input wire reset,       // Active-low reset signal
    input wire [3:0] address,  // Address for memory access (4 bits)
    input wire [7:0] acc,   // ACC value for STA instruction (8 bits)
    input wire mem_read,    // Memory read signal (active high)
    input wire mem_write,   // Memory write signal (active high)
    output wire [7:0] data  // Data output from memory
);

    reg [7:0] ram [0:15];  // 16 locations of 8-bit wide memory

    // Asynchronous reset block to initialize memory
  always @(posedge clk or negedge reset) begin
      if (!reset) begin
          // Initialize RAM to zero on reset, or set to other default values
          integer i;
          for (i = 0; i < 16; i = i + 1) begin
              ram[i] <= 8'd0;  // Initialize all RAM locations to zero
          end
          end else if (mem_write) begin
              ram[address] <= acc;  // Write data (ACC value) to memory on mem_write
          end
      end 

      // Combinational read logic (asynchronous access)
      assign data = (mem_read) ? ram[address] : 8'd0;

endmodule
