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

module  dma_master (

// OUTPUTs
    per_dout,                       // Peripheral data output

    dma_addr,                       // Direct Memory Access address
    dma_din,                        // Direct Memory Access data input
    dma_en,                         // Direct Memory Access enable (high active)
    dma_priority,                   // Direct Memory Access priority (0:low / 1:high)
    dma_we,                         // Direct Memory Access write byte enable (high active)
    dma_wkup,                       // ASIC ONLY: DMA Sub-System Wake-up (asynchronous and non-glitchy)
    nmi,                            // Non-maskable interrupt (asynchronous)

// INPUTs
    mclk,                           // Main system clock
    per_addr,                       // Peripheral address
    per_din,                        // Peripheral data input
    per_en,                         // Peripheral enable (high active)
    per_we,                         // Peripheral write enable (high active)
    puc_rst,                        // Main system reset

    dma_dout,                       // Direct Memory Access data output
    dma_ready,                      // Direct Memory Access is complete
    dma_resp                        // Direct Memory Access response (0:Okay / 1:Error)
);

assign nmi                     = 1'b0;
//assign dma_addr                = 15'h0000;
//assign dma_din                 = 16'h0000;
//assign dma_en                  = 1'b0;
//assign dma_priority            = 1'b0;
//assign dma_we                  = 2'b00;
assign dma_wkup                = 1'b0;
//wire     dma_en

// OUTPUTs
//=========Peripheral part
output       [15:0] per_dout;       // Peripheral data output
//=========dma_master part
output       [15:1] dma_addr;
output       [15:0] dma_din;
output              dma_en;
output              dma_priority;
output       [1:0]  dma_we;
output              dma_wkup;
output              nmi;
// INPUTs
//=========Peripheral part
input               mclk;           // Main system clock
input        [13:0] per_addr;       // Peripheral address
input        [15:0] per_din;        // Peripheral data input
input               per_en;         // Peripheral enable (high active)
input         [1:0] per_we;         // Peripheral write enable (high active)
input               puc_rst;        // Main system reset
//========
input        [15:0] dma_dout;
input               dma_ready;
input               dma_resp;

wire          [15:0] dma_ctl0 ;
wire          [15:0] dma_ctl1 ;
wire          [15:0] dma0_ctl ;
wire          [15:0] dma0_sa  ;
wire          [15:0] dma0_da  ;
wire          [15:0] dma0_sz  ;
wire          [15:0] dma1_ctl ;
wire          [15:0] dma1_sa  ;
wire          [15:0] dma1_da  ;
wire          [15:0] dma1_sz  ;
wire          [15:0] dma2_ctl ;
wire          [15:0] dma2_sa  ;
wire          [15:0] dma2_da  ;
wire          [15:0] dma2_sz  ;
wire          [15:0] per_dout ;




dma_decoder dma_decoder_u (
    .mclk              (mclk    ),
    .puc_rst           (puc_rst ),

    .per_addr          (per_addr),
    .per_din           (per_din ),
    .per_en            (per_en  ),
    .per_we            (per_we  ),

    .dma_ctl0          (dma_ctl0),
    .dma_ctl1          (dma_ctl1),
    .dma0_ctl          (dma0_ctl),
    .dma0_sa           (dma0_sa ),
    .dma0_da           (dma0_da ),
    .dma0_sz           (dma0_sz ),
    .dma1_ctl          (dma1_ctl),
    .dma1_sa           (dma1_sa ),
    .dma1_da           (dma1_da ),
    .dma1_sz           (dma1_sz ),
    .dma2_ctl          (dma2_ctl),
    .dma2_sa           (dma2_sa ),
    .dma2_da           (dma2_da ),
    .dma2_sz           (dma2_sz ),
    .per_dout          (per_dout)
     );



//========================================================

wire [3:0]                 dma0_tsel    ;
wire [3:0]                 dma1_tsel    ;
wire [3:0]                 dma2_tsel    ;

wire                       dma0_wkup     ;
wire                       dma0_en       ;
wire  [14:0]               dma0_addr     ;
wire  [15:0]               dma0_din      ;
wire  [1:0]                dma0_we       ;
wire                       dma0_priority ;


wire                       dma1_wkup     ;
wire                       dma1_en       ;
wire  [14:0]               dma1_addr     ;
wire  [15:0]               dma1_din      ;
wire  [1:0]                dma1_we       ;
wire                       dma1_priority ;

