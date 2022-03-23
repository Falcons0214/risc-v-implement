`include "define.v"

module forward(
    // from DC_ALU
    input wire [`RegAddrSize] addr1,
    input wire [`RegAddrSize] addr2,
    
    // from ALU_MEM
    input wire [`RegAddrSize] preAddr_ALU_MEM,
    
    // from MEM_WB
    input wire [`RegAddrSize] preAddr_MEM_WB,

    output reg [`ALUMuxSelectBus] select1,
    output reg [`ALUMuxSelectBus] select2
);

always @(*) begin
    if (addr1 == preAddr_ALU_MEM) begin
        select1 <= `ALUMuxDataFromALU_MEM;
    end
    else if (addr1 == preAddr_MEM_WB) begin
        select1 <= `ALUMuxDataFromMEM_WB;
    end
    else begin
        select1 <= `ALUMuxDataFromReg;
    end
    if (addr2 == preAddr_ALU_MEM) begin
        select2 <= `ALUMuxDataFromALU_MEM;
    end
    else if (addr2 == preAddr_MEM_WB) begin
        select2 <= `ALUMuxDataFromMEM_WB;
    end
    else begin
        select2 <= `ALUMuxDataFromReg;
    end
end

endmodule