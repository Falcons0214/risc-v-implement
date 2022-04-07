`include "define.v"
`include "ALU.v"

module compare(
    input wire [`DataSize] s1,
    input wire [`DataSize] s2,
    input wire [`DataSize] pc,
    input wire [`DataSize] imm,
    input wire [`OpcodeSize] opcode,
    input wire [`ALUControlBus] op,
    output reg [`DataSize] addrToPc,
    output reg branchFlag
);

always @(*) begin
    addrToPc <= pc + imm;
    if (opcode !== `Opcode_Type_B_BRANCH) begin
        branchFlag <= 1'b0;
    end
    else begin
        if (op === `MYBEQ) begin
            if (s1 ^ s2 === 32'b0) begin
                branchFlag <= 1'b1;
            end
            else begin
                branchFlag <= 1'b0;
            end
        end
        else if (op === `MYBNE) begin
            if(s1 ^ s2 !== 32'b0) begin
                branchFlag <= 1'b1;
            end
            else begin
                branchFlag <= 1'b0;
            end
        end
        else if (op === `MYBLT) begin
            if ((s1[31] === 1'b1 && s2[31] === 1'b0) ||
                (s1[31] === 1'b0 && s2[31] === 1'b0 && s1 < s2) ||
                (s1[31] === 1'b1 && s2[31] === 1'b1 && s1 > s2))
            begin 
                branchFlag <= 1'b1;
            end
            else begin
                branchFlag <= 1'b0;
            end
        end
        else if (op === `MYBGE) begin
            if ((s1[31] === 1'b0 && s2[31] === 1'b1) ||
                (s1[31] === 1'b0 && s2[31] === 1'b0 && s1 >= s2) ||
                (s1[31] === 1'b1 && s2[31] === 1'b1 && s1 <= s2))
            begin 
                branchFlag <= 1'b1;
            end
            else begin
                branchFlag <= 1'b0;
            end
        end
        else if (op === `MYBLTU) begin
            if (s1 < s2) begin
                branchFlag <= 1'b1;
            end
            else begin
                branchFlag <= 1'b0;
            end
        end
        else if (op === `MYBGEU) begin
            if (s1 >= s2) begin
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
    input wire [`ALUControlBus] op,

    // write back data from ALU_MEM
    input wire [`DataSize] wbALUMem,

    // write back data from WB
    input wire [`DataSize] wbMEMWB,

    // to PC
    output wire [`DataSize] branchAddr,

    // to PC & instCache
    output wire branchFlag
);

wire [`DataSize] rs1;
wire [`DataSize] rs2;

mux31Unit m1(
    .dataReg(source1),
    .data_ALU_MEM(wbALUMem), // from ALU
    .data_MEM_WB(wbMEMWB), // from ALU_MEM
    .select(select1),
    .result(rs1)
);

mux31Unit m2(
    .dataReg(source2),
    .data_ALU_MEM(wbALUMem), // from ALU
    .data_MEM_WB(wbMEMWB), // from ALU_MEM
    .select(select2),
    .result(rs2)
);

compare c1(
    .s1(rs1),
    .s2(rs2),
    .pc(pc),
    .imm(immValue),
    .opcode(opcode),
    .op(op),
    .addrToPc(branchAddr),
    .branchFlag(branchFlag)
);

endmodule