`include "define.v"
`include "PC.v"
`include "rom.v"
`include "IF_ID.v"
`include "decoder.v"
`include "registerFile.v"
`include "DEC_ALU.v"
`include "ALU.v"
`include "ALU_MEM.v"
// `include "ram.v"
`include "MEM_WB.v"

module core;

reg clk, enable;

// PC
reg pcResetIn;
reg select;
reg flush;
reg [5:0] pcAddrIn;
reg [5:0] jump;
wire [5:0] pcAddrOut;

// ROM
wire [`DataSize] romDataOut;

// IF_ID
wire [`RomAddr] IF_IDromAddrOut;
wire [`DataSize] IF_IDdataOut;

// decoder
wire [`RegAddrSize] DecRead1;
wire [`RegAddrSize] DecRead2;
wire [`RegAddrSize] DecWrite;
wire DecWriteEnable;
wire [`OpcodeSize] opcodeToControl;
wire [`Func3Size] func3ToControl;
wire [`Func7Size] func7ToControl;
wire [`DataSize] DecImmValue;

// control unit
wire [`ALUControlBus] ALUop;

// register
wire [`DataSize] RegOutData1;
wire [`DataSize] RegOutData2;

// DEC_ALU
wire ALUWriteEnable;
wire [`RegAddrSize] ALUWriteBackAddr;
wire [`DataSize] ALUData1;
wire [`DataSize] ALUData2;
wire [`ALUControlBus] opALU;
wire [`DataSize] ALUimmValue;

// ALU
wire [`DataSize] ALUoutData;

// ALU_MEM
wire aluMemWriteEnable;
wire [`DataSize] aluMemData;
wire [`RegAddrSize] aluMemWriteBackAddrOut;

// MEM_WB
wire wbEnable;
wire [`DataSize] writeBackData;
wire [`RegAddrSize] writeBackAddr;

// temp data
wire [`DataSize] tmpDataFromRam;

initial begin
$readmemb("./data", rom1.rom);
$readmemb("./data2", regF1.regs);
$monitor("time %4d, clock: %b, reset: %b, pcAddrOut: %b, romdataout: %b\ndecoder data1: %b, decoder data2: %b\nreg file dataOut1: %b\nDEC_ALU data1: %b\nALU data: %b immValue: %b\nALU_MEM data: %b\nwrite back data: %b, addr: %b, enable: %b\nResult: %b\n", $stime, clk, pcResetIn, pcAddrOut, romDataOut, DecRead1, DecRead2, RegOutData1, ALUData1, ALUoutData, ALUimmValue, aluMemData, writeBackData, writeBackAddr, wbEnable, regF1.regs[5'b00000]);

clk = 0;
pcResetIn = 1;
enable = 1;
jump = 6'b0;
pcAddrIn = 6'b0;
select = 0;
flush = 0;

#10
pcResetIn = 0;

#90 $finish; 
end

always begin
    #5 clk = ~clk;
end

PC pc1(
    // in
    .clk(clk),
    .resetIn(pcResetIn),
    .enable(enable),
    .select(select),
    .addrIn(pcAddrIn),
    .addrJump(jump),
    // out
    .addrOut(pcAddrOut)
);

rom rom1(
    // in
    .flush(flush),
    .addr(pcAddrOut),
    // out
    .inst(romDataOut)
);

IF_ID ifid1(
    // in
    .clk(clk),
    .enable(enable),
    .addrIn(pcAddrOut),
    .dataIn(romDataOut),
    // out
    .addrOut(IF_IDromAddrOut),
    .dataOut(IF_IDdataOut)
);

decoder dec1(
    // in
    .inst(IF_IDdataOut),
    // out
    .readAddr1(DecRead1),
    .readAddr2(DecRead2),
    .writeAddr(DecWrite),
    .regWriteEnable(DecWriteEnable),
    .OutOpcode(opcodeToControl),
    .OutFunc3(func3ToControl),
    .OutFunc7(func7ToControl),
    .immValue(DecImmValue)
);

controlUnit control1(
    // in from decoder
    .opcode(opcodeToControl),
    .opFunc3(func3ToControl),
    .opFunc7(func7ToControl),
    // out to Dec_ALU
    .ALUop(ALUop)
);

register regF1(
    // in
    .readAddrF(DecRead1),
    .readAddrS(DecRead2),
    .writeEnable(wbEnable), // from WB
    .writeAddr(writeBackAddr), 
    .writeDate(writeBackData), // from WB
    // out
    .outDataF(RegOutData1),
    .outDataS(RegOutData2)
);

DEC_ALU DEC_ALU1(
    // in
    .clk(clk),
    // from register
    .dataReg1(RegOutData1),
    .dataReg2(RegOutData2),
    // from decoder
    .writeEnableReg(DecWriteEnable),
    .writeBackAddrIn(DecWrite),
    .immValueReg(DecImmValue),
    // from control unit
    .ALUop(ALUop),
    // out
    .writeEnableAlu(ALUWriteEnable),
    .writeBackAddrOut(ALUWriteBackAddr),
    .dataAlu1(ALUData1),
    .dataAlu2(ALUData2),
    .op(opALU),
    .immValueAlu(ALUimmValue)
);

ALU ALU1(
    // in
    .op(opALU), // from control unit
    .dataSource1(ALUData1),
    .dataSource2(ALUData2),
    .immValue(ALUimmValue),
    // out
    .data(ALUoutData)
);

ALU_MEM ALU_MEM1(
    // in
    .clk(clk),
    .dataIn(ALUoutData),
    .writeEnableIn(ALUWriteEnable),
    .writeBackAddrIn(ALUWriteBackAddr),
    // out
    .writeEnableOut(aluMemWriteEnable),
    .writeBackAddrOut(aluMemWriteBackAddrOut),
    .dataOut(aluMemData)
);

MEM_WB MEM_WB1(
    // in
    .clk(clk),
    .select(1'b1),
    .dataFromALU(aluMemData),
    .dataFromRam(tmpDataFromRam),
    .writeEnableIn(aluMemWriteEnable),
    .writeBackAddrIn(aluMemWriteBackAddrOut),
    // out
    .writeEnableOut(wbEnable),
    .writeBackAddrOut(writeBackAddr),
    .dataToReg(writeBackData)
);

endmodule