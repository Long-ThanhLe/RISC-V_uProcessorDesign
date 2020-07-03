`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/03/2020 12:00:25 PM
// Design Name: 
// Module Name: pipeline_3_stage
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


module pipeline_3_stage();



reg clk;
wire [31:0] pc_in;
wire [2:0] pc_sel;


/*

    Fetch stage

*/
mux8 PCmux(
    .in0(),
    .in1(),
    .in2(),
    .in3(),
    .in4(),
    .in5(),
    .in6(),
    .in7(),
    .sel(),
    .out()
);

regs PC(
    .in(),
    .out(),
    .clk()
);

mux 

// pipeline reg
always @(posedge clk)
begin


end

always @(*) begin
    clk = 0;
    #10;
    clk = 1;
    #10;
end


/*
    Initial 
*/
initial begin

    
end

endmodule
