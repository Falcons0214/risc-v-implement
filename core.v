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
wire pcResetOut;
reg pcResetIn;
reg select;
reg flush;
reg [5:0] pcAddrIn;
reg [5:0] jump;
wire [5:0] pcAddrOut;

// ROM
wire [`DataSize] romDataOut;

// IF_ID
wire IF_IDreset;
wire [`RomAddr] IF_IDromAddrOut;
wire [`DataSize] IF_IDdataOut;

// decoder
wire [`RegAddrSize] DecRead1;
wire [`RegAddrSize] DecRead2;
wire [`RegAddrSize] DecWrite;
wire DecReset;
wire DecWriteEnable;
wire [`OpcodeSize] DecALUopcode;
wire [`Func3Size] DecALUFunc3;
wire [`Func7Size] DecALUFunc7;
wire [`DataSize] DecImmValue;

// register
wire RegReset;
wire [`DataSize] RegOutData1;
wire [`DataSize] RegOutData2;

// DEC_ALU
wire ALUWriteEnable;
wire [`RegAddrSize] ALUWriteBackAddr;
wire ALUReset;
wire [`DataSize] ALUData1;
wire [`DataSize] ALUData2;
wire [`OpcodeSize] ALUaluopcode;
wire [`Func3Size] ALUfunc3;
wire [`Func7Size] ALUfunc7;
wire [`DataSize] ALUimmValue;

// ALU control
wire ALUcontrolReset;
wire [`ALUControlBus] ALUCop;

// ALU
wire [`DataSize] ALUoutData;

// ALU_MEM
wire aluMemReset;
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
$monitor("time %4d, clock: %b, reset: %b, pcAddrOut: %b, romdataout: %b\ndecoder data1: %b, decoder data2: %b, decoder opcode: %b, decoder func3: %b\nreg file dataOut1: %b\nDEC_ALU data1: %b\nALU data: %b immValue: %b\nALU_MEM data: %b\nwrite back data: %b, addr: %b, enable: %b\nResult: %b", $stime, clk, pcResetIn, pcAddrOut, romDataOut, DecRead1, DecRead2, DecALUopcode, DecALUFunc3, RegOutData1, ALUData1, ALUoutData, ALUimmValue, aluMemData, writeBackData, writeBackAddr, wbEnable, regF1.regs[5'b00000]);

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
    .resetOut(pcResetOut),
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
    .resetIn(pcResetOut),
    .enable(enable),
    .addrIn(pcAddrOut),
    .dataIn(romDataOut),
    // out
    .addrOut(IF_IDromAddrOut),
    .resetOut(IF_IDreset),
    .dataOut(IF_IDdataOut)
);

decoder dec1(
    // in
    .resetIn(IF_IDreset),
    .inst(IF_IDdataOut),
    // out
    .readAddr1(DecRead1),
    .readAddr2(DecRead2),
    .writeAddr(DecWrite),
    .resetOut(DecReset),
    .regWriteEnable(DecWriteEnable),
    .ALUopcode(DecALUopcode),
    .ALUFunc3(DecALUFunc3),
    .ALUFunc7(DecALUFunc7),
    .immValue(DecImmValue)
);

register regF1(
    // in
    .resetIn(DecReset),
    .readAddrF(DecRead1),
    .readAddrS(DecRead2),
    .writeEnable(wbEnable), // from WB
    .writeAddr(writeBackAddr), 
    .writeDate(writeBackData), // from WB
    // out
    .resetOut(RegReset),
    .outDataF(RegOutData1),
    .outDataS(RegOutData2)
);

DEC_ALU DEC_ALU1(
    // in
    .clk(clk),
    .resetIn(RegReset),
    .dataReg1(RegOutData1),
    .dataReg2(RegOutData2),
    .writeEnableReg(DecWriteEnable),
    .writeBackAddrIn(DecWrite),
    .ALUopcodeReg(DecALUopcode),
    .ALUFunc3Reg(DecALUFunc3),
    .ALUFunc7Reg(DecALUFunc7),
    .immValueReg(DecImmValue),
    // out
    .writeEnableAlu(ALUWriteEnable),
    .writeBackAddrOut(ALUWriteBackAddr),
    .resetOut(ALUReset), // to ALU control
    .dataAlu1(ALUData1),
    .dataAlu2(ALUData2), 
    .ALUopcodeAlu(ALUaluopcode), // to ALU control
    .ALUFunc3Alu(ALUfunc3), // to ALU control
    .ALUFunc7Alu(ALUfunc7), // to ALU control
    .immValueAlu(ALUimmValue)
);

aluControl aluControl1(
    // in
    .resetIn(ALUReset),
    .opcode(ALUaluopcode),
    .opFunc3(ALUfunc3),
    .opFunc7(ALUfunc7),
    // out
    .resetOut(ALUcontrolReset),
    .ALUop(ALUCop)
);

ALU ALU1(
    // in
    .op(ALUCop), // from ALU control
    .dataSource1(ALUData1),
    .dataSource2(ALUData2),
    .immValue(ALUimmValue),
    // out
    .data(ALUoutData)
);

ALU_MEM ALU_MEM1(
    // in
    .clk(clk),
    .resetIn(ALUcontrolReset),
    .dataIn(ALUoutData),
    .writeEnableIn(ALUWriteEnable),
    .writeBackAddrIn(ALUWriteBackAddr),
    // out
    .writeEnableOut(aluMemWriteEnable),
    .writeBackAddrOut(aluMemWriteBackAddrOut),
    .resetOut(aluMemReset),
    .dataOut(aluMemData)
);

MEM_WB MEM_WB1(
    // in
    .clk(clk),
    .resetIn(aluMemReset),
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