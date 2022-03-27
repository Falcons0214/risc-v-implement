`include "./define.v"

module IF_ID(
    input wire clk,

    // from Hazard detect unit
    input wire locker,

    // from PC loader
    input wire resetIn,

    // from rom
    input wire [`DataSize]dataIn,

    // back to PC or Dec_ALU
    output reg [`DataSize]addrOut,

    // to Dec
    output reg [`DataSize]dataOut,
    output reg resetOut
);

always @(posedge clk) begin
    resetOut <= resetIn;
    if (locker || resetIn) begin
        dataOut <= dataIn;
    end
    else begin 
        dataOut <= dataOut;
    end
end

endmodule