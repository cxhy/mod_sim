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

module  per2dma (
                 // INPUTs
                     mclk         ,
                     puc_rst      ,

                     dma_ctl0     ,
                     dma_ctl1     ,
                     dma_ctl      ,
                     dma_sa       ,
                     dma_da       ,
                     dma_sz       ,

                     rd_ready     ,
                     rd_date      ,
                     wr_done      ,



//                     dma_dout     ,
//                     dma_ready    ,
//                     dma_resp     ,



                     // OUTPUTs       ,
                     wr_date      ,
                     wr_addr      ,
                     
                     dmadstbyte   ,
                     dmasrcbyte   ,

                     transfer_en   ,
                     transfer_priority ,
                     transfer_we       ,
                     transfer_wkup     ,
                     transfer_nmi
);

input                             mclk    ;
input                             puc_rst ;

input  [15:0]                     dma_ctl0;
input  [15:0]                     dma_ctl1;
input  [15:0]                     dma_ctl;
input  [15:0]                     dma_sa ;
input  [15:0]                     dma_da ;
input  [15:0]                     dma_sz ;
input  [15:0]                     rd_date;
input                             rd_ready;
input  [15:0]                     wr_done           ;
//input  [15:0]                     dma_dout  ;
//input                             dma_ready ;
//input                             dma_resp  ;


//output [15:0]                     addr       ;
//output [15:0]                     data       ;
//output                            transfer_en;
//output                            size       ;
//output                            wr_req     ;
//output                            rd_req     ;
//output                            priority   ;
//output [15:0]                     dma_addr     ;
//output [15:0]                     dma_din      ;
//output                            dma_en       ;
//output                            dma_priority ;
//output [1:0]                      dma_we       ;
//output                            dma_wkup     ;
//output                            nmi          ;

output [15:0]                     wr_date           ;
output [15:0]                     wr_addr           ;


output                            transfer_en       ;
output                            transfer_priority ;
output [1:0]                      transfer_we       ;
output                            transfer_wkup     ;
output                            transfer_nmi      ;



//DMACTL0 DMACTL1
wire                              dma0tselx;
wire                              dma1tselx;
wire                              dma2tselx;
wire                              dmaonfetch;
wire                              roundrobin;
wire                              ennmi;
//DMA0CTL
wire  [2:0]                       dmadtx;
wire  [1:0]                       dmadstincrx;
wire  [1:0]                       dmasrcincrx;
wire                              dmadstbyte;
wire                              dmasrcbyte;
wire                              dmalevel;
reg                               dmaen;
wire                              dmaifg;
wire                              dmaie;
wire                              dmaabort;
reg                               dmareq;

//==========

reg   [15:0]                      T_Size;
reg   [15:0]                      T_SourceAdd;
reg   [15:0]                      T_DestAdd;



assign dma0tselx                  = dma_ctl0[3:0];
assign dma1tselx                  = dma_ctl0[7:4];
assign dma2tselx                  = dma_ctl0[11:8];
assign dmaonfetch                 = dma_ctl1[2];
assign roundrobin                 = dma_ctl1[1];
assign ennmi                      = dma_ctl1[0];

assign dmadtx                     = dma_ctl[14:12]   ;
assign dmadstincrx                = dma_ctl[11:10]   ;
assign dmasrcincrx                = dma_ctl[9:8]     ;
assign dmadstbyte                 = dma_ctl[7]       ;
assign dmasrcbyte                 = dma_ctl[6]       ;
assign dmalevel                   = dma_ctl[5]       ; //unsupport
//assign dmaen                      = dma_ctl[4]       ;
assign dmaifg                     = dma_ctl[3]       ; //unsupport
assign dmaie                      = dma_ctl[2]       ; //unsupport
assign dmaabort                   = dma_ctl[1]       ; //unsupport
//assign dmareq                     = dma_ctl[0]       ;


//考虑到不支持的信号那么表示，跳变沿触发，中断不可被打断，中断不使能，不可被NMI打断

assign  transfer_priority       = 1'b0
assign  transfer_wkup           = 1'b0
assign  transfer_nmi            = 1'b0






wire   dma_en ;

wire [15:0] dma_sz;
wire [15:0] dma_sa;
wire [15:0] dma_da;


//single transfer FSM
parameter RESET      = 9'b000000001;
parameter IDLE_PER   = 9'b000000010;
parameter IDLE       = 9'b000000100;
parameter WAIT_TRI   = 9'b000001000;
parameter HOLD_CPU   = 9'b000010000;
parameter JUMP       = 9'b000100000;
parameter RELOD      = 9'b001000000;
parameter RESET_REQ  = 9'b010000000;
parameter TRANS_DONE = 9'b100000000;


reg [5:0]   current_state;
reg [5:0]   next_state;
reg         reg2temp_done;
reg         dma0req_t1;
reg         dma0req_t2;


wire        dma_tri;
reg         transfer_done;
wire [2:0]  dmadtx;



//
//always@(posedge mclk or negedge puc_rst )begin
//    if(puc_rst = 1'b1)begin
//        dmareq_t1 <= 1'b0;
//        dmareq_t2 <= 1'b0;
//    end
//    else begin
//        dmareq_t1 <= dmareq;
//        dmareq_t2 <= dmareq_t1;
//    end
//end
//assign dma_tri = dmareq_t1 && (!dmareq_t2);



