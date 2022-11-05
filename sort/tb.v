module tb;

  parameter WIDTH_OF_INPUT = 4;
  parameter NUM_OF_INPUT = 8;
  parameter CLK_CYC = 10;
  parameter NUM_OF_TEST = 10;

  reg clk;
  reg rstn;
  reg [NUM_OF_INPUT*WIDTH_OF_INPUT - 1 : 0] in;
  wire [NUM_OF_INPUT*WIDTH_OF_INPUT - 1 : 0] out;

  top #(.n(NUM_OF_INPUT), .k(WIDTH_OF_INPUT)) DUT
  (
    .clk  (clk),
    .rstn (rstn),
    .in   (in),
    .out  (out)
  );

  always # (0.5 * CLK_CYC) clk = ~clk;

  initial begin : init
    integer count, i;
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);

    clk = 1;
    rstn = 0;
    #(3.5 * CLK_CYC)
    rstn = 1;

    for (count = 0; count < NUM_OF_TEST; count = count + 1) begin
      for (i = 0; i < NUM_OF_INPUT; i = i + 1) 
        in[((i + 1)*WIDTH_OF_INPUT - 1)-:WIDTH_OF_INPUT] = {$random}%(2**WIDTH_OF_INPUT);
      #(CLK_CYC);
    end
    #(1.5 * NUM_OF_INPUT *CLK_CYC)
    $finish;
  end
endmodule