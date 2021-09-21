//////////////////////////////////////////////////////////////////////////////////
// Module Name: if_pc
// Author:lerogo
//////////////////////////////////////////////////////////////////////////////////

`ifndef _if_pc
`define _if_pc

module if_pc(
    input wire clk,reset,
    input wire [1:0] pcsource_s1,
    input wire [31:0] baddr_s1,
    input wire [31:0] jaddr_s1,
    input wire [31:0] pc_s1,
	output reg[31:0] npc_s1
);
    always @(negedge reset) begin
        npc_s1 <= 32'b0;
    end
	always @(posedge clk) begin
		  case (pcsource_s1)
		      2'b01:npc_s1<=pc_s1+4;
		      2'b10:npc_s1<=baddr_s1;
		      2'b11:npc_s1<=jaddr_s1;
		      default:npc_s1<=pc_s1;
		  endcase		
	end
endmodule

`endif




