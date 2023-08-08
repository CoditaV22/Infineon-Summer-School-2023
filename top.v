`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.07.2023 10:05:50
// Design Name: 
// Module Name: top
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


module top(
    input pclk_i,presetn_i,
    input [31:0] data_i,
    input compute_req_i,
    output valid_o,
    output [31:0] data_o
    );
    
    wire sout_sel , sout_enable , sout_write;
    wire [7:0] sout_addr;
    wire [31:0] sout_data;
    wire cout_sel , cout_enable , cout_write;
    wire [7:0] cout_addr;
    wire [31:0] cout_data;
    wire memout_ready;
    wire memout_pslverr;
    wire [31:0] memout_data;
    wire slave_sel , slave_en , slave_wr;
    reg [7:0] slave_addr;
    wire [31:0] slave_data;
    
    Sampler sample0(
        .pclk_i(pclk_i),
        .presetn_i(presetn_i),
        .data_i(data_i),
        .psel_o(sout_sel),
        .penable_o(sout_enable),
        .paddr_o(sout_addr),
        .pwdata_o(sout_data),
        .pwrite_o(sout_write),
        .prdata_i(memout_data),
        .pslverr_i(memout_pslverr),
        .pready_i(memout_ready)
    );
    
    
    
    Computer comp0
    (
        .pclk_i(pclk_i),
        .presetn_i(presetn_i),
        .compute_req_i(compute_req_i),
        .psel_o(cout_sel),
        .penable_o(cout_enable),
        .paddr_o(cout_addr),
        .pwdata_o(cout_data),
        .pwrite_o(cout_write),
        .prdata_i(memout_data),
        .pslverr_i(memout_pslverr),
        .pready_i(memout_ready),
        .valid_o(valid_o),
        .data_o(data_o)  
    );
    
    or(slave_sel , sout_sel , cout_sel);
    or(slave_en , sout_enable , cout_enable);
    or(slave_wr , sout_write , cout_write);
    always@(*)
    begin
        if(slave_wr)
            slave_addr = sout_addr;
        else
            slave_addr = cout_addr;
    end         
    Memory mem0
    (
        .pclk_i(pclk_i),
        .presetn_i(presetn_i),
        .psel_i(slave_sel),
        .penable(slave_en),
        .paddr_i(slave_addr),
        .pwdata_i(sout_data | cout_data),
        .pwrite_i(slave_wr),
        .prdata_o(memout_data),
        .pslverr_o(memout_pslverr),
        .pready_o(memout_ready)
    );
    
endmodule
