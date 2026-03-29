// Code your testbench here
// or browse Examples

module sram  #(
    parameter depth = 1024, 
    parameter width = 32
)
  (input clk , rst , we ,
   input [$clog2(depth)-1:0] addr,
   input [width-1:0] wdata,
   output reg [width-1:0] rdata );
  
  reg [width-1:0] mem [depth-1:0];
  
  always @(posedge clk)
    begin 
      if(rst) begin
        rdata <= 0 ;
      end
      else begin
        if (we)
          
          mem[addr] <= wdata ;
      
      rdata <= mem[addr];
      end 
    end 
endmodule 
