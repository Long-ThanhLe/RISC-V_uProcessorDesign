`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/29/2020 05:23:19 PM
// Design Name: 
// Module Name: kill
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


module kill(
    instF,
    instD,
    instX,
    instM,
    instW,
    predict_fail,
    killF_next,
    killD_next,
    killX_next,
    killM_next,
    killW_next,
    kill_en_next,
    in_killF,
    in_killD,
    in_killX,
    in_killM,
    in_killW
    );

input [31:0] instF, instD, instX, instM, instW;
output reg killF_next, killD_next, killX_next, killM_next, killW_next, kill_en_next;
input predict_fail, in_killD, in_killF, in_killM, in_killX, in_killW;

parameter JAL_TYPE = 5'b11011;
parameter JALR_TYPE = 5'b11001;
parameter B_TYPE = 5'b11000;

always @(*)
begin
    if (in_killX == 1'b1)  begin // X stage invalid
        if (in_killD == 1'b1) begin // D stage invalid
            kill_en_next = 1'b0;
        end else begin
            case (instD[6:2])
                // JAL_TYPE: begin
                //     kill_en_next = 1'b1;
                //     killF_next = 1'b0;
                //     killD_next = 1'b1;
                //     killX_next = in_killD;
                //     killM_next = in_killX;
                //     killW_next = in_killM;
                // end
                default: kill_en_next = 1'b0;
            endcase
        end
    end else begin // X stage valid
        case (instX[6:2])
            // JALR_TYPE: begin // kill
            //     kill_en_next = 1'b1;
            //     killF_next = 1'b0;
            //     killD_next = 1'b1;
            //     killX_next = 1'b1;
            //     killM_next = in_killX;
            //     killW_next = in_killM;
            // end
            B_TYPE: begin // can kill
                if (predict_fail == 1'b1) begin // Predict fail, kill 2
                    kill_en_next = 1'b1;
                    killF_next = 1'b0;
                    killD_next = 1'b1;
                    killX_next = 1'b1;
                    killM_next = in_killX;
                    killW_next = in_killM;
                end else begin // Predict okay, no kill
                    kill_en_next = 1'b0;
                end
            end
            default: begin // not kill
                if (in_killD == 1'b1) begin // X valid but not kill, D stage invalid
                    kill_en_next = 1'b0;
                end else begin // X valid but not kill, D stage valid
                    case (instD[6:2])
                        // JAL_TYPE: begin
                        //     kill_en_next = 1'b1;
                        //     killF_next = 1'b0;
                        //     killD_next = 1'b1;
                        //     killX_next = in_killD;
                        //     killM_next = in_killX;
                        //     killW_next = in_killM;
                        // end
                        default: kill_en_next = 1'b0;
                    endcase
                end

            end 
        endcase
    end
end

initial begin
    killF_next <= 1'b0;
    killD_next <= 1'b0;
    killX_next <= 1'b0;
    killM_next <= 1'b0;
    killW_next <= 1'b0;
    kill_en_next <= 1'b0;
end
endmodule
