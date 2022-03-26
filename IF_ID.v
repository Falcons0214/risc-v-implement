`include "./define.v"

module IF_ID(
    input wire clk,

    // from Hazard detect unit
    input wire locker,

    // from PC loader
    input wire reset,
    input wire [`DataSize]addrIn,

    // from rom
    input wire [`DataSize]dataIn,

    // back to PC or Dec_ALU
    output reg [`DataSize]addrOut,

    // to Dec
    output reg [`DataSize]dataOut
);

always @(posedge clk) begin
    if (locker || reset) begin
        addrOut <= addrIn;
        dataOut <= dataIn;
    end
    else begin 
        addrOut <= addrOut;
        dataOut <= dataOut;
    end
end

endmodule