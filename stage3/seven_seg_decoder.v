// Instantiated 3 times in parallel (each for 1 digit of the 3 digit 7 seg display on Basys 3)
module seven_seg_decoder (
    input  wire [3:0] bcd, // Will take a 4 bit value each time (one for the acc's ones column, one for the acc's tens column etc.)
    output reg  [6:0] seg // Goes to top_basys3.v module
);
    always @(*) begin
        case (bcd)
            4'd0: seg = 7'b0111111;
            4'd1: seg = 7'b0000110;
            4'd2: seg = 7'b1011011;
            4'd3: seg = 7'b1001111;
            4'd4: seg = 7'b1100110;
            4'd5: seg = 7'b1101101;
            4'd6: seg = 7'b1111101;
            4'd7: seg = 7'b0000111;
            4'd8: seg = 7'b1111111;
            4'd9: seg = 7'b1101111;
            default: seg = 7'b0000000;
        endcase
    end
endmodule
