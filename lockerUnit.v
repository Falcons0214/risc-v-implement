`include "define.v"

module hazardDetectUnit(
    // from DEC_ALU
    input wire [`OpcodeSize] opCodeFromDec,
    input wire [`RegAddrSize] writeBackAddr,
    input wire flag,

    // from decoder
    input wire [`RegAddrSize] source1,
    input wire [`RegAddrSize] source2,
    input wire [`OpcodeSize] opcodeCur,

    output reg PCLocker,
    output reg IF_IDLocker,
    output reg DECLocker,
    output reg ALUForwardControl, // for computation befroe LW, to IF_ID
    output reg dataCacheWBcontrol // to DEC_ALU 
);

always @(*) begin
    if (opCodeFromDec === `Opcode_Type_I_Load) begin
        if (opcodeCur === `Opcode_Type_R_Store && source2 === writeBackAddr) begin
            PCLocker <= 1'b1;
            IF_IDLocker <= 1'b1;
            DECLocker <= 1'b1;
            dataCacheWBcontrol <= 1'b0;
            ALUForwardControl <= 1'b1;
        end
        else if (source1 === writeBackAddr || source2 === writeBackAddr) begin
            IF_IDLocker <= 1'b0;
            PCLocker <= 1'b0;
            DECLocker <= 1'b0;
            dataCacheWBcontrol <= 1'b1;
            ALUForwardControl <= 1'b0;
        end
        else begin
            PCLocker <= 1'b1;
            IF_IDLocker <= 1'b1;
            DECLocker <= 1'b1;
            dataCacheWBcontrol <= 1'b1;
            ALUForwardControl <= 1'b1;
        end
    end
    else if (opcodeCur === `Opcode_Type_B_BRANCH) begin
        ALUForwardControl <= 1'b1;
        if (flag === 1'b1 && (writeBackAddr === source1 || writeBackAddr === source2)) begin
            PCLocker <= 1'b0;
            IF_IDLocker <= 1'b0;
            DECLocker <= 1'b0;
            dataCacheWBcontrol <= 1'b1;
        end
        else begin
            PCLocker <= 1'b1;
            IF_IDLocker <= 1'b1;
            DECLocker <= 1'b1;
            dataCacheWBcontrol <= 1'b1;
        end
    end
    else begin
        PCLocker <= 1'b1;
        IF_IDLocker <= 1'b1;
        DECLocker <= 1'b1;
        dataCacheWBcontrol <= 1'b1;
        ALUForwardControl <= 1'b1;
    end
end

endmodule