`timescale 1ns/1ps

///////////////////////////////////////////////////////////////
// Module: Memory
///////////////////////////////////////////////////////////////
module Memory(
    input         clk,
    input         we,   //  write enable signal 
    input  [3:0]  addr, // scaled sized of address register 
    input  [7:0]  data_in, // scaled size from the what real done in mano's project of the data transfering 
    output [7:0]  data_out
);
    reg [7:0] mem [0:15]; // declaring a memory array named mem and we storing the instructions and operand inside it 

    initial begin  // initialization of that we need to read the data from the memory array that we created in txt file
        $readmemh("mem_data2.txt", mem);
        $display("Memory Loaded: mem[0]=%h, mem[1]=%h", mem[0], mem[1]);
    end

    always @(posedge clk) begin
        if (we)
            mem[addr] <= data_in;
    end

    assign data_out = mem[addr];
endmodule

///////////////////////////////////////////////////////////////
// Module: ALU
///////////////////////////////////////////////////////////////
module ALU(
    input  [7:0] AC,
    input  [7:0] DR,
    input  [2:0] op,
    output reg [7:0] result,
    output reg       E_out
);
    always @(*) begin
        case (op)
            3'b000: begin result = AC & DR; E_out = 0; end  // AND
            3'b001: {E_out, result} = AC + DR;              // ADD
            3'b010: begin result = DR; E_out = 0; end       // LDA
            3'b011: begin result = 8'b0; E_out = 0; end     // CLA
            default: begin result = 8'b0; E_out = 0; end
        endcase
    end
endmodule

///////////////////////////////////////////////////////////////
// Module: Control Unit
///////////////////////////////////////////////////////////////
module ControlUnit(
    input        clk,
    input        reset,
    input  [7:0] IR,
    output reg [3:0] SC,
    output reg       halt,
    output reg [2:0] alu_op,
    output reg       mem_we,
    output reg       update_pc,
    output reg       update_ar,
    output reg       load_DR,
    output reg       load_AC
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            SC <= 4'd0;
        else
            SC <= SC + 1;
    end

    always @(*) begin
        // Default signals
        halt = 0; alu_op = 0; mem_we = 0;
        update_pc = 0; update_ar = 0;
        load_DR = 0; load_AC = 0;

        case (SC)
            4'd0: update_ar = 1;
            4'd1: update_pc = 1;
            4'd2: begin update_ar = 1; alu_op = IR[6:4]; end
            4'd3: begin
                case (IR[6:4])
                    3'b000, 3'b001, 3'b010: load_DR = 1;   // AND, ADD, LDA
                    3'b011: mem_we = 1;                    // STA
                    3'b111: case (IR[3:0])
                        4'b1000: begin load_AC = 1; alu_op = 3'b011; end // CLA
                        4'b0011: begin load_AC = 1; alu_op = 3'b010; end // INC as LDA + 1
                        4'b0111: halt = 1;                                  // HLT
                    endcase
                endcase
            end
            4'd4: if (IR[6:4] <= 3'b010) begin load_AC = 1; alu_op = IR[6:4]; end
        endcase
    end
endmodule

///////////////////////////////////////////////////////////////
// Module: IO Unit
///////////////////////////////////////////////////////////////
module IOUnit(
    input  [7:0] INPR,
    input  [7:0] AC,
    input        io_sel,
    output reg [7:0] OUTR
);
    always @(*) begin
        OUTR = io_sel ? INPR : AC;
    end
endmodule

///////////////////////////////////////////////////////////////
// Module: Top-Level Basic Computer
///////////////////////////////////////////////////////////////
module BasicComputer_Top(
    input         clk,
    input         reset,
    input  [7:0]  INPR,
    output [7:0]  OUTR,
    output [7:0]  AC,
    output [7:0]  IR,
    output [3:0]  PC,
    output [3:0]  AR,
    output        halt
);
    reg [7:0] reg_IR = 0, reg_DR = 0, reg_AC = 0;
    reg [3:0] reg_PC = 0, reg_AR = 0;

    wire [7:0] mem_data_out, alu_result;
    wire [2:0] alu_op;
    wire       mem_we, update_pc, update_ar;
    wire       load_DR, load_AC, ctrl_halt;
    wire [3:0] SC;
    wire       E_out;

    Memory mem_inst(
        .clk(clk), .we(mem_we), .addr(reg_AR),
        .data_in(reg_AC), .data_out(mem_data_out)
    );

    ALU alu_inst(
        .AC(reg_AC), .DR(reg_DR), .op(alu_op),
        .result(alu_result), .E_out(E_out)
    );

    ControlUnit ctrl_inst(
        .clk(clk), .reset(reset), .IR(reg_IR), .SC(SC),
        .halt(ctrl_halt), .alu_op(alu_op), .mem_we(mem_we),
        .update_pc(update_pc), .update_ar(update_ar),
        .load_DR(load_DR), .load_AC(load_AC)
    );

    IOUnit io_inst(
        .INPR(INPR), .AC(reg_AC), .io_sel(1'b0), .OUTR(OUTR)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_PC <= 0; reg_IR <= 0; reg_DR <= 0;
            reg_AC <= 0; reg_AR <= 0;
        end else begin
            case (SC)
                4'd0: if (update_ar) reg_AR <= reg_PC;
                4'd1: if (update_pc) begin reg_IR <= mem_data_out; reg_PC <= reg_PC + 1; end
                4'd2: if (update_ar) reg_AR <= reg_IR[3:0];
                4'd3: begin
                    if (load_DR) reg_DR <= mem_data_out;
                    else if (reg_IR == 8'hF8) reg_AC <= INPR;
                    else if (reg_IR[6:4] == 3'b111 && reg_IR[3:0] == 4'b0011)
                        reg_AC <= reg_AC + 1;
                end
                4'd4: if (load_AC) reg_AC <= alu_result;
            endcase
        end
    end

    assign AC = reg_AC;
    assign IR = reg_IR;
    assign PC = reg_PC;
    assign AR = reg_AR;
    assign halt = ctrl_halt;

    always @(posedge clk) begin
        $display("[Time=%0t] SC=%d IR=%h PC=%d AR=%d AC=%h DR=%h ALU_OP=%b HALT=%b",
            $time, SC, reg_IR, reg_PC, reg_AR, reg_AC, reg_DR, alu_op, ctrl_halt);
    end
endmodule
