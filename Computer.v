`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2023 09:24:39
// Design Name: 
// Module Name: Computer
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


module Computer(
    input pclk_i , presetn_i , compute_req_i , pready_i , pslverr_i,
    input [31:0] prdata_i,
    output valid_o,
    output reg pwrite_o , psel_o , penable_o,
    output [31:0] data_o,
    output reg [31:0] pwdata_o, 
    output reg [7:0] paddr_o
    );
    
    reg [31:0] out_reg;
    
    localparam IDLE = 2'b00;
    localparam SETUP = 2'b01;
    localparam ACCESS = 2'b10;
    reg [1:0] state , state_next;
    
    
    
    //Addr counter
    always@(posedge pclk_i)
    begin
        if(!presetn_i)
        paddr_o <= 0;
        else if(state == ACCESS && pready_i)
            paddr_o <= paddr_o + 1;
    end
    //End addr counter
    
    //Reg
    always@(posedge pclk_i)
    begin
        if(!presetn_i)
            out_reg <= 0;
        else if(state == ACCESS && pready_i)
            out_reg <= prdata_i;
    end
    //End Reg
    
    
    
    //FSM
    
    always@(posedge pclk_i)
    begin
    if(presetn_i==0)
    state <= 0;
    else
    state <= state_next;
    end
    
    always@(*)
    begin
    state_next = state;
    case(state)
        IDLE: if(compute_req_i) state_next = SETUP;
        SETUP: state_next = ACCESS;
        ACCESS: if(pready_i && (compute_req_i || !paddr_o[0])) state_next = SETUP;
                else if(pready_i) state_next = IDLE;     
    endcase
    end
    
    always@(*)
    begin
    case(state)
    
        SETUP: begin           
               psel_o = 1;
               penable_o = 0;
               pwrite_o = 0;
               pwdata_o = 0;
               end
               
        ACCESS: begin
                psel_o = 1;
                penable_o = 1;
                pwrite_o = 0;
                pwdata_o = 0;
                end
                
        default: begin
                 psel_o = 0;
                 penable_o = 0;
                 pwrite_o = 0;
                 pwdata_o = 0;
                 end           
    endcase
    end
    
    //end FSM
    
    assign data_o = out_reg + prdata_i;
    assign valid_o = (((state == ACCESS) && (pready_i)) && (paddr_o[0]));
endmodule
