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
  __no_init  static unsigned char data[96] @ 0x0200 ;
//  P3DIR = 0xff;
  
 // P1DIR |= 0x01;                            // P1.0  output
 // P6DIR |= 0x00;  
  DMA1SA = 0x0200;                          // Start block address
  DMA1DA = 0x0190;                          // Destination block address
  DMA1SZ = 0x0020;                           // Block size
 
  
  DMA1CTL = DMADT_1 + DMASRCBYTE + DMASRCINCR_3 + DMADSTBYTE + DMAEN; // Rpt, inc SRC, DST

  for (;;)                                  // Repeat
  {
  for(i=0;i<=95;i++)
     {
       data[i]=i;
     }
     
//     for(z=0; z<4; z++)
//     {
//        for(j=8*z; j<(8*z+8); j++)
//       {
//          P2OUT=data[j];
//        }
//     }
   
//    P1OUT |= 0x01;                          // Set P1.0 (LED on)
      DMA1CTL |= DMAREQ;                      // Trigger block transfer
//    P1OUT &= ~0x01;                         // Clear P1.0 (LED off)
//    P3OUT = P6IN;
  }
}

// void InitDma0()
// {
//   DMACTL0 &= DMA0TSEL_0;  //���ԭ���Ĵ���Դ
//   DMACTL0 |= DMA0TSEL_0;  //ѡ�񴥷�Դ���������
//   DMA0CTL  &= DMADT_0;  //���ԭ���Ĵ���ģʽ

//   //ѡ����ģʽ���鴫�䡣Ŀ�ĵ�ַ�Զ����ӡ�Դ��ַ�Զ����ӡ�
//   //Ŀ�ĵ�Ԫ�Ĵ洢��λΪ�ֽڡ�Դ��Ԫ�Ĵ洢��λΪ�ֽ�
//   DMA0CTL |= DMADT_1+DMADSTINCR_3+DMASRCINCR_3+DMADSTBYTE+DMASRCBYTE;
// }


// void InitDma1()
// {
//   DMACTL0 &= DMA1TSEL_0;  //���ԭ���Ĵ���Դ
//   DMACTL0 |= DMA1TSEL_0;  //ѡ�񴥷�Դ���������
//   DMA1CTL  &= DMADT_0;  //���ԭ���Ĵ���ģʽ

//   //ѡ����ģʽ���鴫�䡣Ŀ�ĵ�ַ�Զ����ӡ�Դ��ַ�Զ����ӡ�
//   //Ŀ�ĵ�Ԫ�Ĵ洢��λΪ�ֽڡ�Դ��Ԫ�Ĵ洢��λΪ�ֽ�
//   DMA1CTL |= DMADT_1+DMADSTINCR_3+DMASRCINCR_3+DMADSTBYTE+DMASRCBYTE;

// }

// void InitDma2()
// {
//   DMACTL0 &= DMA2TSEL_0;  //���ԭ���Ĵ���Դ
//   DMACTL0 |= DMA2TSEL_0;  //ѡ�񴥷�Դ���������
//   DMA2CTL  &= DMADT_0;  //���ԭ���Ĵ���ģʽ

//   //ѡ����ģʽ���鴫�䡣Ŀ�ĵ�ַ�Զ����ӡ�Դ��ַ�Զ����ӡ�
//   //Ŀ�ĵ�Ԫ�Ĵ洢��λΪ�ֽڡ�Դ��Ԫ�Ĵ洢��λΪ�ֽڡ�
//   DMA2CTL |= DMADT_1+DMADSTINCR_3+DMASRCINCR_3+DMADSTBYTE+DMASRCBYTE;
// }


// /****************************************************************************
// �򿪻�ر�DMA
// doit��0��ֹͣ  100������  ������ʲô��������
// which��������DMA��ͨ���� 0~2
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
// ����DMA�����Դ��Ŀ���ַ
// which��DMAͨ����0~2
// src_adr��Դ��ַ
// det_adr��Ŀ���ַ
// size�������ֻ����ֽ���Ŀ��
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
// �������DMA
// which��������DMA��ͨ���� 0~2
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