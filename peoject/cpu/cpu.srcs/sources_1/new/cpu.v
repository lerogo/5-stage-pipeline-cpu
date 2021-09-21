`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: cpu
// Author:lerogo
//////////////////////////////////////////////////////////////////////////////////

//include
`include "if_pc.v"
`include "if_im.v"
`include "reg_file.v"
`include "id_decode.v"
`include "id_control.v"
`include "exe_alu.v"
`include "mem_dm.v"
`include "reg_latches.v"

module cpu(clk,reset);
    input clk,reset;
    // number of instruction memory
    parameter MEM_NUM = 0;
    // number of datamem
    parameter MEM_DATA_NUM = 0;
    // fileName of instructions restore 
    parameter IM_DATA_FILENAME = "";

    // hold用于1->2等待执行完，flush用于b和j指令后的重置
    reg hold,flush;

    // 第一阶段
    // 用于对pc的选择
    reg [1:0] pcsource_s1;
    // 跳转的地址 pc地址
    reg [31:0] baddr_s1,jaddr_s1;
    wire [31:0] npc_s1;
    // 第一阶段获取到的指令
    wire [31:0] im_data_s1;
    
    // 第二阶段
    // 传递到第二阶段的npc_s2、传递到第二阶段的im_data_s2
    wire [31:0] npc_s2,im_data_s2;
    // 译码输出
    wire [5:0] opcode_s2;
    wire [4:0] rs_s2,rt_s2,rd_s2;
    wire [15:0] imm_s2;
    wire [31:0] jaddr_s2;
    // b 的地址
    wire [31:0] baddr_s2 = npc_s2 + { {14{imm_s2[15]}},imm_s2, 2'b0 };
    // 控制器输出的控制信号
    wire is_imm_s2,is_branch_s2,is_jump_s2,mem_read_s2,mem_write_s2,write_back_s2;
    wire [4:0] rs_control_s2,rt_control_s2;
    // 寄存器获得的值
    wire [31:0] rs_data_s2,rt_data_s2;
    
    // 第三阶段
    // 传递
    wire [5:0] opcode_s3;
    wire [4:0] rs_control_s3,rt_control_s3,rd_s3;
    wire [15:0] imm_s3;
    wire [31:0] jaddr_s3,baddr_s3;
    wire is_imm_s3,is_branch_s3,is_jump_s3,mem_read_s3,mem_write_s3,write_back_s3;
    wire [31:0] rs_data_s3,rt_data_s3;
    // alu
    reg [31:0] alu_data1_s3,alu_data2_s3;
    wire [31:0] alu_out_s3;
    reg [1:0] rw_bits_s3;
    // 计算下一阶段用的数据
    
    // 第四阶段
    // 传递
    // 写入目标
    wire [5:0] opcode_s4;
    wire [4:0] rd_s4;
    wire [31:0] jaddr_s4,baddr_s4;
    wire is_branch_s4,is_jump_s4,mem_read_s4,mem_write_s4,write_back_s4;
    // 如果要读/写内存 那么写mem的地址为alu_out_s4
    // 如果要回写，那么回写数据为alu_out_s4
    wire [31:0] alu_out_s4;
    // 读/写内存时，读写多少位 默认为00 32位    
    wire [1:0] rw_bits_s4;
    // 读内存的结果    // 写内存的数据
    wire [31:0] mem_read_data_s4,write_data_s4;
    // 回写数据
    wire [31:0] wdata_s4;
    
    // 第五阶段
    // 传递
    wire write_back_s5,mem_read_s5;
    wire [4:0] rd_s5;
    wire [31:0] wdata_s5,alu_out_s5,mem_read_data_s5;

    // 其他 用于4，5阶段修改reg数据 直接短链三阶段的寄存器
    reg [1:0] forward_a,forward_b;
  

    always @(negedge reset) begin
        hold <= 1'b0;
        flush <= 1'b0;
        pcsource_s1 <= 2'b01;
        forward_a <= 1'b0;
        forward_b <= 1'b0;
    end
    // 第一阶段
    //例化pc
    if_pc if_pc1(
        .clk(clk),.reset(reset),
        .pcsource_s1(pcsource_s1),.baddr_s1(baddr_s1),.jaddr_s1(jaddr_s1),
        .pc_s1(npc_s1),.npc_s1(npc_s1)
    );
    // 例化指令读取
    if_im #(.MEM_NUM(MEM_NUM),.IM_DATA_FILENAME(IM_DATA_FILENAME)) if_im1(
        .clk(clk),.npc_s1(npc_s1),.im_data_s1(im_data_s1)
    );
    // 把第一阶段的指令转到第二阶段 （有条件转移）
    reg_latches #(.N(32*2)) reg_latches_s1_1(
        .clk(clk),.clear(flush),.hold(hold),
        .in({npc_s1,im_data_s1}),.out({npc_s2,im_data_s2})
    );

    // 第二阶段
    // 例化指令译码
    id_decode id_decode1(
        .npc_s2(npc_s2),.im_data_s2(im_data_s2),
        .opcode_s2(opcode_s2),.rs_s2(rs_s2),.rt_s2(rt_s2),.rd_s2(rd_s2),
        .imm_s2(imm_s2),.jaddr_s2(jaddr_s2)
    );
    // 例化控制指令
    id_control id_control1(
        .opcode_s2(opcode_s2),.imm_s2(imm_s2),.rs_s2(rs_s2),.rt_s2(rt_s2),.rd_s2(rd_s2),
        .is_imm_s2(is_imm_s2),.is_branch_s2(is_branch_s2),.is_jump_s2(is_jump_s2),
        .mem_read_s2(mem_read_s2),.mem_write_s2(mem_write_s2),.write_back_s2(write_back_s2),
        .rs_control_s2(rs_control_s2),.rt_control_s2(rt_control_s2)
    );
    // 例化寄存器堆
    reg_file reg_file1(
       .clk(clk),.reset(reset),.write_back_s5(write_back_s5),
       .rs_s2(rs_control_s2),.rt_s2(rt_control_s2),.rd_s5(rd_s5),.wdata(wdata_s5),
       .rs_data_s2(rs_data_s2),.rt_data_s2(rt_data_s2)
    );
    // 转移数据
   // 控制信号一定会传下去 或者停一次(lw sw连续时)
   reg_latches #(.N(6+6)) reg_latches_s2_1(
        .clk(clk),.clear(hold | flush),.hold(1'b0),
        .in({opcode_s2,is_imm_s2,is_branch_s2,is_jump_s2,mem_read_s2,mem_write_s2,write_back_s2}),
        .out({opcode_s3,is_imm_s3,is_branch_s3,is_jump_s3,mem_read_s3,mem_write_s3,write_back_s3})
    );
   // 数据不变 或者清除
   reg_latches #(.N(5*3+16+32*2+32*2)) reg_latches_s2_2(
        .clk(clk),.clear(flush),.hold(hold),
        .in({rs_control_s2,rt_control_s2,rd_s2,imm_s2,jaddr_s2,baddr_s2,rs_data_s2,rt_data_s2}),
        .out({rs_control_s3,rt_control_s3,rd_s3,imm_s3,jaddr_s3,baddr_s3,rs_data_s3,rt_data_s3})
    );
    
    // 第三阶段
    // 获得alu两边的操作数
    always @(*) begin
        // 只会存在由于写回问题而短链，访问mem直接停一次
        case(forward_a)
            2'd1: alu_data1_s3 = alu_out_s4;
            2'd2: alu_data1_s3 = wdata_s5;
            default: alu_data1_s3 = rs_data_s3;
        endcase
        if(is_imm_s3) begin
            // 这里解决弄得一个addiu 早知道不弄这个指令了
            if(opcode_s3==6'd3) alu_data2_s3 = { {16{1'b0}},imm_s3};
            else alu_data2_s3 = { {16{imm_s3[15]}},imm_s3};
        end else begin 
            case(forward_b)
                2'd1: alu_data2_s3 = alu_out_s4;
                2'd2: alu_data2_s3 = wdata_s5;
                default: alu_data2_s3 = rt_data_s3;
            endcase
        end
    end
    // 例化alu
    exe_alu exe_alu1(
        .alu_op_s3(opcode_s3),.alu_data1_s3(alu_data1_s3),.alu_data2_s3(alu_data2_s3),
        .alu_out_s3(alu_out_s3)
    );
    // 单独计算一下访问内存时的访问多少位
    always @(*) begin
        if(mem_read_s3|mem_write_s3==1'b1) begin
            case(opcode_s3)
                // 8位 lb sb
                6'd24,6'd27: rw_bits_s3 <= 2'd1;
                // 16位 lh sh
                6'd25,6'd28: rw_bits_s3 <= 2'd2;
                // 32位
                default:rw_bits_s3 <= 2'd0;
            endcase
        end
    end
    // 传递
    reg_latches #(.N(5+32*2+6 + 5 + 32+2+32)) reg_latches_s3_1(
        .clk(clk),.clear(flush),.hold(1'b0),
        .in({   rd_s3,jaddr_s3,baddr_s3,opcode_s3,
                is_branch_s3,is_jump_s3,mem_read_s3,mem_write_s3,write_back_s3,
                alu_out_s3,rw_bits_s3,alu_data1_s3
         }),
        .out({  rd_s4,jaddr_s4,baddr_s4,opcode_s4,
                is_branch_s4,is_jump_s4,mem_read_s4,mem_write_s4,write_back_s4,
                alu_out_s4,rw_bits_s4,write_data_s4
         })
    );
    
    // 第四阶段 mem
    // 例化datamem 访存
    mem_dm #(.MEM_NUM(MEM_DATA_NUM)) mem_dm1(
        .clk(clk),.alu_out_s4(alu_out_s4),.mem_read_s4(mem_read_s4),.mem_write_s4(mem_write_s4),
        .write_data_s4(write_data_s4),.rw_bits_s4(rw_bits_s4),
        .mem_read_data_s4(mem_read_data_s4)
    );
    // jump branch处理
    always @(*) begin
        // default
        pcsource_s1 <= 2'b01;
        flush <= 1'b0;
        baddr_s1 <= baddr_s4;
        jaddr_s1 <= jaddr_s4;
		case (1'b1)
			is_branch_s4: begin
			     if(alu_out_s4==32'b1)begin
			          pcsource_s1 <= 2'b10;
			          flush <= 1'b1;
			      end
			end
			is_jump_s4: begin
			     case(opcode_s4)
			         6'd23: jaddr_s1 <= alu_out_s4;
			     endcase
			     pcsource_s1 <= 2'b11;
			     flush <= 1'b1;
			end
		endcase
	end
	//传递
	reg_latches #(.N(5+2+32*2)) reg_latches_s4_1(
        .clk(clk),.clear(1'b0),.hold(1'b0),
        .in({   rd_s4,write_back_s4,alu_out_s4,mem_read_s4,mem_read_data_s4 }),
        .out({  rd_s5,write_back_s5,alu_out_s5,mem_read_s5,mem_read_data_s5 })
    );
    
	// 第五阶段
    // 计算回写数据
    assign wdata_s5 = mem_read_s5 ? mem_read_data_s5:alu_out_s5;
    
    // 解决冲突
    // 提前 短接入上一指令
    always @(*) begin
		if ((write_back_s4 == 1'b1) && (rd_s4 == rs_control_s3)) begin
			forward_a <= 2'd1;
		end else if ((write_back_s5 == 1'b1) && (rd_s5 == rs_control_s3)) begin
			forward_a <= 2'd2;
		end else
			forward_a <= 2'd0;
		if ((write_back_s4 == 1'b1) & (rd_s4 == rt_control_s3)) begin
			forward_b <= 2'd1;
		end else if ((write_back_s5 == 1'b1) && (rd_s5 == rt_control_s3)) begin
			forward_b <= 2'd2;
		end else
			forward_b <= 2'd0;
	end
    // 如果要读内存
    always @(*) begin
		if (mem_read_s3 == 1'b1 && ((rs_control_s2 == rd_s3) || (rt_control_s2 == rd_s3)) ) begin
			hold <= 1'b1;
		end else
			hold <= 1'b0;
	   if(hold) pcsource_s1 <= 2'b00;
	end
endmodule


