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

module  dma_priority (
                       mclk                      ,
                       puc_rst                   ,

                       dma_ctl0                  ,
                       dma_ctl1                  ,
                       dma0_ctl                  ,
                       dma0_sa                   ,
                       dma0_da                   ,
                       dma0_sz                   ,
                       dma1_ctl                  ,
                       dma1_sa                   ,
                       dma1_da                   ,
                       dma1_sz                   ,
                       dma2_ctl                  ,
                       dma2_sa                   ,
                       dma2_da                   ,
                       dma2_sz                   ,

                       cha0_tf_done              ,
                       cha1_tf_done              ,
                       cha2_tf_done              ,

                       dma_priority              ,
                       cha0_tri                  ,
                       cha1_tri                  ,
                       cha2_tri

);

input                                   mclk     ;
input                                   puc_rst  ;

input  [15:0]                           dma_ctl0 ;
input  [15:0]                           dma_ctl1 ;
input  [15:0]                           dma0_ctl ;
input  [15:0]                           dma0_sa  ;
input  [15:0]                           dma0_da  ;
input  [15:0]                           dma0_sz  ;
input  [15:0]                           dma1_ctl ;
input  [15:0]                           dma1_sa  ;
input  [15:0]                           dma1_da  ;
input  [15:0]                           dma1_sz  ;
input  [15:0]                           dma2_ctl ;
input  [15:0]                           dma2_sa  ;
input  [15:0]                           dma2_da  ;
input  [15:0]                           dma2_sz  ;
input                                   cha0_tf_done;
input                                   cha1_tf_done;
input                                   cha2_tf_done;

output                                  dma_priority;
output                                  cha0_tri ;
output                                  cha1_tri ;
output                                  cha2_tri ;



wire  [15:0]                           dma_ctl0 ;
wire  [15:0]                           dma_ctl1 ;
wire  [15:0]                           dma0_ctl ;
wire  [15:0]                           dma0_sa  ;
wire  [15:0]                           dma0_da  ;
wire  [15:0]                           dma0_sz  ;
wire  [15:0]                           dma1_ctl ;
wire  [15:0]                           dma1_sa  ;
wire  [15:0]                           dma1_da  ;
wire  [15:0]                           dma1_sz  ;
wire  [15:0]                           dma2_ctl ;
wire  [15:0]                           dma2_sa  ;
wire  [15:0]                           dma2_da  ;
wire  [15:0]                           dma2_sz  ;
wire  [3:0]                            DMA0TSELx;
wire  [3:0]                            DMA1TSELx;
wire  [3:0]                            DMA2TSELx;


reg                                    cha0_tri ;
reg                                    cha1_tri ;
reg                                    cha2_tri ;

reg                                    dma0_tri ;
reg                                    dma1_tri ;
reg                                    dma2_tri ;
reg [2:0]                              last_txf_cha;

//  last_txf_cha      说明
//  000               复位之后进行第一次传输
//  001               上一次传输的是通道0
//  010               上一次传输的是通道1
//  100               上一次传输的是通道2



wire                                   ROUNDROBIN   ;
wire                                   DMAONFETCH   ;


parameter IDLE       = 4'b0001;
parameter CHA0       = 4'b0010;
parameter CHA1       = 4'b0100;
parameter CHA2       = 4'b1000;
reg       [3:0]      current_state;
reg       [3:0]      next_state   ;

assign     DMA0TSELx = dma_ctl0[3:0];
assign     DMA1TSELx = dma_ctl0[7:4];
assign     DMA2TSELx = dma_ctl0[11:8];

assign     dma0req   = dma0_ctl[0];
assign     dma1req   = dma1_ctl[0];
assign     dma2req   = dma2_ctl[0];

assign     ROUNDROBIN = dma_ctl1[1];
assign     DMAONFETCH = dma_ctl1[2];
assign     dma_priority = DMAONFETCH;




//dmax_tri  来自触发源的通道触发信号
//chax_tri  向下层输出的通道触发信号


//always@(posedge mclk or negedge puc_rst)begin
//    if(puc_rst == 1'b1)begin
//        dma0_tri  <= 1'b0;
//    end
//    else begin
//        case(DMA0TSELx)
//            0000    : dma0_tri <= dma0req;
//            default : dma0_tri <= 1'b0;
//        endcase;
//    end
//end

