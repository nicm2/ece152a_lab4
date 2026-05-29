import taillights_pkg::*;

module ucsbece152a_fsm (
  input logic clk,
  input logic rst_n,
  input logic left_i,
  input logic right_i,
  input logic hazard_i,
  output state_t state_o,
  output logic [5:0] pattern_o
);

state_t state_d, state_q = S000_000;

assign state_o = state_q;

always_comb begin
    case (state_q)
        S000_000: pattern_o = 6'b000_000;
        S000_100: pattern_o = 6'b000_100;
        S000_110: pattern_o = 6'b000_110;
        S000_111: pattern_o = 6'b000_111;
        S001_000: pattern_o = 6'b001_000;
        S011_000: pattern_o = 6'b011_000;
        S111_000: pattern_o = 6'b111_000;
        S111_111: pattern_o = 6'b111_111;
        default:  pattern_o = 6'b000_000;
    endcase
end

always_comb begin
    state_d = S000_000;

    if (hazard_i || (left_i && right_i)) begin
        case (state_q)
            S111_111: state_d = S000_000;
            default:  state_d = S111_111;
        endcase
    end else if (left_i && !right_i) begin
        case (state_q)
            S000_000: state_d = S001_000;
            S001_000: state_d = S011_000;
            S011_000: state_d = S111_000;
            S111_000: state_d = S000_000;

            S000_100: state_d = S001_000;
            S000_110: state_d = S001_000;
            S000_111: state_d = S001_000;
            default:  state_d = S001_000;
        endcase
    end else if (right_i && !left_i) begin
        case (state_q)
            S000_000: state_d = S000_100;
            S000_100: state_d = S000_110;
            S000_110: state_d = S000_111;
            S000_111: state_d = S000_000;

            S001_000: state_d = S000_100;
            S011_000: state_d = S000_100;
            S111_000: state_d = S000_100;
            default:  state_d = S000_100;
        endcase
    end else begin
        state_d = S000_000;
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state_q <= S000_000;
    end else begin
        state_q <= state_d;
    end
end

endmodule
