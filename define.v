// func size 
`define Func3Size 2:0
`define Func7Size 6:0
`define OpcodeSize 6:0

// data bus size
`define DataSize 31:0
`define ALUControlBus 3:0 // 3rd bit decide imm 0 -> imm, 1 -> reg data
`define immValueBus 11:0

// register file 
`define RegFileSize 31:0
`define RegAddrSize 4:0
`define RegWriteAccept 1'b1
`define RegWriteDeny 1'b0

// rom
`define RomUnitSize 31:0
`define RomSize 63:0

// ram
`define RamUnitSize 31:0
`define RamSize 63:0

// dataCache control signal
`define DataCacheControlBus 1:0
`define DataCacheNOP 2'b00
`define DataCacheRead 2'b01
`define DataCacheWrite 2'b10

// init value
`define RegAddrReset 5'b0
`define DataBusReset 32'b0

// Instruction opcode type
`define Opcode_Type_I_Imm 7'b0010011
`define Opcode_Type_I_Load 7'b0000011
`define Opcode_Type_R_Store 7'b0100011
`define Opcode_Type_R_RRop 7'b0110011
`define Opcode_Type_B_BRANCH 7'b1100011

// I_Type immediate instruction
`define ORI 3'b110
`define ImmReset 7'b0
// `define ImmValue32 31:0

// I_Type Load instruction
`define LH 3'b001
`define LW 3'b010

// R_Type Store instruction
`define SW 3'b010
`define ADDSUB 3'b000
`define ADD 7'b0000000
`define SUB 7'b0100000

// R_Type Branch instruction
`define BEQ 3'b000
`define BNE 3'b001

// ALU control
`define ALUopReset 4'b0000
`define ALUop_ADDI 4'b1001
`define ALUop_SUB 4'b0010
`define ALUop_ADD 4'b0001
`define ALUop_ORI 4'b1110

// ALU 
`define NOP 7'b0

// ALUmuxUnit
`define ALUMuxSelectBus 1:0
`define ALUMuxDataFromReg 2'b01
`define ALUMuxDataFromALU_MEM 2'b10
`define ALUMuxDataFromMEM_WB 2'b11