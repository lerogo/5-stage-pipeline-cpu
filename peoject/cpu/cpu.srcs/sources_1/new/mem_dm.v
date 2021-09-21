//////////////////////////////////////////////////////////////////////////////////
// Module Name: mem_dm
// Author:lerogo
//////////////////////////////////////////////////////////////////////////////////

`ifndef _mem_dm
`define _mem_dm

module mem_dm(
    input clk,
    input [31:0] alu_out_s4,
    input mem_read_s4,
    input mem_write_s4,
    input [31:0] write_data_s4,
    input [1:0] rw_bits_s4,
    output reg [31:0] mem_read_data_s4
);
    parameter MEM_NUM = 0;
    // 32-bit memory with MEM_NUM entries
    // 实际的地址不能超过MEM_NUM * 4
    reg [31:0] mem [0:MEM_NUM];
    integer i = 0;
    initial begin
    	for (i = 0; i < MEM_NUM; i = i + 1) begin
			mem[i] <= 32'b0;
		end
    end

    always @(posedge clk) begin
        if (mem_write_s4) begin
            case(rw_bits_s4)
                // 8bits
                2'd1: begin
                    case(alu_out_s4[1:0])
                        2'b00:mem[alu_out_s4[31:2]][7:0] <= write_data_s4[7:0];
                        2'b01:mem[alu_out_s4[31:2]][15:8] <= write_data_s4[7:0];
                        2'b10:mem[alu_out_s4[31:2]][23:16] <= write_data_s4[7:0];
                        2'b11:mem[alu_out_s4[31:2]][31:24] <= write_data_s4[7:0];
                    endcase
                end
                // 16bits
                2'd2:begin
                    case(alu_out_s4[1])
                        1'b0:mem[alu_out_s4[31:2]][15:0] <= write_data_s4[15:0];
                        1'b1:mem[alu_out_s4[31:2]][31:16] <= write_data_s4[15:0];
                    endcase
                end
                // 32bits
                default:mem[alu_out_s4[31:2]] <= write_data_s4;
            endcase
        end
    end
    
    // read
    always @(*) begin
        if (mem_read_s4) begin
            if(mem_write_s4)begin
                mem_read_data_s4 <= write_data_s4;
            end else begin
                 case(rw_bits_s4)
                    // 8bits
                    2'd1:begin
                        case(alu_out_s4[1:0])
                            2'b00:mem_read_data_s4<={24'b0,mem[alu_out_s4[31:2]][7:0]};
                            2'b01:mem_read_data_s4<={24'b0,mem[alu_out_s4[31:2]][15:8]};
                            2'b10:mem_read_data_s4<={24'b0,mem[alu_out_s4[31:2]][23:16]};
                            2'b11:mem_read_data_s4<={24'b0,mem[alu_out_s4[31:2]][31:24]};
                        endcase
                    end
                    // 16bits
                    2'd2:begin
                        case(alu_out_s4[1])
                            1'b0:mem_read_data_s4<={16'b0,mem[alu_out_s4[31:2]][15:0]};
                            1'b1:mem_read_data_s4<={16'b0,mem[alu_out_s4[31:2]][31:16]};
                        endcase
                    end
                    default:mem_read_data_s4 <= mem[alu_out_s4[31:2]];
                endcase
            end
        end
    end

endmodule

`endif
