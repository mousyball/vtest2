module asynFifo
    #(parameter DATA_WIDTH    = 8,
                ADDRESS_WIDTH = 4,
                FIFO_DEPTH    = (1 << ADDRESS_WIDTH)) //   10000``1

    (// Reading Port
        output [DATA_WIDTH-1:0] Data_out,
        output Empty_out,
        input ReadEn_in,
        input RClk,
        // Writing Port
        input [DATA_WIDTH-1:0] Data_in,
        output Full_out,
        input WriteEn_in,
        input WClk,
        input Clear_in);                 // reset, write clock

    reg [DATA_WIDTH-1:0] buffer [FIFO_DEPTH-1:0];

    reg [ADDRESS_WIDTH-1:0] wptr, rptr;
    reg [ADDRESS_WIDTH-1:0] wptr_r, wptr_r0;
    reg [ADDRESS_WIDTH-1:0] rptr_w, rptr_w0;

    // ==  ==  ==  ==  ==  = //
    // Logic design
    // ==  ==  ==  ==  == //
    reg Clear_r0, Clear_r;
    reg [ADDRESS_WIDTH-1:0] wptr_g, rptr_g;

    // buffer
    always @(posedge Clear_in) begin
        for(integer i=0; i < FIFO_DEPTH; i=i+1) begin
            buffer[i] <= 0;
        end
    end

    //synchronize reset to read clk
    always @(posedge RClk) begin
        Clear_r0 <= Clear_in;
        Clear_r  <= Clear_r0;
    end

    //writing data to fifo at posedge of write clock
    always @(posedge WClk or posedge Clear_in) begin//Asyn reset
        if (Clear_in)
            wptr <= 0;
        else if (WriteEn_in && ! Full_out) begin
            wptr         <= wptr + 1;
            buffer[wptr] <= Data_in;
            // $display("wptr= %d, buffer[wptr] = %d, Data_in = %d", wptr, buffer[wptr], Data_in);
        end
    end

    // [NOTE] read?
    always @(posedge RClk or posedge Clear_in) begin//Asyn reset
        if (Clear_in)
            rptr <= 0;
        else if (ReadEn_in && ! Empty_out) begin
            rptr    <= rptr + 1;
        end
    end

    //reading data from fifo
    assign Data_out = (ReadEn_in && ! Empty_out) ? buffer[rptr] : 'bx;


    // ==  ==  ==  ==  = EMPTY / FULL ==  ==  ==  == //
    assign Empty_out = (wptr_r == gray(rptr));
    assign Full_out  = (gray(wptr+1) == rptr_w);

    //synchronize wptr to read clock
    always @(posedge WClk) wptr_g <= gray(wptr);
    always @(posedge RClk) begin
        wptr_r0 <= wptr_g;
        wptr_r  <= wptr_r0;
        $display("wptr= %d, wptr_r = %d, gray(rptr) = %d", wptr, wptr_r, gray(rptr));
    end

    //synchronize rptr to write clock
    always @(posedge RClk) rptr_g <= gray(rptr);
    always @(posedge WClk) begin
        rptr_w0 <= rptr_g;
        rptr_w  <= rptr_w0;
    end

    //gray code transfer
    function [ADDRESS_WIDTH-1:0] gray;
        input [ADDRESS_WIDTH-1:0] bin_addr;
        gray[ADDRESS_WIDTH-1:0] = bin_addr ^ {1'b0, bin_addr[ADDRESS_WIDTH-1:1]};
    endfunction

endmodule
