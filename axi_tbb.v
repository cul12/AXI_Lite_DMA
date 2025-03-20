`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/10/2025 01:55:01 PM
// Design Name: 
// Module Name: axi_tbb
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


module axi_tbb();
reg clk, reset, trigger, ARREADY, RVALID, AWREADY, WREADY, BVALID;
reg[4:0] length;
reg[31:0] source_address, destination_address, RDATA;
wire done, ARVALID, RREADY, AWVALID, WVALID, BREADY;
wire[31:0] ARADDR, AWADDR, WDATA;
wire[4:0] r_count, w_count;
reg[31:0] source_mem[0:3];
reg[31:0] dest_mem[0:3];

 axilite axilite_uut( .clk(clk), .reset(reset), .trigger(trigger), .ARREADY(ARREADY), .RVALID(RVALID), .AWREADY(AWREADY), .WREADY(WREADY),
             .BVALID(BVALID), .length(length), .source_address(source_address), .destination_address(destination_address), .RDATA(RDATA),
             .done(done), .ARVALID(ARVALID), .RREADY(RREADY), .AWVALID(AWVALID), .WVALID(WVALID), .BREADY(BREADY), .ARADDR(ARADDR),
             .AWADDR(AWADDR), .WDATA(WDATA), .r_count(r_count), .w_count(w_count));
             
 initial begin
        source_mem[0]=32'hAABBCCDD;
        source_mem[1]=32'h11223344;
        source_mem[2]=32'hABBBCCDD;
        source_mem[3]=32'h12223344;
        
        dest_mem[0]=32'h00000000;
        dest_mem[1]=32'h00000000;
        dest_mem[2]=32'h00000000;
        dest_mem[3]=32'h00000000;
       
    end
    
 always #5 clk= ~clk;
 
 initial begin
        clk=0;
        reset=1;
        trigger=0;
        ARREADY=0;
        RVALID=0;
        AWREADY=0;
        WREADY=0;
        BVALID=0;
        length=16;
        source_address=32'h1000;
        destination_address=32'h2000;

        #20 reset=0; 
        #10 trigger=1; 
        #10 trigger=0;
        end
        
 initial begin
          #20
          repeat(length>>2) begin
          #20 ARREADY=1;
          RDATA= source_mem[(ARADDR-32'h1000)>>2];
          #10 RVALID=1; ARREADY=0;
          #10 RVALID=0;
          end
         end
         
 initial begin
          #70
          repeat(length>>2) begin
          #60 AWREADY=1; WREADY=1;
          #10 AWREADY=0; WREADY=0; BVALID=1;
          #10 BVALID=0; 
          #10 dest_mem[(AWADDR-32'h2000)>>2]=WDATA;
          end
         end
 initial begin
    $monitor("Time=%0t, ARADDR=%h, r_count=%d, w_count=%d", $time, ARADDR, r_count, w_count);
 end
endmodule
