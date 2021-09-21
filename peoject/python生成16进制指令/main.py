import os
import re


def trans_mips2hex(instruction: str):
    opList = {
        'add': 1, 'addi': 2, 'addiu': 3, 'sub': 4, 'and': 5, 'andi': 6, 'or': 7, 'ori': 8, 'nor': 9, 'nori': 10,
        'xor': 11, 'xori': 12, 'beq': 13, 'beqz': 14, 'bne': 15, 'bnez': 16, 'bgt': 17, 'bge': 18, 'blt': 19, 'ble': 20,
        'j': 21, 'jr': 23, 'lb': 24, 'lh': 25, 'lw': 26, 'sb': 27, 'sh': 28, 'sw': 29, 'slli': 30,
        'sll': 31, 'srli': 32, 'srl': 33, 'srai': 34, 'sra': 35, 'slt': 36, 'slti': 37
    }
    num_3reg = ['add', 'sub', 'and', 'or', 'nor', 'xor', 'sll', 'srl', 'sra', 'slt']
    num_2reg_imm = ['addi', 'addiu', 'andi', 'ori', 'nori', 'xori', 'beq', 'bne', 'bgt', 'bge', 'blt',
                    'ble', 'slli', 'srli', 'srai', 'slti']
    num_reg_imm = ['beqz', 'bnez']
    num_imm = ['j']
    num_reg = ['jr']
    num_2reg = ['lb', 'lh', 'lw', 'sb', 'sh', 'sw']

    instruction = instruction.strip()
    op = re.match(r'([A-Za-z]*)', instruction).group(0)
    reg_imm = instruction.split(op)[-1].strip().split(",")
    op_bin = '{:b}'.format(int(opList.get(op)) & 0xffff).zfill(6)
    args_bin = ""
    if op in num_3reg:
        regs = ['{:b}'.format(int(reg_imm[i]) & 0xffff).zfill(5) for i in range(3)]
        args_bin += "".join(regs)
        result_bin = (op_bin + args_bin).ljust(32, '0')
    elif op in num_2reg_imm:
        regs = ['{:b}'.format(int(reg_imm[i]) & 0xffff).zfill(5) for i in range(2)]
        args_bin += "".join(regs)
        args_bin += '{:b}'.format(int(reg_imm[2]) & 0xffff).zfill(16)
        result_bin = (op_bin + args_bin).ljust(32, '0')
    elif op in num_reg_imm:
        args_bin = ('{:b}'.format(int(reg_imm[0]) & 0xffff).zfill(5)).ljust(10, '0')
        args_bin += '{:b}'.format(int(reg_imm[1]) & 0xffff).zfill(16)
        result_bin = (op_bin + args_bin).ljust(32, '0')
    elif op in num_imm:
        args_bin += ('{:b}'.format(int(reg_imm[0]) & 0xfffffff).zfill(26))[-26:]
        result_bin = (op_bin + args_bin).ljust(32, '0')
    elif op in num_reg:
        args_bin += '{:b}'.format(int(reg_imm[0]) & 0xffff).zfill(5)
        result_bin = (op_bin + args_bin).ljust(32, '0')
    elif op in num_2reg:
        regs = ['{:b}'.format(int(reg_imm[i]) & 0xffff).zfill(5) for i in range(2)]
        args_bin += "".join(regs)
        result_bin = (op_bin + args_bin).ljust(32, '0')
    else:
        raise Exception("指令出错")
    return result_bin, '{:x}'.format(int(result_bin, 2) & 0xffffffff).zfill(8)


if __name__ == "__main__":
    filePath = os.path.join(os.getcwd(), "mips.asm")
    ResultFilePathBin = os.path.join(os.getcwd(), "bin.mem")
    ResultFilePathHex = os.path.join(os.getcwd(), "hex.mem")
    binData = []
    hexData = []
    with open(filePath, mode="r", encoding="utf8") as f:
        for val in f.readlines():
            if len(val.strip()) == 0 or val.strip().startswith(";"):
                continue
            bin_num, hex_num = trans_mips2hex(val)
            binData.append(bin_num + "\n")
            hexData.append(hex_num + "\n")
    with open(ResultFilePathBin, mode="w", encoding="utf8") as f:
        f.writelines(binData)

    with open(ResultFilePathHex, mode="w", encoding="utf8") as f:
        f.writelines(hexData)
