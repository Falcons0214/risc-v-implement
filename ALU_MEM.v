`include "define.v"

module ALU_MEM(
    input wire clk,

    // from alu
    input wire [`DataSize] dataIn,

    // from DEC_ALU
    input wire [`DataSize] dataRs2In,
    input wire writeEnableIn,
    input wire CSLToDataCacheIn,
    input wire [`DataCacheControlBus] dataCacheControlIn,
    input wire [`RegAddrSize] writeBackAddrIn,
    
    // to ram
    output reg [`DataCacheControlBus] dataCacheControlOut,
    output reg [`DataSize] dataOut,
    output reg [`DataSize] dataRs2Out,
    output reg CSLToDataCacheOut,

    // to MEM_WB
    output reg writeEnableOut,
    output reg [`RegAddrSize] writeBackAddrOut
);

always @(posedge clk) begin
    writeEnableOut <= writeEnableIn;
    dataCacheControlOut <= dataCacheControlIn;
    dataOut <= dataIn;
    writeBackAddrOut <= writeBackAddrIn;
    dataRs2Out <= dataRs2In;
    CSLToDataCacheOut <= CSLToDataCacheIn;
end

endmodule