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

    // from MEM_WB
    input wire isLWDone,

    // to PC
    output reg PCLocker,
    
    // to IF_ID
    output reg IF_IDLocker,
    output reg ALUForwardControl, // for computation befroe LW
    output reg select,

    // to DEC_ALU
    output reg DECLocker,
    output reg dataCacheWBcontrol,

    // to ALU_MEM
    output reg branchForwardCSL
);

always @(*) begin
    if (opCodeFromDec === `Opcode_Type_I_Load) begin
        select <= 1'b0;
        branchForwardCSL <= 1'b1;
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
        if (opCodeFromDec !== `Opcode_Type_I_Load && flag === 1'b1 && (writeBackAddr === source1 || writeBackAddr === source2)) begin
            PCLocker <= 1'b0;
            IF_IDLocker <= 1'b0;
            DECLocker <= 1'b0;
            dataCacheWBcontrol <= 1'b1;
            select <= 1'b0;
            branchForwardCSL <= 1'b1;
        end
        else if ((opCodeFromDec === `Opcode_Type_I_Load || isLWDone) && (writeBackAddr === source1 || writeBackAddr === source2)) begin
            PCLocker <= 1'b0;
            IF_IDLocker <= 1'b0;
            DECLocker <= 1'b0;
            dataCacheWBcontrol <= 1'b1;
            select <= 1'b1;
            branchForwardCSL <= 1'b0;
        end
        else begin
            PCLocker <= 1'b1;
            IF_IDLocker <= 1'b1;
            DECLocker <= 1'b1;
            dataCacheWBcontrol <= 1'b1;
            select <= 1'b0;
            branchForwardCSL <= 1'b1;
        end
    end
    else begin
        PCLocker <= 1'b1;
        IF_IDLocker <= 1'b1;
        DECLocker <= 1'b1;
        dataCacheWBcontrol <= 1'b1;
        ALUForwardControl <= 1'b1;
        select <= 1'b0;
        branchForwardCSL <= 1'b1;
    end
end

endmodule