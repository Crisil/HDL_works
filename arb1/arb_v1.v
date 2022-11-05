module arb_v1 #(parameter NUM_PORTS = 4)
(
    input  [NUM_PORTS-1:0] req_i,
    output [NUM_PORTS-1:0] gnt_o
);

//assign gnt_o = {{(NUM_PORTS - 1){1'b0}}, req_i[0]};
assign gnt_o[0] = req_i[0];

genvar i;
for (i = 1; i < NUM_PORTS; i = i + 1) begin
  assign gnt_o[i] = req_i[i] & ~(|gnt_o[i - 1:0]);
end

endmodule