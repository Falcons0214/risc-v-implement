`include "define.v"

module DEC_ALU(
    input wire clk,

    // from IF_ID
    input wire reset,

    // from register
    input wire [`DataSize] dataReg1,
    input wire [`DataSize] dataReg2,

    // from decoder
    input wire [`OpcodeSize] opCodeFromDec,
    input wire [`RegAddrSize] writeBackAddrIn,
    input wire [`RegAddrSize] dataS1AddrIn, 
    input wire [`RegAddrSize] dataS2AddrIn,

    // from contol unit
    input wire [`ALUControlBus] ALUop,
    input wire writeEnableReg,
    input wire [`DataCacheControlBus] dataCacheControlIn,
    input wire [`DataSize] immValueIn,

    // from locker unit
    input wire locker,
    input wire CSLToALUMEMIn,

    // to ALU_MEM
    output reg writeEnableAlu,
    output reg CSLToALUMEMOut,
    output reg [`DataCacheControlBus] dataCacheControlOut,
    output reg [`RegAddrSize] writeBackAddrOut,

    // to ALU
    output reg [`DataSize] dataAlu1,
    output reg [`DataSize] dataAlu2, // & to ALU_MEM
    output reg [`ALUControlBus] op,
    output reg [`DataSize] immValueOut,

    // to hazard detect unit
    output reg [`OpcodeSize] opCodeToHazard,

    // to forwarding unit
    output reg [`RegAddrSize] dataS1AddrOut,
    output reg [`RegAddrSize] dataS2AddrOut
);

always @(posedge clk)begin
    opCodeToHazard <= opCodeFromDec;
    if(locker || reset) begin
        writeEnableAlu <= writeEnableReg;
        dataCacheControlOut <= dataCacheControlIn;
        writeBackAddrOut <= writeBackAddrIn;
        dataAlu1 <= dataReg1;
        dataAlu2 <= dataReg2;
        op <= ALUop;
        immValueOut <= immValueIn;
        dataS1AddrOut <= dataS1AddrIn;
        dataS2AddrOut <= dataS2AddrIn;
        CSLToALUMEMOut <= CSLToALUMEMIn;
    end
    else begin
        writeEnableAlu <= writeEnableAlu;
        dataCacheControlOut <= dataCacheControlOut;
        writeBackAddrOut <= writeBackAddrOut;
        dataAlu1 <= dataAlu1;
        dataAlu2 <= dataAlu2;
        op <= op;
        immValueOut <= immValueOut;
        dataS1AddrOut <= dataS1AddrOut;
        dataS2AddrOut <= dataS2AddrOut;
        CSLToALUMEMOut <= CSLToALUMEMOut;
    end
end

endmodule