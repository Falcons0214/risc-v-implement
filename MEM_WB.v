`include "define.v"

module MEM_WB(
    input wire clk,
    input wire select,
    input wire [`DataSize]dataFromALU,
    input wire [`DataSize]dataFromRam,

    // from ALU_MEM
    input wire regWriteEnableIn,
    input wire [`RegAddrSize] writeBackAddrIn,

    // to register file
    output reg regWriteEnableOut,
    output reg [`RegAddrSize] writeBackAddrOut,
    output reg [`DataSize] dataToReg
);

always @(posedge clk) begin
    regWriteEnableOut <= regWriteEnableIn;
    writeBackAddrOut <= writeBackAddrIn;
    if(select) begin
        dataToReg <= dataFromRam;
    end 
    else begin
        dataToReg <= dataFromALU;
    end
end

endmodule