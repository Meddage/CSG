/*
 * Copyright (c) 2006 Arch Rock Corporation
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the Arch Rock Corporation nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE
 * ARCH ROCK OR ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE
 */

/**
 * @author Alec Woo <awoo@archrock.com>
 * @author Jonathan Hui <jhui@archrock.com>
 * @version $Revision: 1.7 $ $Date: 2010/06/29 22:07:43 $
 */

/*
 * Copyright (c) 2004-2005 Crossbow Technology, Inc.  All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of Crossbow Technology nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/** 
 * Private component of the Atmega128 serial port HPL.
 *
 * @author Martin Turon <mturon@xbow.com>
 * @author David Gay
 */

#include <Atm128Uart.h>

module HplAtm128UartP {
  
  provides interface Init as Uart0Init;
  provides interface StdControl as Uart0TxControl;
  provides interface StdControl as Uart0RxControl;
  provides interface HplAtm128Uart as HplUart0;
    
  provides interface Init as Uart1Init;
  provides interface StdControl as Uart1TxControl;
  provides interface StdControl as Uart1RxControl;
  provides interface HplAtm128Uart as HplUart1;
  
  uses interface Atm128Calibrate;
  uses interface McuPowerState;
}
implementation {
  
  //=== Uart Init Commands. ====================================
  command error_t Uart0Init.init() {
    Atm128UartMode_t    mode;
    Atm128UartStatus_t  stts;
    Atm128UartControl_t ctrl;
    uint16_t ubrr0;

    ctrl.bits = (struct Atm128_UCSRB_t) {rxcie:0, txcie:0, rxen:0, txen:0};
    stts.bits = (struct Atm128_UCSRA_t) {u2x:1};
    mode.bits = (struct Atm128_UCSRC_t) {ucsz:ATM128_UART_DATA_SIZE_8_BITS};

    ubrr0 = call Atm128Calibrate.baudrateRegister(PLATFORM_BAUDRATE);
    UBRR0L = ubrr0;
    UBRR0H = ubrr0 >> 8;
    UCSR0A = stts.flat;
    UCSR0C = mode.flat;
    UCSR0B = ctrl.flat;

    return SUCCESS;
  }

  command error_t Uart0TxControl.start() {
    SET_BIT(UCSR0B, TXEN);
    call McuPowerState.update();
    return SUCCESS;
  }

  command error_t Uart0TxControl.stop() {
    CLR_BIT(UCSR0B, TXEN);
    call McuPowerState.update();
    return SUCCESS;
  }

  command error_t Uart0RxControl.start() {
    SET_BIT(UCSR0B, RXEN);
    call McuPowerState.update();
    return SUCCESS;
  }

  command error_t Uart0RxControl.stop() {
    CLR_BIT(UCSR0B, RXEN);
    call McuPowerState.update();
    return SUCCESS;
  }
  
  async command error_t HplUart0.enableTxIntr() {
    SET_BIT(UCSR0A, TXC);
    SET_BIT(UCSR0B, TXCIE);
    return SUCCESS;
  }
  
  async command error_t HplUart0.disableTxIntr(){
    CLR_BIT(UCSR0B, TXCIE);
    return SUCCESS;
  }
  
  async command error_t HplUart0.enableRxIntr(){
    SET_BIT(UCSR0B, RXCIE);
    return SUCCESS;
  }

  async command error_t HplUart0.disableRxIntr(){
    CLR_BIT(UCSR0B, RXCIE);
    return SUCCESS;
  }
  
  async command bool HplUart0.isTxEmpty(){
    return READ_BIT(UCSR0A, TXC);
  }

  async command bool HplUart0.isRxEmpty(){
    return !READ_BIT(UCSR0A, RXC);
  }
  
  async command uint8_t HplUart0.rx(){
    return UDR0;
  }

  async command void HplUart0.tx(uint8_t data) {
    atomic{
      UDR0 = data; 
      SET_BIT(UCSR0A, TXC);
    }
  }
  
  AVR_ATOMIC_HANDLER(SIG_UART0_RECV) {
    if (READ_BIT(UCSR0A, RXC)) {
      signal HplUart0.rxDone(UDR0);
    }
  }
  
  AVR_NONATOMIC_HANDLER(SIG_UART0_TRANS) {
    signal HplUart0.txDone();
  }
  
  command error_t Uart1Init.init() {
    Atm128UartMode_t    mode;
    Atm128UartStatus_t  stts;
    Atm128UartControl_t ctrl;
    uint16_t ubrr1;
    
    ctrl.bits = (struct Atm128_UCSRB_t) {rxcie:0, txcie:0, rxen:0, txen:0};
    stts.bits = (struct Atm128_UCSRA_t) {u2x:1};
    mode.bits = (struct Atm128_UCSRC_t) {ucsz:ATM128_UART_DATA_SIZE_8_BITS};

    ubrr1 = call Atm128Calibrate.baudrateRegister(PLATFORM_BAUDRATE);
    UBRR1L = ubrr1;
    UBRR1H = ubrr1 >> 8;
    UCSR1A = stts.flat;
    UCSR1C = mode.flat;
    UCSR1B = ctrl.flat;

    return SUCCESS;
  }

  command error_t Uart1TxControl.start() {
    SET_BIT(UCSR1B, TXEN);
    call McuPowerState.update();
    return SUCCESS;
  }

  command error_t Uart1TxControl.stop() {
    CLR_BIT(UCSR1B, TXEN);
    call McuPowerState.update();
    return SUCCESS;
  }

  command error_t Uart1RxControl.start() {
    SET_BIT(UCSR1B, RXEN);
    call McuPowerState.update();
    return SUCCESS;
  }

  command error_t Uart1RxControl.stop() {
    CLR_BIT(UCSR1B, RXEN);
    call McuPowerState.update();
    return SUCCESS;
  }
  
  async command error_t HplUart1.enableTxIntr() {
    SET_BIT(UCSR1A, TXC);
    SET_BIT(UCSR1B, TXCIE);
    return SUCCESS;
  }
  
  async command error_t HplUart1.disableTxIntr(){
    CLR_BIT(UCSR1B, TXCIE);
    return SUCCESS;
  }
  
  async command error_t HplUart1.enableRxIntr(){
    SET_BIT(UCSR1B, RXCIE);
    return SUCCESS;
  }

  async command error_t HplUart1.disableRxIntr(){
    CLR_BIT(UCSR1B, RXCIE);
    return SUCCESS;
  }
  
  async command bool HplUart1.isTxEmpty() {
    return READ_BIT(UCSR1A, TXC);
  }

  async command bool HplUart1.isRxEmpty() {
    return !READ_BIT(UCSR1A, RXC);
  }
  
  async command uint8_t HplUart1.rx(){
    return UDR1;
  }

  async command void HplUart1.tx(uint8_t data) {
    atomic{
      UDR1 = data; 
      SET_BIT(UCSR1A, TXC);
    }
  }
  
  AVR_ATOMIC_HANDLER(SIG_UART1_RECV) {
    if (READ_BIT(UCSR1A, RXC))
      signal HplUart1.rxDone(UDR1);
  }
  
  AVR_NONATOMIC_HANDLER(SIG_UART1_TRANS) {
    signal HplUart1.txDone();
  }
  
  default async event void HplUart0.txDone() {} 
  default async event void HplUart0.rxDone(uint8_t data) {}
  default async event void HplUart1.txDone() {}
  default async event void HplUart1.rxDone(uint8_t data) {}
  
}
