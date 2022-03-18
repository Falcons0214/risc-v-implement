`include "define.v"

module decoder( 
    // from IF_ID
    input wire [`DataSize]inst,

    // to register file
    output reg [`RegAddrSize]readAddr1, 
    output reg [`RegAddrSize]readAddr2,
    output reg [`RegAddrSize]writeAddr,
    
    // to Dec_ALU
    output reg regWriteEnable,

    // to control unit
    output reg [`OpcodeSize] OutOpcode,
    output reg [`Func3Size] OutFunc3,
    output reg [`Func7Size] OutFunc7,
    
    // sign extend
    output reg [`DataSize] immValue
);

wire [6:0] opCode = inst[6:0];
wire [4:0] rd = inst[11:7];
wire [2:0] func3 = inst[14:12];
wire [4:0] rs1 = inst[19:15];
wire [4:0] rs2 = inst[24:20];
wire [6:0] func7 = inst[31:25];

always @(*) begin
    case (opCode)
        `Opcode_Type_I_Imm: begin 
            readAddr1 <= rs1;
            readAddr2 <= `RegAddrReset;
            regWriteEnable <= `RegWriteAccept;
            writeAddr <= rd;
            OutOpcode <= opCode;
            OutFunc3 <= func3;
            OutFunc7 <= func7;
            immValue <= {{20{inst[31]}}, inst[31:20]}; // sign extend
        end
        `Opcode_Type_I_Load: begin
            readAddr1 <= rs1;
            readAddr2 <= `RegAddrReset;
            regWriteEnable <= `RegWriteAccept;
            writeAddr <= rd;
            OutOpcode <= opCode;
            OutFunc3 <= func3;
            OutFunc7 <= func7;
            immValue <= {{20{inst[31]}}, inst[31:20]};
        end
        default: begin
            readAddr1 <= `RegAddrReset;
            readAddr2 <= `RegAddrReset;
            regWriteEnable <= `RegWriteDeny;
            writeAddr <= `RegAddrReset;
            OutOpcode <= `NOP;
            OutFunc3 <= func3;
            OutFunc7 <= func7;
            immValue <= `DataBusReset;
        end
    endcase
end 

endmodule

module controlUnit(
    // from decoder
    input wire [`OpcodeSize] opcode,
    input wire [`Func3Size] opFunc3,
    input wire [`Func7Size] opFunc7,

    // to Dec_ALU
    output reg [`ALUControlBus] ALUop
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
        end
        `Opcode_Type_I_Load: begin
            case (opFunc3)
                `LW: begin
                    ALUop <= `ALUop_ADD;
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

endmodule