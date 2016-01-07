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
// $LastChangedDate:  2015-12-28 16:09:15
//----------------------------------------------------------------------------
// *File Name: dma_master.v
//
// *Module Description:
//                       DMA主机
//
// *Author(s):
//              - Guodezheng cxhy1981@gmail.com,
//
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
    tansfer_end,

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
// assign dma_priority            = 1'b0;
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
output              tansfer_end;
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
//=============================================================================
// 1)  PARAMETER DECLARATION
//=============================================================================

// Register base address (must be aligned to decoder bit width)
parameter       [14:0] BASE_ADDR   = 15'h0100;

// Decoder bit width (defines how many bits are considered for address decoding)
parameter              DEC_WD      =  8;

// Register addresses offset
parameter [DEC_WD-1:0] DMACTL0      = 'h22,
                       DMACTL1      = 'h24,
                       DMA0CTL      = 'hE0,
                       DMA0SA       = 'hE2,
                       DMA0DA       = 'hE4,
                       DMA0SZ       = 'hE6,
                       DMA1CTL      = 'hE8,
                       DMA1SA       = 'hEA,
                       DMA1DA       = 'hEC,
                       DMA1SZ       = 'hEE,
                       DMA2CTL      = 'hF0,
                       DMA2SA       = 'hF2,
                       DMA2DA       = 'hF4,
                       DMA2SZ       = 'hF6,
                       DMA3CTL      = 'hD8,
                       DMA3SA       = 'hDA,
                       DMA3DA       = 'hDC,
                       DMA3SZ       = 'hDE,
                       DMA4CTL      = 'hD0,
                       DMA4SA       = 'hD2,
                       DMA4DA       = 'hD4,
                       DMA4SZ       = 'hD6;

