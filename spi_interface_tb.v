`timescale 1ns/1ns
module spi_interface_tb();
reg clk,rst_n,send_en;
wire spi_clk,spi_cs_n,mosi;
reg miso;

always #10 clk = ~clk;
initial begin
    clk <= 'b0;
    rst_n <= 'b0;
    send_en <= 1'b0; 
    miso <= 1'bz;
    #200
    rst_n <= 1'b1;  
    #100
    send_en <= 1'b1;
    #20
    send_en <= 1'b0;  
    #1920
    miso <= 1'b1;
    #640
    miso <= 1'bz;
    #500
    $stop;
end


spi_interface spi_interface_u(
    .clk            (clk),
    .rst_n          (rst_n),
    .send_en        (send_en),

    .spi_clk    (spi_clk),
    .spi_cs_n   (spi_cs_n),
    .mosi       (mosi),
    .miso       (miso)
);

endmodule