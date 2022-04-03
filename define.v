// func size 
`define Func3Size 2:0
`define Func7Size 6:0
`define OpcodeSize 6:0

// data bus size
`define DataSize 31:0
`define ALUControlBus 4:0 // 3rd bit decide imm 0 -> imm, 1 -> reg data
`define immValueBus 19:0 // ?

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
`define DataBusReset 32'b0
`define NOP 32'b0

// Instruction opcode type
`define Opcode_Type_I_Imm 7'b0010011
`define Opcode_Type_I_Load 7'b0000011
`define Opcode_Type_I_JALR 7'b1100111
`define Opcode_Type_J_JAL 7'b1101111
`define Opcode_Type_R_Store 7'b0100011
`define Opcode_Type_R_RRop 7'b0110011
`define Opcode_Type_B_BRANCH 7'b1100011

// I_Type immediate instruction func3
`define ADDI 3'b000
`define SLTI 3'b010 // compare is sign number
`define SLTIU 3'b011 // compare is unsign number
`define XORI 3'b100
`define ORI 3'b110
`define ANDI 3'b111
`define SLLI 3'b001
`define SRLI 3'b101
`define SRAI 3'b101
`define SRLI7 7'b0
`define SRAI7 7'b0100000
`define ImmReset 20'b0
// `define ImmValue32 31:0

// I_Type Load instruction
`define LH 3'b001
`define LW 3'b010

// R_Type Store instruction
`define SW 3'b010
// R_Type_func3
`define ADDSUB 3'b000
`define SLL 3'b001
`define SLT 3'b010
`define SLTU 3'b011
`define XOR 3'b100
`define SRL 3'b101
`define SRA 3'b101
`define OR 3'b110
`define AND 3'b111
// R_Type_func7
`define FUNC7NOP 7'b0
`define SRL 7'b0000000
`define SRA 7'b0100000
`define ADD 7'b0000000
`define SUB 7'b0100000

// R_Type Branch instruction, using ALUControlBus, ([00]->not used [000]->decide operation) 
`define BEQ 3'b000
`define BNE 3'b001
`define MYBEQ 5'b00000
`define MYBNE 5'b00001

// ALU control ( [0]->decdie is it immValue, [0000]->operation )
`define ALUopReset 5'b00000
`define ALUop_ADDI 5'b10001
`define ALUop_SLTI 5'b10101
`define ALUop_SLTIU 5'b10110
`define ALUop_ANDI 5'b10011
`define ALUop_ORI 5'b10100
`define ALUop_XORI 5'b10111
`define ALUop_XOR 5'b00111
`define ALUop_AND 5'b00011
`define ALUop_OR 5'b00100
`define ALUop_SUB 5'b00010
`define ALUop_ADD 5'b00001

`define MYADD 4'b0001
`define MYSUB 4'b0010
`define MYAND 4'b0011
`define MYOR 4'b0100
`define MYSLT 4'b0101
`define MYSLTU 4'b0110
`define MYXOR 4'b0111

// ALU 
`define NOP 7'b0

// ALUmuxUnit
`define ALUMuxSelectBus 1:0
`define ALUMuxDataFromReg 2'b01
`define ALUMuxDataFromALU_MEM 2'b10
`define ALUMuxDataFromMEM_WB 2'b11