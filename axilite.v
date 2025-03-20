`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/10/2025 01:54:35 PM
// Design Name: 
// Module Name: axilite
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module axilite(
    input clk, reset, trigger, ARREADY, RVALID, AWREADY, WREADY, BVALID,
    input[4:0] length,
    input[31:0] source_address, destination_address, RDATA,
    output reg done, ARVALID, RREADY, AWVALID, WVALID, BREADY,
    output reg[31:0] ARADDR, AWADDR, WDATA,
    output reg[4:0] r_count, w_count);
    
    parameter READ_NONE=3'b000,
              READ_ADDR=3'b001,
              READ_DATA=3'b010,
              READ_STORE=3'b011,
              READ_DONE=3'b100;
    parameter WRITE_NONE=3'b000,          
              WRITE_ADDR=3'b001,
              WRITE_DATA=3'b010,
              WRITE_VALID=3'b011,
              WRITE_DONE=3'b100;
    
    reg [2:0] r_state, w_state;
    reg fifo_rd, fifo_wr;
    wire fifo_full, fifo_empty;
    wire [31:0] fifo_data;
    
    FIFO fifom(.clk(clk), .reset(reset), .FIFO_RD(fifo_rd), .FIFO_WR(fifo_wr), .RDATA(RDATA), .FIFO_EMPTY(fifo_empty), .FIFO_FULL(fifo_full),
                .DATA_OUT(fifo_data));
    
    always @(posedge clk) begin
        if(reset) begin
            r_state<= READ_NONE;
            RREADY<=0;
            fifo_wr<=0;
            r_count<= length>>2;
         end
         else begin
            case(r_state)
            READ_NONE: begin
                       if(trigger) begin
                        ARADDR<= source_address;
                        ARVALID<=1;
                        RREADY<=1;
                        r_state<= READ_ADDR; end
                       end
            READ_ADDR: begin
                       if(ARREADY) begin
                       ARVALID<=0;
                       r_state<= READ_DATA; end
                       end 
            READ_DATA: begin
                       if(RVALID && !fifo_full) begin
                       fifo_wr<=1;
                       r_state<= READ_STORE; end
                       end 
            READ_STORE: begin
                         r_count<=r_count-1;
                         r_state<=READ_DONE;
                        end
            READ_DONE: begin
                       fifo_wr<=0;
                       if(r_count==0)
                        RREADY<=0;
                       else begin
                        ARADDR<=ARADDR+4; 
                        r_state<=READ_ADDR; end
                       end
            endcase
        end
   end 
   
   always @(posedge clk) begin
           if(reset) begin
            w_state<= WRITE_NONE;
            AWVALID<=0;
            WVALID<=0;
            BREADY<=0;
            fifo_rd<=0;
            done<=0;
            w_count<= length>>2;
           end
         
           else begin 
            case(w_state)
            WRITE_NONE: begin
                         if(trigger) begin
                          AWADDR<=destination_address;
                          AWVALID<=1;
                          WVALID<=1;
                          BREADY<=1;
                          w_state<=WRITE_ADDR; end
                         end
            WRITE_ADDR: begin
                         if(AWREADY) begin
                          AWVALID<=0;
                         end
                         if(WREADY && !fifo_empty) begin 
                          WVALID<=0;
                          fifo_rd<=1; 
                          w_state<=WRITE_DATA; end
                         end
            WRITE_DATA: begin
                         if(BVALID) begin
                          w_count<=w_count-1;
                          w_state<=WRITE_VALID; end
                        end
            WRITE_VALID: begin
                         WDATA<=fifo_data;
                         fifo_rd<=0;
                         w_state<=WRITE_DONE;
                         end
            WRITE_DONE: begin
                         if(w_count==0) begin
                          BREADY<=0;
                          done<=1;end
                         else begin
                          AWADDR<=AWADDR+4;
                          w_state<=WRITE_ADDR; end
                        end
            endcase
      end
       
     end
         
     
     
endmodule
    
module FIFO(
    input clk, reset, FIFO_RD, FIFO_WR,
    input [31:0] RDATA,
    output reg FIFO_EMPTY, FIFO_FULL,
    output reg[31:0] DATA_OUT);
    
    reg[3:0] fifo_depth;
    reg[31:0] fifo_mem[0:15];
    reg[3:0] n,m;
    integer i;
    
    always @(posedge clk) begin
    if(reset) begin
                n<=0;
                m<=0;
                fifo_depth<=0;
                FIFO_EMPTY<=1'b1;
                FIFO_FULL<=1'b0;
                for (i=0; i<16; i=i+1) begin
                fifo_mem[i]<=0; 
                end
               end
    else begin
            FIFO_EMPTY<= (fifo_depth==0);
            FIFO_FULL<= (fifo_depth==15);
            
            if(!FIFO_FULL && FIFO_WR)
                begin
                    fifo_mem[n]<=RDATA;
                    n<=(n==15)? 0:n+1;
                    if(fifo_depth<15) fifo_depth<=fifo_depth+1;
                end
            
            if( !FIFO_EMPTY && FIFO_RD )
                begin
                    DATA_OUT<=fifo_mem[m];
                    m<=(m==15)? 0:m+1;
                    if(fifo_depth>0) fifo_depth<=fifo_depth-1;
                end
          end
     end 
endmodule 
    
    

