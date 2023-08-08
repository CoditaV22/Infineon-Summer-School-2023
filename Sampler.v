`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.07.2023 17:21:50
// Design Name: 
// Module Name: Sampler
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


module Sampler(
    input pclk_i,presetn_i,
    input [31:0] data_i,
    input pready_i,pslverr_i,
    input [31:0] prdata_i,
    output psel_o,penable_o,pwrite_o,
    output reg [7:0] paddr_o,
    output reg [31:0] pwdata_o
    );
    
    //Counter params
    wire sample_s;
    reg [18:0] count;
    wire end_transfer;
    
    //FSM params
    localparam IDLE = 2'b00;
    localparam SETUP = 2'b01;
    localparam ACCESS = 2'b10;
    reg [1:0] state , state_next;
        
    //1ms Counter
    always@(posedge pclk_i)
    begin
      if(!presetn_i)
      count <= 16;
      else begin
      if(count == 0)
      begin
      count <= 16;
      end
      
      else begin
      count <= count - 1;
      end
      end
      
    end
    
    assign sample_s = (count == 0) ? 1 : 0;
    
    always@(*)
    begin
        if(sample_s == 1)
        pwdata_o = data_i;
        else
        if(state == IDLE)
        pwdata_o = 0;    
    end
    
    
    //end 1 ms Counter
    
    //Addr Counter
    always@(posedge pclk_i)
    begin
        if(!presetn_i)
        paddr_o <= 0;
        else 
        if(end_transfer)
        paddr_o <= paddr_o + 1;
        
    end
    //End addr Counter
    
    //FSM
    
    always@(posedge pclk_i)
    begin
        if(!presetn_i)
        state <= IDLE;
        else
        state <= state_next;
    end
    
    always@(*)
    begin
    state_next = state;
    case(state)
        IDLE: if(sample_s) state_next = SETUP;
        SETUP: state_next = ACCESS;
        ACCESS:  begin  
                 if(sample_s && pready_i) state_next = SETUP;
                 else if(pready_i) state_next = IDLE;
                 end 
                
    endcase
    
    end
    
    assign psel_o = (state != IDLE);
    assign penable_o = (state == ACCESS);
    assign pwrite_o = (state != IDLE);
    assign end_transfer = (state == ACCESS && state_next != ACCESS);
    
    //end FSM
    
  
endmodule
