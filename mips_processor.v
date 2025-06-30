
module mips_processor(
    input wire clk,
    input wire reset
);
    // Wires for connections between modules
    wire [31:0] pc_current, pc_next, pc_plus4;
    wire [31:0] pc_next_temp, pc_next_temp2;
    wire [31:0] instruction;
    wire [31:0] reg_write_data;
    wire [31:0] reg_write_data_temp;
    wire [31:0] reg_read_data1, reg_read_data2;
    wire [31:0] sign_ext_imm;
    wire [31:0] alu_result;
    wire [31:0] mem_read_data;
    wire [31:0] alu_input2;
    wire [31:0] branch_target;
    wire [31:0] jump_target;
    wire [4:0] reg_write_addr;
    wire [4:0] reg_write_addr_temp;
    
    // Control signals
    wire reg_dst, jump, branch, mem_read, mem_to_reg, mem_write;
    wire alu_src, reg_write, jump_and_link, jump_reg;
    wire [1:0] alu_op;
    wire [2:0] alu_control;
    wire alu_zero;
    wire pc_src;
    
    // PC update calculation
    assign pc_plus4 = pc_current + 32'd4;
    assign branch_target = pc_plus4 + {sign_ext_imm[29:0], 2'b00};
    assign jump_target = {pc_plus4[31:28], instruction[25:0], 2'b00};
    assign pc_src = branch & alu_zero;
    
    // PC register
    pc PC(
        .clk(clk),
        .reset(reset),
        .pc_next(pc_next),
        .pc_current(pc_current)
    );
    
    mux2 PC_BRANCH_MUX(
        .sel(pc_src),
        .a(pc_plus4),
        .b(branch_target),
        .y(pc_next_temp)
    );
    
    mux2 PC_JUMP_MUX(
        .sel(jump),
        .a(pc_next_temp),
        .b(jump_target),
        .y(pc_next_temp2)
    );
    
    mux2 PC_JR_MUX(
        .sel(jump_reg),
        .a(pc_next_temp2),
        .b(reg_read_data1),  // rs register contains return address
        .y(pc_next)
    );
    
    // Instruction memory
    instruction_memory IMEM(
        .pc(pc_current),
        .instruction(instruction)
    );
    
    // Control unit
    control_unit CTRL(
        .opcode(instruction[31:26]),
        .funct(instruction[5:0]),
        .reg_dst(reg_dst),
        .jump(jump),
        .branch(branch),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .jump_and_link(jump_and_link),
        .jump_reg(jump_reg)
    );
    
    // ALU control
    alu_control ALU_CTRL(
        .alu_op(alu_op),
        .funct(instruction[5:0]),
        .alu_control(alu_control)
    );
    
    // Multiplexer for register write address
    mux2 #(.WIDTH(5)) REG_DST_MUX(
        .sel(reg_dst),
        .a(instruction[20:16]),
        .b(instruction[15:11]),
        .y(reg_write_addr_temp)
    );
    
    mux2 #(.WIDTH(5)) JAL_REG_MUX(
        .sel(jump_and_link),
        .a(reg_write_addr_temp),
        .b(5'd31),  // $ra register for jal
        .y(reg_write_addr)
    );
    
    // Multiplexer for register write data for jal
    mux2 JAL_DATA_MUX(
        .sel(jump_and_link),
        .a(reg_write_data_temp),
        .b(pc_plus4),
        .y(reg_write_data)
    );
    
    // Register file
    register_file REG_FILE(
        .clk(clk),
        .reset(reset),
        .reg_write(reg_write),
        .read_reg1(instruction[25:21]),
        .read_reg2(instruction[20:16]),
        .write_reg(reg_write_addr),
        .write_data(reg_write_data),
        .read_data1(reg_read_data1),
        .read_data2(reg_read_data2)
    );
    
    // Sign extension
    sign_extend SIGN_EXT(
        .in(instruction[15:0]),
        .out(sign_ext_imm)
    );
    
    // ALU source multiplexer
    mux2 ALU_SRC_MUX(
        .sel(alu_src),
        .a(reg_read_data2),
        .b(sign_ext_imm),
        .y(alu_input2)
    );
    
    // ALU
    alu ALU(
        .a(reg_read_data1),
        .b(alu_input2),
        .alu_control(alu_control),
        .result(alu_result),
        .zero(alu_zero)
    );
    
    // Data memory
    data_memory DMEM(
        .clk(clk),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .address(alu_result),
        .write_data(reg_read_data2),
        .read_data(mem_read_data)
    );
    
    // Memory to register multiplexer
    mux2 MEM_TO_REG_MUX(
        .sel(mem_to_reg),
        .a(alu_result),
        .b(mem_read_data),
        .y(reg_write_data_temp)
    );
    
endmodule