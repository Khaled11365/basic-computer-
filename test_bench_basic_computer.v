`timescale 1ns/1ps

module tb_BasicComputer;
    reg clk = 0, reset;
    reg [7:0] INPR;
    wire [7:0] OUTR, AC, IR;
    wire [3:0] PC, AR;
    wire       halt;

    BasicComputer_Top DUT(
        .clk(clk), .reset(reset), .INPR(INPR),
        .OUTR(OUTR), .AC(AC), .IR(IR), .PC(PC), .AR(AR), .halt(halt)
    );

    always #2.5 clk = ~clk;

    initial begin
        $display("=== Simulation Start ===");
        $readmemh("mem_data2.txt", DUT.mem_inst.mem);
        INPR = 8'h0F;
        reset = 1; #10; reset = 0;
        #1000;
        $display("=== Simulation End ===");
        $stop;
    end
endmodule
