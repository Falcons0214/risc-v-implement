`include "define.v"

module ALU_MEM(
    input wire clk,

    // from alu
    input wire [`DataSize] dataIn,

    // from DEC_ALU
    input wire [`DataSize] dataRs2In,
    input wire writeEnableIn,
    input wire dataCacheReadEnableIn,
    input wire dataCacheWriteEnableIn,
    input wire [`RegAddrSize] writeBackAddrIn,
    
    // to ram
    output reg dataCacheReadEnableOut,
    output reg dataCacheWriteEnableOut,
    output reg [`DataSize] dataOut,
    output reg [`DataSize] dataRs2Out,

    // to MEM_WB
    output reg writeEnableOut,
    output reg [`RegAddrSize] writeBackAddrOut

);

always @(posedge clk) begin
    writeEnableOut <= writeEnableIn;
    dataCacheReadEnableOut <= dataCacheReadEnableIn;
    dataCacheWriteEnableOut <= dataCacheWriteEnableIn;
    dataOut <= dataIn;
    writeBackAddrOut <= writeBackAddrIn;
    dataRs2Out <= dataRs2In;
end

endmodule