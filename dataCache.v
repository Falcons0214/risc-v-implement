`include "define.v"

module ram(
    // from ALU_MEM
    input wire [`DataCacheControlBus] dataCacheContol,                          
    input wire [`DataSize] addr,
    input wire [`DataSize] dataWrite,

    // to MEM_WB
    output reg select,
    output reg [`DataSize] dataRead
);

reg [`RamUnitSize] ram[`RamSize];

always @(*) begin
    if (dataCacheContol == `DataCacheRead) begin
        dataRead <= ram[addr];
        select <= 1'b1;
    end
    else if (dataCacheContol == `DataCacheWrite) begin
        ram[addr] <= dataWrite;
        select <= 1'b0;
    end
    else begin
        dataRead <= `DataBusReset;
        select <= 1'b0;
    end
end

endmodule