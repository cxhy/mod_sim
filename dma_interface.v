//----------------------------------------------------------------------------
// Copyright (C) 2009 , Olivier Girard
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of the authors nor the names of its contributors
//       may be used to endorse or promote products derived from this software
//       without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
// OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
// THE POSSIBILITY OF SUCH DAMAGE
//
//----------------------------------------------------------------------------
//
// *File Name: dma_master.v
//
// *Module Description:
//                       dma主机
//
// *Author(s):
//              - guodezheng,    cxhy1981@gmail.com
//
//----------------------------------------------------------------------------
// $Rev: 134 $
// $LastChangedBy: guodezheng $
// $LastChangedDate: 2015/10/6 星期二 12:02:45 $
//----------------------------------------------------------------------------

module  dma_interface (

                     //input
                     mclk               ,
                     puc_rst            ,

                     wr_date            ,
                     wr_addr            ,
                     dmadstbyte         ,
                     dmasrcbyte         ,

                     transfer_en        ,
                     transfer_priority  ,
                     transfer_we        ,
                     transfer_wkup      ,
                     transfer_nmi       ,

                     dma_dout           ,
                     dma_ready          ,
                     dma_resp           ,

                     //output
                     wr_done            ,

                     dma_addr           ,
                     dma_din            ,
                     dma_en             ,
                     dma_priority       ,
                     dma_we             ,
                     dma_wkup           ,
                     nmi
);

//input
input                         mclk                ;
input                         puc_rst             ;

input [15:0]                  wr_date             ;
input [15:0]                  wr_addr             ;
input                         dmasrcbyte          ;
input                         dmadstbyte          ;

input                         transfer_en         ;
input                         transfer_priority   ;
input [1:0]                   transfer_we         ;
input                         transfer_wkup       ;
input                         transfer_nmi        ;

input [15:0]                  dma_dout            ;
input                         dma_ready           ;
input                         dma_resp            ;

//output
output                        wr_done             ;
output [15:1]                 dma_addr            ;
output [15:0]                 dma_din             ;
output                        dma_en              ;
output                        dma_priority        ;
output [1:0]                  dma_we              ;
output                        dma_wkup            ;
output                        nmi                 ;

function [33:0] write ;
    input  [14:0]                addr;
    input  [15:0]                data;
    input                        resp;
    input                        size;
    reg    [14:0]                dma_wr_addr;
    reg                          dma_wr_en;
    reg    [1:0]                 dma_wr_we;
    reg    [15:0]                dma_wr_din;
    begin
        dma_wr_addr = addr;
        dma_wr_en   = 1'b1;
        dma_wr_we   = size    ? 2'b11  :
                     addr[0]  ? 2'b10  :  2'b01;   //size为1则是16位读写，size为0时，addr最低位为0表示写16bie的低位，we为01，addr最低位为1标志写16bit的高位，we为10。
        dma_wr_din  = data;
        write       = {dma_wr_addr, dma_wr_en, dma_wr_we, dma_wr_din };
    end
endfunction

function [] read ;
    input 
    
    begin
    
    end

//function write_16b ;
//    input  [15:0] addr;
//    input  [15:0] data;
//    input         resp;
//    
//    begin
//        write (addr, data, resp, 1'b1);
//    end
//endfunction    

always (posedge mclk or negedge puc_rst)begin
    if(puc_rst == 1'b1)begin
        dma_addr     <= 15'b0;
        dma_din      <= 16'b0;
        dma_en       <= 1'b0;
        dma_priority <= 1'b0;
        dma_we       <= 2'b0;
        dma_wkup     <= 1'b0;
        nmi          <= 1'b0;        
    end
    else begin
        if(wr_req == 1'b1)begin
            dma_addr <= addr;
        end                   
    end
    
    
end




















endmodule