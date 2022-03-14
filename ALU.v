`include "define.v"

module ALU(
    // from ALUcontrol
    input wire [`ALUControlBus] op,

    // from DEC_ALU
    input wire [`DataSize] dataSource1,
    input wire [`DataSize] dataSource2,
    input wire [`DataSize] immValue,
    
    // to ALU_MEM
    output reg [`DataSize] data
);

always @(*) begin
    case (op)
        `ALUop_OR: begin
            data <= dataSource1 | immValue;
        end
        default: begin
            data <= `DataBusReset;
        end
    endcase
end

endmodule

module aluControl(
    input resetIn,
    // from DEC_ALU
    input wire [`OpcodeSize] opcode,
    input wire [`Func3Size] opFunc3,
    input wire [`Func7Size] opFunc7,

    // to ALU_MEM
    output reg resetOut,

    // to ALU
    output reg [`ALUControlBus] ALUop
);

always @(*) begin
    if (resetIn) begin
        ALUop <= `ALUopReset;
        resetOut <= 1'b1;
    end
    else begin
        resetOut <= 1'b0;
        case (opcode)
            `Opcode_Type_I: begin
                case (opFunc3)
                    `ORI: begin
                        ALUop <= `ALUop_OR;
                    end
                    default: begin
                        ALUop <= `ALUopReset;
                    end
                endcase
            end
            default: begin
                ALUop <= `ALUopReset;
            end
        endcase
    end
end

endmodule