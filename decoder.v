`include "define.v"

module decoder( 
    // from IF_ID
    input wire resetIn,
    input wire [`DataSize]inst,

    // to register file
    output reg [`RegAddrSize]readAddr1,
    output reg [`RegAddrSize]readAddr2,
    output reg [`RegAddrSize]writeAddr,
    
    // to Dec_ALU
    output reg resetOut,
    output reg writeEnable,
    output reg [`OpcodeSize] ALUopcode,
    output reg [`Func3Size] ALUFunc3,
    output reg [`Func7Size] ALUFunc7,
    
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
    if (resetIn) begin
        resetOut <= 1'b1;
        readAddr1 <= `RegAddrReset;
        readAddr2 <= `RegAddrReset;
        writeEnable <= `RegWriteDeny;
        writeAddr <= `RegAddrReset;
        ALUopcode <= `NOP;
        ALUFunc3 <= func3;
        ALUFunc7 <= func7;
        immValue <= `DataBusReset;
    end
    else begin
        resetOut <= 1'b0;
        case (opCode)
            `Opcode_Type_I: begin 
                case (func3)
                    `ORI: begin
                        readAddr1 <= rs1;
                        readAddr2 <= `RegAddrReset;
                        writeEnable <= `RegWriteAccept;
                        writeAddr <= rd;
                        ALUopcode <= opCode;
                        ALUFunc3 <= func3;
                        ALUFunc7 <= func7;
                        immValue <= {{20{inst[31]}}, inst[31:20]};
                    end
                    default: begin
                        readAddr1 <= `RegAddrReset;
                        readAddr2 <= `RegAddrReset;
                        writeEnable <= `RegWriteDeny;
                        writeAddr <= `RegAddrReset;
                        ALUopcode <= `NOP;
                        ALUFunc3 <= func3;
                        ALUFunc7 <= func7;
                        immValue <= `DataBusReset;
                    end
                endcase 
            end
            default: begin
                readAddr1 <= `RegAddrReset;
                readAddr2 <= `RegAddrReset;
                writeEnable <= `RegWriteDeny;
                writeAddr <= `RegAddrReset;
                ALUopcode <= `NOP;
                ALUFunc3 <= func3;
                ALUFunc7 <= func7;
                immValue <= `DataBusReset;
            end
        endcase
    end
end 

endmodule