`include "define.v"

module ram(
    // from ALU_MEM
    input wire [`DataCacheControlBus] dataCacheContol,                          
    input wire [`DataSize] addr,
    input wire [`DataSize] dataWrite,
    input wire dataSelect, // from locker unit 1-> write from ALU_MEM, 0-> write from WB

    // from MEM_WB
    input wire [`DataSize] preData,
    
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
        if (dataSelect) begin
            ram[addr] <= dataWrite;
        end
        else begin
            ram[addr] <= preData;
        end
        select <= 1'b0;
    end
    else begin
        dataRead <= `DataBusReset;
        select <= 1'b0;
    end
end

endmodule