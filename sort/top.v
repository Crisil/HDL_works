// A verilog code to perform transposition sorting
// It is executed in phases, there are even and odd phase
// In even phase entries with even index are compare against there
// right neighbours and swapped if required
// In odd phase entries with odd index are compared against there
// right neighbours and swapped if required
// sorts n elements in n clock cycle (n is even)
module top #(parameter n= 8, parameter k = 8)
(
  input clk, 
  input rstn,
  input  [n * k - 1 : 0] in,
  output [n * k - 1 : 0] out
);

reg [n * k - 1 : 0] inp_reg;

always @(posedge clk or negedge rstn) begin
  if (!rstn)
    inp_reg <= 0;
  else 
    inp_reg <= in;
end

wire [(n*k -1) : 0] stage[n:0];
assign stage[0] = inp_reg;

genvar i;
generate 
  for (i = 0; i < n; i = i + 1) begin
    odd_even_sort #(.n(n), .k(k), .ODD_PHASE(i & 1'b1)) u_odd_even_sort
    (
      .clk  (clk),
      .rstn (rstn),
      .in (stage[i]),
      .out (stage[i + 1])
    );
    
  end
endgenerate

assign out = stage[n];

endmodule
