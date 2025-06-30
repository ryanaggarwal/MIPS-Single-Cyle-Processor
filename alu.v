// ALU
module alu(
    input wire [31:0] a,
    input wire [31:0] b,
    input wire [2:0] alu_control,
    output reg [31:0] result,
    output wire zero
);
    // ALU control codes
    parameter ALU_AND = 3'b000;
    parameter ALU_OR  = 3'b001;
    parameter ALU_ADD = 3'b010;
    parameter ALU_SUB = 3'b110;
    parameter ALU_SLT = 3'b111;
    
    always @(*) begin
        case (alu_control)
            ALU_AND: result = a & b;
            ALU_OR:  result = a | b;
            ALU_ADD: result = a + b;
            ALU_SUB: result = a - b;
            ALU_SLT: result = (a < b) ? 32'h1 : 32'h0;
            default: result = 32'h00000000;
        endcase
    end
    
    assign zero = (result == 32'h00000000) ? 1'b1 : 1'b0;
endmodule