`timescale 1ns / 1ps

module tb_ec_aa4_registred_axi();

  parameter TOTAL_HS_QUAN           = 50000;
  parameter CLK_I_SEMIPERIOD        = 3;
  parameter PCQ_DELAY               = 1;

  parameter SS_DELAY_PARAM          = 3; // probability of delay insertion after handshake is equal to    1 / ( 1 + SS_DELAY_PARAM )
  parameter MAX_SS_DELAY_IN_CYCLES  = 3; // set to 0 for test without ss delay

  parameter SM_DELAY_PARAM          = 3; // similar to SS_DELAY_PARAM
  parameter MAX_SM_DELAY_IN_CYCLES  = 3; // similar to MAX_SS_DELAY_IN_CYCLES


  parameter DATA_WIDTH = 3;


  reg                   clk_i;
  reg                   aresetn_i;
  reg                   ss_valid_i = 0;
  reg [DATA_WIDTH-1:0]  ss_data_i  = 0;
  wire                  ss_ready_o;
  wire                  sm_valid_o;
  wire [DATA_WIDTH-1:0] sm_data_o;
  reg                   sm_ready_i = 0;


  BUFFER#(
    .DATA_WIDTH    ( DATA_WIDTH  )
  ) DUT (
    .clk_i         ( clk_i       ),
    .arstn_i       ( aresetn_i   ),

    .tvalid_i      ( ss_valid_i  ),
    .tdata_i       ( ss_data_i   ),
    .tready_o      ( ss_ready_o  ),

    .tvalid_o      ( sm_valid_o  ),
    .tdata_o       ( sm_data_o   ),
    .tready_i      ( sm_ready_i  )
  );


  initial begin
    clk_i = 1'b1;
    forever #CLK_I_SEMIPERIOD clk_i = !clk_i;
  end


  initial begin
    aresetn_i = 0;

    repeat( 1000 )
      @( posedge clk_i );
    #PCQ_DELAY;
    aresetn_i <= 1; 
  end


  initial begin : ss_part
    integer delay_quan;
    integer i;
    @( posedge clk_i );
    while ( !aresetn_i )
      @( posedge clk_i );
    #PCQ_DELAY;

    for ( i = 0; i < TOTAL_HS_QUAN; i = i + 1 ) begin
      ss_valid_i <= 1;
      ss_data_i  <= i % (2**DATA_WIDTH);

      @( posedge clk_i );
      while ( !ss_ready_o )
        @( posedge clk_i );

      #PCQ_DELAY;
      ss_valid_i <= 0;

      if ( !$urandom_range(SS_DELAY_PARAM, 0) && MAX_SS_DELAY_IN_CYCLES > 0 ) begin
        delay_quan = $urandom_range(MAX_SS_DELAY_IN_CYCLES, 1);
        repeat( delay_quan )
          @( posedge clk_i );
        #PCQ_DELAY;
      end
    end
  end


  initial begin : sm_part
    integer delay_quan;
    integer i;
    @( posedge clk_i );
    while ( !aresetn_i )
      @( posedge clk_i );
    #PCQ_DELAY;

    for (  i = 0; i < TOTAL_HS_QUAN; i = i + 1 ) begin
      sm_ready_i <= 1;

      @( posedge clk_i );
      while ( !sm_valid_o )
        @( posedge clk_i );

      if ( sm_data_o != (i % (2**DATA_WIDTH)) )begin
        $display( "ERROR: sm_data_o = %0d, expected value = %0d at time %t", sm_data_o, (i % (2**DATA_WIDTH)), $time );
        $stop;
      end

      #PCQ_DELAY;
      sm_ready_i <= 0;

      if ( !($random % (SM_DELAY_PARAM+1)) && MAX_SM_DELAY_IN_CYCLES > 0 ) begin
        delay_quan = $urandom_range(MAX_SM_DELAY_IN_CYCLES, 1);
        repeat( delay_quan )
          @( posedge clk_i );
        #PCQ_DELAY;
      end
    end

    $display( "INFO: Test successfully passed" );
    $finish;
  end


endmodule
