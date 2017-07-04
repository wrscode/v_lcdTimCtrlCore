/*
 * File name: counterFromZeroToLimit.v
 * Created on: Jul 5, 2017
 *
 * author: wrscode
 */

`timescale 1ns / 1ps


    module counterFromZeroToLimit #
    (
        parameter integer C_WIDTH = 8
    )
    (
        output reg [C_WIDTH - 1 : 0] oCount,
        input wire [C_WIDTH - 1 : 0] iLimit,
        input wire iClk,
        input wire iRst,
        input wire iEn
    );
    
    always @(posedge iClk or negedge iRst) begin
        if (!iRst) begin
            oCount <= 0;
        end else begin
            if(iEn) begin
                if (oCount < iLimit - 1) begin
                    oCount <= oCount + 1;
                end else begin
                    oCount <= 0;
                end
            end
        end
    end
    endmodule