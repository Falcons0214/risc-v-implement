`include "define.v"
`include "pcLoader.v"
`include "rom.v"

module test;

reg clk;
reg enable;
reg select;
reg reset;
reg flush;
reg [`MemAddr]in;
reg [`MemAddr]j;
wire [`MemAddr]out; // output from pc load in rom
wire [`DataSize] data; // output from rom 

initial begin
$readmemb("./data", rom1.mem);
$monitor("Time: %4d, clk: %b, out: %b, data: %b, reset: %b", $stime, clk, out, data, reset);

clk = 0;
enable = 1;
select = 0;
reset = 0;
flush = 0;

in = 6'b1;
j = 6'b1;

#10;
reset = 1;

#20
reset = 0;

#180 $finish;
end

always begin
    #10 clk = ~clk;
end

pcLoader pc1(
    .clk(clk),
    .reset(reset),
    .enable(enable),
    .select(select),
    .addrIn(in),
    .addrJump(j),
    .addrOut(out)
);

rom rom1(
    .flush(flush),
    .addr(out),
    .inst(data)
);

endmodule