//对dmaxtsel信号进行触发信号的归一化处理。
always@(posedge mclk or negedge puc_rst)begin
    if(puc_rst == 1'b1)begin
        dma0_tri <= 1'b0;
    end
    else begin
        case (DMA0TSELx)
            0000    : dma0_tri <= dma0req;
            default : dma0_tri <= 1'b0;
        endcase
    end
end


always@(posedge mclk or negedge puc_rst)begin
    if(puc_rst == 1'b1)begin
        dma1_tri  <= 1'b0;
    end
    else begin
        case(DMA1TSELx)
            0000    : dma1_tri <= dma1req;
            default : dma1_tri <= 1'b0;
        endcase
    end
end


always@(posedge mclk or negedge puc_rst)begin
    if(puc_rst == 1'b1)begin
        dma2_tri  <= 1'b0;
    end
    else begin
        case(DMA2TSELx)
            0000    : dma2_tri <= dma2req;
            default : dma2_tri <= 1'b0;
        endcase
    end
end

//状态机
//
always@(posedge mclk or negedge puc_rst)begin
    if(puc_rst == 1'b1)begin
        current_state <= IDLE;
    end
    else begin
        current_state <= next_state;
    end
end

//idle ： 是否是循环优先级，如果不是，那么判断通道0是否有触发信号，如果有，则进入状态CHA0
//当通道0无触发信号是，则判断通道1。类似直到通道2.如果通道2仍然没有触发信号，则留在本状态
//如果是循环优先级，则需要根据变量last_txf_cha判断上一次传输通道序号
//如果自从上一次复位以来没有传输，那么优先级为 0-1-2
//如果上一次通道为1，则优先级为2-0-1
//如果上一次通道为2，则优先级为0-1-2
//如果上一次通道为0，则优先级为1-2-0
always@(*)begin
    if(puc_rst == 1'b1)begin
        next_state <= IDLE;
    end
    else begin
        case(current_state)
            IDLE    :    begin
                if(ROUNDROBIN == 1'b0)begin
                    next_state = (dma0_tri) ? CHA0 :
                                 (dma1_tri) ? CHA1 :
                                 (dma2_tri) ? CHA2 : IDLE;
                end
                else begin
                //2time
                    if(last_txf_cha == 3'b000)begin
                        if(dma0_tri)begin
                            next_state <= CHA0;
                        end
                        else if(dma1_tri)begin
                            next_state <= CHA1;
                        end
                        else if(dma2_tri)begin
                            next_state <= CHA2;
                        end
                        else begin
                        end
                    end
                    else if(last_txf_cha == 3'b001)begin
                        if(dma1_tri)begin
                            next_state <= CHA1;
                        end
                        else if(dma2_tri)begin
                            next_state <= CHA2;
                        end
                        else if(dma0_tri)begin
                            next_state <= CHA0;
                        end
                        else begin
                        end
                    end
                    else if(last_txf_cha == 3'b010)begin
                        if(dma2_tri)begin
                            next_state <= CHA2;
                        end
                        else if(dma0_tri)begin
                            next_state <= CHA0;
                        end
                        else if(dma1_tri)begin
                            next_state <= CHA1;
                        end
                        else begin
                        end
                    end
                    else if(last_txf_cha == 3'b100)begin
                        if(dma0_tri)begin
                            next_state <= CHA0;
                        end
                        else if(dma1_tri)begin
                            next_state <= CHA1;
                        end
                        else if(dma2_tri)begin
                            next_state <= CHA2;
                        end
                        else begin
                        end
                    end
                    else begin
                    end

                //一次失败的装逼
//                    case (last_txf_cha)
//                    000    : begin
//                             next_state = (dma0_tri) ? CHA0 :
//                                          (dma1_tri) ? CHA1 :
//                                          (dma2_tri) ? CHA2 : IDLE;
//                    end
//                    001    : begin
//                             next_state = (dma1_tri) ? CHA1 :
//                                          (dma2_tri) ? CHA2 :
//                                          (dma0_tri) ? CHA0 : IDLE;
//                    end
//                    010    : begin
//                             next_state = (dma2_tri) ? CHA2 :
//                                          (dma0_tri) ? CHA0 :
//                                          (dma1_tri) ? CHA1 : IDLE;
//                    end
//                    100    : begin
//                             next_state = (dma0_tri) ? CHA0 :
//                                          (dma1_tri) ? CHA1 :
//                                          (dma2_tri) ? CHA2 : IDLE;
//                    end
//                    default : next_state = IDLE;
//                    endcase
                end
            end
            CHA0    :    next_state = (cha0_tf_done == 1'b1) ? IDLE : CHA0;
            CHA1    :    next_state = (cha1_tf_done == 1'b1) ? IDLE : CHA1;
            CHA2    :    next_state = (cha2_tf_done == 1'b1) ? IDLE : CHA2;
            default :    next_state = IDLE;
        endcase
    end
end

always@(posedge mclk or negedge puc_rst)begin
    if(puc_rst == 1'b1)begin
        last_txf_cha <= 3'b0;
        cha0_tri     <= 1'b0;
        cha1_tri     <= 1'b0;
        cha2_tri     <= 1'b0;
    end
    else begin
        case(current_state)
            IDLE    :    begin
            end
            CHA0    :    begin
                last_txf_cha <= 3'b001;
                cha0_tri      = (cha0_tf_done == 1'b1 ) ? 1'b0 : dma0_tri;
            end
            CHA1    :begin
                last_txf_cha <= 3'b010;
                cha1_tri      = (cha1_tf_done == 1'b1 ) ? 1'b0 : dma1_tri;
            end
            CHA2    :begin
                last_txf_cha <= 3'b100;
                cha2_tri      = (cha2_tf_done == 1'b1 ) ? 1'b0 : dma2_tri;
            end
            default : begin
            end
        endcase
    end
end




endmodule // dma_priority


