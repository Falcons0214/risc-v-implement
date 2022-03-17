`include "define.v"

module ram(
    // from ALU_MEM
    input wire [63:0] writeAddr,
    input wire [`DataSize] dataWrite,

    // to MEM_WB
    output wire [`DataSize] dataRead,
);

reg [`RamUnitSize] ram[`RamSize];

always @(*) begin

end

endmodule