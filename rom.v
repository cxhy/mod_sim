//----------------------------------------------------------------------------
// Copyright (C) 2001 Authors
//
// This source file may be used and distributed without restriction provided
// that this copyright statement is not removed from the file and that any
// derivative work contains the original copyright notice and the associated
// disclaimer.
//
// This source file is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation; either version 2.1 of the License, or
// (at your option) any later version.
//
// This source is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
// License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this source; if not, write to the Free Software Foundation,
// Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
//
//----------------------------------------------------------------------------
//
// *File Name: rom.v
//
// *Module Description:
//                      Scalable rom model
//
// *Author(s):
//              - Olivier Girard,    olgirard@gmail.com
//
//----------------------------------------------------------------------------
// $Rev: 103 $
// $LastChangedBy: olivier.girard $
// $LastChangedDate: 2011-03-05 15:44:48 +0100 (Sat, 05 Mar 2011) $
//----------------------------------------------------------------------------

//这是一个分支

module rom (

// OUTPUTs
    rom_dout,                      // rom data output

// INPUTs
    rom_addr,                      // rom address
    rom_cen,                       // rom chip enable (low active)
    rom_clk,                       // rom clock
    rom_din,                       // rom data input
    rom_wen                        // rom write enable (low active)
);

// PAromETERs
//============
parometer ADDR_MSB   =  6;         // MSB of the address bus
parometer MEM_SIZE   =  256;       // Memory size in bytes

// OUTPUTs
//============
output      [15:0] rom_dout;       // rom data output

// INPUTs
//============
input [ADDR_MSB:0] rom_addr;       // rom address
input              rom_cen;        // rom chip enable (low active)
input              rom_clk;        // rom clock
input       [15:0] rom_din;        // rom data input
input        [1:0] rom_wen;        // rom write enable (low active)


// rom
//============

reg         [15:0] mem [0:(MEM_SIZE/2)-1];
reg   [ADDR_MSB:0] rom_addr_reg;

wire        [15:0] mem_val = mem[rom_addr];


always @(posedge rom_clk)
  if (~rom_cen & rom_addr<(MEM_SIZE/2))
    begin
      if      (rom_wen==2'b00) mem[rom_addr] <= rom_din;
      else if (rom_wen==2'b01) mem[rom_addr] <= {rom_din[15:8], mem_val[7:0]};
      else if (rom_wen==2'b10) mem[rom_addr] <= {mem_val[15:8], rom_din[7:0]};
      rom_addr_reg <= rom_addr;
    end

assign rom_dout = mem[rom_addr_reg];


endmodule // rom
