module dff (
	input clk, 
	input rst_n,
	input e,
	input d,
	output reg q,
	output reg qr
);

reg q1;
reg q2;
reg qr1;
reg qr2;

//always @(posedge clk or negedge rst_n) begin
//	if (!rst_n) begin
//		q  <= 1'b0;
//		q1 <= 1'b0;
//		q2 <= 1'b0;
//	end else begin
//		q1 <= d;
//		q2 <= q1;
//		q  <= q2;
//	end
//end
//
//always @(posedge clk or negedge rst_n) begin
//	if (!rst_n) begin
//		qr  = 1'b0;
//		qr1 = 1'b0;
//		qr2 = 1'b0;
//	end else begin
//		qr1 = d;
//		qr2 = qr1;
//		qr  = qr2;
//	end
//end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n)
		q <= 1'b0;
	else if (e)
		q <= d;
end

endmodule
