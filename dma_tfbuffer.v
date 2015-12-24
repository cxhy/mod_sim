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
// $CreatDate:   2015-11-19 15:21:53
// $LastChangedBy: guodezheng $
// $LastChangedDate:  2015-12-24 10:00:14
//----------------------------------------------------------------------------
//
// *File Name: dma_tfbuffer.v
//
// *Module Description:
//                       进行把enoder和decoder的数据暂时存储在018f和0190寄存器下面。
//                       可以让外部读取这两个寄存器下的数据以及向这两个地址下写数据。
//
// *Author(s):
//              - Guodezheng cxhy1981@gmail.com,
//
//----------------------------------------------------------------------------

// encoder_buffer 01cc
// decoder_buffer 01ce

module dma_tfbuffer(
    //Inputs
    mclk,
    puc_rst,
    per_addr,
    per_din,
    per_en,
    per_we,
    encoder_buffer_din,
    //Outputs
    decoder_buffer_dout,
    code_ctrl,
    per_dout
);

 input                      mclk;
 input                      puc_rst;
 input          [13:0]      per_addr;
 input          [15:0]      per_din;
 input                      per_en;
 input          [1:0]       per_we;
 input          [7:0]       encoder_buffer_din;

 output         [7:0]       decoder_buffer_dout;
 output         [7:0]       code_ctrl;
 output         [15:0]      per_dout;

 parameter [14:0]               BASE_ADDR = 15'h01aa;
 parameter DEC_WD    = 3;
 parameter [DEC_WD-1 :0] ENCODER_BUFFERIN            = 'h00,
                         DECODER_BUFFEROUT           = 'h02,
                         CODE_CTRLOUT                = 'h04;

