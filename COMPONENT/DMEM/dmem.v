`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2020 09:45:53 AM
// Design Name: 
// Module Name: dmem
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


module dmem(
    addr,
    dataw,
    datar,
    Wen,
    RSel,
    WSel,
    clk
    );
    
input [31:0] addr, dataw;
input [1:0] WSel;
input [2:0] RSel;

input Wen, clk;
output [31:0] datar;

reg [31:0] datar;
reg [31:0] MEM [1 << 11 : 0];
reg [31:0] Rword, Wword;
integer i;

initial begin
    datar <= 32'd0;
    for (i = 0; i < 1 << 11; i = i +1)
    MEM[i] = 32'd0;
end

always @(*)
begin
    case (Wen)
    1'b0: // Read
    begin
    case (RSel)
        3'd0: // Word 
            datar = MEM[addr[12:2]];
        3'd1: // Halfword
            case (addr[1])
            1'b0:
                datar = ((MEM[addr[12:2]] & 32'h0000ffff) << 16) >>> 16;
            1'b1:
                datar = (MEM[addr[12:2]] & 32'hffff0000 ) >>> 16 ;
            endcase
        3'd2: // Byte 
            case (addr[1:0])
            2'd0: datar = ((MEM[addr[12:2]] & 32'h000000ff ) << 24) >>> 24;
            2'd1: datar = ((MEM[addr[12:2]] & 32'h0000ff00 ) << 16) >>> 24;
            2'd2: datar = ((MEM[addr[12:2]] & 32'h00ff0000 ) << 8 ) >>> 24;
            2'd3: datar = ((MEM[addr[12:2]] & 32'hff000000 ) << 0 ) >>> 24;
            endcase
        3'd3: //Unsigned Halfword
                case (addr[1])
                1'b0:
                    datar = MEM[addr[12:2]] & 32'h0000ffff;
                1'b1:
                    datar = (MEM[addr[12:2]] & 32'hffff0000 ) >> 16 ;
                endcase
        3'd4: //Unsigned Byte 
            case (addr[1:0])
            2'd0: datar = (MEM[addr[12:2]] & 32'h000000ff );
            2'd1: datar = (MEM[addr[12:2]] & 32'h0000ff00 ) >> 8;
            2'd2: datar = (MEM[addr[12:2]] & 32'h00ff0000 ) >> 16;
            2'd3: datar = (MEM[addr[12:2]] & 32'hff000000 ) >> 24;
            endcase
        endcase
    end
    1'b1: // Write
    begin
    end
    endcase
end

always @(posedge clk)
begin
    case (Wen)
    1'b0: // Read
    begin
    end
    1'b1: // Write
    begin
        case (WSel)
        2'd0: // Word 
            MEM[addr[12:2]] <= dataw[31:0];
        2'd1: // Halfword
            case (addr[1])
            1'b0:
                MEM[addr[12:2]] <= (MEM[addr[12:2]] & 32'hffff0000 ) | (dataw[31:0] & 32'h0000ffff);
            1'b1:
                MEM[addr[12:2]] <= (MEM[addr[12:2]] & 32'h0000ffff ) | (dataw[31:0] << 16);
            endcase
        2'd2: // Byte 
            case (addr[1:0])
            2'd0: MEM[addr[12:2]] <= (MEM[addr[12:2]] & 32'hffffff00 ) | (dataw[31:0] & 32'h000000ff);
            2'd1: MEM[addr[12:2]] <= (MEM[addr[12:2]] & 32'hffff00ff ) | ((dataw[31:0] & 32'h000000ff) << 8) ;
            2'd2: MEM[addr[12:2]] <= (MEM[addr[12:2]] & 32'hff00ffff ) | ((dataw[31:0] & 32'h000000ff) << 16) ;
            2'd3: MEM[addr[12:2]] <= (MEM[addr[12:2]] & 32'h00ffffff ) | ((dataw[31:0] & 32'h000000ff) << 24) ;
            endcase
        endcase
    end
    endcase
end
endmodule
