`include "define.v"

module MEM_WB(
    input wire clk,

    // from ram
    input wire select,
    input wire [`DataSize] dataFromRam,

    // from ALU_MEM
    input wire regWriteEnableIn,
    input wire branchForCSLIn,
    input wire [`DataSize] dataFromALU,
    input wire [`RegAddrSize] writeBackAddrIn,
    input wire [`DataCacheControlBus] isLW,

    // to Lock unit
    output reg CSLToLock,

    // to Branch Forward
    output reg branchForCSLOut, 

    // to register file
    output reg regWriteEnableOut,
    output reg [`RegAddrSize] writeBackAddrOut,
    output reg [`DataSize] dataToReg
);

always @(posedge clk) begin
    regWriteEnableOut <= regWriteEnableIn;
    writeBackAddrOut <= writeBackAddrIn;
    branchForCSLOut <= branchForCSLIn;
    if (isLW === `DataCacheRead) begin
        CSLToLock <= 1'b0;
    end
    else begin
        CSLToLock <= 1'b1;
    end
    if (select) begin
        dataToReg <= dataFromRam;
    end 
    else begin
        dataToReg <= dataFromALU;
    end
end

endmodule