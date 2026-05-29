import taillights_pkg::*;

module ucsbece152a_taillights (
    input  logic clk,
    input  logic rst_n,
    input  logic clk_dimmer_i,
    input  logic left_i,
    input  logic right_i,
    input  logic hazard_i,
    input  logic brake_i,
    input  logic runlights_i,
    output logic [5:0] lights_o
);

logic [5:0] fsm_pattern;
logic [5:0] lights_runlightsoff, lights_runlightson;

ucsbece152a_fsm fsm (
    .clk(clk),
    .rst_n(rst_n),
    .left_i(left_i),
    .right_i(right_i),
    .hazard_i(hazard_i),
    .state_o(),
    .pattern_o(fsm_pattern)
);

// left side = bits [5:3], right side = bits [2:0]
always_comb begin
    if (brake_i) begin

        lights_runlightsoff[5:3] = (left_i && !right_i && !hazard_i)
                                    ? fsm_pattern[5:3] : 3'b111;

        lights_runlightsoff[2:0] = (right_i && !left_i && !hazard_i)
                                    ? fsm_pattern[2:0] : 3'b111;
    end else begin
        lights_runlightsoff = fsm_pattern;
    end
end

always_comb begin
    lights_runlightson = lights_runlightsoff |
                         (~lights_runlightsoff & {6{clk_dimmer_i}});
end

always_comb begin
    lights_o = runlights_i ? lights_runlightson : lights_runlightsoff;
end

endmodule 
