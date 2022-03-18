`include "define.v"

module DEC_ALU(
    input wire clk,

    // from register
    input wire [`DataSize] dataReg1,
    input wire [`DataSize] dataReg2,

    // from decoder
    input wire writeEnableReg,
    input wire [`RegAddrSize] writeBackAddrIn,
    input wire [`DataSize] immValueReg,

    // from contol unit
    input wire [`ALUControlBus] ALUop,

    // to ALU_MEM
    output reg writeEnableAlu,
    output reg [`RegAddrSize] writeBackAddrOut,

    // to ALU
    output reg [`DataSize] dataAlu1,
    output reg [`DataSize] dataAlu2,
    output reg [`ALUControlBus] op,
    output reg [`DataSize] immValueAlu 
);

always @(posedge clk)begin
    writeEnableAlu <= writeEnableReg;
    writeBackAddrOut <= writeBackAddrIn;
    dataAlu1 <= dataReg1;
    dataAlu2 <= dataReg2;
    op <= ALUop;
    immValueAlu <= immValueReg;
end

endmodule