module spi_interface(
    input clk,
    input rst_n,
    input send_en,

    output reg spi_clk,
    output reg spi_cs_n,
    output reg mosi,
    input      miso
);


localparam READ_EN   = 8'b10101001;
localparam READ_ADDR = 8'b10000001;
/*
reg  [4:0]  cnt_clk;
reg  [1:0]  cnt_byte;
reg  [1:0]  spi_clk_cnt;
reg  [2:0]  spi_bit;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)                  cnt_clk <= 'b0;
    else if(cnt_clk==5'd31 || spi_cs_n==1'b1)     
                                cnt_clk <= 'b0;
    else                        cnt_clk <= cnt_clk+1'b1;   
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)                  cnt_byte <= 'b0;
    else if(cnt_clk==5'd31)     cnt_byte <= cnt_byte + 1'b1;
    else if((cnt_clk==5'd31 && cnt_byte==2'd2)|| spi_cs_n==1'b1)
                                cnt_byte <= 'b0;
    else                        cnt_byte <= cnt_byte;      
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)                  spi_clk_cnt <= 'b0;
    else if(cnt_byte==2'd1)     spi_clk_cnt <= spi_clk_cnt + 1'b1;
    else                        spi_clk_cnt <= 'b0;  
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)                  spi_bit <= 'b0;
    else if(cnt_byte==2'd1)
        if(spi_clk_cnt==2'd3)   spi_bit <= spi_bit + 1'b1;
        else                    spi_bit <= spi_bit;
    else                        spi_bit <= 'b0;  
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)                  spi_cs_n <= 1'b1;
    else if (send_en)           spi_cs_n <= 1'b0;
    else if (cnt_byte==2'd2&&cnt_clk==5'd31)    
                                spi_cs_n <= 1'b1;
    else                        spi_cs_n <= spi_cs_n;                            
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)                  spi_clk <= 'b0;
    else if (spi_clk_cnt==2'd2) spi_clk <= 1'b1;
    else if (spi_clk_cnt==2'd0) spi_clk <= 1'b0;
    else                        spi_clk <= spi_clk;
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)                  mosi <= 'b0;
    else if(cnt_byte==2'd1)     mosi <= data[7 - spi_bit];    
end
*/



localparam  IDLE    = 5'b00001,
            START   = 5'b00010,
            WIRTE   = 5'b00100,
            READ    = 5'b01000,
            FINISH  = 5'b10000; 
reg  [5:0]  stage;
reg  [4:0]  cnt_clk;
reg  [2:0]  cnt_byte;
reg [1:0]   spi_clk_cnt;
reg  [2:0]  spi_bit;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)                  cnt_clk <= 'b0;
    else if(cnt_clk==5'd31 || spi_cs_n==1'b1)     
                                cnt_clk <= 'b0;
    else                        cnt_clk <= cnt_clk+1'b1;   
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)                  cnt_byte <= 'b0;
    else if(cnt_clk==5'd31)     cnt_byte <= cnt_byte + 1'b1;
    else if((cnt_clk==5'd31 && cnt_byte==3'd3)|| spi_cs_n==1'b1)
                                cnt_byte <= 'b0;
    else                        cnt_byte <= cnt_byte;      
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)              stage <= IDLE;
    else begin
            case(stage)
            IDLE :  if(send_en)  stage <= START;
                    else         stage <= IDLE;
            START : if(cnt_byte==3'd1)  
                                 stage <= WIRTE;
                    else         stage <= START;
            WIRTE:  if(cnt_byte==3'd3)
                                 stage <= READ;
                    else         stage <= WIRTE;
            READ:   if(cnt_byte==3'd4)
                                 stage <= FINISH;
                    else         stage <= READ;
            FINISH: if(spi_cs_n == 1'b1)
                                 stage <= IDLE;
                    else         stage <= FINISH;
            default : stage <= IDLE; 
            endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)                  spi_cs_n <= 1'b1;
    else if (send_en)           spi_cs_n <= 1'b0;
    else if (stage == FINISH)    
                                spi_cs_n <= 1'b1;
    else                        spi_cs_n <= spi_cs_n;                            
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)                  spi_clk_cnt <= 'b0;
    else if((stage == WIRTE)||(stage == READ))     
                                spi_clk_cnt <= spi_clk_cnt + 1'b1;
    else                        spi_clk_cnt <= 'b0;  
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)                  spi_clk <= 'b0;
    else if (spi_clk_cnt==2'd2) spi_clk <= 1'b1;
    else if (spi_clk_cnt==2'd0) spi_clk <= 1'b0;
    else                        spi_clk <= spi_clk;
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)                  spi_bit <= 'b0;
    else if((stage == WIRTE)||(stage == READ))
        if(spi_clk_cnt==2'd3)   spi_bit <= spi_bit + 1'b1;
        else                    spi_bit <= spi_bit;
    else                        spi_bit <= 'b0;  
end
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)                  mosi <= 'b0;
    else if((stage == WIRTE)&&(cnt_byte==3'd1))     mosi <= READ_EN[7 - spi_bit];    
    else if((stage == WIRTE)&&(cnt_byte==3'd2))     mosi <= READ_ADDR[7 - spi_bit];
    else                                            mosi <= 'b0;
end
reg [7:0]   data_in;
always @(posedge spi_clk or negedge rst_n) begin
    if(!rst_n)                  data_in <= 'd0;
    else if(stage == READ)      data_in <= {data_in[6:0],miso};
    else                        data_in <= data_in;
end
endmodule