parameter                DEC_SZ  = (1 << DEC_WD);
parameter [DEC_SZ-1:0]   DEC_REG = {{DEC_SZ-1{1'b0}},1'b1};

parameter [DEC_SZ-1:0]   ENCODER_BUFFERIN_D  = (DEC_REG << ENCODER_BUFFERIN),
                         DECODER_BUFFEROUT_D = (DEC_REG << DECODER_BUFFEROUT),
                         CODE_CTRLOUT_D      = (DEC_REG << CODE_CTRLOUT);

wire           reg_sel          = per_en & (per_addr [13:DEC_WD-1] == BASE_ADDR[14:DEC_WD]);
wire      [DEC_WD-1:0] reg_addr = {1'b0,per_addr[DEC_WD-2:0]};
wire      [DEC_SZ-1:0] reg_dec  = (ENCODER_BUFFERIN_D         & {DEC_SZ{(reg_addr == ( ENCODER_BUFFERIN       >>1))}})|
                                  (DECODER_BUFFEROUT_D        & {DEC_SZ{(reg_addr == ( DECODER_BUFFEROUT      >>1))}})|
                                  (CODE_CTRLOUT_D             & {DEC_SZ{(reg_addr == ( CODE_CTRLOUT           >>1))}});

wire              reg_lo_write =  per_we[0] & reg_sel;
wire              reg_hi_write =  per_we[1] & reg_sel;
wire              reg_read     = ~|per_we   & reg_sel;

wire [DEC_SZ-1:0] reg_hi_wr    = reg_dec & {DEC_SZ{reg_hi_write}};
wire [DEC_SZ-1:0] reg_lo_wr    = reg_dec & {DEC_SZ{reg_lo_write}};
wire [DEC_SZ-1:0] reg_rd       = reg_dec & {DEC_SZ{reg_read}};


reg  [7:0] decoder_reg;

wire       decoder_reg_wr  = DECODER_BUFFEROUT[0] ? reg_hi_wr[DECODER_BUFFEROUT]   : reg_lo_wr[DECODER_BUFFEROUT];
wire [7:0] decoder_reg_nxt;
// wire [7:0] decoder_reg_nxt_dly1 <= decoder_reg_nxt;
// wire [7:0] decoder_reg_nxt_dly2 <= decoder_reg_nxt_dly1;
// wire   [7:0] decoder_reg_nxt;
// always @(posedge mclk or posedge puc_rst) begin
// 	if (puc_rst) begin
// 		// reset
//         decoder_reg_nxt <= 8'b0;
// 	end
// 	else if () begin

// 	end
// end
reg [7:0] decoder_reg_nxt_reg;
reg [7:0] decoder_reg_nxt_reg_dly1;
reg [7:0] decoder_reg_nxt_reg_dly2;
reg [7:0] decoder_reg_nxt_reg_dly3;
reg [7:0] decoder_reg_nxt_reg_dly4;
reg [7:0] decoder_reg_nxt_reg_dly5;
reg [7:0] decoder_reg_nxt_reg_dly6;
reg [7:0] decoder_reg_nxt_reg_dly7;
reg [7:0] decoder_reg_nxt_reg_dly8;
reg [7:0] decoder_reg_nxt_reg_dly9;
reg [7:0] decoder_reg_nxt_reg_dly10;

always @(posedge mclk or posedge puc_rst) begin
	if (puc_rst) begin
		// reset
		decoder_reg_nxt_reg <= 8'b0;
	end
	else begin
        decoder_reg_nxt_reg       <=  per_din[7:0];
        decoder_reg_nxt_reg_dly1  <= decoder_reg_nxt_reg;
        decoder_reg_nxt_reg_dly2  <= decoder_reg_nxt_reg_dly1;
        decoder_reg_nxt_reg_dly3  <= decoder_reg_nxt_reg_dly2;
        decoder_reg_nxt_reg_dly4  <= decoder_reg_nxt_reg_dly3;
        decoder_reg_nxt_reg_dly5  <= decoder_reg_nxt_reg_dly4;
        decoder_reg_nxt_reg_dly6  <= decoder_reg_nxt_reg_dly5;
        decoder_reg_nxt_reg_dly7  <= decoder_reg_nxt_reg_dly6;
        decoder_reg_nxt_reg_dly8  <= decoder_reg_nxt_reg_dly7;
        decoder_reg_nxt_reg_dly9  <= decoder_reg_nxt_reg_dly8;
        decoder_reg_nxt_reg_dly10 <= decoder_reg_nxt_reg_dly9;
	end
end

assign decoder_reg_nxt = decoder_reg_nxt_reg_dly1;

always @(posedge mclk or posedge puc_rst)
	if (puc_rst)                decoder_reg <= 8'h0;
	else if (decoder_reg_wr)    decoder_reg <= decoder_reg_nxt;

assign decoder_buffer_dout = decoder_reg ;

reg  [7:0] code_ctrl_reg;

wire       code_ctrl_reg_wr  = CODE_CTRLOUT_D[0] ? reg_hi_wr[CODE_CTRLOUT] : reg_lo_wr[CODE_CTRLOUT];
wire [7:0] code_ctrl_reg_nxt = CODE_CTRLOUT[0] ? per_din[15:8]                  : per_din[7:0];

always @(posedge mclk or posedge puc_rst)
    if (puc_rst)                   code_ctrl_reg <= 8'h0;
    else if (code_ctrl_reg_wr)     code_ctrl_reg <= code_ctrl_reg_nxt;

assign code_ctrl = code_ctrl_reg ;



wire [15:0] decoder_reg_rd   = {8'h0, (decoder_reg         & {8{reg_rd[decoder_buffer_dout]}})} << (8 & {4{decoder_buffer_dout[0]}});
wire [15:0] code_ctrl_reg_rd = {8'h0, (code_ctrl_reg       & {8{reg_rd[code_ctrl_reg]}})}       << (8 & {4{code_ctrl_reg[0]}});

wire [15:0] per_dout  =  decoder_reg_rd |
                         code_ctrl_reg ;

//en_buffer_din
endmodule  //dma_tfbuffer.v