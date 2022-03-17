`include "define.v"

module DEC_ALU(
    input wire clk,
    input wire resetIn,

    // from register
    input wire [`DataSize]dataReg1,
    input wire [`DataSize]dataReg2,

    // from decoder
    input wire writeEnableReg,
    input wire [`RegAddrSize]writeBackAddrIn,
    input wire [`OpcodeSize]ALUopcodeReg,
    input wire [`Func3Size]ALUFunc3Reg,
    input wire [`Func7Size]ALUFunc7Reg,
    input wire [`DataSize]immValueReg,

    // to ALU_MEM
    output reg writeEnableAlu,
    output reg [`RegAddrSize]writeBackAddrOut,

    // to ALU
    output reg resetOut,
    output reg [`DataSize]dataAlu1,
    output reg [`DataSize]dataAlu2,
    output reg [`OpcodeSize]ALUopcodeAlu,
    output reg [`Func3Size]ALUFunc3Alu,
    output reg [`Func7Size]ALUFunc7Alu,
    output reg [`DataSize]immValueAlu 
);

always @(posedge clk)begin
    if (resetIn) begin
        resetOut <= 1'b1;
        writeEnableAlu <= `RegWriteDeny;
        writeBackAddrOut <= `RegAddrReset;
        dataAlu1 <= `DataBusReset;
        dataAlu2 <= `DataBusReset;
        ALUopcodeAlu <= `NOP;
        ALUFunc3Alu <= ALUFunc3Reg;
        ALUFunc7Alu <= ALUFunc7Reg;
        immValueAlu <= immValueReg;
    end
    else begin
        resetOut <= 1'b0;
        writeEnableAlu <= writeEnableReg;
        writeBackAddrOut <= writeBackAddrIn;
        dataAlu1 <= dataReg1;
        dataAlu2 <= dataReg2;
        ALUopcodeAlu <= ALUopcodeReg;
        ALUFunc3Alu <= ALUFunc3Reg;
        ALUFunc7Alu <= ALUFunc7Reg;
        immValueAlu <= immValueReg;
    end
end

endmodule