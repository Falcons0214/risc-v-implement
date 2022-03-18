`include "./define.v"

module IF_ID(
    input wire clk,

    // from Hazard detect unit
    input wire enable,

    // from PC loader
    input wire [`RomAddr]addrIn,

    // from rom
    input wire [`DataSize]dataIn,

    // back to PC or Dec_ALU
    output reg [`RomAddr]addrOut,

    // to Dec
    output reg [`DataSize]dataOut
);

always @(posedge clk) begin
    if (enable) begin
        addrOut <= addrIn;
        dataOut <= dataIn;
    end
    else begin 
        addrOut <= addrOut;
        dataOut <= dataOut;
    end
end

endmodule