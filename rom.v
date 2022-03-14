`include "define.v"

module rom(
    // from Hazard detect unit
    input wire flush,
    
    // from PC loader
    input wire [`RomAddr]addr,

    // to IF_ID
    output reg [`DataSize]inst
);

reg [`RomUnitSize] rom[63:0]; // 64 unit, per unit 32 bits 

always @(*) begin
    if (flush) begin
        inst <= `DataBusReset;
    end
    else begin
        inst <= rom[addr];
    end
end

endmodule

// module test;

// reg f;
// reg [5:0] addr;
// wire [31:0] data;

// initial begin
// $readmemb("./data", rom1.mem);
// $monitor("time %4d, flush: %b, addr: %b, data: %b", $stime, f, addr, data);

// f = 0;
// addr = 6'b10;

// #10 f = 1;
// #10 addr = 6'b1;
// #10 f = 0;

// #10 $finish;
// end

// rom rom1(
//     .flush(f),
//     .addr(addr),
//     .inst(data)
// );

// endmodule
