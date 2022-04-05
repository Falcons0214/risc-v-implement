`include "define.v"

module mux31Unit(
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

module mux21Unit(
    input wire [`DataSize] s1, // rs2
    input wire [`DataSize] s2, // immValue
    input wire select,
    output reg [`DataSize] out
);

always @(*) begin
    if (select === 1'b1) begin
        out <= s2;
    end
    else begin
        out <= s1;
    end
end

endmodule

module ALUComputationUnit(
    // from DEC_ALU
    input wire [`DataSize] dataSource1,
    input wire [`DataSize] dataSource2, // Maybe the rs2 or immValue
    input wire [3:0] op,

    // to ALU_MEM
    output reg [`DataSize] data
);

always @(*) begin
    case (op)
        `MYOR: begin
            data <= dataSource1 | dataSource2;
        end
        `MYXOR: begin
            data <= dataSource1 ^ dataSource2;
        end
        `MYADD: begin
            data <= dataSource1 + dataSource2;
        end
        `MYSUB: begin
            data <= dataSource1 - dataSource2;
        end
        `MYAND: begin
            data <= dataSource1 & dataSource2;
        end
        `MYSLT: begin 
            if ((dataSource1[31] === 1'b1 && dataSource2[31] === 1'b0) ||
                (dataSource1[31] === 1'b0 && dataSource2[31] === 1'b0 && dataSource1 < dataSource2) ||
                (dataSource1[31] === 1'b1 && dataSource2[31] === 1'b1 && dataSource1 > dataSource2))
            begin 
                data <= 32'b1;
            end
            else begin
                data <= `DataBusReset;
            end
        end
        `MYSLTU: begin
            if (dataSource1 < dataSource2) begin
                data <= 32'b1;
            end
            else begin
                data <= `DataBusReset;
            end
        end
        `MYSLL: begin
            data <= dataSource1 << dataSource1;
        end
        `MYSRL: begin
            data <= dataSource1 >> dataSource2;
        end
        `MYSRA: begin
            data <= $signed(dataSource1) >>> dataSource2;
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
wire [`DataSize] r3;

mux31Unit mux1(
    .dataReg(regDataFromRegS1),
    .data_ALU_MEM(regDataFromALU_MEM),
    .data_MEM_WB(regDataFromMEM_WB),
    .select(select1),
    .result(r1)
);

mux31Unit mux2(
    .dataReg(regDataFromRegS2),
    .data_ALU_MEM(regDataFromALU_MEM),
    .data_MEM_WB(regDataFromMEM_WB),
    .select(select2),
    .result(r2)
);

mux21Unit mux3(
    .s1(r2),
    .s2(immValue),
    .select(op[4]),
    .out(r3)
);

ALUComputationUnit ALUcom(
    .dataSource1(r1),
    .dataSource2(r3),
    .op(op[3:0]),
    .data(dataToALU_MEM)
);

endmodule