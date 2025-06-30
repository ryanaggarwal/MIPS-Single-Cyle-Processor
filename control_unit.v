
module control_unit(
    input wire [5:0] opcode,
    input wire [5:0] funct,
    output reg reg_dst,
    output reg jump,
    output reg branch,
    output reg mem_read,
    output reg mem_to_reg,
    output reg [1:0] alu_op,
    output reg mem_write,
    output reg alu_src,
    output reg reg_write,
    output reg jump_and_link,
    output reg jump_reg  
);
    // Opcodes
    parameter OP_RTYPE = 6'b000000;
    parameter OP_LW    = 6'b100011;
    parameter OP_SW    = 6'b101011;
    parameter OP_BEQ   = 6'b000100;
    parameter OP_J     = 6'b000010;
    parameter OP_JAL   = 6'b000011;
    parameter OP_ADDI  = 6'b001000;
    
    // Function codes
    parameter F_JR = 6'b001000;  
    
    always @(*) begin
        // Default control signals
        reg_dst = 1'b0;
        jump = 1'b0;
        branch = 1'b0;
        mem_read = 1'b0;
        mem_to_reg = 1'b0;
        alu_op = 2'b00;
        mem_write = 1'b0;
        alu_src = 1'b0;
        reg_write = 1'b0;
        jump_and_link = 1'b0;
        jump_reg = 1'b0;
        
        case (opcode)
            OP_RTYPE: begin
                // Check if it's a JR instruction
                if (funct == F_JR) begin
                    jump_reg = 1'b1;
                end else begin
                    reg_dst = 1'b1;
                    alu_op = 2'b10;
                    reg_write = 1'b1;
                end
            end
            
            OP_LW: begin
                alu_src = 1'b1;
                mem_to_reg = 1'b1;
                mem_read = 1'b1;
                reg_write = 1'b1;
            end
            
            OP_SW: begin
                alu_src = 1'b1;
                mem_write = 1'b1;
            end
            
            OP_BEQ: begin
                branch = 1'b1;
                alu_op = 2'b01;
            end
            
            OP_J: begin
                jump = 1'b1;
            end
            
            OP_JAL: begin
                jump = 1'b1;
                reg_write = 1'b1;
                jump_and_link = 1'b1;
            end
            
            OP_ADDI: begin
                alu_src = 1'b1;
                reg_write = 1'b1;
            end
            
            default: begin
                // Default values already set
            end
        endcase
    end
endmodule