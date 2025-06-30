
module instruction_memory(
    input wire [31:0] pc,
    output wire [31:0] instruction
);
    reg [31:0] memory [255:0]; // Memory size: 256 words

    
    localparam P_MAIN      = 0;
    localparam P_BEQ       = 5;
    localparam P_SUB       = 6;
    localparam P_JUMP_END  = 7;
    localparam P_LABEL     = 8; // Skipped by BEQ
    localparam P_END       = 9; // Target of JUMP_END
    localparam P_SLT       = 9; // Execution continues here
    localparam P_AND       = 10;
    localparam P_OR        = 11;
    localparam P_JAL       = 12; // Calls subroutine
    localparam P_CONTINUE  = 13; // Return point from JAL ($ra)
    localparam P_EXIT      = 14; // Infinite loop jump target
    localparam P_SUBROUTINE= 16; // Start of subroutine
    localparam P_JR        = 17; // End of subroutine

    initial begin
        
        for(integer i=0; i<256; i=i+1) memory[i] = 32'h00000000; // sll $0,$0,0

        // MIPS assembly equivalent:
        // main:                       # Address (Word)
        memory[P_MAIN+0] = 32'h20080005;  // addi $t0, $zero, 5    # 0: t0 = 5
        memory[P_MAIN+1] = 32'h20090007;  // addi $t1, $zero, 7    # 1: t1 = 7
        memory[P_MAIN+2] = 32'h01095020;  // add $t2, $t0, $t1     # 2: t2 = t0 + t1 (12)
        memory[P_MAIN+3] = 32'hac0a0000;  // sw $t2, 0($zero)      # 3: Mem[0] = t2
        memory[P_MAIN+4] = 32'h8c0b0000;  // lw $t3, 0($zero)      # 4: t3 = Mem[0] (12)
        // beq: PC=0x14, PC+4=0x18, Target=label(word 8)=0x20. Offset = (0x20-0x18)/4 = 1 word
        memory[P_BEQ]    = 32'h11090001;  // beq $t0, $t1, label   # 5: Not taken (5!=7)
        memory[P_SUB]    = 32'h01685822;  // sub $t3, $t3, $t0     # 6: t3 = t3 - t0 (12-5=7)
        // jump: PC=0x1C, Target=end(word 9)=0x24. Instr field = 9
        memory[P_JUMP_END]= 32'h08000000 | P_END; // j end       # 7: Jump to 'end' (word 9)
        memory[P_LABEL]  = 32'h016b5820;  // add $t3, $t3, $t3     # 8: label: (skipped by jump)
        // end: (Continues execution after jump)
        memory[P_SLT]    = 32'h0109602a;  // slt $t4, $t0, $t1     # 9: t4 = (t0 < t1) = 1
        // Calculate t5, t6 *before* calling subroutine
        memory[P_AND]    = 32'h01096824;  // and $t5, $t0, $t1     # 10: t5 = t0 & t1 (5 & 7 = 5)
        memory[P_OR]     = 32'h01097025;  // or $t6, $t0, $t1      # 11: t6 = t0 | t1 (5 | 7 = 7)
        // jal: PC=0x30, PC+4=0x34(word 13), Target=subroutine(word 16)=0x40. Instr field = 16
        memory[P_JAL]    = 32'h0C000000 | P_SUBROUTINE; // jal subroutine # 12: Jump to subroutine, $ra=0x34
        // continue: (Return point from subroutine)
        memory[P_CONTINUE]=32'h00000000;  // nop                   # 13: (Instruction after JAL, $ra points here)
        // exit: (Infinite loop)
        // jump: PC=0x38, Target=exit(word 14)=0x38. Instr field = 14
        memory[P_EXIT]   = 32'h08000000 | P_EXIT; // j exit       # 14: Infinite loop
        // Skipped instruction (just in case)
        memory[15]       = 32'h00000000;  // nop

        // subroutine:
        memory[P_SUBROUTINE]=32'h01ae7820; // add $t7, $t5, $t6     # 16: t7 = t5 + t6 (5 + 7 = 12)
        memory[P_JR]       = 32'h03e00008; // jr $ra                # 17: Return to caller (address in $ra=0x34)
        // Instructions after subroutine code
        memory[18]       = 32'h00000000;
        memory[19]       = 32'h00000000;


        $display("Instruction Memory Initialized with CORRECTED program.");
    end

   
    assign instruction = memory[pc[9:2]];
endmodule