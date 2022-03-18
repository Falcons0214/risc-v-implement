`include "define.v"

module register(
    // from decoder
    input wire [`RegAddrSize]readAddrF, // rs1
    input wire [`RegAddrSize]readAddrS, // rs2
    input wire [`RegAddrSize]writeAddr, // rd
    
    // from WB
    input wire writeEnable,
    input wire [`DataSize]writeDate,
    
    // to Dec_ALU
    output reg [`DataSize]outDataF,
    output reg [`DataSize]outDataS
);

reg [`DataSize] regs[`RegFileSize];

always @(*) begin
    if (writeEnable) begin
        regs[writeAddr] <= writeDate;
    end
    else begin
        regs[writeAddr] <= regs[writeAddr];
    end
    outDataF <= regs[readAddrF];
    outDataS <= regs[readAddrS];
end

endmodule

// module test;

// reg [4:0] read1;
// reg [4:0] read2;
// reg [4:0] write1;
// reg [31:0] data;
// reg writeEn;
// wire [31:0] out1;
// wire [31:0] out2;

// initial begin
// $readmemb("./data", reg1.regs);
// // $monitor("time %4d, : %b, : %b, : %b", $stime, );
// // $display("time %4d, ", $stime, );
// read1 = 5'b01000;
// read2 = 5'b01001;
// write1 = 5'b01000;
// data = 32'd0;
// writeEn = 0;

// #10
// $display("time %4d, out1 %b, out2 %b, writeEn: %b", $stime, out1, out2, writeEn);

// read1 = 5'b01000;
// writeEn = 1;

// #100
// $display("time %4d, out1 %b, out2 %b, writeEn: %b", $stime, out1, out2, writeEn);

// #10 $finish;
// end

// register reg1(
//     .readAddrF(read1),
//     .readAddrS(read2),
//     .writeEnable(writeEn),
//     .writeAddr(write1),
//     .writeDate(data),
//     .outDataF(out1),
//     .outDataS(out2)
// );

// endmodule