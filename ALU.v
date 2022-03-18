`include "define.v"

module ALU(
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
        `ALUop_OR: begin
            data <= dataSource1 | immValue;
        end
        `ALUop_ADD: begin
            data <= dataSource1 + immValue;
        end
        default: begin
            data <= `DataBusReset;
        end
    endcase
end

endmodule