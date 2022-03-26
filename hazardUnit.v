`include "define.v"

module hazardDetectUnit(
    // from DEC_ALU
    input wire [`OpcodeSize] opCodeFromDec,
    input wire [`RegAddrSize] writeBackAddr,

    // from decoder
    input wire [`RegAddrSize] source1,
    input wire [`RegAddrSize] source2,

    output reg IF_IDLocker,
    output reg PCLocker
);



always @(*) begin
    if (opCodeFromDec === `Opcode_Type_I_Load) begin
        if (source1 === writeBackAddr || source2 === writeBackAddr) begin
            IF_IDLocker <= 1'b0;
            PCLocker <= 1'b0;  
        end
        else begin
            IF_IDLocker <= 1'b1;
            PCLocker <= 1'b1;
        end
    end
    else begin
        IF_IDLocker <= 1'b1;
        PCLocker <= 1'b1;
    end
end

endmodule