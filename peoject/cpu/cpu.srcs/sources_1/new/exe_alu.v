//////////////////////////////////////////////////////////////////////////////////
// Module Name: exe_alu
// Author:lerogo
//////////////////////////////////////////////////////////////////////////////////
`ifndef _exe_alu
`define _exe_alu

module exe_alu(
    input [5:0] alu_op_s3,
    input [31:0] alu_data1_s3,
    input [31:0] alu_data2_s3,
    output reg [31:0] alu_out_s3
    );
    always @(*) begin
        case(alu_op_s3)
            // add addi addiu
            6'd1,6'd2,6'd3: alu_out_s3 <= alu_data1_s3 + alu_data2_s3;
            // sub
            6'd4: alu_out_s3 <= alu_data1_s3 - alu_data2_s3;
            // and andi
            6'd5,6'd6: alu_out_s3 <= alu_data1_s3 & alu_data2_s3;
            // or ori
            6'd7,6'd8: alu_out_s3 <= alu_data1_s3 | alu_data2_s3;
            // nor nori
            6'd9,6'd10: alu_out_s3 <= ~(alu_data1_s3 | alu_data2_s3);
            // xor xori
            6'd11,6'd12: alu_out_s3 <= alu_data1_s3 ^ alu_data2_s3;
            // beq beqz
            6'd13,6'd14: alu_out_s3 <= (alu_data1_s3 == alu_data2_s3)?32'b1:32'b0;
            // bne bnez
            6'd15,6'd16: alu_out_s3 <= (alu_data1_s3 != alu_data2_s3)?32'b1:32'b0;
            // bgt
            6'd17: alu_out_s3 <= (alu_data1_s3 > alu_data2_s3)?32'b1:32'b0;
            // bge
            6'd18: alu_out_s3 <= (alu_data1_s3 >= alu_data2_s3)?32'b1:32'b0;
            // blt
            6'd19: alu_out_s3 <= (alu_data1_s3 < alu_data2_s3)?32'b1:32'b0;
            // ble
            6'd20: alu_out_s3 <= (alu_data1_s3 <= alu_data2_s3)?32'b1:32'b0;
            // j 
            6'd21: alu_out_s3 <= 32'b0;
            // jr
            6'd23: alu_out_s3 <= alu_data1_s3;
            // lb lh lw
            6'd24,6'd25,6'd26: alu_out_s3 <= alu_data1_s3;
            // sb sh sw
            6'd27,6'd28,6'd29: alu_out_s3 <= alu_data2_s3;
            // slli
            6'd30: alu_out_s3 <= alu_data1_s3 << alu_data2_s3;
            // sll
            6'd31: alu_out_s3 <= alu_data1_s3 << alu_data2_s3[4:0];
            // srli
            6'd32: alu_out_s3 <= alu_data1_s3 >> alu_data2_s3;
            // srl
            6'd33: alu_out_s3 <= alu_data1_s3 >> alu_data2_s3[4:0];
            // srai
            6'd34: alu_out_s3 <= alu_data1_s3 >>> alu_data2_s3;
            // sra
            6'd35: alu_out_s3 <= alu_data1_s3 >>> alu_data2_s3[4:0];
            // slt slti
            6'd36,6'd37: alu_out_s3 <= (alu_data1_s3 < alu_data2_s3)?32'b1:32'b0;
        endcase
    end
    
endmodule
`endif








