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
wire [2:0] func3 = inst[14:12];
// wire [4:0] rd = inst[11:7];
// wire [4:0] rs1 = inst[19:15];
// wire [`immValueBus] immV = inst[31:20];

always @(*) begin
    OutOpcode <= opCode;
    OutFunc3 <= func3;
    if (opCode == `Opcode_Type_I_Imm ||
        opCode == `Opcode_Type_I_Load ||
        opCode == `Opcode_Type_R_RRop) begin
        readAddr1 <= inst[19:15]; // rs1, load base addr
        readAddr2 <= inst[24:20]; // rs2
        writeAddr <= inst[11:7]; // rd, dest
        immValue <= inst[31:20]; // imm, offset
    end
    else if (opCode == `Opcode_Type_R_Store) begin
        readAddr1 <= inst[19:15]; // base addr
        readAddr2 <= inst[24:20]; // rs2, src
        writeAddr <= `RegAddrReset;
        immValue <= {inst[31:25], inst[11:7]}; // offset
    end
    else begin
        readAddr1 <= `RegAddrReset;
        readAddr2 <= `RegAddrReset;
        writeAddr <= `RegAddrReset;
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
            immValueOut <= {{20{immValueIn[11]}}, immValueIn[11:0]};
        end
        `Opcode_Type_I_Load: begin
            case (opFunc3) // decide sign extend width
                `LW: begin // 32bit
                    ALUop <= `ALUop_ADDI;
                    immValueOut <= {{20{immValueIn[11]}}, immValueIn[11:0]};
                end
                default: begin
                    ALUop <= `ALUopReset;
                    immValueOut <= immValueIn;
                end
            endcase
            regWriteEnable <= `RegWriteAccept;
            dataCacheControl <= `DataCacheRead;
        end
        `Opcode_Type_R_Store: begin
            case (opFunc3) // same as Load
                `SW: begin // 32bits
                    ALUop <= `ALUop_ADDI;
                    immValueOut <= {{20{immValueIn[11]}}, immValueIn[11:0]};
                end
                default: begin
                    ALUop <= `ALUopReset;
                    immValueOut <= immValueIn;
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
            immValueOut <= immValueIn;
            regWriteEnable <= `RegWriteAccept;
            dataCacheControl <= `DataCacheNOP;
        end
        default: begin
            ALUop <= `ALUopReset;
            immValueOut <= immValueIn;
            regWriteEnable <= `RegWriteDeny;
            dataCacheControl <= `DataCacheNOP;
        end
    endcase
end

endmodule