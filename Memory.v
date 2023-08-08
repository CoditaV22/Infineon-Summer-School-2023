module Memory
(	
	input pclk_i , presetn_i , psel_i , penable , pwrite_i,
	input [7:0] paddr_i,
	input [31:0] pwdata_i,
	output pready_o,
	output pslverr_o,
	output [31:0] prdata_o
);

wire rd_en , wr_en;
reg [31:0] mem_efectiva [0:255];

localparam IDLE = 2'b00;
localparam SETUP = 2'b01;
localparam ACCESS = 2'b10;

reg [1:0] state , state_next;

assign wr_en = pwrite_i & penable & psel_i;
assign rd_en = ~pwrite_i & penable & psel_i;



always@(posedge pclk_i)
begin
	if(wr_en)
		mem_efectiva[paddr_i] <= pwdata_i; 		

end


assign prdata_o = (rd_en) ? mem_efectiva[paddr_i] : 0;




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
		IDLE: if(psel_i && !penable) state_next = SETUP;
		SETUP: if(psel_i && penable) state_next = ACCESS;
		ACCESS: begin
			if(!psel_i) state_next = IDLE;
			if(psel_i && !penable) state_next = SETUP;
		end
		default: state_next = IDLE;
		
	endcase
end


assign pready_o = ~(state == SETUP);

assign pslverr_o = 0;


endmodule
