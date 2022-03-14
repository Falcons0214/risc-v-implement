`include "./define.v"

module IF_ID(
    input wire clk,
    input wire resetIn,

    // from Hazard detect unit
    input wire enable,

    // from PC loader
    input wire [`RomAddr]addrIn,

    // from rom
    input wire [`DataSize]dataIn,

    // back to PC or Dec_ALU
    output reg [`RomAddr]addrOut,

    // to Dec
    output reg resetOut,
    output reg [`DataSize]dataOut
);

always @(posedge clk) begin
    if (resetIn) begin
        resetOut <= 1'b1;
        addrOut <= `RomAddrReset;
        dataOut <= `DataBusReset;
    end
    else begin
        resetOut <= 1'b0;
        if (enable) begin
            addrOut <= addrIn;
            dataOut <= dataIn;
        end
        else begin 
            addrOut <= addrOut;
            dataOut <= dataOut;
        end
    end
end

endmodule