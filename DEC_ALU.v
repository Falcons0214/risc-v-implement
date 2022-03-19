`include "define.v"

module DEC_ALU(
    input wire clk,

    // from register
    input wire [`DataSize] dataReg1,
    input wire [`DataSize] dataReg2,

    // from decoder
    input wire [`RegAddrSize] writeBackAddrIn,

    // from contol unit
    input wire [`ALUControlBus] ALUop,
    input wire writeEnableReg,
    input wire dataCacheReadEnableIn,
    input wire dataCacheWriteEnableIn,
    input wire [`DataSize] immValueIn,

    // to ALU_MEM
    output reg writeEnableAlu,
    output reg dataCacheReadEnableOut,
    output reg dataCacheWriteEnableOut,
    output reg [`RegAddrSize] writeBackAddrOut,

    // to ALU
    output reg [`DataSize] dataAlu1,
    output reg [`DataSize] dataAlu2, // & to ALU_MEM
    output reg [`ALUControlBus] op,
    output reg [`DataSize] immValueOut 
);

always @(posedge clk)begin
    writeEnableAlu <= writeEnableReg;
    dataCacheReadEnableOut <= dataCacheReadEnableIn;
    dataCacheWriteEnableOut <= dataCacheWriteEnableIn;
    writeBackAddrOut <= writeBackAddrIn;
    dataAlu1 <= dataReg1;
    dataAlu2 <= dataReg2;
    op <= ALUop;
    immValueOut <= immValueIn;
end

endmodule