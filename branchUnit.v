`include "define.v"
`include "ALU.v"

module compare(
    input wire [`DataSize] s1,
    input wire [`DataSize] s2,
    input wire [`DataSize] pc,
    input wire [`DataSize] imm,
    input wire [`OpcodeSize] opcode,
    input wire [`ALUControlBus] opFunc3,
    output reg [`DataSize] addrToPc,
    output reg branchFlag
);

always @(*) begin
    addrToPc <= pc + imm;
    if (opcode !== `Opcode_Type_B_BRANCH) begin
        branchFlag <= 1'b0;
    end
    else begin
        if (opFunc3 === `BEQ4) begin
            if(s1 ^ s2 === 32'b0) begin
                branchFlag <= 1'b1;
            end
            else begin
                branchFlag <= 1'b0;
            end
        end
        else if (opFunc3 === `BNE4) begin
            if(s1 ^ s2 !== 32'b0) begin
                branchFlag <= 1'b1;
            end
            else begin
                branchFlag <= 1'b0;
            end
        end
        else begin
            branchFlag <= 1'b0;
        end
    end
end

endmodule

module branchUnit(
    // from IF_ID
    input wire [`DataSize] pc,
    
    // from register
    input wire [`DataSize] source1,
    input wire [`DataSize] source2,

    // from forward unit "for Branch"
    input wire [`ALUMuxSelectBus] select1,
    input wire [`ALUMuxSelectBus] select2,

    // from decoder
    input wire [`OpcodeSize] opcode,
    
    // from control unit
    input wire [`DataSize] immValue,
    input wire [`ALUControlBus] opFunc3,

    // write back data from ALU
    input wire [`DataSize] wbALU,

    // write back data from ALU_MEM
    input wire [`DataSize] wbALUMem,

    // to PC
    output wire [`DataSize] branchAddr,

    // to PC & instCache
    output wire branchFlag
);

wire [`DataSize] rs1;
wire [`DataSize] rs2;

muxUnit m1(
    .dataReg(source1),
    .data_ALU_MEM(wbALU), // from ALU
    .data_MEM_WB(wbALUMem), // from ALU_MEM
    .select(select1),
    .result(rs1)
);

muxUnit m2(
    .dataReg(source2),
    .data_ALU_MEM(wbALU), // from ALU
    .data_MEM_WB(wbALUMem), // from ALU_MEM
    .select(select2),
    .result(rs2)
);

compare c1(
    .s1(rs1),
    .s2(rs2),
    .pc(pc),
    .imm(immValue),
    .opcode(opcode),
    .opFunc3(opFunc3),
    .addrToPc(branchAddr),
    .branchFlag(branchFlag)
);

endmodule