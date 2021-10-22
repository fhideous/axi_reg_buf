
module BUFFER( 
    input               clk_i,
    input               arstn_i,

    input               tvalid_i,
    output reg          tready_o,
    input       [3:0]   tdata_i,

    input               tready_i,
    output reg          tvalid_o,
    output reg  [3:0]   tdata_o
);

reg   [3:0]             data_reg_0;
reg   [3:0]             data_reg_1;

wire                    handshake_left;
wire                    handshake_right;

reg   [1:0]             state;  
reg   [1:0]             next_state;


localparam    IDLE_S                 = 2'b00;
localparam    ONE_BIT_HOLD_S         = 2'b01;  
localparam    TWO_BIT_HOLD_S         = 2'b10;

always @( posedge clk_i ) begin
    if ( !arstn_i ) 
        tready_o       <= 1;
    else begin
        //if ( state == ONE_BIT_HOLD_S && tvalid_i && !tready_i)
         if ( next_state == TWO_BIT_HOLD_S )
            tready_o <= 1'b0;
        //else if ( state == TWO_BIT_HOLD_S && tready_i )
        else if ( state == TWO_BIT_HOLD_S && next_state == ONE_BIT_HOLD_S )
            tready_o <= 1'b1; 
    end
end

always @( posedge clk_i ) begin
    if ( !arstn_i )
        tvalid_o      <= 0;
    else begin 
        //if ( state == ONE_BIT_HOLD_S && !tvalid_i && tready_i )
        if ( next_state == IDLE_S )
            tvalid_o <= 1'b0;
        //else if ( state == IDLE_S && tvalid_i)
        else if ( next_state == ONE_BIT_HOLD_S )
            tvalid_o <= 1'b1;

    end
end

//assign    handshake_left  = ( tready_o && tvalid_i ) ; /* || ( tvalid_i && handshake_right ) */ 
//assign    handshake_right = ( tready_i && tvalid_o );
assign    handshake_left  = (  tvalid_i ) ; /* || ( tvalid_i && handshake_right ) */ 
assign    handshake_right = ( tready_i  );

always @( posedge clk_i ) begin
    if ( !arstn_i ) begin
        tdata_o     <= 
        'b0;
        data_reg_0  <= 'b0;
        data_reg_1  <= 'b0;
    end
    else begin
        if      (state == IDLE_S         && handshake_left)
            data_reg_0  <= tdata_i;
        else if (state == TWO_BIT_HOLD_S && handshake_left && handshake_right) begin
            tdata_o     <= data_reg_0;
            data_reg_0  <= data_reg_1;
            data_reg_1  <= tdata_i;
        end
        else if (state == ONE_BIT_HOLD_S && handshake_left && handshake_right) begin
            tdata_o     <= data_reg_0;
            data_reg_0  <= tdata_i;
        end
        else if (state == ONE_BIT_HOLD_S && handshake_left)
            data_reg_1  <= tdata_i;
        else if (state == ONE_BIT_HOLD_S && handshake_right)
            tdata_o     <= data_reg_0;
        else if (state == TWO_BIT_HOLD_S && handshake_right) begin
            tdata_o     <= data_reg_0;
            data_reg_0  <= data_reg_1;
        end
    end    
end

always @( posedge clk_i )
  if( !arstn_i )
    state <= IDLE_S;
  else
    state <= next_state;

always @( * ) begin

  case( state )
    IDLE_S:
      begin
        if( handshake_left )
          next_state = ONE_BIT_HOLD_S;
        else 
          next_state = IDLE_S;
      end

    ONE_BIT_HOLD_S:
      begin
        if ( handshake_left && handshake_right ) 
          next_state  = ONE_BIT_HOLD_S;
        else if( handshake_right ) 
            next_state = IDLE_S;
        else if ( handshake_left )
            next_state = TWO_BIT_HOLD_S;
        else 
            next_state = ONE_BIT_HOLD_S;
        end

    TWO_BIT_HOLD_S:
      begin
        if( handshake_right && handshake_left )
            next_state  = TWO_BIT_HOLD_S;
        else if ( handshake_right )
            next_state = ONE_BIT_HOLD_S;
        else 
            next_state = TWO_BIT_HOLD_S; 
      end
  
    default:
      begin
        next_state = IDLE_S;
      end

  endcase
end
  
  
  endmodule