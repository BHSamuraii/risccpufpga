module clk_divider_1hz (
    input  wire clk_100mhz,
    input  wire reset,       // ← ACTIVE-LOW
    output reg  clk_1hz
);
    reg [26:0] cnt;
    
    // Initialize registers
    initial begin
        cnt = 0;
        clk_1hz = 0;
    end

    always @(posedge clk_100mhz or negedge reset) begin
        if (!reset) begin    // ← reset when reset == 0 (button pressed)
            cnt <= 27'd0;
            clk_1hz <= 1'b0;
        end else begin
            if (cnt >= 27'd49_999_999) begin
                cnt <= 27'd0;
                clk_1hz <= ~clk_1hz;  // Toggle every 0.5s → 1 Hz square wave
            end else begin
                cnt <= cnt + 27'd1;
            end
        end
    end
endmodule
