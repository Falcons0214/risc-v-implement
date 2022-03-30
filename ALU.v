`include "define.v"

module muxUnit(
    // from DEC_ALU
    input wire [`DataSize] dataReg,

    // from ALU_MEM
    input wire [`DataSize] data_ALU_MEM,

    // from MEM_WB
    input wire [`DataSize] data_MEM_WB,

    // from forwarding unit 
    input wire [`ALUMuxSelectBus] select,

    // to ALU
    output reg [`DataSize] result
);

always @(*) begin
    case (select)
        `ALUMuxDataFromReg: begin
            result <= dataReg;
        end
        `ALUMuxDataFromALU_MEM: begin
            result <= data_ALU_MEM;
        end
        `ALUMuxDataFromMEM_WB: begin
            result <= data_MEM_WB;
        end
        default: begin
            result <= dataReg;
        end
    endcase
end

endmodule


module ALUComputationUnit(
    // from DEC_ALU
    input wire [`DataSize] dataSource1,
    input wire [`DataSize] dataSource2,
    input wire [`DataSize] immValue,
    input wire [`ALUControlBus] op,

    // to ALU_MEM
    output reg [`DataSize] data
);

always @(*) begin
    case (op)
        `ALUop_ORI: begin
            data <= dataSource1 | immValue;
        end
        `ALUop_ADDI: begin
            data <= dataSource1 + immValue;
        end
        `ALUop_ADD: begin
            data <= dataSource1 + dataSource2;
        end
        `ALUop_SUB: begin
            data <= dataSource1 - dataSource2;
        end
        default: begin
            data <= `DataBusReset;
        end
    endcase
end

endmodule

module ALU(
    input wire [`DataSize] regDataFromRegS1,
    input wire [`DataSize] regDataFromRegS2,
    input wire [`DataSize] regDataFromALU_MEM,
    input wire [`DataSize] regDataFromMEM_WB,

    // from DEC_ALU
    input wire [`DataSize] immValue,
    input wire [`ALUControlBus] op,

    // from forwarding unit
    input wire [`ALUMuxSelectBus] select1,
    input wire [`ALUMuxSelectBus] select2,

    // to ALU_MEM
    output wire [`DataSize] dataToALU_MEM
);

wire [`DataSize] r1;
wire [`DataSize] r2;

muxUnit mux1(
    .dataReg(regDataFromRegS1),
    .data_ALU_MEM(regDataFromALU_MEM),
    .data_MEM_WB(regDataFromMEM_WB),
    .select(select1),
    .result(r1)
);

muxUnit mux2(
    .dataReg(regDataFromRegS2),
    .data_ALU_MEM(regDataFromALU_MEM),
    .data_MEM_WB(regDataFromMEM_WB),
    .select(select2),
    .result(r2)
);

ALUComputationUnit ALUcom(
    .dataSource1(r1),
    .dataSource2(r2),
    .immValue(immValue),
    .op(op),
    .data(dataToALU_MEM)
);

endmodule