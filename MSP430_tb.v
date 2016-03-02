module  tb_openMSP430;

output
cpu_en            
dbg_en            
dbg_i2c_addr      
dbg_i2c_broadcast 
dbg_i2c_scl       
dbg_i2c_sda_in    
dbg_uart_rxd      
dco_clk           
dmem_dout         
irq               
lfxt_clk          
dma_addr          
dma_din           
dma_en            
dma_priority      
dma_we            
dma_wkup         
nmi               
per_dout          
pmem_dout         
reset_n           
scan_enable       
scan_mode         
wkup              


reg               dco_enable;

initial
  begin
     // Initialize data memory
     for (tb_idx=0; tb_idx < `DMEM_SIZE/2; tb_idx=tb_idx+1)
       dmem_0.mem[tb_idx] = 16'h0000;

     // Initialize program memory
     #10 $readmemh("./pmem.mem", pmem_0.mem);
  end


//
// Generate Clock & Reset
//------------------------------
initial
  begin
     dco_clk          = 1'b0;
     dco_local_enable = 1'b0;
     forever
       begin
          #25;   // 20 MHz
          dco_local_enable = (dco_enable===1) ? dco_enable : (dco_wkup===1);
          if (dco_local_enable | scan_mode)
            dco_clk = ~dco_clk;
       end
  end

initial
  begin
     lfxt_clk          = 1'b0;
     lfxt_local_enable = 1'b0;
     forever
       begin
          #763;  // 655 kHz
          lfxt_local_enable = (lfxt_enable===1) ? lfxt_enable : (lfxt_wkup===1);
          if (lfxt_local_enable)
            lfxt_clk = ~lfxt_clk;
       end
  end

initial
  begin
     reset_n       = 1'b1;
     #93;
     reset_n       = 1'b0;
     #593;
     reset_n       = 1'b1;
  end

initial
  begin

     irq                     = {`IRQ_NR-2{1'b0}};
     nmi                     = 1'b0;

     cpu_en                  = 1'b1;
     dbg_en                  = 1'b0;
     dbg_uart_rxd_sel        = 1'b0;
     dbg_uart_rxd_dly        = 1'b1;
     dbg_uart_rxd_pre        = 1'b1;
     dbg_uart_rxd_meta       = 1'b0;
     dbg_uart_buf            = 16'h0000;
     dbg_uart_rx_busy        = 1'b0;
     dbg_uart_tx_busy        = 1'b0;
     dbg_scl_master_sel      = 1'b0;
     dbg_scl_master_dly      = 1'b1;
     dbg_scl_master_pre      = 1'b1;
     dbg_scl_master_meta     = 1'b0;
     dbg_sda_master_out_sel  = 1'b0;
     dbg_sda_master_out_dly  = 1'b1;
     dbg_sda_master_out_pre  = 1'b1;
     dbg_sda_master_out_meta = 1'b0;
     dbg_i2c_string          = "";
     p1_din                  = 8'h00;
     p2_din                  = 8'h00;
     p3_din                  = 8'h00;
     p4_din                  = 8'h00;
     p5_din                  = 8'h00;
     p6_din                  = 8'h00;
     inclk                   = 1'b0;
     taclk                   = 1'b0;
     ta_cci0a                = 1'b0;
     ta_cci0b                = 1'b0;
     ta_cci1a                = 1'b0;
     ta_cci1b                = 1'b0;
     ta_cci2a                = 1'b0;
     ta_cci2b                = 1'b0;
     scan_enable             = 1'b0;
     scan_mode               = 1'b0;
  end

endmodule