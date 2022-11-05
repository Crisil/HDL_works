`define N 4
`define PATTERN 4'b1011 
module tb;
    reg clk;
    reg rstn;
    reg xin;
    
    wire det_o;
    
    det #(.N(`N), .PATTERN(`PATTERN)) u_det
    (
        .clk    (clk),
        .rstn   (rstn),
        .xin    (xin),
        .det_o  (det_o)
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
      xin = 1'b1;

      #10
      xin = 1'b0;

      #10
      xin = 1'b1;

      #10
      xin = 1'b1;

      #10
      xin = 1'b0;
           
    
      #500
      $finish;
    
    end


endmodule