module top_basys3 (
    input  wire CLK100MHZ,      // 100 MHz board clock
    input  wire CPU_RESETN,     // Center button (active-low)
    output wire [6:0] SEG,      // 7-segment lines (CA to CG)
    output wire [7:0] AN,       // 8 anode controls
    output wire DP,             // Decimal point (off)
    output wire [7:0] LED       // 8 LEDs show full ACC
);

    // === RESET INVERSION ===
    // Basys3 CPU_RESETN (BTNC): LOW when not pressed, HIGH when pressed
    // Our modules expect active-low reset: LOW = reset, HIGH = run
    // So we INVERT: button pressed (1) → reset (0), button released (0) → run (1)
    wire reset_n = ~CPU_RESETN;

    // === 1 Hz CLOCK ===
    wire clk_1hz;
    clk_divider_1hz cpu_clk (
        .clk_100mhz(CLK100MHZ),
        .reset(reset_n),         // active-low
        .clk_1hz(clk_1hz)
    );
    
    // Debug: Show clock on LED[7]
    // assign LED[7] = clk_1hz;  // Uncomment to verify clock is toggling

    // === CPU (runs at 1 Hz) ===
    wire [7:0] acc;
    cpu uut (
        .clk(clk_1hz),
        .reset(reset_n),         // active-low
        .acc_out(acc)
    );

    // === 8 LEDs SHOW FULL ACC (binary) + clock debug ===
    assign LED[7] = clk_1hz;     // Debug: see clock toggle
    assign LED[6:0] = acc[6:0];  // Show lower 7 bits of ACC

    // === BCD Conversion (proper implementation) ===
    reg [3:0] ones;
    reg [3:0] tens;
    reg [3:0] hundreds;
    
    always @(*) begin
        // Double dabble algorithm for binary to BCD
        hundreds = 0;
        tens = 0;
        ones = 0;
        
        if (acc >= 200) begin hundreds = 2; tens = (acc - 200) / 10; ones = (acc - 200) % 10; end
        else if (acc >= 100) begin hundreds = 1; tens = (acc - 100) / 10; ones = (acc - 100) % 10; end
        else begin hundreds = 0; tens = acc / 10; ones = acc % 10; end
    end

    // === Decode digits ===
    wire [6:0] seg_ones, seg_tens, seg_hundreds;
    seven_seg_decoder dec_ones     (.bcd(ones),     .seg(seg_ones));
    seven_seg_decoder dec_tens     (.bcd(tens),     .seg(seg_tens));
    seven_seg_decoder dec_hundreds (.bcd(hundreds), .seg(seg_hundreds));

    // === Fast refresh clock (~1 kHz) ===
    reg refresh_clk = 0;
    reg [16:0] refresh_counter = 0;
    localparam REFRESH_MAX = 49_999;  // 100MHz / 50k = 2kHz, toggle = 1kHz

    always @(posedge CLK100MHZ or negedge reset_n) begin
        if (!reset_n) begin
            refresh_counter <= 0;
            refresh_clk <= 0;
        end else if (refresh_counter == REFRESH_MAX) begin
            refresh_counter <= 0;
            refresh_clk <= ~refresh_clk;
        end else begin
            refresh_counter <= refresh_counter + 1;
        end
    end

    // === 7-segment multiplexing ===
    reg [6:0] seg_out = 7'b1111111;
    reg [7:0] an_out  = 8'b11111111;
    reg [1:0] digit_sel = 0;

    always @(posedge refresh_clk or negedge reset_n) begin
        if (!reset_n) begin
            digit_sel <= 0;
            seg_out   <= 7'b1111111;  // all off
            an_out    <= 8'b11111111; // all off
        end else begin
            digit_sel <= digit_sel + 1;
            case (digit_sel)
                2'd0: begin 
                    an_out <= 8'b11111110;  // AN[0] = rightmost
                    seg_out <= seg_ones;
                end
                2'd1: begin 
                    an_out <= 8'b11111101;  // AN[1] = middle
                    seg_out <= seg_tens;
                end
                2'd2: begin 
                    an_out <= 8'b11111011;  // AN[2] = left
                    seg_out <= seg_hundreds;
                end
                2'd3: begin 
                    an_out <= 8'b11111111;  // all off (blank the 4th cycle)
                    seg_out <= 7'b1111111;
                end
            endcase
        end
    end

    // === Output to board (common-anode, so invert segments) ===
    assign SEG = ~seg_out;
    assign AN  = an_out;
    assign DP  = 1'b1;  // decimal point off

endmodule
