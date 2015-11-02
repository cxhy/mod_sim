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


module dma_channel(
    mclk          ,
    puc_rst       ,

    dmax_ctl      ,
    dmax_sa       ,
    dmax_da       ,
    dmax_sz       ,
    dmax_tsel     ,

    trigger       ,
    transfer_done ,

    dma_ready     ,
    dma_resp      ,
    dma_dout      ,
    dma_wkup      ,
    dma_en        ,
    dma_addr      ,
    dma_din       ,
    dma_we

);

input                 mclk          ;
input                 puc_rst       ;

input          [15:0] dmax_ctl      ;
input          [15:0] dmax_sa       ;
input          [15:0] dmax_da       ;
input          [15:0] dmax_sz       ;
input           [3:0] dmax_tsel     ;

input                 trigger       ;
output                transfer_done ;

input                 dma_ready     ;
input                 dma_resp      ;
input          [15:0] dma_dout      ;
output                dma_wkup      ;
output                dma_en        ;
output         [14:0] dma_addr      ;
output         [15:0] dma_din       ;
output          [1:0] dma_we        ;


wire          [15:0] dmax_ctl       ;
wire          [15:0] dmax_sa        ;
wire          [15:0] dmax_da        ;
wire          [15:0] dmax_sz        ;
wire           [3:0] dmax_tsel      ;
wire                 trigger        ;
wire                 dma_ready      ;
wire                 dma_resp       ;
wire          [15:0] dma_dout       ;
reg                  transfer_done  ;
wire                 dma_wkup       ;
reg                  dma_en         ;
reg           [14:0] dma_addr       ;
reg           [15:0] dma_din        ;
reg            [1:0] dma_we         ;




wire           [2:0] DMADTx         ;
wire           [1:0] DMADSTINCRx    ;
wire           [1:0] DMASRCINCRx    ;
wire                 DMADSTBYTE     ;
wire                 DMASRCBYTE     ;
wire                 DMALEVEL       ;
wire                 DMAEN          ;
wire                 DMAIFG         ;
wire                 DMAIE          ;
wire                 DMAABORT       ;
wire                 DMAREQ         ;

assign DMADTx      = dmax_ctl[14:12] ;
assign DMADSTINCRx = dmax_ctl[11:10] ;
assign DMASRCINCRx = dmax_ctl[9:8]   ;
assign DMADSTBYTE  = dmax_ctl[7]     ;
assign DMASRCBYTE  = dmax_ctl[6]     ;
assign DMALEVEL    = dmax_ctl[5]     ;
assign DMAEN       = dmax_ctl[4]     ;
assign DMAIFG      = dmax_ctl[3]     ;
assign DMAIE       = dmax_ctl[2]     ;
assign DMAABORT    = dmax_ctl[1]     ;
assign DMAREQ      = dmax_ctl[0]     ;
assign dma_wkup    = 1'b0            ;

//FSM

parameter RESET      = 9'b000000001  ;
parameter INI        = 9'b000000010  ;
parameter IDLE       = 9'b000000100  ;
parameter WAIT_TRI   = 9'b000001000  ;
parameter HOLD       = 9'b000010000  ;
parameter RELOAD     = 9'b000100000  ;
parameter TF_DONE    = 9'b001000000  ;
parameter AUTO_RESET = 9'b010000000  ;

reg              [8:0] current_state ;
reg              [8:0] next_state    ;
reg             [15:0] T_size        ;
reg             [15:0] T_SourceAdd   ;
reg             [15:0] T_DestAdd     ;
reg                    trigger_r     ;
reg                    trigger_pos   ;


always@(posedge mclk or posedge puc_rst)begin
    if(puc_rst == 1'b1)begin
    
    end
    else begin
    
    end
end

always@(posedge mclk or posedge puc_rst)begin
    if(puc_rst == 1'b1)begin
        current_state <= RESET;
    end
    else begin
        current_state <= next_state;
    end
end

always@(*)begin
    if(puc_rst == 1'b1)begin
        next_state <= RESET;
    end
    else begin
     case (current_state)
         RESET         :    next_state = (DMAEN == 1'b1) ? INI : RESET;
         INI           :    next_state = (DMAEN == 1'b1) ? IDLE : RESET;
         IDLE          :    next_state = (DMAEN == 1'b1) ? WAIT_TRI : RESET;
         WAIT_TRI      :    
         HOLD          :    
         RELOAD        :    
         TF_DONE       :    
         AUTO_RESET    :                 
     endcase
    end
end

always@(current_state or posedge puc_rst)begin
    if(puc_rst == 1'b1)begin

    end
    else begin
        case(current_state)
            RESET         :
            INI           :    begin
                T_size      <= dmax_sz;
                T_SourceAdd <= dmax_sa;
                T_DestAdd   <= dmax_da;
            end
            IDLE          :    
            WAIT_TRI      :    begin
                trigger_r = trigger;
                trigger_pos = trigger && (!trigger_r);
            end
            HOLD          :
            RELOAD        :
            TF_DONE       :
            AUTO_RESET    :        
        endcase

    end
end

reg                 [63:0] state_ascii;
always@(*)begin
    case (current_state)
        9'b000000001   :    state_ascii <= "RESET     " ;
        9'b000000010   :    state_ascii <= "INI       " ;
        9'b000000100   :    state_ascii <= "IDLE      " ;
        9'b000001000   :    state_ascii <= "WAIT_TRI  " ;
        9'b000010000   :    state_ascii <= "HOLD      " ;
        9'b000100000   :    state_ascii <= "RELOAD    " ;
        9'b001000000   :    state_ascii <= "TF_DONE   " ;
        9'b010000000   :    state_ascii <= "AUTO_RESET" ;
        default        :    begin
        end
    endcase
end




endmodule