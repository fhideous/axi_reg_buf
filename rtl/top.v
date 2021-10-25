
module BUFFER #(
    parameter DATA_WIDTH = 3
)(  
    input                            clk_i,
    input                            arstn_i,

    input                            tvalid_i,
    output reg                       tready_o,
    input       [DATA_WIDTH - 1:0]   tdata_i,

    input                            tready_i,
    output reg                       tvalid_o,
    output reg  [DATA_WIDTH - 1:0]   tdata_o
);

reg  [DATA_WIDTH - 1:0]              data_hold;

wire                                 handshake_left;
wire                                 handshake_right;

wire [DATA_WIDTH - 1:0]              state;  

assign state = {tready_o , tvalid_o};

localparam    IDLE_S                 = 2'b10;
localparam    ONE_BIT_HOLD_S         = 2'b11;  
localparam    TWO_BIT_HOLD_S         = 2'b01;

assign        handshake_left  = (state[1] && tvalid_i);
assign        handshake_right = (state[0] && tready_i);

always @( posedge clk_i ) begin
    if ( !arstn_i ) 
        tready_o      <= 1'b1;
    else begin
        if (state == ONE_BIT_HOLD_S && tvalid_i && !tready_i)
            tready_o <= 1'b0;
        else if (state == TWO_BIT_HOLD_S && tready_i)
            tready_o <= 1'b1;
    end
end

always @( posedge clk_i ) begin
    if ( !arstn_i )
        tvalid_o      <= 1'b0;
    else begin 
        if (state == IDLE_S && tvalid_i)
            tvalid_o <= 1'b1;
        else if (state == ONE_BIT_HOLD_S && tready_i && !tvalid_i)
            tvalid_o <= 1'b0;  
    end
end

always @( posedge clk_i ) begin
    if ( !arstn_i ) begin
        tdata_o     <= 'b0;
        data_hold   <= 'b0;
    end
    else begin
        if (state == IDLE_S && handshake_left)
            tdata_o     <= tdata_i;
        else if (state == ONE_BIT_HOLD_S && handshake_left && handshake_right)
            tdata_o     <= tdata_i;
        else if (state == ONE_BIT_HOLD_S && handshake_left)
            data_hold   <= tdata_i;
        else if (state == TWO_BIT_HOLD_S && handshake_right)
            tdata_o     <= data_hold;
    end    
end

  endmodule