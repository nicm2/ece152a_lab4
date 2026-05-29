module ucsbece152a_taillights_tb();
 
import taillights_pkg::*;

logic clk = 0;
always #(10) clk = ~clk; 

logic clk_dimmer_i = 0;
always #(3) clk_dimmer_i = ~clk_dimmer_i;

logic rst_n;
logic left_i, right_i, hazard_i, brake_i, runlights_i;
logic [5:0] lights_o;

ucsbece152a_taillights DUT (
    .clk(clk),
    .rst_n(rst_n),
    .clk_dimmer_i(clk_dimmer_i),
    .left_i(left_i),
    .right_i(right_i),
    .hazard_i(hazard_i),
    .brake_i(brake_i),
    .runlights_i(runlights_i),
    .lights_o(lights_o)
);

initial begin
    $display("Begin simulation.");

    left_i=0; right_i=0; hazard_i=0; brake_i=0; runlights_i=0;

    rst_n = 0;
    @(negedge clk);
    rst_n = 1;
    if (lights_o !== 6'b000_000)
        $display("Error: expected lights_o=000000 after reset, received %b", lights_o);

    // test 1: right turn signal
    right_i = 1;
    @(negedge clk);
    if (lights_o !== 6'b000_100)
        $display("Error T1a: expected 000100, received %b", lights_o);
    @(negedge clk);
    if (lights_o !== 6'b000_110)
        $display("Error T1b: expected 000110, received %b", lights_o);
    @(negedge clk);
    if (lights_o !== 6'b000_111)
        $display("Error T1c: expected 000111, received %b", lights_o);
    @(negedge clk);
    if (lights_o !== 6'b000_000)
        $display("Error T1d: expected 000000 (wrap), received %b", lights_o);
    right_i = 0;
    @(negedge clk);

    // test 2: left turn signal
    left_i = 1;
    @(negedge clk);
    if (lights_o !== 6'b001_000)
        $display("Error T2a: expected 001000, received %b", lights_o);
    @(negedge clk);
    if (lights_o !== 6'b011_000)
        $display("Error T2b: expected 011000, received %b", lights_o);
    @(negedge clk);
    if (lights_o !== 6'b111_000)
        $display("Error T2c: expected 111000, received %b", lights_o);
    @(negedge clk);
    if (lights_o !== 6'b000_000)
        $display("Error T2d: expected 000000 (wrap), received %b", lights_o);
    left_i = 0;
    @(negedge clk);

    // test 3: hazard lights
    hazard_i = 1;
    @(negedge clk);
    if (lights_o !== 6'b111_111)
        $display("Error T3a: expected 111111, received %b", lights_o);
    @(negedge clk);
    if (lights_o !== 6'b000_000)
        $display("Error T3b: expected 000000, received %b", lights_o);
    @(negedge clk);
    if (lights_o !== 6'b111_111)
        $display("Error T3c: expected 111111, received %b", lights_o);
    hazard_i = 0;
    @(negedge clk);

    // test 4: both turn signals
    left_i = 1; right_i = 1;
    @(negedge clk);
    if (lights_o !== 6'b111_111)
        $display("Error T4a: expected 111111, received %b", lights_o);
    @(negedge clk);
    if (lights_o !== 6'b000_000)
        $display("Error T4b: expected 000000, received %b", lights_o);
    left_i = 0; right_i = 0;
    @(negedge clk);

    // test 5: brake only
    brake_i = 1;
    @(negedge clk);
    if (lights_o !== 6'b111_111)
        $display("Error T5: expected 111111, received %b", lights_o);
    brake_i = 0;
    @(negedge clk);

    // test 6: brake and left turn
    left_i = 1; brake_i = 1;
    @(negedge clk);
    if (lights_o !== 6'b001_111)
        $display("Error T6a: expected 001111, received %b", lights_o);
    @(negedge clk);
    if (lights_o !== 6'b011_111)
        $display("Error T6b: expected 011111, received %b", lights_o);
    @(negedge clk);
    if (lights_o !== 6'b111_111)
        $display("Error T6c: expected 111111, received %b", lights_o);
    left_i = 0; brake_i = 0;
    @(negedge clk);

    // test 7: brake and right turn
    right_i = 1; brake_i = 1;
    @(negedge clk);
    if (lights_o !== 6'b111_100)
        $display("Error T7a: expected 111100, received %b", lights_o);
    @(negedge clk);
    if (lights_o !== 6'b111_110)
        $display("Error T7b: expected 111110, received %b", lights_o);
    @(negedge clk);
    if (lights_o !== 6'b111_111)
        $display("Error T7c: expected 111111, received %b", lights_o);
    right_i = 0; brake_i = 0;
    @(negedge clk);

    // test 8: hazard overrides turning signal
    left_i = 1;
    @(negedge clk); // S001_000
    hazard_i = 1;   // hazard kicks in
    @(negedge clk);
    if (lights_o !== 6'b111_111)
        $display("Error T8: expected 111111, received %b", lights_o);
    left_i = 0; hazard_i = 0;
    @(negedge clk);

    // test 9: brake overrides hazard
    hazard_i = 1; brake_i = 1;
    @(negedge clk);
    if (lights_o !== 6'b111_111)
        $display("Error T9: expected 111111, received %b", lights_o);
    hazard_i = 0; brake_i = 0;
    @(negedge clk);

    // test 10: running lights only
    runlights_i = 1;
    @(negedge clk);
    // off lights should flicker with clk_dimmer_i
    // just check it doesn't output all 0s or all 1s constantly
    @(negedge clk);
    @(negedge clk);
    runlights_i = 0;
    @(negedge clk);

    // test 11: running lights and right turn
    right_i = 1; runlights_i = 1;
    @(negedge clk);
    @(negedge clk);
    @(negedge clk);
    right_i = 0; runlights_i = 0;
    @(negedge clk);

    // test 12: reset 
    left_i = 1;
    @(negedge clk);
    @(negedge clk);
    rst_n = 0;  // reset mid sequence
    @(negedge clk);
    if (lights_o !== 6'b000_000)
        $display("Error T12: expected 000000 after reset, received %b", lights_o);
    rst_n = 1;
    left_i = 0;
    @(negedge clk);

    $display("End simulation.");
    $stop;
end

endmodule
