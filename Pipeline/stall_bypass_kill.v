`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/28/2020 03:34:40 PM
// Design Name: 
// Module Name: stall
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module stall_bypass_kill(
    clk,
    instF,
    instD,
    instE,
    instM, 
    instW,
    stall,
    kill_branch_1,
    kill_branch_2,
    alumux1,
    alumux2,
    ASrc,
    BSrc
    );
input clk, alumux1, alumux2;
input [31:0] instF, instD, instE, instM, instW;
output reg [1:0] ASrc, BSrc;
output reg stall, kill_branch_1, kill_branch_2;



wire stall_load, stall_add_addi, stall_branch, stall_jump, stall_total;
wire bypassA, bypassB;

wire we_bypassD, we_stallD, re1D, re2D;
wire we_bypassE, we_stallE, re1E, re2E;
wire we_bypassM, we_stallM, re1M, re2M;
wire we_bypassW, we_stallW, re1W, re2W;

wire [4:0] wsD, rs1D, rs2D; 
wire [4:0] wsE, rs1E, rs2E;
wire [4:0] wsM, rs1M, rs2M;
wire [4:0] wsW, rs1W, rs2W;

stall_bypass stall_bypass()


always @(posedge clk)
begin
    stall_pre <= stall;
    stall_pre_2 <= stall_pre;
end
initial begin
    stall = 1'b0;
    done_stall = 1'b0;
end
endmodule
