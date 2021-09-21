//////////////////////////////////////////////////////////////////////////////////
// Module Name: id_decode
// Author:lerogo
//////////////////////////////////////////////////////////////////////////////////

`ifndef _id_decode
`define _id_decode

module id_decode(
    input [31:0] npc_s2,
    input [31:0] im_data_s2,
    output [5:0] opcode_s2,
    output [4:0] rs_s2,
    output [4:0] rt_s2,
    output [4:0] rd_s2,
    output [15:0] imm_s2,
    output [31:0] jaddr_s2
    );
    assign opcode_s2  = im_data_s2[31:26];
	assign rd_s2 = im_data_s2[25:21];
	assign rs_s2 = im_data_s2[20:16];
	assign rt_s2 = im_data_s2[15:11];
	assign imm_s2 = im_data_s2[15:0];
	assign jaddr_s2 = {npc_s2[31:28], im_data_s2[25:0], {2{1'b0}}};
    
endmodule

`endif





