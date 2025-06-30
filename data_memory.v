// Data Memory
module data_memory(
    input wire clk,
    input wire mem_write,
    input wire mem_read,
    input wire [31:0] address,
    input wire [31:0] write_data,
    output wire [31:0] read_data
);
    reg [31:0] memory [255:0];
    integer i;
    
    // Initialize memory
    initial begin
        for (i = 0; i < 256; i = i + 1)
            memory[i] = 32'h00000000;
    end
    
    // Write operation
    always @(posedge clk) begin
        if (mem_write)
            memory[address[9:2]] <= write_data;
    end
    
    // Read operation
    assign read_data = mem_read ? memory[address[9:2]] : 32'h00000000;
endmodule

