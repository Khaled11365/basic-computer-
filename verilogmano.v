// ==================== Memory Module ====================
module Memory(
    input [7:0] address,
    input [15:0] data_in,
    input write_enable,
    output reg [15:0] data_out
);
    reg [15:0] mem [0:255];

    initial begin
        $readmemh("C:\\Users\\aldawlia\\Downloads\\mem_data.txt", mem);
    end

    always @(*) begin
        data_out = mem[address];
    end

    always @(posedge write_enable) begin
        mem[address] <= data_in;
    end
endmodule

// ==================== Control Unit Module ====================
module ControlUnit(
    input clk,
    output reg [3:0] timeCount
);
    initial timeCount = 0;

    always @(posedge clk) begin
        timeCount <= timeCount + 1;
    end
endmodule

// ==================== Datapath Module ====================
module Datapath(
    input clk,
    input [15:0] mem_data,
    input [3:0] timeCount,
    output reg [15:0] IR, TR, DR, AC,
    output reg [11:0] PC, AR,
    output reg I, E,
    output reg halt
);
    initial begin
        IR = 0; TR = 0; DR = 0; AC = 0;
        PC = 0; AR = 0;
        I = 0; E = 0; halt = 0;
    end

    always @(posedge clk) begin
        if (halt) begin
            // halted
        end else if (timeCount == 0) begin
            AR <= PC;
        end else if (timeCount == 1) begin
            IR <= mem_data;
            PC <= PC + 1;
        end else if (timeCount == 2) begin
            AR <= IR[11:0];
            I <= IR[15];
        end
        // ... add rest of control logic from your behavioral model here
    end
endmodule

// ==================== Top-Level Module ====================
module BasicComputer(
    output [15:0] IR, TR, DR, AC,
    output [11:0] PC, AR,
    input clk,
    output [3:0] timeCount
);

    wire [15:0] mem_out;
    wire [7:0] mem_address;
    wire mem_write_enable;
    wire [15:0] mem_data_in;
    wire I, E, halt;

    ControlUnit CU(clk, timeCount);

    Memory MEM(
        .address(AR[7:0]),
        .data_in(mem_data_in),
        .write_enable(mem_write_enable),
        .data_out(mem_out)
    );

    Datapath DP(
        .clk(clk),
        .mem_data(mem_out),
        .timeCount(timeCount),
        .IR(IR), .TR(TR), .DR(DR), .AC(AC),
        .PC(PC), .AR(AR),
        .I(I), .E(E), .halt(halt)
    );
endmodule
