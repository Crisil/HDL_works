module p2s #(parameter DWIDTH = 4)
(
    input clk,
    input rstn,
    
    input [DWIDTH-1:0] indata,
    input invalid,

    output empty,
    output dout,
    output valid
);

localparam M = $clog2(DWIDTH);

reg  [DWIDTH-1:0] shift_ff;
wire [DWIDTH-1:0] nxt_shift;

reg  [M:0] count_ff;
wire [M:0] nxt_count;

always @(posedge clk or negedge rstn) begin
  if (!rstn) begin
    shift_ff <= 0;
  end else if (invalid) begin
    shift_ff <= nxt_shift;
  end

end

assign nxt_shift = empty ? indata : {1'b0, shift_ff[DWIDTH-1:1]};

always @(posedge clk or negedge rstn) begin
  if (!rstn) begin
    count_ff <= 0;
  end else if (invalid) begin
    count_ff <= nxt_count;
  end 
end

assign nxt_count = (count_ff == DWIDTH) ? 0 : count_ff + 1'b1;


assign dout = shift_ff[0];
assign valid = |count_ff && invalid;
assign empty = (count_ff == 0) || !invalid;

endmodule
