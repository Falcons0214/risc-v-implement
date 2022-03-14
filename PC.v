`include "define.v"

module PC(
    input wire clk,
    input wire resetIn,
    input wire enable, 
    input wire select, // 1: jump, 0: next
    input wire [`RomAddr] addrIn,
    input wire [`RomAddr] addrJump,
    
    // to rom
    output reg resetOut,
    output reg [`RomAddr] addrOut 
);

always @(posedge clk) begin
    if (resetIn) begin
        addrOut <= `RomAddrReset;
        resetOut <= 1'b1;
    end
    else begin
        resetOut <= 1'b0;
        if (enable) begin
            if (select) begin
                addrOut <= addrJump;
            end
            else begin
                addrOut <= addrOut + 2'b10;
            end
        end
        else begin
            addrOut <= addrOut;
        end
    end
end

endmodule

// module test;

// reg clock, re, enable, select;
// reg [5:0]addrF;
// reg [5:0]jump;
// wire [5:0] addrT;

// initial begin
//     $monitor("time %4d, clock: %b, reset: %b, addr: %b, enable: %d", $stime, clock, re, addrT, enable);
//     clock = 0;
//     re = 0;
//     enable = 1;
//     jump = 6'b100;
//     addrF = 6'b0;
//     select = 0;

//     #10 re = 1;
//     #30 re = 0;
//     #10 select = 1;
//     // #50 re = 0;
//     #10 select = 0;
//     #50 $finish;
// end

// always begin
//     #10 clock = ~clock;
// end 

// pcLoader pc1(
//     .clk(clock),
//     .reset(re),
//     .enable(enable),
//     .select(select),
//     .addrIn(addrF),
//     .addrJump(jump),
//     .addrOut(addrT)
// );

// endmodule
