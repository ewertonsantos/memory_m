module memory_m #(parameter DWIDTH = 8, AWIDTH = 5) (
  inout logic [DWIDTH-1:0] data,
  input logic [AWIDTH-1:0] addr,
  input logic read,
  input logic write
);
  reg [DWIDTH-1:0] reg_array [31:0];
  logic [7:0] temp_data;
  
  always_comb begin
    if (read)
      temp_data = reg_array[addr];
    else
      temp_data = 8'bzzzzzzzz;
  end
  
  assign data = ( write & ~read) ? data : temp_data;
  
  always_ff @(posedge write) begin
    if ( write & ~read)
      reg_array[addr] <= data;
  end	

endmodule