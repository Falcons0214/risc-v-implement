`include "define.v"

module decoder( 
    // from IF_ID
    input wire [`DataSize]inst,

    // to register file
    output reg [`RegAddrSize]readAddr1, 
    output reg [`RegAddrSize]readAddr2,

    // to DEC_ALU
    output reg [`RegAddrSize]writeAddr,

    // to control unit
    output reg [`OpcodeSize] OutOpcode, // to DEC_ALU
    output reg [`Func3Size] OutFunc3,
    output reg [`immValueBus] immValue
);

always @(*) begin
    OutOpcode <= inst[6:0];
    OutFunc3 <= inst[14:12];
    readAddr1 <= inst[19:15];
    readAddr2 <= inst[24:20];
    writeAddr <= inst[11:7];
    if (inst[6:0] == `Opcode_Type_I_Imm ||
        inst[6:0] == `Opcode_Type_I_Load ||
        inst[6:0] == `Opcode_Type_R_RRop) begin
        immValue <= inst[31:20];
    end
    else if (inst[6:0] == `Opcode_Type_R_Store) begin
        immValue <= {inst[31:25], inst[11:7]};
    end
    else if (inst[6:0] == `Opcode_Type_B_BRANCH) begin
        immValue <= {inst[31], inst[7], inst[30:25], inst[11:8]};
    end
    else begin
        immValue <= `ImmReset;
    end
end 

endmodule

module controlUnit(
    // from decoder
    input wire [`OpcodeSize] opcode,
    input wire [`Func3Size] opFunc3,
    input wire [`immValueBus] immValueIn,

    // to Dec_ALU
    output reg [`DataSize] immValueOut,
    output reg [`ALUControlBus] ALUop,
    output reg [`DataCacheControlBus] dataCacheControl,
    output reg regWriteEnable
);

always @(*) begin
    if (opcode === `Opcode_Type_B_BRANCH) begin
        immValueOut <= {{19{immValueIn[11]}}, immValueIn[11:0], 1'b0}; // LSD add 0
        ALUop <= `ALUopReset;
        regWriteEnable <= `RegWriteDeny;
        dataCacheControl <= `DataCacheNOP;
    end
    else begin
        immValueOut <= {{20{immValueIn[11]}}, immValueIn[11:0]};
        case (opcode)
            `Opcode_Type_I_Imm: begin
                case (opFunc3)
                    `ORI: begin
                        ALUop <= `ALUop_ORI;
                    end
                    default: begin
                        ALUop <= `ALUopReset;
                    end
                endcase
                regWriteEnable <= `RegWriteAccept;
                dataCacheControl <= `DataCacheNOP;
            end
            `Opcode_Type_I_Load: begin
                case (opFunc3) // decide sign extend width
                    `LW: begin // 32bit
                        ALUop <= `ALUop_ADDI;
                    end
                    default: begin
                        ALUop <= `ALUopReset;
                    end
                endcase
                regWriteEnable <= `RegWriteAccept;
                dataCacheControl <= `DataCacheRead;
            end
            `Opcode_Type_R_Store: begin
                case (opFunc3) // same as Load
                    `SW: begin // 32bits
                        ALUop <= `ALUop_ADDI;
                    end
                    default: begin
                        ALUop <= `ALUopReset;
                    end
                endcase
                regWriteEnable <= `RegWriteDeny;
                dataCacheControl <= `DataCacheWrite;
            end
            `Opcode_Type_R_RRop: begin
                case (opFunc3)
                    `ADDSUB: begin
                        case (immValueIn[11:5])
                            `ADD: begin
                                ALUop <= `ALUop_ADD;
                            end
                            `SUB: begin
                                ALUop <= `ALUop_SUB;
                            end
                        endcase
                    end
                endcase
                regWriteEnable <= `RegWriteAccept;
                dataCacheControl <= `DataCacheNOP;
            end
            default: begin // `Opcode_Type_B_CB in here
                ALUop <= `ALUopReset;
                regWriteEnable <= `RegWriteDeny;
                dataCacheControl <= `DataCacheNOP;
            end
        endcase
    end
end

endmodule