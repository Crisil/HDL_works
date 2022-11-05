module odd_even_sort #(parameter n = 8, parameter k = 8, parameter ODD_PHASE = 1)
(
  input  clk, 
  input  rstn,
  input  [n * k - 1 : 0] in,
  output [n * k - 1 : 0] out
);

reg [n * k - 1 : 0] out_reg;

genvar i;
generate
  if (ODD_PHASE) begin : odd
    for (i = 1; i < n/2; i = i + 1) begin
      always @(posedge clk or negedge rstn) begin
        if (rstn == 1'b0) begin
          out_reg[((2*i + 1)*k - 1)-: 2*k] <= 0;
        end else begin
          if (in[((2*i + 0)*k - 1)-: k] >= in[((2*i + 1)*k - 1)-: k]) begin
            out_reg[((2*i + 0)*k - 1)-: k] <= in[((2*i + 1)*k - 1)-: k];
            out_reg[((2*i + 1)*k - 1)-: k] <= in[((2*i + 0)*k - 1)-: k];
          end else begin
            out_reg[((2*i + 1)*k -1)-: 2*k] <= in[((2*i + 1)*k -1)-: 2*k];
          end 
        end 
      end
    end

    always @(posedge clk or negedge rstn) begin
      if (rstn == 1'b0) begin
        out_reg[k - 1 : 0] <= 0;
        out_reg[((n*k) - 1)-: k] <= 0;
      end else begin
        out_reg[k - 1 : 0]  <= in[k - 1 : 0];
        out_reg[((n*k) - 1)-: k] <= in[((n*k) - 1)-: k];
      end 
    end 

  end else begin : even
    for (i = 0; i < n/2; i = i + 1) begin
      always @(posedge clk or negedge rstn) begin
        if (rstn == 1'b0)
          out_reg[((2*i + 2)*k -1)-: 2*k] <= 0; 
        else begin
          if (in[((2*i + 1)*k - 1)-: k] >= in[((2*i + 2)*k - 1)-: k]) begin
            out_reg[((2*i + 1)*k - 1)-: k] <= in[((2*i + 2)*k - 1)-: k];
            out_reg[((2*i + 2)*k - 1)-: k] <= in[((2*i + 1)*k - 1)-: k];
          end else begin
            out_reg[((2*i + 2)*k -1)-: 2*k] <= in[((2*i + 2)*k -1)-: 2*k];
          end
        end 
      end
    end


  end

endgenerate
assign out = out_reg;
endmodule