`define NUM_PORTS 8
module tb ();   
    reg clk; 
    reg  [`NUM_PORTS-1:0] req_i;
    wire [`NUM_PORTS-1:0] gnt_o;

    arb_v1 #(.NUM_PORTS(`NUM_PORTS)) u_arb_v1
    (        
        .req_i (req_i),
        .gnt_o (gnt_o)
    );

    initial begin
      $dumpfile("tb.vcd");
      $dumpvars(0, tb);

      #20

      req_i = 8'b10110000;
      #5;        

      #500
      $finish;
    end

    always #5 clk = ~clk;
endmodule