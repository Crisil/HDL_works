`define DWIDTH 4
module tb;
    reg clk;
    reg rstn;
    reg [`DWIDTH-1:0] indata;
    reg invalid;

    wire empty;
    wire dout;
    wire valid;

    p2s #(.DWIDTH(`DWIDTH)) u_p2s
    (
        .clk    (clk),
        .rstn   (rstn),
        .indata (indata),
        .invalid(invalid),
        .empty  (empty),
        .dout   (dout),
        .valid  (valid)
    );

    always #5 clk = ~clk;

    initial begin
      $dumpfile("tb.vcd");
      $dumpvars (0, tb);

      clk  = 1'b0;
      rstn = 1'b0;

      #12
      rstn = 1'b1;

      #2
      indata = 4'b1010;
      invalid = 1'b1;

      #40
      invalid = 1'b0;
    
      #500
      $finish;
    

    end


endmodule