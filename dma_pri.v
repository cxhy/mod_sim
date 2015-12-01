//----------------------------------------------------------------------------
// Copyright (C) 2009 , Guo Dezheng
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
// $Rev:  $
// $CreatDate:   2015-11-06 11:57:15
// $LastChangedBy: guodezheng $
// $LastChangedDate:  2015-12-01 11:33:57
//----------------------------------------------------------------------------
//
// *File Name: dma_pri.v 
// 
// *Module Description:
//                       ���ȼ�����ģ�飬���²��ṩ��ǰ�����ͨ�����ṩͨ�����䴥���ź�
//                       ��������ͨ���Ĵ�������źŲ�����ͨ�����ȼ��Ŀ�����Ϣ�Ĵ���
//
// *Author(s):
//              - Guodezheng cxhy1981@gmail.com,
//
//---------------------------------------------------------------------------- 

module  dma_pri (
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
                       dma3_ctl                  ,
                       dma3_sa                   ,
                       dma3_da                   ,
                       dma3_sz                   ,
                       dma4_ctl                  ,
                       dma4_sa                   ,
                       dma4_da                   ,
                       dma4_sz                   ,                                              
                       cha0_tf_done              ,
                       cha1_tf_done              ,
                       cha2_tf_done              ,
                       cha3_tf_done              ,
                       cha4_tf_done              ,

                       dma_priority              ,
                       cha0_tri                  ,
                       cha1_tri                  ,
                       cha2_tri                  ,
                       cha3_tri                  ,
                       cha4_tri                  
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
input  [15:0]                           dma3_ctl ;
input  [15:0]                           dma3_sa  ;
input  [15:0]                           dma3_da  ;
input  [15:0]                           dma3_sz  ;
input  [15:0]                           dma4_ctl ;
input  [15:0]                           dma4_sa  ;
input  [15:0]                           dma4_da  ;
input  [15:0]                           dma4_sz  ;
input                                   cha0_tf_done;
input                                   cha1_tf_done;
input                                   cha2_tf_done;
input                                   cha3_tf_done;
input                                   cha4_tf_done;

output                                  dma_priority;
output                                  cha0_tri ;
output                                  cha1_tri ;
output                                  cha2_tri ;
output                                  cha3_tri ;
output                                  cha4_tri ;



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
wire  [15:0]                           dma3_ctl ;
wire  [15:0]                           dma3_sa  ;
wire  [15:0]                           dma3_da  ;
wire  [15:0]                           dma3_sz  ;
wire  [15:0]                           dma4_ctl ;
wire  [15:0]                           dma4_sa  ;
wire  [15:0]                           dma4_da  ;
wire  [15:0]                           dma4_sz  ;
wire  [3:0]                            DMA0TSELx;
wire  [3:0]                            DMA1TSELx;
wire  [3:0]                            DMA2TSELx;
wire  [3:0]                            DMA3TSELx;
wire  [3:0]                            DMA4TSELx;


reg                                    cha0_tri ;
reg                                    cha1_tri ;
reg                                    cha2_tri ;
reg                                    cha3_tri ;
reg                                    cha4_tri ;
reg                                    dma0_tri ;
reg                                    dma1_tri ;
reg                                    dma2_tri ;
reg                                    dma3_tri ;
reg                                    dma4_tri ;
reg [4:0]                              last_txf_cha;




wire                                   ROUNDROBIN   ;
wire                                   DMAONFETCH   ;


parameter IDLE       = 6'b00_0001;
parameter CHA0       = 6'b00_0010;
parameter CHA1       = 6'b00_0100;
parameter CHA2       = 6'b00_1000;
parameter CHA3       = 6'b01_0000;
parameter CHA4       = 6'b10_0000;
reg       [5:0]      current_state;
reg       [5:0]      next_state   ;

assign     DMA0TSELx = dma_ctl0[3:0];
assign     DMA1TSELx = dma_ctl0[7:4];
assign     DMA2TSELx = dma_ctl0[11:8];
assign     DMA3TSELx = dma_ctl0[15:12];
assign     DMA4TSELx = dma_ctl1[7:4];

assign     dma0req   = dma0_ctl[0];
assign     dma1req   = dma1_ctl[0];
assign     dma2req   = dma2_ctl[0];
assign     dma3req   = dma3_ctl[0];
assign     dma4req   = dma4_ctl[0];

assign     ROUNDROBIN = dma_ctl1[1];
assign     DMAONFETCH = dma_ctl1[2];
assign     dma_priority = DMAONFETCH;




//dmax_tri  ���Դ���Դ��ͨ�������ź�
//chax_tri  ���²������ͨ�������ź�


//always@(posedge mclk or posedge puc_rst)begin
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

//��dmaxtsel�źŽ��д����źŵĹ�һ������
//����DMAxTSELx�źŰ������req���������Ĵ����ź�ͳһΪdmax_tri
always@(posedge mclk or posedge puc_rst)begin
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


always@(posedge mclk or posedge puc_rst)begin
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


always@(posedge mclk or posedge puc_rst)begin
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

always@(posedge mclk or posedge puc_rst)begin
    if(puc_rst == 1'b1)begin
        dma3_tri  <= 1'b0;
    end
    else begin
        case(DMA3TSELx)
            0000    : dma3_tri <= dma3req;
            default : dma3_tri <= 1'b0;
        endcase
    end
end


always@(posedge mclk or posedge puc_rst)begin
    if(puc_rst == 1'b1)begin
        dma3_tri  <= 1'b0;
    end
    else begin
        case(DMA3TSELx)
            0000    : dma3_tri <= dma3req;
            default : dma3_tri <= 1'b0;
        endcase
    end
end

//״̬��
//
always@(posedge mclk or posedge puc_rst)begin
    if(puc_rst == 1'b1)begin
        current_state <= IDLE;
    end
    else begin
        current_state <= next_state;
    end
end

// //FSM for sim
// // synthesis translate_off
// reg                [63:0]                state_ascii;
// always @ ( * ) begin
//         case(current_state)
//             6'b00_0001  :  state_ascii  <= "IDLE" ;  
//             6'b00_0010  :  state_ascii  <= "CHA0" ; 
//             6'b00_0100  :  state_ascii  <= "CHA1" ; 
//             6'b00_1000  :  state_ascii  <= "CHA2" ; 
//             6'b01_0000  :  state_ascii  <= "CHA3" ; 
//             6'b10_0000  :  state_ascii  <= "CHA4" ; 
//             default     :  state_ascii  <= "ERROR";
//         endcase
// end

//idle �� �Ƿ���ѭ�����ȼ���������ǣ���ô�ж�ͨ��0�Ƿ��д����źţ�����У������״̬CHA0
//��ͨ��0�޴����ź��ǣ����ж�ͨ��1������ֱ��ͨ��2.���ͨ��2��Ȼû�д����źţ������ڱ�״̬
//�����ѭ�����ȼ�������Ҫ���ݱ���last_txf_cha�ж���һ�δ���ͨ�����
//����Դ���һ�θ�λ����û�д��䣬��ô���ȼ�Ϊ 0-1-2-3-4
//��ǰ���ȼ�     ��ǰ����ͨ��  �µ����ȼ�
//0-1-2-3-4       0            1-2-3-4-0
//1-2-3-4-0       1            2-3-4-0-1
//2-3-4-0-1       2            3-4-0-1-2
//3-4-0-1-2       3            4-0-1-2-3
//4-0-1-2-3       4            0-1-2-3-4

//  last_txf_cha      ˵��
//  5'b00_000               ��λ֮����е�һ�δ���
//  5'b00_001               ��һ�δ������ͨ��0
//  5'b00_010               ��һ�δ������ͨ��1
//  5'b00_100               ��һ�δ������ͨ��2
//  5'b01_000               ��һ�δ������ͨ��3
//  5'b10_000               ��һ�δ������ͨ��4

always@(*)begin
    if(puc_rst == 1'b1)begin
        next_state <= IDLE;
    end
    else begin
        case(current_state)
            IDLE    :    begin
                if(ROUNDROBIN == 1'b0)begin
                //�̶����ȼ�
                    next_state = (dma0_tri) ? CHA0 :
                                 (dma1_tri) ? CHA1 :
                                 (dma2_tri) ? CHA2 :
                                 (dma3_tri) ? CHA3 :
                                 (dma4_tri) ? CHA4 : IDLE;
                end
                else begin
                //ѭ�����ȼ�
                //2time
                //��λ���״δ��䣬���ȼ�Ϊ0-1-2-3-4
                    if(last_txf_cha == 5'b00_000)begin
                        if(dma0_tri)begin
                            next_state <= CHA0;
                        end
                        else if(dma1_tri)begin
                            next_state <= CHA1;
                        end
                        else if(dma2_tri)begin
                            next_state <= CHA2;
                        end
                        else if (dma3_tri) begin
                            next_state <= CHA3;
                        end
                        else if (dma4_tri) begin
                            next_state <= CHA4;
                        end
                        else begin
                        end
                    end
                //֮ǰ����ͨ��Ϊ0����ǰ���ȼ�Ϊ1-2-3-4-0
                    else if(last_txf_cha == 5'b00_001)begin
                        if(dma1_tri)begin
                            next_state <= CHA1;
                        end
                        else if(dma2_tri)begin
                            next_state <= CHA2;
                        end
                        else if(dma3_tri)begin
                            next_state <= CHA3;
                        end
                        else if (dma4_tri) begin
                            next_state <= CHA4; 
                        end
                        else if (dma0_tri) begin
                            next_state <= CHA0;
                        end
                        else begin
                        end
                    end
                //֮ǰ����ͨ����1����ǰ�������ȼ�Ϊ2-3-4-0-1
                    else if(last_txf_cha ==  5'b00_010)begin
                        if(dma2_tri)begin
                            next_state <= CHA2;
                        end
                        else if(dma3_tri)begin
                            next_state <= CHA3;
                        end
                        else if(dma4_tri)begin
                            next_state <= CHA4;
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
                 //֮ǰ����ͨ����2����ǰ�������ȼ�Ϊ3-4-0-1-2          
                    else if(last_txf_cha == 5'b00_100)begin
                        if(dma3_tri)begin
                            next_state <= CHA3;
                        end
                        else if(dma4_tri)begin
                            next_state <= CHA4;
                        end
                        else if(dma0_tri)begin
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
                 //֮ǰ����ͨ����3����ǰ�������ȼ�Ϊ4-0-1-2-3
                    else if(last_txf_cha == 5'b01_000)begin
                        if(dma4_tri)begin
                            next_state <= CHA4;
                        end
                        else if(dma0_tri)begin
                            next_state <= CHA0;
                        end
                        else if(dma1_tri)begin
                            next_state <= CHA1;
                        end
                        else if(dma2_tri)begin
                            next_state <= CHA2;
                        end
                        else if(dma3_tri)begin
                            next_state <= CHA3;
                        end
                        else begin
                        end
                    end
                 //֮ǰ����ͨ����4����ǰ�������ȼ�Ϊ0-1-2-3-4        
                    else if(last_txf_cha == 5'b10_000)begin
                        if(dma0_tri)begin
                            next_state <= CHA0;
                        end
                        else if(dma1_tri)begin
                            next_state <= CHA1;
                        end
                        else if(dma2_tri)begin
                            next_state <= CHA2;
                        end
                        else if(dma3_tri)begin
                            next_state <= CHA3;
                        end
                        else if(dma4_tri)begin
                            next_state <= CHA4;
                        end
                        else begin
                        end
                    end

                    else begin
                    end

                //һ��ʧ�ܵ�װ��
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
            CHA3    :    next_state = (cha3_tf_done == 1'b1) ? IDLE : CHA3;
            CHA4    :    next_state = (cha4_tf_done == 1'b1) ? IDLE : CHA4;
            default :    next_state = IDLE;
        endcase
    end
end

always@(posedge mclk or posedge puc_rst)begin
    if(puc_rst == 1'b1)begin
        last_txf_cha <= 3'b0;
        cha0_tri     <= 1'b0;
        cha1_tri     <= 1'b0;
        cha2_tri     <= 1'b0;
        cha3_tri     <= 1'b0;
        cha4_tri     <= 1'b0;
    end
    else begin
        case(current_state)
            IDLE    :    begin
            end
            CHA0    :    begin
                last_txf_cha <= 5'b00_001;
                cha0_tri      = (cha0_tf_done == 1'b1 ) ? 1'b0 : dma0_tri;
            end
            CHA1    :begin
                last_txf_cha <= 5'b00_010;
                cha1_tri      = (cha1_tf_done == 1'b1 ) ? 1'b0 : dma1_tri;
            end
            CHA2    :begin
                last_txf_cha <= 5'b00_100;
                cha2_tri      = (cha2_tf_done == 1'b1 ) ? 1'b0 : dma2_tri;
            end
            CHA3    :begin
                last_txf_cha <= 5'b01_000 ;
                cha3_tri      = (cha3_tf_done == 1'b1 ) ? 1'b0 : dma3_tri;
            end
            CHA4    :begin
                last_txf_cha <= 5'b10_000;
                cha4_tri      = (cha4_tf_done == 1'b1 ) ? 1'b0 : dma4_tri;
            end                        
            default : begin
            end
        endcase
    end
end


//FSM for sim
// synthesis translate_off
reg                [63:0]                state_ascii;
always @ ( * ) begin
        case(current_state)
        IDLE       :        state_ascii        <= "IDLE   ";
        CHA0       :        state_ascii        <= "CHA0   ";
        CHA1       :        state_ascii        <= "CHA1   ";
        CHA2       :        state_ascii        <= "CHA2   ";
        CHA3       :        state_ascii        <= "CHA3   ";    
        CHA4       :        state_ascii        <= "CHA4   ";    
        default    :        state_ascii        <= "default";
        endcase
end
// synthesis translate_on




endmodule // dma_priority


