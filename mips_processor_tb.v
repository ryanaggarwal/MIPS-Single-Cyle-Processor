
module mips_processor_tb;
    reg clk;
    reg reset;

    // Instantiate the MIPS processor
    mips_processor uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns period (100MHz clock)
    end

    initial begin
        // Initialize signals
        reset = 1;

        // Apply reset for a few clock cycles
        #20;
        reset = 0;

        // Run the simulation for a sufficient number of cycles
        // to complete the test program in instruction memory
        #500; // Adjust time as needed, 300ns should be enough for this short program

        
        $display("\n--- Final Register File Contents (Corrected Program) ---");
        $display("$zero (R0): %h", uut.REG_FILE.registers[0]); // Should be 0
        $display("$t0   (R8): %h", uut.REG_FILE.registers[8]); // Expected: 5
        $display("$t1   (R9): %h", uut.REG_FILE.registers[9]); // Expected: 7
        $display("$t2  (R10): %h", uut.REG_FILE.registers[10]);// Expected: c (12)
        $display("$t3  (R11): %h", uut.REG_FILE.registers[11]);// Expected: 7 (12 -> 12 - 5)
        $display("$t4  (R12): %h", uut.REG_FILE.registers[12]);// Expected: 1 (slt result)
        $display("$t5  (R13): %h", uut.REG_FILE.registers[13]);// Expected: 5 (and result)
        $display("$t6  (R14): %h", uut.REG_FILE.registers[14]);// Expected: 7 (or result)
        $display("$t7  (R15): %h", uut.REG_FILE.registers[15]);// Expected: c (12) (subroutine result: 5+7)
        $display("$ra  (R31): %h", uut.REG_FILE.registers[31]);// Expected: 34 (0x13 * 4, PC after JAL)


        $display("\n--- Final Data Memory Contents ---");
        $display("Memory[0]: %h", uut.DMEM.memory[0]); // Expected: c (12)

        $finish;
    end

    initial begin
    
        $monitor("Time=%0t PC=%h Inst=%h | Rs=%h Rt=%h Rd=%b | WR=%b WD=%h | JR=%b JMP=%b BRA=%b | ALUC=%b ALUZ=%b | MR=%b MW=%b MRD=%h",
                 $time, uut.pc_current, uut.instruction,
                 uut.reg_read_data1, uut.reg_read_data2, uut.reg_dst, // Read data, RegDst
                 uut.reg_write, uut.reg_write_data,              // Write enable, Write data
                 uut.jump_reg, uut.jump, uut.branch,             // Jump/Branch controls
                 uut.alu_control, uut.alu_zero,                  // ALU control, Zero flag
                 uut.mem_read, uut.mem_write, uut.mem_read_data); // Memory controls, Mem read data
    end

    //  Dump waveform for viewing in a waveform viewer
    initial begin
        $dumpfile("mips_processor_tb.vcd");
        $dumpvars(0, mips_processor_tb);
    end
endmodule