always@(posedge mclk or negedge puc_rst)begin
    if(puc_rst = 1'b1)begin
        current_state <= RESET;
    end
    else begin
        current_state <= next_state;
    end
end


always@(*)begin
    if(puc_rst = 1'b1)begin
        next_state <= RESET;
    end
    else begin
        case (current_state)
            RESET       : next_state = (dmaen == 1)          ? IDLE_PER : RESET    ;
            IDLE_PER    : next_state = (reg2temp_done == 1 ) ? IDLE     : IDLE_PER ;
            IDLE        : next_state = (dmaen == 1)          ? WAIT_TRI : RESET    ;
            WAIT_TRI    : next_state = (dma_tri == 1)        ? HOLD_CPU : WAIT_TRI ;
            READ        : next_state = (read_done == 1)      ? WRITE    : READ     ;
            WRITE       : next_state = (wr_done == 1)        ? JUMP     : WRITE    ;
            JUMP        : begin
                              if((dmadtx == 3'b100) & (T_Size == 0) & (dmaen == 1) )begin
                                  next_state = RELOD;
                              end
                              else if ((T_Size != 0) & (dmaen == 1) )begin
                                  next_state = RESET_REQ;
                              end
                              else if (((dmaen == 0)&(dma_tri == 0)) | (dmaen == 0)  )begin
                                  next_state = TRANS_DONE;
                              end
                              else begin
                                  next_state = RESET;
                              end
            end
            RELOD       : next_state <= RESET_REQ;
            RESET_REQ   : next_state <= WAIT_TRI;
            TRANS_DONE  : next_state <= RESET;
            default     : next_state <= RESET;
        endcase;
    end
end

always@(puc_rst or current_state)begin
    if(puc_rst == 1'b1)begin
        dmareq_t1 <= 1'b0;
        dmareq_t2 <= 1'b0;
        transfer_en <= 1'b0;
    end
    else begin
        case (current_state)begin
            RESET       : ;begin
                reg2temp_done <= 1'b0;
                dmaen         <= dma_ctl[4];
//                transfer_done <= 1'b0;
            end
            IDLE_PER    : begin
                reg2temp_done = 1'b0;
//                transfer_done <= 1'b0;
                if(dmaen)begin
                    T_Size       <= dma_sz;
                    T_SourceAdd  <= dma_sa;
                    T_DestAdd    <= dma_da;
                    reg2temp_done<=1'b1;
                end
            end
            IDLE        : begin
//                reg2temp_done <= 1'b0;
//                transfer_done <= 1'b0;

            end
            WAIT_TRI    :begin
//                reg2temp_done <= 1'b0;
                dmareq        <= dma_ctl[0];
                transfer_done <= 1'b0;
                dmareq_t1 <= dmareq;
                dmareq_t2 <= dmareq_t1;
                dma_tri <= dmareq_t1 && (!dmareq_t2);
            end
            READ       :begin
                if(rd_ready)begin
                    transfer_en <= 1'b1;
                    dma_addr[15:1] <= T_SourceAdd;
                    trans_data     <= rd_date;
                    read_done      <= 1'b1;
                    transfer_we    <= 2'b0;
                end
                else begin
                    read_done      <= 1'b0;
                end
            end
            WRITE       :begin
                   transfer_we   = (~dmadstbyte) ? 2'b11             :
                                    wr_addr[0]    ? 2'b10 : 2'b01;
                   wr_date <= trans_data;
                   wr_addr <= T_DestAdd;
            end
            JUMP        :begin
//                reg2temp_done <= 1'b0;
//                transfer_done <= 1'b0;
                T_Size <= T_Size - 1;
//                T_SourceAdd = (~dmadstincrx[1]) ? T_SourceAdd : X;
//                X  = (~dmadstincrx[0]) ? X1 : X2;
//                X1 = (T_SourceAdd - 2) : (T_SourceAdd - 1);
//                X1 = (T_SourceAdd + 2) : (T_SourceAdd + 1);
                T_SourceAdd = (~dmadstincrx[1]) ? T_SourceAdd :
                              ((~dmadstincrx[0]) ? ((T_SourceAdd - 2) :
                              (T_SourceAdd - 1)) : ((T_SourceAdd + 2) :
                              (T_SourceAdd + 1)))
//                T_DestAdd = (~dmasrcbyte[1]) ? T_DestAdd : X;
//                X  = (~dmasrcbyte[0]) ? X1 : X2;
//                X1 = (T_DestAdd - 2) : (T_DestAdd - 1);
//                X1 = (T_DestAdd + 2) : (T_DestAdd + 1);
                T_DestAdd = (~dmasrcbyte[1]) ? T_DestAdd :
                              ((~dmasrcbyte[0]) ? ((T_DestAdd - 2) :
                              (T_DestAdd - 1))  : ((T_DestAdd + 2) :
                              (T_DestAdd + 1)))
            end
            RELOD       : begin
                T_Size       <= dma_sz;
                T_SourceAdd  <= dma_sa;
                T_DestAdd    <= dma_da;
            end
            RESET_REQ   : begin
                dmareq <= 1'b0;
            end
            TRANS_DONE  : begin
                dmaen <= 1'b0;
                dmareq <= 1'b0;
                T_Size       <= dma_sz;
            end
            default     :begin
//                reg2temp_done <= 1'b0;
//                transfer_done <= 1'b0;
            end
        endcase

    end
end



endmodule // per2dma

