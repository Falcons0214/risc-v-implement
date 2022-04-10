`include "./define.v"

module IF_ID(
    input wire clk,

    // from lock unit
    input wire locker,
    input wire ALUForwardCSLFromLockIn,
    input wire select,

    // from IF_ID
    input wire [`DataSize] nextInst,

    // from PC loader
    input wire resetIn,
    input wire [`DataSize] pcIn,

    // from inst cache
    input wire [`DataSize] dataIn,

    // to Decoder
    output reg [`DataSize] dataOut,

    // to DEC_ALU
    output reg resetOut,
    output reg ALUForwardCSLFromLockOut,

    // to branchUnit
    output reg [`DataSize] pcOut
);

always @(posedge clk) begin
    resetOut <= resetIn;
    pcOut <= pcIn;
    ALUForwardCSLFromLockOut <= ALUForwardCSLFromLockIn;
    if (select) begin
        dataOut <= nextInst;
    end
    else begin
        if (locker || resetIn) begin
            dataOut <= dataIn;
        end
        else begin 
            dataOut <= dataOut;
        end
    end
end

endmodule