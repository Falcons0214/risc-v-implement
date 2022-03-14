`include "define.v"

module ram(
    // from ALU_MEM
    input wire [63:0] writeAddr,
    input wire [`DataSize] dataWrite,

    // to MEM_WB
    output wire [`DataSize] dataRead,
);

reg [`MemSize] ram[63:0];

always @(*) begin

end

endmodule