`include "define.v"

module DEC_ALU(
    input wire clk,

    // from register
    input wire [`DataSize] dataReg1,
    input wire [`DataSize] dataReg2,

    // from decoder
    input wire [`RegAddrSize] writeBackAddrIn,
    input wire [`RegAddrSize] dataS1AddrIn, 
    input wire [`RegAddrSize] dataS2AddrIn,

    // from contol unit
    input wire [`ALUControlBus] ALUop,
    input wire writeEnableReg,
    input wire [`DataCacheControlBus] dataCacheControlIn,
    input wire [`DataSize] immValueIn,

    // to ALU_MEM
    output reg writeEnableAlu,
    output reg [`DataCacheControlBus] dataCacheControlOut,
    output reg [`RegAddrSize] writeBackAddrOut,

    // to ALU
    output reg [`DataSize] dataAlu1,
    output reg [`DataSize] dataAlu2, // & to ALU_MEM
    output reg [`ALUControlBus] op,
    output reg [`DataSize] immValueOut 
);

always @(posedge clk)begin
    writeEnableAlu <= writeEnableReg;
    dataCacheControlOut <= dataCacheControlIn;
    writeBackAddrOut <= writeBackAddrIn;
    dataAlu1 <= dataReg1;
    dataAlu2 <= dataReg2;
    op <= ALUop;
    immValueOut <= immValueIn;
end

endmodule