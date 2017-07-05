/*
 * File name: lcdTimCtrlCore.v
 * Created on: Jul 5, 2017
 *
 * author: wrscode
 */

`timescale 1ns / 1ps

    module lcdTimCtrlCore #
    (
        parameter integer C_HOR_WIDTH = 8,
        parameter integer C_VER_WIDTH = 8
    )
    (
        output reg oHSynch,
        output reg oVSynch,
        output reg oEnVideo,
    
        output reg [C_HOR_WIDTH - 1 : 0] oHAddr,
        output reg [C_VER_WIDTH - 1 : 0] oVAddr,
    
        input wire [C_HOR_WIDTH - 1 : 0] iHWidth,
        input wire [C_HOR_WIDTH - 1 : 0] iHBackPorch,
        input wire [C_HOR_WIDTH - 1 : 0] iHFrontPorch,
        input wire [C_HOR_WIDTH - 1 : 0] iHResolution,
    
        input wire iHPolarity,

        input wire [C_VER_WIDTH - 1 : 0] iVWidth,
        input wire [C_VER_WIDTH - 1 : 0] iVBackPorch,
        input wire [C_VER_WIDTH - 1 : 0] iVFrontPorch,
        input wire [C_VER_WIDTH - 1 : 0] iVResolution,
    
        input wire iVPolarity,
                
        input wire iEnVideoPolarity,
        
        input wire iClkPixel,
        input wire iRst,
        input wire iEn
    );

    wire [C_VER_WIDTH + 1 : 0] vCounter;
    wire [C_VER_WIDTH + 1 : 0] vPeriod;
    
    wire [C_HOR_WIDTH + 1 : 0] hCounter;
    wire [C_HOR_WIDTH + 1 : 0] hPeriod;
    
    reg hEnabler;
    reg vEnabler;

/* ------------------------------------------------------------------------------------------------------------------ */
/* horizontal counter ----------------------------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------------------------------ */
    counterFromZeroToLimit #
        (
            .C_WIDTH(C_HOR_WIDTH + 2)
        )HorizontalCounter(
            .oCount(hCounter),
            .iLimit(hPeriod),
            .iClk(iClkPixel),
            .iRst(iRst),
            .iEn(iEn)
        );
    
/* ------------------------------------------------------------------------------------------------------------------ */
/* vertical counter ------------------------------------------------------------------------------------------------- */
/* ------------------------------------------------------------------------------------------------------------------ */
    counterFromZeroToLimit #
        (
            .C_WIDTH(C_VER_WIDTH + 2)
        )VerticalCounter(
            .oCount(vCounter),
            .iLimit(vPeriod),
            .iClk(iClkPixel),
            .iRst(iRst),
            .iEn(vEnabler)
        );
    
/* ---------------------------------------------------------------------------------------------------------------- */

    assign vPeriod = iVWidth + iVBackPorch + iVFrontPorch + iVResolution;
    assign hPeriod = iHWidth + iHBackPorch + iHFrontPorch + iHResolution;
    
/* ---------------------------------------------------------------------------------------------------------------- */
    //HS impuls
    always @(*) begin 
        if((0 <= hCounter) && (hCounter < iHWidth)) begin
            oHSynch = iHPolarity;
        end else begin 
            oHSynch = ~iHPolarity;
        end    
    end
     
    //oHAddr
    always @(*) begin 
        if(((iHWidth + iHBackPorch) <= hCounter) && (hCounter < (iHWidth + iHBackPorch + iHResolution)) &&
        (hEnabler == 1'b1)) begin
            oHAddr = hCounter[C_HOR_WIDTH - 1 : 0] - (iHWidth + iHBackPorch);
        end else begin 
            oHAddr = 0;
        end    
    end     
 
     //hEnabler impulse
    always @(*) begin 
        if(((iVWidth + iVBackPorch) <= vCounter) && (vCounter < (iVWidth + iVBackPorch + iVResolution))) begin
            hEnabler = 1'b1;
        end else begin 
            hEnabler = 1'b0;
        end    
    end
 
     //oEnVideo impuls
    always @(*) begin 
        if(((iHWidth + iHBackPorch) <= hCounter) && (hCounter < (iHWidth + iHBackPorch + iHResolution)) && 
        (hEnabler == 1'b1)) begin
            oEnVideo = iEnVideoPolarity;
        end else begin 
            oEnVideo = ~iEnVideoPolarity;
        end    
    end    
 
    //vEnabler
    always @(*) begin 
        if((hCounter == 0)) begin
            vEnabler = 1'b1;
        end else begin 
            vEnabler = 1'b0;
        end    
    end 
    
    //VS impulse
    always @(*) begin 
        if((0 <= vCounter) && (vCounter < iVWidth)) begin
            oVSynch = iVPolarity;
        end else begin 
            oVSynch = ~iVPolarity;
        end    
    end    
  
    //oVAddr
    always @(*) begin 
        if(((iVWidth + iVBackPorch) <= vCounter) && (vCounter < (iVWidth + iVBackPorch + iVResolution))) begin
            oVAddr = vCounter[C_VER_WIDTH - 1 : 0] - (iVWidth + iVBackPorch);
        end else begin 
            oVAddr = 0;
        end    
    end   
     
    endmodule
