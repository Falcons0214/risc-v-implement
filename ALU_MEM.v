`include "define.v"

module ALU_MEM(
    input wire clk,
    input wire resetIn,

    // from alu
    input wire [`DataSize] dataIn,

    // from DEC_ALU
    input wire writeEnableIn,
    input wire [`RegAddrSize] writeBackAddrIn,

    // to MEM_WB
    output reg writeEnableOut,
    output reg [`RegAddrSize] writeBackAddrOut,

    // to ram
    output reg resetOut,
    output reg [`DataSize] dataOut
);

always @(posedge clk) begin
    writeEnableOut <= writeEnableIn;
    if(resetIn) begin
        resetOut <= 1'b1;
        dataOut <= `DataBusReset;
        writeBackAddrOut <= `RegAddrReset;
    end
    else begin 
        resetOut <= 1'b0;
        dataOut <= dataIn;
        writeBackAddrOut <= writeBackAddrIn;
    end
end

endmodule