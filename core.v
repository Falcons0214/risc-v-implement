`include "define.v"
`include "PC.v"
`include "instCache.v"
`include "IF_ID.v"
`include "decoder.v"
`include "registerFile.v"
`include "DEC_ALU.v"
`include "ALU.v"
`include "ALU_MEM.v"
`include "dataCache.v"
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
wire [`OpcodeSize] opcodeToControl;
wire [`Func3Size] func3ToControl;
wire [`immValueBus] DecImmValue;

// control unit
wire [`DataSize] ImmToALU;
wire [`ALUControlBus] ALUop;
wire regWriteEnable;
wire dataCacheReadEnableDec;

// register
wire [`DataSize] RegOutData1;
wire [`DataSize] RegOutData2;

// DEC_ALU
wire ALUWriteEnable;
wire dataCacheReadEnableALU;
wire [`RegAddrSize] ALUWriteBackAddr;
wire [`DataSize] ALUData1;
wire [`DataSize] ALUData2;
wire [`ALUControlBus] opALU;
wire [`DataSize] ALUimmValue;

// ALU
wire [`DataSize] ALUoutData;

// ALU_MEM
wire aluMemWriteEnable;
wire dataCacheReadEnableCache;
wire [`DataSize] aluMemData;
wire [`DataSize] aluMemRs2Data;
wire [`RegAddrSize] aluMemWriteBackAddrOut;

// ram
wire selectS;
wire [`DataSize] dataOut;

// MEM_WB
wire wbEnable;
wire [`DataSize] writeBackData;
wire [`RegAddrSize] writeBackAddr;

initial begin
$readmemb("./data3", ram1.ram);
$readmemb("./data2", regF1.regs);
$readmemb("./data", rom1.rom);
$monitor("time %4d, clock: %b, reset: %b, pcAddrOut: %b, romdataout: %b\ndecoder data1: %b, decoder data2: %b\nreg file dataOut1: %b\nDEC_ALU data1: %b\nALU data: %b immValue: %b\nALU_MEM data: %b\nwrite back data: %b, addr: %b, enable: %b\nResult: %b\n", $stime, clk, pcResetIn, pcAddrOut, romDataOut, DecRead1, DecRead2, RegOutData1, ALUData1, ALUoutData, ALUimmValue, aluMemData, writeBackData, writeBackAddr, wbEnable, regF1.regs[5'b01100]);

clk = 0;
pcResetIn = 1;
enable = 1;
jump = 6'b0;
pcAddrIn = 6'b000110;
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
    .OutOpcode(opcodeToControl),
    .OutFunc3(func3ToControl),
    .immValue(DecImmValue)
);

controlUnit control1(
    // in from decoder
    .opcode(opcodeToControl),
    .opFunc3(func3ToControl),
    .immValueIn(DecImmValue),
    // out to Dec_ALU
    .ALUop(ALUop),
    .immValueOut(ImmToALU),
    .dataCacheReadEnable(dataCacheReadEnableDec),
    .regWriteEnable(regWriteEnable)
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
    .writeBackAddrIn(DecWrite),
    // from control unit
    .ALUop(ALUop),
    .immValueIn(ImmToALU),
    .dataCacheReadEnableIn(dataCacheReadEnableDec),
    .writeEnableReg(regWriteEnable),
    // out
    .dataCacheReadEnableOut(dataCacheReadEnableALU),
    .writeEnableAlu(ALUWriteEnable),
    .writeBackAddrOut(ALUWriteBackAddr),
    .dataAlu1(ALUData1),
    .dataAlu2(ALUData2),
    .op(opALU),
    .immValueOut(ALUimmValue)
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
    .dataRs2In(ALUData2),
    .writeEnableIn(ALUWriteEnable),
    .dataCacheReadEnableIn(dataCacheReadEnableALU),
    .writeBackAddrIn(ALUWriteBackAddr),
    // out
    .dataOut(aluMemData),
    .dataRs2Out(aluMemRs2Data),
    .writeEnableOut(aluMemWriteEnable),
    .dataCacheReadEnableOut(dataCacheReadEnableCache),
    .writeBackAddrOut(aluMemWriteBackAddrOut)
);

ram ram1(
    .dataCacheReadEnable(dataCacheReadEnableCache),
    .addr(aluMemData),
    .dataWrite(aluMemRs2Data),
    .select(selectS),
    .dataRead(dataOut)
);

MEM_WB MEM_WB1(
    // in
    .clk(clk),
    .select(selectS),
    .dataFromALU(aluMemData),
    .dataFromRam(dataOut),
    .regWriteEnableIn(aluMemWriteEnable),
    .writeBackAddrIn(aluMemWriteBackAddrOut),
    // out
    .regWriteEnableOut(wbEnable),
    .writeBackAddrOut(writeBackAddr),
    .dataToReg(writeBackData)
);

endmodule