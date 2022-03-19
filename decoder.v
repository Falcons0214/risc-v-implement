`include "define.v"

module decoder( 
    // from IF_ID
    input wire [`DataSize]inst,

    // to register file
    output reg [`RegAddrSize]readAddr1, 
    output reg [`RegAddrSize]readAddr2,
    output reg [`RegAddrSize]writeAddr,

    // to control unit
    output reg [`OpcodeSize] OutOpcode,
    output reg [`Func3Size] OutFunc3,
    output reg [`immValueBus] immValue
);

wire [6:0] opCode = inst[6:0];
wire [4:0] rd = inst[11:7];
wire [2:0] func3 = inst[14:12];
wire [4:0] rs1 = inst[19:15];
wire [`immValueBus] immV = inst[31:20]; // [11:5]: func7 + [4:0]: rs2

always @(*) begin
    if (opCode == `Opcode_Type_I_Imm ||
        opCode == `Opcode_Type_I_Load) begin
        readAddr1 <= rs1;
        readAddr2 <= `RegAddrReset;
        writeAddr <= rd;
        OutOpcode <= opCode;
        OutFunc3 <= func3;
        immValue <= immV;
    end    
    else begin
        readAddr1 <= `RegAddrReset;
        readAddr2 <= `RegAddrReset;
        writeAddr <= `RegAddrReset;
        OutOpcode <= `NOP;
        OutFunc3 <= func3;
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
    output reg dataCacheReadEnable,
    output reg regWriteEnable

);

always @(*) begin
    case (opcode)
        `Opcode_Type_I_Imm: begin
            case (opFunc3)
                `ORI: begin
                    ALUop <= `ALUop_OR;
                end
                default: begin
                    ALUop <= `ALUopReset;
                end
            endcase
            regWriteEnable <= `RegWriteAccept;
            dataCacheReadEnable <= `DataCacheReadDeny;
            immValueOut <= {{20{immValueIn[11]}}, immValueIn[11:0]};
        end
        `Opcode_Type_I_Load: begin
            case (opFunc3) // decide sign extend width
                `LW: begin // 32bit
                    ALUop <= `ALUop_ADD;
                    immValueOut <= {{20{immValueIn[11]}}, immValueIn[11:0]};
                end
                default: begin
                    ALUop <= `ALUopReset;
                    immValueOut <= immValueIn;
                end
            endcase
            regWriteEnable <= `RegWriteAccept;
            dataCacheReadEnable <= `DataCacheReadAccept;
        end
        default: begin
            ALUop <= `ALUopReset;
            immValueOut <= immValueIn;
            regWriteEnable <= `RegWriteDeny;
            dataCacheReadEnable <= `DataCacheReadDeny;
        end
    endcase
end

endmodule