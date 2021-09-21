//////////////////////////////////////////////////////////////////////////////////
// Module Name: reg_file
// Author:lerogo
//////////////////////////////////////////////////////////////////////////////////

`ifndef _reg_file
`define _reg_file

module reg_file(
    input clk,reset,
    input write_back_s5,
    input [4:0] rs_s2,
    input [4:0] rt_s2,
    input [4:0] rd_s5,
    input [31:0] wdata,
    output [31:0] rs_data_s2,
    output [31:0] rt_data_s2
 );
    // 32-bit memory with 32 entries
    reg [31:0] mem [0:31];
    reg [31:0] _data1, _data2;
    integer i = 0;
    always @(negedge reset) begin
    	for (i = 0; i < 32; i = i + 1) begin
			mem[i] <= 32'b0;
		end
    end
    always @(*) begin
		if (rs_s2 == 5'd0)
			_data1 = 32'd0;
	    // 解决写入问题
		else if ((rs_s2 == rd_s5) && write_back_s5)
			_data1 = wdata;
		else
			_data1 = mem[rs_s2][31:0];
    end
    always @(*) begin
		if (rt_s2 == 5'd0)
			_data2 = 32'd0;
		else if ((rt_s2 == rd_s5) && write_back_s5)
			_data2 = wdata;
		else
			_data2 = mem[rt_s2][31:0];
    end
    assign rs_data_s2 = _data1;
	assign rt_data_s2 = _data2;
	
	always @(posedge clk) begin
		if (write_back_s5 && rd_s5 != 5'd0) begin
			mem[rd_s5] <= wdata;
		end
	end
    
endmodule

`endif







