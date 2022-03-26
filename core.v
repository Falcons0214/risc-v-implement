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
`include "forward.v"
`include "hazardUnit.v"

module core;

reg clk;

// PC
reg pcResetIn;
reg select;
reg flush;
wire resetToIFID;
reg [`DataSize] pcAddrIn;
reg [`DataSize] jump;
wire [`DataSize] pcAddrOut;

// ROM
wire [`DataSize] romDataOut;

// IF_ID
wire [`DataSize] IF_IDromAddrOut;
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
wire [`DataCacheControlBus] dataCCDec;

// hazard dectect unit
wire IFIDlock;
wire PClock;

// register
wire [`DataSize] RegOutData1;
wire [`DataSize] RegOutData2;

// DEC_ALU
wire ALUWriteEnable;
wire [`DataCacheControlBus] dataCCALU;
wire [`RegAddrSize] ALUWriteBackAddr;
wire [`DataSize] ALUData1;
wire [`DataSize] ALUData2;
wire [`ALUControlBus] opALU;
wire [`DataSize] ALUimmValue;
wire [`RegAddrSize] regDataAddr1;
wire [`RegAddrSize] regDataAddr2;
wire [`OpcodeSize] opCodeToHa;

// forwarding unit
wire [`ALUMuxSelectBus] s1;
wire [`ALUMuxSelectBus] s2;

// ALU
wire [`DataSize] ALUoutData;

// ALU_MEM
wire aluMemWriteEnable;
wire [`DataCacheControlBus] dataCCMem;
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
$monitor("time %4d, clock: %b, reset: %b, pcAddrOut: %b, romdataout: %b\ndecoder data1: %b, decoder data2: %b, opcode: %b\nreg file dataOut1: %b\nDEC_ALU data1: %b\nALU data: %b immValue: %b\nALU_MEM data: %b\nwrite back data: %b, addr: %b, enable: %b\nResult: %b\nReg 17: %b\nReg 18: %b\nReg 19: %b", $stime, clk, pcResetIn, pcAddrOut, romDataOut, DecRead1, DecRead2, opcodeToControl, RegOutData1, ALUData1, ALUoutData, ALUimmValue, aluMemData, writeBackData, writeBackAddr, wbEnable, regF1.regs[5'b01100], regF1.regs[5'b10000], regF1.regs[5'b10001], regF1.regs[5'b10010]);

clk = 0;
pcResetIn = 1;
jump = `DataBusReset;
pcAddrIn = `DataBusReset;
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
    .locker(PClock),
    .select(select),
    .addrIn(pcAddrIn),
    .addrJump(jump),
    // out
    .addrOut(pcAddrOut),
    .resetOut(resetToIFID)
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
    .locker(IFIDlock),
    .reset(resetToIFID),
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
    .dataCacheControl(dataCCDec),
    .regWriteEnable(regWriteEnable)
);

register regF1(
    // in
    .readAddrF(DecRead1),
    .readAddrS(DecRead2),
    .writeEnable(wbEnable), // from WB
    .writeAddr(writeBackAddr), // from WB
    .writeDate(writeBackData), // from WB
    // out
    .outDataF(RegOutData1),
    .outDataS(RegOutData2)
);

hazardDetectUnit ha1(
    .opCodeFromDec(opCodeToHa),
    .writeBackAddr(ALUWriteBackAddr),
    .source1(DecRead1),
    .source2(DecRead2),
    .IF_IDLocker(IFIDlock),
    .PCLocker(PClock)
);

DEC_ALU DEC_ALU1(
    // in
    .clk(clk),
    // from register
    .dataReg1(RegOutData1),
    .dataReg2(RegOutData2),
    // from decoder
    .opCodeFromDec(opcodeToControl),
    .writeBackAddrIn(DecWrite),
    .dataS1AddrIn(DecRead1),
    .dataS2AddrIn(DecRead2),
    // from control unit
    .ALUop(ALUop),
    .immValueIn(ImmToALU),
    .dataCacheControlIn(dataCCDec),
    .writeEnableReg(regWriteEnable),
    // out
    .dataCacheControlOut(dataCCALU),
    .writeEnableAlu(ALUWriteEnable),
    .writeBackAddrOut(ALUWriteBackAddr),
    .dataAlu1(ALUData1),
    .dataAlu2(ALUData2),
    .op(opALU),
    .immValueOut(ALUimmValue),
    .opCodeToHazard(opCodeToHa), // to hazard detect unit
    .dataS1AddrOut(regDataAddr1), // to forwarding unit
    .dataS2AddrOut(regDataAddr2)  // to forwarding unit
);

forward forwardUnit(
    .addr1(regDataAddr1),
    .addr2(regDataAddr2),
    .preAddr_ALU_MEM(aluMemWriteBackAddrOut), // from ALU_MEM
    .preAddr_MEM_WB(writeBackAddr), // from MEM_WB
    .select1(s1),
    .select2(s2)
);

ALU ALU1(
    // in
    .regDataFromRegS1(ALUData1),
    .regDataFromRegS2(ALUData2),
    .regDataFromALU_MEM(aluMemData),
    .regDataFromMEM_WB(writeBackData),
    .immValue(ALUimmValue),
    .op(opALU),
    .select1(s1),
    .select2(s2),
    // out
    .dataToALU_MEM(ALUoutData)
);

ALU_MEM ALU_MEM1(
    // in
    .clk(clk),
    .dataIn(ALUoutData),
    .dataRs2In(ALUData2),
    .writeEnableIn(ALUWriteEnable),
    .writeBackAddrIn(ALUWriteBackAddr),
    .dataCacheControlIn(dataCCALU),
    // out
    .dataOut(aluMemData),
    .dataRs2Out(aluMemRs2Data),
    .dataCacheControlOut(dataCCMem),
    .writeEnableOut(aluMemWriteEnable),
    .writeBackAddrOut(aluMemWriteBackAddrOut)
);

ram ram1(
    .dataCacheContol(dataCCMem),
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