`include "define.v"

module ram(
    // from ALU_MEM
    input wire dataCacheReadEnable,
    input wire dataCacheWriteEnable,
    input wire [`DataSize] addr,
    input wire [`DataSize] dataWrite,

    // to MEM_WB
    output reg select,
    output reg [`DataSize] dataRead
);

reg [`RamUnitSize] ram[`RamSize];

always @(*) begin
    if (dataCacheReadEnable == `DataCacheReadAccept) begin
        dataRead <= ram[addr];
        select <= 1'b1;
    end
    else if (dataCacheWriteEnable == `DataCacheWriteAccept) begin
        ram[addr] <= dataWrite;
        select <= 1'b0;
    end
    else begin
        dataRead <= `DataBusReset;
        select <= 1'b0;
    end
end

endmodule