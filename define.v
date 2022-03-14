// func size 
`define Func3Size 2:0
`define Func7Size 6:0
`define OpcodeSize 6:0

// data 
`define DataSize 31:0

// register file 
`define RegFileSize 31:0
`define RegAddrSize 4:0
`define RegWriteAccept 1'b1
`define RegWriteDeny 1'b0

// rom
`define RomUnitSize 31:0
`define RomSize 31:0
`define RomAddr 5:0 

// init value
`define RegAddrReset 5'b0
`define RomAddrReset 6'b0
`define DataBusReset 32'b0

// Instruction opcode type
`define Opcode_Type_I 7'b0010011

// I_Type instruction
`define ORI 3'b110

// ALU control
`define ALUopReset 3'b0
`define ALUControlBus 2:0

`define ALUop_OR 3'b110

// ALU 
`define NOP 7'b0
