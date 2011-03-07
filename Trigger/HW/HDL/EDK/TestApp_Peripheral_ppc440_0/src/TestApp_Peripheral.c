/*
 *
 * Xilinx, Inc.
 * XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" AS A 
 * COURTESY TO YOU.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION AS
 * ONE POSSIBLE   IMPLEMENTATION OF THIS FEATURE, APPLICATION OR 
 * STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION 
 * IS FREE FROM ANY CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE 
 * FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION
 * XILINX EXPRESSLY DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO 
 * THE ADEQUACY OF THE IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO 
 * ANY WARRANTIES OR REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE 
 * FROM CLAIMS OF INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY 
 * AND FITNESS FOR A PARTICULAR PURPOSE.
 */

/*
 * Xilinx EDK 12.4 EDK_MS4.81d
 *
 * This file is a sample test application
 *
 * This application is intended to test and/or illustrate some 
 * functionality of your system.  The contents of this file may
 * vary depending on the IP in your system and may use existing
 * IP driver functions.  These drivers will be generated in your
 * XPS project when you run the "Generate Libraries" menu item
 * in XPS.
 *
 * Your XPS project directory is at:
 *    \\aristoteles\kimei\MASTER\COMPET\Trigger\HW\HDL\EDK\
 */


// Located in: ppc440_0/include/xparameters.h
#include "xparameters.h"

#include "xil_cache.h"

#include "stdio.h"

#include "uartlite_header.h"
#include "xbasic_types.h"
#include "xgpio.h"
#include "gpio_header.h"
#include "xemaclite.h"
#include "xemaclite_example.h"
#include "emaclite_header.h"
#include "xsysace.h"
#include "sysace_header.h"

//====================================================

int main (void) {


   Xil_ICacheEnableRegion(0x80000000);
   Xil_DCacheEnableRegion(0x80000000);
   print("-- Entering main() --\r\n");

   /*
    * Peripheral SelfTest will not be run for RS232
    * because it has been selected as the STDOUT device
    */



   {
      int status;
      
      print("\r\nRunning UartLiteSelfTestExample() for RS232_USB...\r\n");
      status = UartLiteSelfTestExample(XPAR_RS232_USB_DEVICE_ID);
      if (status == 0) {
         print("UartLiteSelfTestExample PASSED\r\n");
      }
      else {
         print("UartLiteSelfTestExample FAILED\r\n");
      }
   }


   {
      u32 status;
      
      print("\r\nRunning GpioOutputExample() for LEDs_8Bit...\r\n");

      status = GpioOutputExample(XPAR_LEDS_8BIT_DEVICE_ID,8);
      
      if (status == 0) {
         print("GpioOutputExample PASSED.\r\n");
      }
      else {
         print("GpioOutputExample FAILED.\r\n");
      }
   }


   {
      u32 status;
      
      print("\r\nRunning GpioInputExample() for DIP_Switches_8Bit...\r\n");

      u32 DataRead;
      
      status = GpioInputExample(XPAR_DIP_SWITCHES_8BIT_DEVICE_ID, &DataRead);
      
      if (status == 0) {
         xil_printf("GpioInputExample PASSED. Read data:0x%X\r\n", DataRead);
      }
      else {
         print("GpioInputExample FAILED.\r\n");
      }
   }


   {
      u32 status;
      
      print("\r\nRunning GpioInputExample() for Push_Buttons_3Bit...\r\n");

      u32 DataRead;
      
      status = GpioInputExample(XPAR_PUSH_BUTTONS_3BIT_DEVICE_ID, &DataRead);
      
      if (status == 0) {
         xil_printf("GpioInputExample PASSED. Read data:0x%X\r\n", DataRead);
      }
      else {
         print("GpioInputExample FAILED.\r\n");
      }
   }


   {
      int status;
      
      print("\r\nRunning EmacLitePolledExample() for Ethernet_MAC...\r\n");
      status = EmacLitePolledExample(XPAR_ETHERNET_MAC_DEVICE_ID);
      if (status == 0) {
         print("EmacLite Polled Example PASSED\r\n");
      }
      else {
         print("EmacLite Polled Example FAILED\r\n");
      }
   }


   {
      int status;
      
      print("\r\nRunning SysAceSelfTestExample() for SysACE_CompactFlash...\r\n");
      status = SysAceSelfTestExample(XPAR_SYSACE_COMPACTFLASH_DEVICE_ID);
      if (status == 0) {
         print("SysAceSelfTestExample PASSED\r\n");
      }
      else {
         print("SysAceSelfTestExample FAILED\r\n");
      }
   }

   print("-- Exiting main() --\r\n");
   Xil_DCacheDisable();
   Xil_ICacheDisable();
   return 0;
}

