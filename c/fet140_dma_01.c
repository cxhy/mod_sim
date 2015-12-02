//******************************************************************************
//  MSP-FET430P140 Demo - DMA0, Repeated Burst to-from RAM, Software Trigger
//
//  Description: A 16 word block from 220h-240h is transfered to 240h-260h
//  using DMA0 in a burst block using software DMAREQ trigger.
//  After each transfer, source, destination and DMA size are
//  reset to inital software setting because DMA transfer mode 5 is used.
//  P1.0 is toggled durring DMA transfer only for demonstration purposes.
//  * RAM location 0x220 - 0x260 used - always make sure no compiler conflict *
//  ACLK = n/a, MCLK = SMCLK = default DCO ~ 800k
//  //* MSP430F169 Device Required *//
//
//               MSP430F169
//            -----------------
//        /|\|              XIN|-
//         | |                 |
//         --|RST          XOUT|-
//           |                 |
//           |             P1.0|-->LED
//
//  M. Buccini
//  Texas Instruments Inc.
//  Feb 2005
//  Built with CCE Version: 3.2.0 and IAR Embedded Workbench Version: 3.21A
//******************************************************************************

#include  <msp430x16x.h>

void main(void)
{
  WDTCTL = WDTPW + WDTHOLD;                 // Stop watchdog
  unsigned int i=0 ;
  //unsigned int j=0;
  //unsigned int z=0;
 // unsigned char temp=0x00 ;
  
// #pragma location=0x0200 
//  __no_init static char data[5];
  __no_init  static unsigned char data_0[96] @ 0x0200 ;
  __no_init  static unsigned char data_1[96] @ 0x0300 ;
  __no_init  static unsigned char data_3[96] @ 0x0500 ;
//  P3DIR = 0xff;
   
 // P1DIR |= 0x01;                            // P1.0  output
 // P6DIR |= 0x00;  
  DMA0SA = 0x0200;                          // Start block address
  DMA0DA = 0x02f0;                          // Destination block address
  DMA0SZ = 0x0020;                           // Block size
 
  
  DMA1SA = 0x0300;                          // Start block address
  DMA1DA = 0x03f0;                          // Destination block address
  DMA1SZ = 0x0020;                           // Block size
  
  
  // DMA2SA = 0x0400;                          // Start block address
  // DMA2DA = 0x04f0;                          // Destination block address
  // DMA2SZ = 0x0020;                           // Block size
  
  
  DMA3SA = 0x0500;                          // Start block address
  DMA3DA = 0x05f0;                          // Destination block address
  DMA3SZ = 0x0020;                           // Block size
  
  
  
  // DMA4SA = 0x0600;                          // Start block address
  // DMA4DA = 0x06f0;                          // Destination block address
  // DMA4SZ = 0x0020;                           // Block size
  
  
  DMA0CTL = DMADT_0 + DMASRCBYTE + DMASRCINCR_3 + DMADSTBYTE + DMAEN; // Rpt, inc SRC, DST
  DMA1CTL = DMADT_0 + DMASRCBYTE + DMASRCINCR_3 + DMADSTBYTE + DMAEN; // Rpt, inc SRC, DST
  // DMA2CTL = DMADT_1 + DMASRCBYTE + DMASRCINCR_3 + DMADSTBYTE + DMAEN; // Rpt, inc SRC, DST
  DMA3CTL = 0*0x1000u + 0x0040u + 3*0x0100u + 0x0080u + 0x0010u; // Rpt, inc SRC, DST
  // DMA4CTL = DMADT_1 + DMASRCBYTE + DMASRCINCR_3 + DMADSTBYTE + DMAEN; // Rpt, inc SRC, DST
  DMACTL1 = ROUNDROBIN;

  for (;;)                                  // Repeat
  {
  for(i=0;i<50;i++)
     {
       data_0[i]=i;
     }
    for(i=0;i<50;i++)
     {
       data_1[i]=i;
     }
  for(i=0;i<50;i++)
     {
       data_3[i]=i;
     }  
//     for(z=0; z<4; z++)
//     {
//        for(j=8*z; j<(8*z+8); j++)
//       {
//          P2OUT=data[j];
//        }
//     }
   
//    P1OUT |= 0x01;                          // Set P1.0 (LED on)
        //DMA0CTL |= DMAREQ;                      // Trigger block transfer
        //DMA1CTL |= DMAREQ;                      // Trigger block transfer  
        // DMA1CTL |= DMAREQ;                      // Trigger block transfer
        //DMA2CTL |= DMAREQ;                      // Trigger block transfer
      //DMA3CTL |= DMAREQ;                      // Trigger block transfer
       DMA3CTL = |= 0x0001u ;        
        // DMA4CTL |= DMAREQ;                      // Trigger block transfer
//    P1OUT &= ~0x01;                         // Clear P1.0 (LED off)
//    P3OUT = P6IN;
  }
}

