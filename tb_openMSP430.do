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
add wave sim:/tb_openMSP430/template_periph_8b_0/*
radix -hex
view wave
run -all

