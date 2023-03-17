module memory_test_m ;

  timeunit      1ns ;
  timeprecision 1ns ;

  wire logic [7:0] data  ; // memory_test data bus (bidirectional)
  var  logic       read  ; // memory_test read (asynch)
  var  logic       write ; // memory_test write (synch pos)
  var  logic [4:0] addr  ; // memory_test address

  localparam bit debug = 1 ;  // messages yes/no
  localparam int DWIDTH = 8 ; // data width
  localparam int AWIDTH = 5 ; // address width

  ///////////////////////////////////////////////////////////////////////
  // TO DO - INSTANTIATE mem MODULE USING IMPLICIT .* PORT CONNECTIONS //
  ///////////////////////////////////////////////////////////////////////
  memory_m #( DWIDTH, AWIDTH ) memory ( .* ) ;

  // Why are we doing this? -- because the memory continuously assigns data.
  //  "A variable cannot be continuously assigned." -- [6.7]
  //  "A net cannot be procedurally assigned."      -- [6.7]
  logic [DWIDTH-1:0] data_w ;        // procedurally write data_w and
  assign data = read ? 'z : data_w ; // assign it to bidirectional data

  //////////////////////////////////////////////////////////////////
  // TO DO - DECLARE AND DEFINE write_mem TASK                    //
  //         INPUT ADDRESS, DATA AND DEBUG FLAG                   //
  //         DEASSERT write AND read; SET addr AND data_w         //
  //         WAIT 5 NS AND SET write HIGH                         //
  //         WAIT 5 NS AND SET write LOW                          //
  //         OPTIONALLY DISPLAY DIAGNOSTICS IF DEBUG FLAG IS HIGH //
  //////////////////////////////////////////////////////////////////
  task write_mem ( input [AWIDTH-1:0] waddr, input [DWIDTH-1:0] wdata, input debug=0 ) ;
    write  = 0 ;
    read   = 0 ;
    addr   = waddr ;
    data_w = wdata ;
    #5ns write  = 1 ;
    if (debug == 1) 
      $display("%t: Write - Address:%d  Data:%h", $time, waddr, wdata);
    #5ns write  = 0 ;
  endtask

  //////////////////////////////////////////////////////////////////
  // TO DO - DECLARE AND DEFINE read_mem TASK                     //
  //         INPUT ADDRESS AND DEBUG FLAG; OUTPUT READ DATA       //
  //         DEASSERT write; ASSERT read; SET addr                //
  //         WAIT 5 NS AND GET data                               //
  //         WAIT 5 NS AND SET read LOW                           //
  //         OPTIONALLY DISPLAY DIAGNOSTICS IF DEBUG FLAG IS HIGH //
  //////////////////////////////////////////////////////////////////
  task read_mem ( input [AWIDTH-1:0] raddr, output [DWIDTH-1:0] rdata, input debug = 0 ) ;
    write = 0 ;
    read  = 1 ;
    addr  = raddr ;
    #5ns rdata = data ;
    if (debug == 1) 
       $display("%t: Read  - Address:%d  Data:%h", $time, raddr, rdata);
    #5ns read  = 0 ;
  endtask

  /////////////////////////////////////////////////////
  // TO DO - DECLARE AND DEFINE printstatus FUNCTION //
  //         INPUT ERROR COUNT                       //
  //         RETURN VOID                             //
  //         DISPLAY STATUS                          //
  //         IF ANY ERRORS TERMINATE SIMULATION      //
  /////////////////////////////////////////////////////
  function void printstatus ( input int unsigned status ) ;
    $display("MEMORY TEST %s with %0d errors",status?"FAILED":"PASSED",status);
    if ( status != 0 ) $finish ;
  endfunction

  initial
    begin
      logic [DWIDTH-1:0] data_read ;
      int unsigned errors ;
      $timeformat ( -9, 0, "ns", 6 ) ;

      /////////////////////////////////////////////////////
      // TO DO - CLEAR THE MEMORY                        //
      //         IN A LOOP CALL write_mem TO WRITE ZEROS //
      //         IN A LOOP CALL read_mem TO READ MEMORY  //
      //         COUNT THE NUMBER OF ERRORS              //
      //         CALL printstatus TO REPORT ERROR COUNT  //
      /////////////////////////////////////////////////////
      $display ( "CLEARING THE MEMORY" ) ;
      errors = 0 ;
      for ( int i = 0; i <= 2**AWIDTH-1; ++i )
        write_mem (i, 0, 0) ;
      for ( int i = 0; i <= 2**AWIDTH-1; ++i )
        begin 
           read_mem (i, data_read, 0) ;
           if ( data_read !== 0 )
             ++errors ;
        end
      printstatus ( errors ) ;

      /////////////////////////////////////////////////////
      // TO DO - PERFORM "DATA = ADDRESS" TEST           //
      //         IN A LOOP CALL write_mem TO WRITE DATA  //
      //         IN A LOOP CALL read_mem TO READ MEMORY  //
      //         COUNT THE NUMBER OF ERRORS              //
      //         CALL printstatus TO REPORT ERROR COUNT  //
      /////////////////////////////////////////////////////
      $display ( "TEST DATA = ADDRESS" ) ;
      errors = 0 ;
      for ( int i = 0; i <= 2**AWIDTH-1; ++i )
        write_mem (i, i, debug) ;
      for ( int i = 0; i <= 2**AWIDTH-1; ++i )
        begin 
           read_mem (i, data_read, debug) ;
           if ( data_read !== i )
             ++errors ;
        end
      printstatus ( errors ) ;
 
    $finish ;

  end

endmodule : memory_test_m