// Register one-hot decoder utilities
parameter              DEC_SZ      =  (1 << DEC_WD);
parameter [DEC_SZ-1:0] BASE_REG    =  {{DEC_SZ-1{1'b0}}, 1'b1};

// Register one-hot decoder
parameter [DEC_SZ-1:0] DMACTL0_D          = (BASE_REG << DMACTL0),
                       DMACTL1_D          = (BASE_REG << DMACTL1),
                       DMA0CTL_D          = (BASE_REG << DMA0CTL),
                       DMA0SA_D           = (BASE_REG << DMA0SA ),
                       DMA0DA_D           = (BASE_REG << DMA0DA ),
                       DMA0SZ_D           = (BASE_REG << DMA0SZ ),
                       DMA1CTL_D          = (BASE_REG << DMA1CTL),
                       DMA1SA_D           = (BASE_REG << DMA1SA ),
                       DMA1DA_D           = (BASE_REG << DMA1DA ),
                       DMA1SZ_D           = (BASE_REG << DMA1SZ ),
                       DMA2CTL_D          = (BASE_REG << DMA2CTL),
                       DMA2SA_D           = (BASE_REG << DMA2SA ),
                       DMA2DA_D           = (BASE_REG << DMA2DA ),
                       DMA2SZ_D           = (BASE_REG << DMA2SZ ),
                       DMA3CTL_D          = (BASE_REG << DMA3CTL),
                       DMA3SA_D           = (BASE_REG << DMA3SA ),
                       DMA3DA_D           = (BASE_REG << DMA3DA ),
                       DMA3SZ_D           = (BASE_REG << DMA3SZ ),
                       DMA4CTL_D          = (BASE_REG << DMA4CTL),
                       DMA4SA_D           = (BASE_REG << DMA4SA ),
                       DMA4DA_D           = (BASE_REG << DMA4DA ),
                       DMA4SZ_D           = (BASE_REG << DMA4SZ );

//============================================================================
// 2)  REGISTER DECODER
//============================================================================

// Local register selection
wire              reg_sel   =  per_en & (per_addr[13:DEC_WD-1]==BASE_ADDR[14:DEC_WD]);

// Register local address
wire [DEC_WD-1:0] reg_addr  =  {per_addr[DEC_WD-2:0], 1'b0};

// Register address decode
wire [DEC_SZ-1:0] reg_dec   =  (DMACTL0_D  &  {DEC_SZ{(reg_addr == DMACTL0 )}})  |
                               (DMACTL1_D  &  {DEC_SZ{(reg_addr == DMACTL1 )}})  |
                               (DMA0CTL_D  &  {DEC_SZ{(reg_addr == DMA0CTL )}})  |
                               (DMA0SA_D   &  {DEC_SZ{(reg_addr == DMA0SA  )}})  |
                               (DMA0DA_D   &  {DEC_SZ{(reg_addr == DMA0DA  )}})  |
                               (DMA0SZ_D   &  {DEC_SZ{(reg_addr == DMA0SZ  )}})  |
                               (DMA1CTL_D  &  {DEC_SZ{(reg_addr == DMA1CTL )}})  |
                               (DMA1SA_D   &  {DEC_SZ{(reg_addr == DMA1SA  )}})  |
                               (DMA1DA_D   &  {DEC_SZ{(reg_addr == DMA1DA  )}})  |
                               (DMA1SZ_D   &  {DEC_SZ{(reg_addr == DMA1SZ  )}})  |
                               (DMA2CTL_D  &  {DEC_SZ{(reg_addr == DMA2CTL )}})  |
                               (DMA2SA_D   &  {DEC_SZ{(reg_addr == DMA2SA  )}})  |
                               (DMA2DA_D   &  {DEC_SZ{(reg_addr == DMA2DA  )}})  |
                               (DMA2SZ_D   &  {DEC_SZ{(reg_addr == DMA2SZ  )}})  |
                               (DMA3CTL_D  &  {DEC_SZ{(reg_addr == DMA3CTL )}})  |
                               (DMA3SA_D   &  {DEC_SZ{(reg_addr == DMA3SA  )}})  |
                               (DMA3DA_D   &  {DEC_SZ{(reg_addr == DMA3DA  )}})  |
                               (DMA3SZ_D   &  {DEC_SZ{(reg_addr == DMA3SZ  )}})  |
                               (DMA4CTL_D  &  {DEC_SZ{(reg_addr == DMA4CTL )}})  |
                               (DMA4SA_D   &  {DEC_SZ{(reg_addr == DMA4SA  )}})  |
                               (DMA4DA_D   &  {DEC_SZ{(reg_addr == DMA4DA  )}})  |
                               (DMA4SZ_D   &  {DEC_SZ{(reg_addr == DMA4SZ  )}})  ;



// Read/Write probes
wire              reg_write =  |per_we & reg_sel;
wire              reg_read  = ~|per_we & reg_sel;

// Read/Write vectors
wire [DEC_SZ-1:0] reg_wr    = reg_dec & {DEC_SZ{reg_write}};
wire [DEC_SZ-1:0] reg_rd    = reg_dec & {DEC_SZ{reg_read}};


//============================================================================
// 3) REGISTERS
//============================================================================

// dma_ctl0 Register
//-----------------
reg  [15:0] dma_ctl0;

wire        dma_ctl0_wr = reg_wr[DMACTL0];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)         dma_ctl0 <=  16'h0000;
  else if (dma_ctl0_wr) dma_ctl0 <=  per_din;


// dmactl1 Register
//-----------------
reg  [15:0] dma_ctl1;

wire        dma_ctl1_wr = reg_wr[DMACTL1];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        dma_ctl1 <=  16'h0000;
  else if (dma_ctl1_wr) dma_ctl1 <=  per_din;


// dma0_ctl Register
//-----------------
reg  [15:0] dma0_ctl;

wire        dma0_ctl_wr = reg_wr[DMA0CTL];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        dma0_ctl <=  16'h0000;
  else if (dma0_ctl_wr) dma0_ctl <=  per_din;


// dma0sa Register
//-----------------
reg  [15:0] dma0_sa;

wire        dma0_sa_wr = reg_wr[DMA0SA];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        dma0_sa <=  16'h0000;
  else if (dma0_sa_wr) dma0_sa <=  per_din;


// dma0da Register
//-----------------
reg  [15:0] dma0_da;

wire        dma0_da_wr = reg_wr[DMA0DA];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        dma0_da <=  16'h0000;
  else if (dma0_da_wr) dma0_da <=  per_din;


// dma0sz Register
//-----------------
reg  [15:0] dma0_sz;

wire        dma0_sz_wr = reg_wr[DMA0SZ];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        dma0_sz <=  16'h0000;
  else if (dma0_sz_wr) dma0_sz <=  per_din;

// dma1ctl Register
//-----------------
reg  [15:0] dma1_ctl;

wire        dma1_ctl_wr = reg_wr[DMA1CTL];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        dma1_ctl <=  16'h0000;
  else if (dma1_ctl_wr) dma1_ctl <=  per_din;


// dma1sa Register
//-----------------
reg  [15:0] dma1_sa;

wire        dma1_sa_wr = reg_wr[DMA1SA];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        dma1_sa <=  16'h0000;
  else if (dma1_sa_wr) dma1_sa <=  per_din;


// dma1da Register
//-----------------
reg  [15:0] dma1_da;

wire        dma1_da_wr = reg_wr[DMA1DA];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        dma1_da <=  16'h0000;
  else if (dma1_da_wr) dma1_da <=  per_din;


// dma1sz Register
//-----------------
reg  [15:0] dma1_sz;

wire        dma1_sz_wr = reg_wr[DMA1SZ];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        dma1_sz <=  16'h0000;
  else if (dma1_sz_wr) dma1_sz <=  per_din;


  // dma2ctl Register
//-----------------
reg  [15:0] dma2_ctl;

wire        dma2_ctl_wr = reg_wr[DMA2CTL];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)         dma2_ctl <=  16'h0000;
  else if (dma2_ctl_wr) dma2_ctl <=  per_din;


// dma2sa Register
//-----------------
reg  [15:0] dma2_sa;

wire        dma2_sa_wr = reg_wr[DMA2SA];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        dma2_sa <=  16'h0000;
  else if (dma2_sa_wr) dma2_sa <=  per_din;


// dma2da Register
//-----------------
reg  [15:0] dma2_da;

wire        dma2_da_wr = reg_wr[DMA2DA];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        dma2_da <=  16'h0000;
  else if (dma2_da_wr) dma2_da <=  per_din;


// dma2sz Register
//-----------------
reg  [15:0] dma2_sz;

wire        dma2_sz_wr = reg_wr[DMA2SZ];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        dma2_sz <=  16'h0000;
  else if (dma2_sz_wr) dma2_sz <=  per_din;

// dma3ctl Register
//-----------------
reg  [15:0] dma3_ctl;

wire        dma3_ctl_wr = reg_wr[DMA3CTL];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        dma3_ctl <=  16'h0000;
  else if (dma3_ctl_wr) dma3_ctl <=  per_din;

// dma3sa Register
//-----------------
reg  [15:0] dma3_sa;

wire        dma3_sa_wr = reg_wr[DMA3SA];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        dma3_sa <=  16'h0000;
  else if (dma3_sa_wr) dma3_sa <=  per_din;

// dma3da Register
//-----------------
reg  [15:0] dma3_da;

wire        dma3_da_wr = reg_wr[DMA3DA];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        dma3_da <=  16'h0000;
  else if (dma3_da_wr) dma3_da <=  per_din;


// dma3sz Register
//-----------------
reg  [15:0] dma3_sz;

wire        dma3_sz_wr = reg_wr[DMA3SZ];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        dma3_sz <=  16'h0000;
  else if (dma3_sz_wr) dma3_sz <=  per_din;


// dma4ctl Register
//-----------------
reg  [15:0] dma4_ctl;

wire        dma4_ctl_wr = reg_wr[DMA4CTL];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        dma4_ctl <=  16'h0000;
  else if (dma4_ctl_wr) dma4_ctl <=  per_din;

// dma4sa Register
//-----------------
reg  [15:0] dma4_sa;

wire        dma4_sa_wr = reg_wr[DMA4SA];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        dma4_sa <=  16'h0000;
  else if (dma4_sa_wr) dma4_sa <=  per_din;

// dma4da Register
//-----------------
reg  [15:0] dma4_da;

wire        dma4_da_wr = reg_wr[DMA4DA];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        dma4_da <=  16'h0000;
  else if (dma4_da_wr) dma4_da <=  per_din;

// dma4sz Register
//-----------------
reg  [15:0] dma4_sz;

wire        dma4_sz_wr = reg_wr[DMA4SZ];

always @ (posedge mclk or posedge puc_rst)
  if (puc_rst)        dma4_sz <=  16'h0000;
  else if (dma4_sz_wr) dma4_sz <=  per_din;

//============================================================================
// 4) DATA OUTPUT GENERATION
//============================================================================




// Data output mux
wire [15:0] dma_ctl0_rd  = dma_ctl0  & {16{reg_rd[DMACTL0]}};
wire [15:0] dma_ctl1_rd  = dma_ctl1  & {16{reg_rd[DMACTL1]}};
wire [15:0] dma0_ctl_rd  = dma0_ctl  & {16{reg_rd[DMA0CTL]}};
wire [15:0] dma0_sa_rd   = dma0_sa   & {16{reg_rd[DMA0SA]}};
wire [15:0] dma0_da_rd   = dma0_da   & {16{reg_rd[DMA0DA]}};
wire [15:0] dma0_sz_rd   = dma0_sz   & {16{reg_rd[DMA0SZ]}};
wire [15:0] dma1_ctl_rd  = dma1_ctl  & {16{reg_rd[DMA1CTL]}};
wire [15:0] dma1_sa_rd   = dma1_sa   & {16{reg_rd[DMA1SA]}};
wire [15:0] dma1_da_rd   = dma1_da   & {16{reg_rd[DMA1DA]}};
wire [15:0] dma1_sz_rd   = dma1_sz   & {16{reg_rd[DMA1SZ]}};
wire [15:0] dma2_ctl_rd  = dma2_ctl  & {16{reg_rd[DMA2CTL]}};
wire [15:0] dma2_sa_rd   = dma2_sa   & {16{reg_rd[DMA2SA]}};
wire [15:0] dma2_da_rd   = dma2_da   & {16{reg_rd[DMA2DA]}};
wire [15:0] dma2_sz_rd   = dma2_sz   & {16{reg_rd[DMA2SZ]}};
wire [15:0] dma3_ctl_rd  = dma3_ctl  & {16{reg_rd[DMA2CTL]}};
wire [15:0] dma3_sa_rd   = dma3_sa   & {16{reg_rd[DMA2SA]}};
wire [15:0] dma3_da_rd   = dma3_da   & {16{reg_rd[DMA2DA]}};
wire [15:0] dma3_sz_rd   = dma3_sz   & {16{reg_rd[DMA2SZ]}};
wire [15:0] dma4_ctl_rd  = dma4_ctl  & {16{reg_rd[DMA2CTL]}};
wire [15:0] dma4_sa_rd   = dma4_sa   & {16{reg_rd[DMA2SA]}};
wire [15:0] dma4_da_rd   = dma4_da   & {16{reg_rd[DMA2DA]}};
wire [15:0] dma4_sz_rd   = dma4_sz   & {16{reg_rd[DMA2SZ]}};


wire [15:0] per_dout   =  dma_ctl0_rd   |
                          dma_ctl1_rd   |
                          dma0_ctl_rd   |
                          dma0_sa_rd    |
                          dma0_da_rd    |
                          dma0_sz_rd    |
                          dma1_ctl_rd   |
                          dma1_sa_rd    |
                          dma1_da_rd    |
                          dma1_sz_rd    |
                          dma2_ctl_rd   |
                          dma2_sa_rd    |
                          dma2_da_rd    |
                          dma2_sz_rd    |
                          dma3_ctl_rd   |
                          dma3_sa_rd    |
                          dma3_da_rd    |
                          dma3_sz_rd    |
                          dma4_ctl_rd   |
                          dma4_sa_rd    |
                          dma4_da_rd    |
                          dma4_sz_rd    ;

//========================================================

wire [3:0]                 dma0_tsel    ;
wire [3:0]                 dma1_tsel    ;
wire [3:0]                 dma2_tsel    ;
wire [3:0]                 dma3_tsel    ;
wire [3:0]                 dma4_tsel    ;

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

wire                       dma3_wkup     ;
wire                       dma3_en       ;
wire  [14:0]               dma3_addr     ;
wire  [15:0]               dma3_din      ;
wire  [1:0]                dma3_we       ;
wire                       dma3_priority ;

wire                       dma4_wkup     ;
wire                       dma4_en       ;
wire  [14:0]               dma4_addr     ;
wire  [15:0]               dma4_din      ;
wire  [1:0]                dma4_we       ;
wire                       dma4_priority ;







assign dma0_tsel = dma_ctl0[3:0]  ;
assign dma1_tsel = dma_ctl0[7:4]  ;
assign dma2_tsel = dma_ctl0[11:8] ;
assign dma3_tsel = dma_ctl0[15:12] ;
assign dma4_tsel = dma_ctl0[15:12] ;

dma_pri  dma_pri_u(
                       .mclk                      (mclk        ),
                       .puc_rst                   (puc_rst     ),

                       .dma_ctl0                  (dma_ctl0    ),
                       .dma_ctl1                  (dma_ctl1    ),
                       .dma0_ctl                  (dma0_ctl    ),
                       .dma0_sa                   (dma0_sa     ),
                       .dma0_da                   (dma0_da     ),
                       .dma0_sz                   (dma0_sz     ),
                       .dma1_ctl                  (dma1_ctl    ),
                       .dma1_sa                   (dma1_sa     ),
                       .dma1_da                   (dma1_da     ),
                       .dma1_sz                   (dma1_sz     ),
                       .dma2_ctl                  (dma2_ctl    ),
                       .dma2_sa                   (dma2_sa     ),
                       .dma2_da                   (dma2_da     ),
                       .dma2_sz                   (dma2_sz     ),
                       .dma3_ctl                  (dma3_ctl    ),
                       .dma3_sa                   (dma3_sa     ),
                       .dma3_da                   (dma3_da     ),
                       .dma3_sz                   (dma3_sz     ),
                       .dma4_ctl                  (dma4_ctl    ),
                       .dma4_sa                   (dma4_sa     ),
                       .dma4_da                   (dma4_da     ),
                       .dma4_sz                   (dma4_sz     ),

                       .cha0_tf_done              (cha0_tf_done),
                       .cha1_tf_done              (cha1_tf_done),
                       .cha2_tf_done              (cha2_tf_done),
                       .cha3_tf_done              (cha3_tf_done),
                       .cha4_tf_done              (cha4_tf_done),

                       .dma_priority              (dma_priority),
                       .cha0_tri                  (cha0_tri    ),
                       .cha1_tri                  (cha1_tri    ),
                       .cha2_tri                  (cha2_tri    ),
                       .cha3_tri                  (cha3_tri    ),
                       .cha4_tri                  (cha4_tri    )
);

// dma_priority dma_priority_u (
//     .mclk                        (mclk),
//     .puc_rst                     (puc_rst),

//     .dma_ctl0                    (dma_ctl0),
//     .dma_ctl1                    (dma_ctl1),
//     .dma0_ctl                    (dma0_ctl),
//     .dma0_sa                     (dma0_sa),
//     .dma0_da                     (dma0_da),
//     .dma0_sz                     (dma0_sz),
//     .dma1_ctl                    (dma1_ctl),
//     .dma1_sa                     (dma1_sa),
//     .dma1_da                     (dma1_da),
//     .dma1_sz                     (dma1_sz),
//     .dma2_ctl                    (dma2_ctl),
//     .dma2_sa                     (dma2_sa),
//     .dma2_da                     (dma2_da),
//     .dma2_sz                     (dma2_sz),

//     .cha0_tf_done                (cha0_tf_done),
//     .cha1_tf_done                (cha1_tf_done),
//     .cha2_tf_done                (cha2_tf_done),


//     .dma_priority                (dma_priority),
//     .cha0_tri                    (cha0_tri    ),
//     .cha1_tri                    (cha1_tri    ),
//     .cha2_tri                    (cha2_tri    )
// );

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

dma_channel dma_channel_u3(
    .mclk                        (mclk),
    .puc_rst                     (puc_rst),

    .dmax_ctl                    (dma3_ctl),
    .dmax_sa                     (dma3_sa),
    .dmax_da                     (dma3_da),
    .dmax_sz                     (dma3_sz),
    .dmax_tsel                   (dma3_tsel),

    .trigger                     (cha3_tri),
    .transfer_done               (cha3_tf_done),

    .dma_ready                   (dma_ready),
    .dma_resp                    (dma_resp),
    .dma_dout                    (dma_dout),
    .dma_wkup                    (dma3_wkup    ),
    .dma_en                      (dma3_en      ),
    .dma_addr                    (dma3_addr    ),
    .dma_din                     (dma3_din     ),
    .dma_we                      (dma3_we      )
//    .dma_priority                (dma2_priority)
);

dma_channel dma_channel_u4(
    .mclk                        (mclk),
    .puc_rst                     (puc_rst),

    .dmax_ctl                    (dma4_ctl),
    .dmax_sa                     (dma4_sa),
    .dmax_da                     (dma4_da),
    .dmax_sz                     (dma4_sz),
    .dmax_tsel                   (dma4_tsel),

    .trigger                     (cha4_tri),
    .transfer_done               (cha4_tf_done),

    .dma_ready                   (dma_ready),
    .dma_resp                    (dma_resp),
    .dma_dout                    (dma_dout),
    .dma_wkup                    (dma4_wkup    ),
    .dma_en                      (dma4_en      ),
    .dma_addr                    (dma4_addr    ),
    .dma_din                     (dma4_din     ),
    .dma_we                      (dma4_we      )
//    .dma_priority                (dma2_priority)
);

assign dma_wkup       =   dma0_wkup  | dma1_wkup    | dma2_wkup    | dma3_wkup    | dma4_wkup   ;
assign dma_en         =   dma0_en    | dma1_en      | dma2_en      | dma3_en      | dma4_en     ;
assign dma_addr       =   dma0_addr  | dma1_addr    | dma2_addr    | dma3_addr    | dma4_addr   ;
assign dma_din        =   dma0_din   | dma1_din     | dma2_din     | dma3_din     | dma4_din    ;
assign dma_we         =   dma0_we    | dma1_we      | dma2_we      | dma3_we      | dma4_we     ;
assign tansfer_end    = cha0_tf_done | cha1_tf_done | cha2_tf_done | cha3_tf_done | cha4_tf_done;







//per2dma per2dma_u (
//
//    .mclk                        (mclk),
//    .puc_rst                     (puc_rst),
//
//    .dma_ctl0                    (dma_ctl0),
//    .dma_ctl1                    (dma_ctl1),
//    .dma_ctl                     (dma_ctl),
//    .dma_sa                      (dma_sa),
//    .dma_da                      (dma_da),
//    .dma_sz                      (dma_sz),
//
//    .addr                        (addr),
//    .data                        (data),
//    .transfer_en                 (transfer_en),
//    .size                        (size),
//    .wr_req                      (wr_req),
//    .rd_req                      (rd_req),
//    .priority                    (priority)
//);



//========================================================
//======================================================== DMA_INTERFACE ==============================================//
//wire                 dma_tfx_cancel;
//
//wire [15:0]          dma_wr_8b_addr;
//wire [15:0]          dma_wr_16b_addr;
//wire [15:0]          dma_wr_8b_data;
//wire [15:0]          dma_wr_16b_data;
//wire                 size_wr;
//
//wire [15:0]          dma_rd_8b_addr;
//wire [15:0]          dma_rd_16b_addr;
//wire [15:0]          dma_rd_8b_data;
//wire [15:0]          dma_rd_16b_data;
//wire                 size_rd;
//
//reg  [15:1]          dma_addr;
//reg                  dma_en;
//reg  [15:0]          dma_din;
//reg  [1:0]           dma_we;

//test part



//end of test part


//8bit write
//always@( posedge mclk ) begin
//    dma_addr = dma_wr_8b_addr[15:1];
//    dma_en   = 1'b1;
//    dma_we   = (~size_wr) ? 2'b11             :
//                            dma_wr_8b_addr[0] ? 2'b10 : 2'b01;
//    dma_din  = dma_wr_8b_data;
//    if((~dma_ready) | dma_tfx_cancel)begin
//        dma_en     = 1'b0;
//        dma_we     = 2'b00;
//        dma_addr   = 15'h0000;
//        dma_din    = 16'h0000;
//    end
//end
//








//======================================================== DMA_INTERFACE ==============================================//









endmodule // dma_master