// void InitDma0()
// {
//   DMACTL0 &= DMA0TSEL_0;  //清除原来的触发源
//   DMACTL0 |= DMA0TSEL_0;  //选择触发源：软件触发
//   DMA0CTL  &= DMADT_0;  //清除原来的传输模式

//   //选择传输模式：块传输。目的地址自动增加。源地址自动增加。
//   //目的单元的存储单位为字节。源单元的存储单位为字节
//   DMA0CTL |= DMADT_1+DMADSTINCR_3+DMASRCINCR_3+DMADSTBYTE+DMASRCBYTE;
// }


// void InitDma1()
// {
//   DMACTL0 &= DMA1TSEL_0;  //清除原来的触发源
//   DMACTL0 |= DMA1TSEL_0;  //选择触发源：软件触发
//   DMA1CTL  &= DMADT_0;  //清除原来的传输模式

//   //选择传输模式：块传输。目的地址自动增加。源地址自动增加。
//   //目的单元的存储单位为字节。源单元的存储单位为字节
//   DMA1CTL |= DMADT_1+DMADSTINCR_3+DMASRCINCR_3+DMADSTBYTE+DMASRCBYTE;

// }

// void InitDma2()
// {
//   DMACTL0 &= DMA2TSEL_0;  //清除原来的触发源
//   DMACTL0 |= DMA2TSEL_0;  //选择触发源：软件触发
//   DMA2CTL  &= DMADT_0;  //清除原来的传输模式

//   //选择传输模式：块传输。目的地址自动增加。源地址自动增加。
//   //目的单元的存储单位为字节。源单元的存储单位为字节。
//   DMA2CTL |= DMADT_1+DMADSTINCR_3+DMASRCINCR_3+DMADSTBYTE+DMASRCBYTE;
// }


// /****************************************************************************
// 打开或关闭DMA
// doit：0：停止  100：运行  其他：什么都不做，
// which：操作的DMA的通道号 0~2
// ****************************************************************************/
// void OpenDma(unsigned char doit,unsigned which)
// {
//   unsigned int *pr;
//   switch(which)
//   {
//     case 0:
//       pr= (unsigned int *)DMA0CTL_;
//     break;
//     case 1:
//       pr= (unsigned int *)DMA1CTL_;
//     break;
//     case 2:
//       pr= (unsigned int *)DMA2CTL_;
//     break;
//   }
//   if(doit==0)
//   {
//     *pr &= ~DMAEN;
//   }
//   else if(doit==100)
//   {
//     *pr |= DMAEN;
//   }
// }

// /****************************************************************************
// 设置DMA传输的源、目标地址
// which：DMA通道号0~2
// src_adr：源地址
// det_adr：目标地址
// size：传送字或者字节数目。
// ****************************************************************************/
// void DmaAdr(unsigned char which,unsigned int src_adr,unsigned int det_adr,unsigned int size )
// {
//   if(which==0)
//   {
//     DMA0SA=src_adr;
//     DMA0DA=det_adr;
//     DMA0SZ=size;
//   }
//   else if(which==1)
//   {
//     DMA1SA=src_adr;
//     DMA1DA=det_adr;
//     DMA1SZ=size;
//   }
//   else
//   {
//     DMA2SA=src_adr;
//     DMA2DA=det_adr;
//     DMA2SZ=size;
//   }
// }

// /****************************************************************************
// 软件触发DMA
// which：操作的DMA的通道号 0~2
// ****************************************************************************/
// void DmaSoftGo(unsigned char which)
// {
//   switch(which)
//   {
//     case 0:
//       DMA0CTL |= DMAREQ;
//     break;
//     case 1:
//       DMA1CTL |= DMAREQ;
//     break;
//     case 2:
//       DMA2CTL |= DMAREQ;
//     break;
//   }
// }