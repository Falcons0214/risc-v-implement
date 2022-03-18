// func size 
`define Func3Size 2:0
`define Func7Size 6:0
`define OpcodeSize 6:0

// data bus size
`define DataSize 31:0

// register file 
`define RegFileSize 31:0
`define RegAddrSize 4:0
`define RegWriteAccept 1'b1
`define RegWriteDeny 1'b0

// rom
`define RomUnitSize 31:0
`define RomSize 63:0
`define RomAddr 5:0 

// ram
`define RamUnitSize 31:0
`define RamSize 63:0

// init value
`define RegAddrReset 5'b0
`define RomAddrReset 6'b0
`define DataBusReset 32'b0

// Instruction opcode type
`define Opcode_Type_I_Imm 7'b0010011
`define Opcode_Type_I_Load 7'b0000011

// I_Type immediate instruction
`define ORI 3'b110

// I_Type Load instruction
`define LH 3'b001
`define LW 3'b010

// R_Type Store instruction
`define SW 3'b010

// ALU control
`define ALUControlBus 2:0
`define ALUopReset 3'b0

`define ALUop_ADD 3'b001
`define ALUop_OR 3'b110

// ALU 
`define NOP 7'b0
