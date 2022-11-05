module axilite_reg #(parameter C_S_AXI_DATA_WIDTH = 32, parameter C_S_AXI_ADDR_WIDTH = 4)
(
	input s_axi_aclk,
	input s_axi_aresetn,

	input  [C_S_AXI_ADDR_WIDTH-1:0] s_axi_awaddr,
	input  [2:0] s_axi_awport,
	input  s_axi_awvalid,
	output s_axi_awready,

	input  [C_S_AXI_DATA_WIDTH-1:0] s_axi_wdata,
	input  s_axi_wvalid,
	output s_axi_wready,
	input  [(C_S_AXI_DATA_WIDTH/8)-1:0] s_axi_wstrb,

	output [1:0] s_axi_bresp,
	output s_axi_bvalid,
	input  s_axi_bready,

	input  [C_S_AXI_ADDR_WIDTH-1:0] s_axi_araddr,
	input  [2:0] s_axi_arport,
	input  s_axi_arvalid,
	output s_axi_arready,
	output [C_S_AXI_DATA_WIDTH-1:0] s_axi_rdata,
	output [1:0] s_axi_rresp,
	output s_axi_rvalid,
	input  s_axi_rready
);

localparam ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
localparam OPT_MEM_ADDR_BITS = 1;
localparam STROBE_WIDTH = C_S_AXI_DATA_WIDTH/8;

reg [C_S_AXI_ADDR_WIDTH-1:0] axi_awaddr;
reg axi_awready;
reg axi_wready;
reg [1:0] axi_bresp;
reg axi_bvalid;
reg [C_S_AXI_ADDR_WIDTH-1:0] axi_araddr;
reg axi_arready;
reg [C_S_AXI_DATA_WIDTH-1:0] axi_rdata;
reg [1:0] axi_rresp;
reg axi_rvalid;

reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg0;
reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg1;
reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg2;
reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg3;
wire slv_reg_wen;
wire slv_reg_rden;

wire [1:0] dbg_wreg = axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB];

reg [C_S_AXI_DATA_WIDTH-1:0] reg_data_out;

// Generate AXI awready
always @(posedge s_axi_aclk) begin
	if (!s_axi_aresetn) 
		axi_awready <= 1'b0;
	else begin
		if (s_axi_awvalid && s_axi_wvalid && ~axi_awready)
			axi_awready <= 1'b1;
		else 
			axi_awready <= 1'b0;
	end
end

// Latch Address
always @(posedge s_axi_aclk) begin
	if (!s_axi_aresetn)
		axi_awaddr <= 0;
	else begin
		if (s_axi_awvalid && s_axi_wvalid && ~axi_awready)
			axi_awaddr <= s_axi_awaddr;
	end
end

// Generate AXI wready
always @(posedge s_axi_aclk) begin
	if (!s_axi_aresetn)
		axi_wready <= 1'b0;
	else begin
		if (s_axi_awvalid && s_axi_wvalid && ~axi_wready)
			axi_wready <= 1'b1;
		else 
			axi_wready <= 1'b0;
	end
end

// Implement Memory Mapped registers
assign slv_reg_wen = s_axi_wvalid && axi_wready && s_axi_awvalid && axi_awready;

reg [31:0] msg;
integer i = 0;
always @(posedge s_axi_aclk) begin
	if (!s_axi_aresetn) begin
		slv_reg0 <= 0;
		slv_reg1 <= 0;
		slv_reg2 <= 0;
		slv_reg3 <= 0;
	end else begin
		if (slv_reg_wen) begin
		  case (axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB])
				2'h0: begin
					for (i = 0; i < STROBE_WIDTH; i=i+1) begin
						if (s_axi_wstrb[i]) slv_reg0[(i*8) +: 8] <= s_axi_wdata[(i*8) +: 8];
					end
				end 

				2'h1: begin
					for (i = 0; i < STROBE_WIDTH; i=i+1) begin
						if (s_axi_wstrb[i]) slv_reg1[(i*8) +: 8] <= s_axi_wdata[(i*8) +: 8];
					end
        end

				2'h2: begin
					for (i = 0; i < STROBE_WIDTH; i=i+1) begin
						if (s_axi_wstrb[i]) slv_reg2[(i*8) +: 8] <= s_axi_wdata[(i*8) +: 8];
					end
        end

				2'h3: begin
					for (i = 0; i < STROBE_WIDTH; i=i+1) begin
						if (s_axi_wstrb[i]) slv_reg3[(i*8) +: 8] <= s_axi_wdata[(i*8) +: 8];
					end
			 end
		  endcase
	  end
	end
end

// Write Response
always @(posedge s_axi_aclk) begin
	if (!s_axi_aresetn) begin
		axi_bvalid <= 1'b0;
		axi_bresp  <= 2'b0;
	end else begin
		if (axi_awready && s_axi_awvalid && axi_wready && s_axi_wvalid && ~axi_bvalid) begin
			axi_bvalid <= 1'b1;
			axi_bresp  <= 2'b00;
		end else begin
			axi_bvalid <= 1'b0;
		end
	end
end

// AXI read ready
always @(posedge s_axi_aclk) begin 
	if (!s_axi_aresetn)
		axi_arready <= 1'b0;
	else begin
		if (s_axi_arvalid && ~axi_arready) begin
			axi_arready <= 1'b1;
			axi_araddr  <= s_axi_araddr;
		end else 
			axi_arready <= 1'b0;
	end
end

always @(posedge s_axi_aclk) begin
	if (!s_axi_aresetn) begin
		axi_rvalid <= 1'b0;
		axi_rresp  <= 2'b0;
	end else begin
		if (axi_arready && s_axi_arvalid && ~axi_rvalid) begin
			axi_rvalid <= 1'b1;
			axi_rresp  <= 2'b0;
		end else 
			axi_rvalid <= 1'b0;
	end
end

assign slv_reg_rden = axi_arready && s_axi_arvalid && ~axi_rvalid;

always @* begin
	if (!s_axi_aresetn) 
		reg_data_out <= 0;
	else begin
		case (axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB])
			2'h0 : reg_data_out <= slv_reg0;
			2'h1 : reg_data_out <= slv_reg1;
			2'h2 : reg_data_out <= slv_reg2;
			2'h3 : reg_data_out <= slv_reg3;
		endcase
	end
end

always @(posedge s_axi_aclk) begin
	if (!s_axi_aresetn)
		axi_rdata <= 0;
	else begin
		if (slv_reg_rden)
			axi_rdata <= reg_data_out;
	end
end

assign s_axi_awready = axi_awready;
assign s_axi_wready  = axi_wready;
assign s_axi_bresp   = axi_bresp;
assign s_axi_bvalid  = axi_bvalid;
assign s_axi_arready = axi_arready;
assign s_axi_rdata   = axi_rdata;
assign s_axi_rresp   = axi_rresp;
assign s_axi_rvalid  = axi_rvalid;
endmodule
