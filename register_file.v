// Register File (32 registers, each 32-bit)
module register_file(
    input wire clk,
    input wire reset,
    input wire reg_write,
    input wire [4:0] read_reg1,
    input wire [4:0] read_reg2,
    input wire [4:0] write_reg,
    input wire [31:0] write_data,
    output wire [31:0] read_data1,
    output wire [31:0] read_data2
);
    reg [31:0] registers [31:0];
    integer i;
    
    // Initialize registers
    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = 32'h00000000;
    end
    
    // Write operation
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'h00000000;
        end else if (reg_write && write_reg != 5'b00000) begin
            registers[write_reg] <= write_data;
        end
    end
    
    // Read operations (asynchronous)
    assign read_data1 = (read_reg1 == 5'b00000) ? 32'h00000000 : registers[read_reg1];
    assign read_data2 = (read_reg2 == 5'b00000) ? 32'h00000000 : registers[read_reg2];
endmodule