`timescale 1ns / 100ps

module tb;
  parameter DATA_WIDTH = 8;
  // Reading
  reg rst_n;
  reg rclk, read_en;
  wire empty;
  wire [DATA_WIDTH-1:0] data_out;
  // Writing
  reg wclk, write_en, clear_in;
  wire full;
  reg [DATA_WIDTH-1:0] data_in;

  integer i;

  always #10 rclk = ~rclk;
  always #5 wclk = ~wclk;

  asynFifo fifo_u0 (
      // reading
      .RClk(rclk),
      .ReadEn_in(read_en),
      .Empty_out(empty),
      .Data_out(data_out),
      // writing
      .WClk(wclk),
      .WriteEn_in(write_en),
      .Full_out(full),
      .Data_in(data_in),
      .Clear_in(clear_in)
  );

  initial begin
    rclk <= 0;
    wclk <= 0;
    read_en <= 0;
    write_en <= 0;
    clear_in <= 0;

    // reset
    repeat (1) @ (posedge wclk);
    clear_in <= 1;
    repeat (1) @ (posedge wclk);
    clear_in <= 0;

    // write burst
    #100;
    write_en = 1;
    repeat (10) @ (posedge wclk) begin
      data_in = $urandom % 16;
      $display("d_in= %d", data_in);
    end
    @ (posedge wclk);
    write_en <= 0;
    data_in <= 8'bx;

    $dumpfile("dump.vcd"); $dumpvars;

    #300 $finish;
  end

  initial begin
    // read
    #200;
    for (i = 0; i < 10; i=i+1) begin
      @ (posedge rclk);
      if (i > 2) begin
        read_en <= 1;
        $display("d_out = %d", data_out);
      end
    end
    read_en <= 0;
  end
endmodule