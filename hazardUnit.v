`include "define.v"

module hazardDetectUnit(
    // from DEC_ALU
    input wire [`OpcodeSize] opCodeFromDec,
    input wire [`RegAddrSize] writeBackAddr,

    // from decoder
    input wire [`RegAddrSize] source1,
    input wire [`RegAddrSize] source2,

    output reg PCLocker,
    output reg IF_IDLocker,
    output reg DECLocker
);

always @(*) begin
    if (opCodeFromDec === `Opcode_Type_I_Load) begin
        if (source1 === writeBackAddr || source2 === writeBackAddr) begin
            IF_IDLocker <= 1'b0;
            PCLocker <= 1'b0;
            DECLocker <= 1'b0;
        end
        else begin
            PCLocker <= 1'b1;
            IF_IDLocker <= 1'b1;
            DECLocker <= 1'b1;
        end
    end
    else begin
        PCLocker <= 1'b1;
        IF_IDLocker <= 1'b1;
        DECLocker <= 1'b1;
    end
end

endmodule