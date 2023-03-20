// Code your design here
module memory_m #(parameter DWIDTH = 8, AWIDTH = 5) (
  inout logic [DWIDTH-1:0] data,
  input logic [AWIDTH-1:0] addr,
  input logic read,
  input logic write
);
  // internal registar thats isnt input or output, its the reason its here
  reg [DWIDTH-1:0] reg_array [(2**AWIDTH)-1:0];
  // intermadiate variable for data when its treated as output 
  //cause we cannot pass a register directly to a logical inside awalys block
  logic [7:0] temp_data;
  
  always_comb begin
    if (read & ~write)
      temp_data = reg_array[addr];
    else
      temp_data = {DWIDTH{1'bz}};;
  end 
    
  always_ff @(posedge write) begin
    if ( write & ~read)
      reg_array[addr] <= data;
  end	
  
  assign data = ( write & ~read) ? data : temp_data;

endmodule