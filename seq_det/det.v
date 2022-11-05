/*
 * A module to detect pattern
 */
module det #(parameter N = 4, parameter PATTERN = 4'b1011)
(
    input clk,
    input rstn,

    input xin,
    output det_o
);

reg [N-1:0] f_shift;
reg [N-1:0] nxt_shift;

always @(posedge clk or negedge rstn) begin
  if (!rstn) begin
    f_shift <= 0;
  end else begin
    f_shift <= nxt_shift;
  end
end

assign nxt_shift = {f_shift[N-2:0], xin};
assign det_o = (f_shift == PATTERN);

endmodule