wire                       dma2_wkup     ;
wire                       dma2_en       ;
wire  [14:0]               dma2_addr     ;
wire  [15:0]               dma2_din      ;
wire  [1:0]                dma2_we       ;
wire                       dma2_priority ;







assign dma0_tsel = dma_ctl0[3:0]  ;
assign dma1_tsel = dma_ctl0[7:4]  ;
assign dma2_tsel = dma_ctl0[11:8] ;

dma_priority dma_priority_u (
    .mclk                        (mclk),
    .puc_rst                     (puc_rst),

    .dma_ctl0                    (dma_ctl0),
    .dma_ctl1                    (dma_ctl1),
    .dma0_ctl                    (dma0_ctl),
    .dma0_sa                     (dma0_sa),
    .dma0_da                     (dma0_da),
    .dma0_sz                     (dma0_sz),
    .dma1_ctl                    (dma1_ctl),
    .dma1_sa                     (dma1_sa),
    .dma1_da                     (dma1_da),
    .dma1_sz                     (dma1_sz),
    .dma2_ctl                    (dma2_ctl),
    .dma2_sa                     (dma2_sa),
    .dma2_da                     (dma2_da),
    .dma2_sz                     (dma2_sz),

    .cha0_tf_done                (cha0_tf_done),
    .cha1_tf_done                (cha1_tf_done),
    .cha2_tf_done                (cha2_tf_done),


    .dma_priority                (dma_priority),
    .cha0_tri                    (cha0_tri    ),
    .cha1_tri                    (cha1_tri    ),
    .cha2_tri                    (cha2_tri    )
);

dma_channel dma_channel_u0(
    .mclk                        (mclk),
    .puc_rst                     (puc_rst),

    .dmax_ctl                    (dma0_ctl),
    .dmax_sa                     (dma0_sa),
    .dmax_da                     (dma0_da),
    .dmax_sz                     (dma0_sz),
    .dmax_tsel                   (dma0_tsel),

    .trigger                     (cha0_tri),
    .transfer_done               (cha0_tf_done),

    .dma_ready                   (dma_ready),
    .dma_resp                    (dma_resp),
    .dma_dout                    (dma_dout),
    .dma_wkup                    (dma0_wkup    ),
    .dma_en                      (dma0_en      ),
    .dma_addr                    (dma0_addr    ),
    .dma_din                     (dma0_din     ),
    .dma_we                      (dma0_we      )
//    .dma_priority                (dma0_priority)
);

dma_channel dma_channel_u1(
    .mclk                        (mclk),
    .puc_rst                     (puc_rst),

    .dmax_ctl                    (dma1_ctl),
    .dmax_sa                     (dma1_sa),
    .dmax_da                     (dma1_da),
    .dmax_sz                     (dma1_sz),
    .dmax_tsel                   (dma1_tsel),

    .trigger                     (cha1_tri),
    .transfer_done               (cha1_tf_done),

    .dma_ready                   (dma_ready),
    .dma_resp                    (dma_resp),
    .dma_dout                    (dma_dout),
    .dma_wkup                    (dma1_wkup    ),
    .dma_en                      (dma1_en      ),
    .dma_addr                    (dma1_addr    ),
    .dma_din                     (dma1_din     ),
    .dma_we                      (dma1_we      )
//    .dma_priority                (dma1_priority)
);


dma_channel dma_channel_u2(
    .mclk                        (mclk),
    .puc_rst                     (puc_rst),

    .dmax_ctl                    (dma2_ctl),
    .dmax_sa                     (dma2_sa),
    .dmax_da                     (dma2_da),
    .dmax_sz                     (dma2_sz),
    .dmax_tsel                   (dma2_tsel),

    .trigger                     (cha2_tri),
    .transfer_done               (cha2_tf_done),

    .dma_ready                   (dma_ready),
    .dma_resp                    (dma_resp),
    .dma_dout                    (dma_dout),
    .dma_wkup                    (dma2_wkup    ),
    .dma_en                      (dma2_en      ),
    .dma_addr                    (dma2_addr    ),
    .dma_din                     (dma2_din     ),
    .dma_we                      (dma2_we      )
//    .dma_priority                (dma2_priority)
);

assign dma_wkup       =   dma0_wkup | dma1_wkup | dma2_wkup ;
assign dma_en         =   dma0_en   | dma1_en   | dma2_en   ;
assign dma_addr       =   dma0_addr | dma1_addr | dma2_addr ;
assign dma_din        =   dma0_din  | dma1_din  | dma2_din  ;
assign dma_we         =   dma0_we   | dma1_we   | dma2_we   ;










endmodule // dma_master

