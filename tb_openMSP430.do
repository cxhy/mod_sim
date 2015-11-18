vlib work
vmap work work

vlog -work work tb_openMSP430.v
vlog -work work openMSP430.v


vcom -work work dma_channel.vhd
vlog -work work dma_priority.v
vlog -work work dma_master.v

vlog -work work io_cell.v
vlog -work work msp_debug.v
vlog -work work omsp_alu.v
vlog -work work omsp_and_gate.v
vlog -work work omsp_clock_gate.v
vlog -work work omsp_clock_module.v
vlog -work work omsp_clock_mux.v
vlog -work work omsp_dbg.v
vlog -work work omsp_dbg_hwbrk.v
vlog -work work omsp_dbg_i2c.v
vlog -work work omsp_dbg_uart.v
vlog -work work omsp_execution_unit.v
vlog -work work omsp_frontend.v
vlog -work work omsp_gpio.v
vlog -work work omsp_mem_backbone.v
vlog -work work omsp_multiplier.v
vlog -work work omsp_register_file.v
vlog -work work omsp_scan_mux.v
vlog -work work omsp_sfr.v
vlog -work work omsp_sync_cell.v
vlog -work work omsp_sync_reset.v
vlog -work work omsp_timerA.v
vlog -work work omsp_timerA_defines.v
vlog -work work omsp_timerA_undefines.v
vlog -work work omsp_wakeup_cell.v
vlog -work work omsp_watchdog.v
vlog -work work openMSP430_defines.v
vlog -work work openMSP430_undefines.v
vlog -work work ram.v
vlog -work work template_periph_8b.v
vlog -work work timescale.v

vsim -novopt tb_openMSP430
#add wave sim:/tb_openMSP430/dma_master_0/dma_priority_u/*
#add wave  \
#sim:/tb_openMSP430/dma_master_0/dma_addr \
#sim:/tb_openMSP430/dma_master_0/dma_din \
#sim:/tb_openMSP430/dma_master_0/dma_en \
#sim:/tb_openMSP430/dma_master_0/dma_we \
#sim:/tb_openMSP430/dma_master_0/mclk \
#sim:/tb_openMSP430/dma_master_0/dma_dout \
#sim:/tb_openMSP430/dma_master_0/dma_ready \
#sim:/tb_openMSP430/dma_master_0/dma_resp
#add wave sim:/tb_openMSP430/template_periph_8b_0/*
#add wave sim:/tb_openMSP430/gpio_0/*
#添加P3口和P6口的仿真信号
add wave  \
sim:/tb_openMSP430/gpio_0/P3_EN \
sim:/tb_openMSP430/gpio_0/P6_EN
add wave  \
sim:/tb_openMSP430/gpio_0/P3_EN_MSK \
sim:/tb_openMSP430/gpio_0/P6_EN_MSK
add wave  \
sim:/tb_openMSP430/gpio_0/P3IN \
sim:/tb_openMSP430/gpio_0/P3OUT \
sim:/tb_openMSP430/gpio_0/P3DIR \
sim:/tb_openMSP430/gpio_0/P3SEL
add wave  \
sim:/tb_openMSP430/gpio_0/P6IN \
sim:/tb_openMSP430/gpio_0/P6OUT \
sim:/tb_openMSP430/gpio_0/P6DIR \
sim:/tb_openMSP430/gpio_0/P6SEL
add wave  \
sim:/tb_openMSP430/gpio_0/p3_dout \
sim:/tb_openMSP430/gpio_0/p3_dout_en \
sim:/tb_openMSP430/gpio_0/p3_sel \
sim:/tb_openMSP430/gpio_0/p6_dout \
sim:/tb_openMSP430/gpio_0/p6_dout_en \
sim:/tb_openMSP430/gpio_0/p6_sel \
sim:/tb_openMSP430/gpio_0/per_dout \
sim:/tb_openMSP430/gpio_0/mclk \
sim:/tb_openMSP430/gpio_0/p3_din \
sim:/tb_openMSP430/gpio_0/p6_din \
sim:/tb_openMSP430/gpio_0/per_addr \
sim:/tb_openMSP430/gpio_0/per_din \
sim:/tb_openMSP430/gpio_0/per_en \
sim:/tb_openMSP430/gpio_0/per_we \
sim:/tb_openMSP430/gpio_0/puc_rst \
sim:/tb_openMSP430/gpio_0/p3in \
sim:/tb_openMSP430/gpio_0/p3out \
sim:/tb_openMSP430/gpio_0/p3out_wr \
sim:/tb_openMSP430/gpio_0/p3out_nxt \
sim:/tb_openMSP430/gpio_0/p3dir \
sim:/tb_openMSP430/gpio_0/p3dir_wr \
sim:/tb_openMSP430/gpio_0/p3dir_nxt \
sim:/tb_openMSP430/gpio_0/p3sel \
sim:/tb_openMSP430/gpio_0/p3sel_wr \
sim:/tb_openMSP430/gpio_0/p3sel_nxt \
sim:/tb_openMSP430/gpio_0/p6in \
sim:/tb_openMSP430/gpio_0/p6out \
sim:/tb_openMSP430/gpio_0/p6out_wr \
sim:/tb_openMSP430/gpio_0/p6out_nxt \
sim:/tb_openMSP430/gpio_0/p6dir \
sim:/tb_openMSP430/gpio_0/p6dir_wr \
sim:/tb_openMSP430/gpio_0/p6dir_nxt \
sim:/tb_openMSP430/gpio_0/p6sel \
sim:/tb_openMSP430/gpio_0/p6sel_wr \
sim:/tb_openMSP430/gpio_0/p6sel_nxt \
sim:/tb_openMSP430/gpio_0/p3in_rd \
sim:/tb_openMSP430/gpio_0/p3out_rd \
sim:/tb_openMSP430/gpio_0/p3dir_rd \
sim:/tb_openMSP430/gpio_0/p3sel_rd \
sim:/tb_openMSP430/gpio_0/p6in_rd \
sim:/tb_openMSP430/gpio_0/p6out_rd \
sim:/tb_openMSP430/gpio_0/p6dir_rd \
sim:/tb_openMSP430/gpio_0/p6sel_rd

radix -hex
view wave
run 100us

