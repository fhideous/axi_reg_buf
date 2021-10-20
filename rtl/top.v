
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

reg                     handshake_left;
reg                     handshake_right;

reg   [1:0]             state;  
reg   [1:0]             next_state;


localparam    IDLE_S                 = 2'b00;
localparam    ONE_BIT_HOLD_S         = 2'b01;  
localparam    TWO_BIT_HOLD_S         = 2'b10;

always @( posedge clk_i ) begin
    if ( !arstn_i )
        handshake_left <= 0;
    else begin
        if (state == IDLE_S || state == ONE_BIT_HOLD_S ) begin
            if ( tvalid_i ) begin
                handshake_left <= 1'b1;
                if (state == ONE_BIT_HOLD_S)
                    tready_o <= 1'b0;
                tvalid_o <= 1'b1;
            end
        end
        else if ( handshake_left )
            handshake_left <= 1'b0;
    end
end

always @( posedge clk_i ) begin
    if ( !arstn_i )
        handshake_right <= 1'b0;
    else begin 
        if ( state == ONE_BIT_HOLD_S || state == TWO_BIT_HOLD_S ) begin
            if ( tready_i ) begin
                handshake_right <= 1'b1;      
            end
            if ( state == ONE_BIT_HOLD_S )
                tvalid_o <= 1'b0;
            else
                tready_o <= 1'b0;
        end
        else if ( handshake_right )
            handshake_right <= 1'b0; 
    end
end

always @( posedge clk_i ) begin
    if ( !arstn_i ) begin
        tdata_o     <= 'b0;
        data_reg_0  <= 'b0;
        data_reg_1  <= 'b0;
    end
    else begin
        if      (state == IDLE_S         && next_state == ONE_BIT_HOLD_S)
            data_reg_0  <= tdata_i;
        else if (state == ONE_BIT_HOLD_S && next_state == IDLE_S)
            tdata_o     <= data_reg_0;
        else if (state == ONE_BIT_HOLD_S && next_state == TWO_BIT_HOLD_S)
            data_reg_1  <= tdata_i;
        else if (state == TWO_BIT_HOLD_S && next_state == ONE_BIT_HOLD_S)
            tdata_o     <= data_reg_1;
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
        if ( handshake_left ) 
          next_state  = TWO_BIT_HOLD_S;
        else begin
          if( handshake_right ) 
            next_state = IDLE_S;
          else 
            next_state = ONE_BIT_HOLD_S;
        end
      end

    TWO_BIT_HOLD_S:
      begin
        if( handshake_right )
            next_state  = ONE_BIT_HOLD_S;
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