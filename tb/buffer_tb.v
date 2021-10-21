`timescale 1ns / 1ps

module buffer_tb;
    reg         clk_i;
    reg         arstn_i;

    reg         tvalid_i;
    wire        tready_o;
    reg  [3:0]  tdata_i;

    reg         tready_i;
    wire        tvalid_o;
    wire [3:0]  tdata_o;

    localparam CLK_SEMIPERIOD = 5;

    BUFFER uut
    (
            .clk_i      (   clk_i       ),
            .arstn_i    (   arstn_i     ),
            
            .tvalid_i   (   tvalid_i    ),
            .tready_o   (   tready_o    ),
            .tdata_i    (   tdata_i     ),
            
            .tready_i   (   tready_i    ),
            .tvalid_o   (   tvalid_o    ),
            .tdata_o    (   tdata_o     )
    );

    task buffer_test;
        input reg           valid_i;
        input reg           ready_i;
        input reg  [3:0]    data_i;
                
        begin
            tvalid_i    = valid_i;
            tdata_i     = data_i;
            tready_i    = ready_i;
            #10
            
                $display("--------------");
        end

    endtask

    initial begin
        clk_i = 'b0;
        forever begin 
              #CLK_SEMIPERIOD clk_i = ~clk_i;
        end
    end

    initial begin
        arstn_i         <=  0;
        #400
        arstn_i         <=  1;
        
        buffer_test(0, 0, 4'b0100);
        buffer_test(1, 0, 4'b0001);
        buffer_test(1, 0, 4'b1000);
        buffer_test(1, 0, 4'b0010);
        buffer_test(0, 0, 4'b1100);
        buffer_test(1, 1, 4'b1100);
        buffer_test(0, 0, 4'b0101);
        buffer_test(0, 1, 4'b1001);
        buffer_test(0, 1, 4'b1111);
        #100
        buffer_test(1, 1, 4'b0011);
        buffer_test(1, 0, 4'b1001);
        buffer_test(1, 0, 4'b1011);
        buffer_test(1, 0, 4'b1011);
        buffer_test(0, 1, 4'b1101);
        buffer_test(1, 1, 4'b0111);
        buffer_test(0, 1, 4'b1111);
        
        #100
        buffer_test(1, 0, 4'b0011);
        buffer_test(1, 1, 4'b1001);
        buffer_test(1, 1, 4'b0011);
        buffer_test(1, 1, 4'b1110);
        buffer_test(1, 1, 4'b1000);
        buffer_test(0, 1, 4'b1100);
        buffer_test(0, 1, 4'b1110);
        


    end

endmodule
