`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2020 09:01:15 AM
// Design Name: 
// Module Name: regs
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


module regs(
    data_D,
    addr_D,
    addr_A,
    addr_B,
    Wen,
    clk,
    data_A,
    data_B
    );
    
input [31:0] data_D;
input [4:0] addr_D, addr_A, addr_B;
input Wen, clk;
output [31:0] data_A, data_B;
reg [31:0] data_A, data_B;
reg [31:0] reg_file [31:0];

integer i;

always @(*)
begin
    case (addr_A)
        5'd00: data_A <= reg_file[00];
        5'd01: data_A <= reg_file[01];
        5'd02: data_A <= reg_file[02];
        5'd03: data_A <= reg_file[03];
        5'd04: data_A <= reg_file[04];
        5'd05: data_A <= reg_file[05];
        5'd06: data_A <= reg_file[06];
        5'd07: data_A <= reg_file[07];
        5'd08: data_A <= reg_file[08];
        5'd09: data_A <= reg_file[09];
        5'd10: data_A <= reg_file[10];
        5'd11: data_A <= reg_file[11];
        5'd12: data_A <= reg_file[12];
        5'd13: data_A <= reg_file[13];
        5'd14: data_A <= reg_file[14];
        5'd15: data_A <= reg_file[15];
        5'd16: data_A <= reg_file[16];
        5'd17: data_A <= reg_file[17];
        5'd18: data_A <= reg_file[18];
        5'd19: data_A <= reg_file[19];
        5'd20: data_A <= reg_file[20];
        5'd21: data_A <= reg_file[21];
        5'd22: data_A <= reg_file[22];
        5'd23: data_A <= reg_file[23];
        5'd24: data_A <= reg_file[24];
        5'd25: data_A <= reg_file[25];
        5'd26: data_A <= reg_file[26];
        5'd27: data_A <= reg_file[27];
        5'd28: data_A <= reg_file[28];
        5'd29: data_A <= reg_file[29];
        5'd30: data_A <= reg_file[30];
        5'd31: data_A <= reg_file[31];
    endcase
    case (addr_B)
        5'd00: data_B <= reg_file[00];
        5'd01: data_B <= reg_file[01];
        5'd02: data_B <= reg_file[02];
        5'd03: data_B <= reg_file[03];
        5'd04: data_B <= reg_file[04];
        5'd05: data_B <= reg_file[05];
        5'd06: data_B <= reg_file[06];
        5'd07: data_B <= reg_file[07];
        5'd08: data_B <= reg_file[08];
        5'd09: data_B <= reg_file[09];
        5'd10: data_B <= reg_file[10];
        5'd11: data_B <= reg_file[11];
        5'd12: data_B <= reg_file[12];
        5'd13: data_B <= reg_file[13];
        5'd14: data_B <= reg_file[14];
        5'd15: data_B <= reg_file[15];
        5'd16: data_B <= reg_file[16];
        5'd17: data_B <= reg_file[17];
        5'd18: data_B <= reg_file[18];
        5'd19: data_B <= reg_file[19];
        5'd20: data_B <= reg_file[20];
        5'd21: data_B <= reg_file[21];
        5'd22: data_B <= reg_file[22];
        5'd23: data_B <= reg_file[23];
        5'd24: data_B <= reg_file[24];
        5'd25: data_B <= reg_file[25];
        5'd26: data_B <= reg_file[26];
        5'd27: data_B <= reg_file[27];
        5'd28: data_B <= reg_file[28];
        5'd29: data_B <= reg_file[29];
        5'd30: data_B <= reg_file[30];
        5'd31: data_B <= reg_file[31];
    endcase
end

always @(posedge clk)
begin
    if (Wen == 1'b1)
        begin
            case (addr_D)
                5'd00: reg_file[00]  <= 32'd0; 
                5'd01: reg_file[01]  <= data_D[31:0]; 
                5'd02: reg_file[02]  <= data_D[31:0]; 
                5'd03: reg_file[03]  <= data_D[31:0]; 
                5'd04: reg_file[04]  <= data_D[31:0]; 
                5'd05: reg_file[05]  <= data_D[31:0]; 
                5'd06: reg_file[06]  <= data_D[31:0]; 
                5'd07: reg_file[07]  <= data_D[31:0]; 
                5'd08: reg_file[08]  <= data_D[31:0]; 
                5'd09: reg_file[09]  <= data_D[31:0]; 
                5'd10: reg_file[10]  <= data_D[31:0]; 
                5'd11: reg_file[11]  <= data_D[31:0]; 
                5'd12: reg_file[12]  <= data_D[31:0]; 
                5'd13: reg_file[13]  <= data_D[31:0]; 
                5'd14: reg_file[14]  <= data_D[31:0]; 
                5'd15: reg_file[15]  <= data_D[31:0]; 
                5'd16: reg_file[16]  <= data_D[31:0]; 
                5'd17: reg_file[17]  <= data_D[31:0]; 
                5'd18: reg_file[18]  <= data_D[31:0]; 
                5'd19: reg_file[19]  <= data_D[31:0]; 
                5'd20: reg_file[20]  <= data_D[31:0]; 
                5'd21: reg_file[21]  <= data_D[31:0]; 
                5'd22: reg_file[22]  <= data_D[31:0]; 
                5'd23: reg_file[23]  <= data_D[31:0]; 
                5'd24: reg_file[24]  <= data_D[31:0]; 
                5'd25: reg_file[25]  <= data_D[31:0]; 
                5'd26: reg_file[26]  <= data_D[31:0]; 
                5'd27: reg_file[27]  <= data_D[31:0]; 
                5'd28: reg_file[28]  <= data_D[31:0]; 
                5'd29: reg_file[29]  <= data_D[31:0]; 
                5'd30: reg_file[30]  <= data_D[31:0]; 
                5'd31: reg_file[31]  <= data_D[31:0]; 
            endcase
        end
end

initial begin
    for (i = 0; i <32; i = i + 1)
    begin
        reg_file[i] = 32'd0;
    end
end
endmodule
