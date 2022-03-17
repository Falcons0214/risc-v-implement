`include "define.v"

module MEM_WB(
    input wire clk,
    input wire resetIn,

    input wire select,
    input wire [`DataSize]dataFromALU, 
    input wire [`DataSize]dataFromRam,

    // from ALU_MEM
    input wire writeEnableIn,
    input wire [`RegAddrSize] writeBackAddrIn,

    // to register file
    output reg writeEnableOut,
    output reg [`RegAddrSize] writeBackAddrOut,
    output reg [`DataSize] dataToReg
);

always @(posedge clk) begin
    writeEnableOut <= writeEnableIn;
    if (resetIn) begin
        dataToReg <= `DataBusReset;;
        writeBackAddrOut <= `RegAddrReset;
    end
    else begin
        writeBackAddrOut <= writeBackAddrIn;
        if(select) begin 
            dataToReg <= dataFromALU;
        end 
        else begin
            dataToReg <= dataFromRam;
        end
    end 
end

endmodule