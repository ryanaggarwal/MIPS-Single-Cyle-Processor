// ALU Control
module alu_control(
    input wire [1:0] alu_op,
    input wire [5:0] funct,
    output reg [2:0] alu_control
);
    // Function codes
    parameter F_ADD = 6'b100000;
    parameter F_SUB = 6'b100010;
    parameter F_AND = 6'b100100;
    parameter F_OR  = 6'b100101;
    parameter F_SLT = 6'b101010;
    parameter F_JR  = 6'b001000;  
    
    // ALU operation codes
    parameter ALU_AND = 3'b000;
    parameter ALU_OR  = 3'b001;
    parameter ALU_ADD = 3'b010;
    parameter ALU_SUB = 3'b110;
    parameter ALU_SLT = 3'b111;
    
    always @(*) begin
        case (alu_op)
            2'b00: alu_control = ALU_ADD;  // lw, sw operations
            2'b01: alu_control = ALU_SUB;  // beq operation
            2'b10: begin  // R-type instructions
                case (funct)
                    F_ADD: alu_control = ALU_ADD;
                    F_SUB: alu_control = ALU_SUB;
                    F_AND: alu_control = ALU_AND;
                    F_OR:  alu_control = ALU_OR;
                    F_SLT: alu_control = ALU_SLT;
                    F_JR:  alu_control = ALU_ADD; // Don't care for JR
                    default: alu_control = ALU_ADD;
                endcase
            end
            default: alu_control = ALU_ADD;
        endcase
    end
endmodule