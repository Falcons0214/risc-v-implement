`include "define.v"

module ALU_MEM(
    input wire clk,

    // from alu
    input wire [`DataSize] dataIn,

    // from DEC_ALU
    input wire writeEnableIn,
    input wire [`RegAddrSize] writeBackAddrIn,

    // to MEM_WB
    output reg resetOut,
    output reg writeEnableOut,
    output reg [`RegAddrSize] writeBackAddrOut,

    // to ram
    output reg [`DataSize] dataOut
);

always @(posedge clk) begin
    writeEnableOut <= writeEnableIn;
    resetOut <= 1'b0;
    dataOut <= dataIn;
    writeBackAddrOut <= writeBackAddrIn;
end

endmodule