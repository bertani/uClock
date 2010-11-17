; binaryClock, just another binary clock written in 8-bit-microchip-Assembly
;
; Copyright (C) 2010 Thomas Bertani <sylar@anche.no>
;
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License, version 3, as
; published by the Free Software Foundation.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


#include <p16f628a.inc>

__CONFIG _INTOSC_OSC_NOCLKOUT & _MCLRE_OFF & _WDT_OFF & _PWRTE_ON & _BODEN_OFF & _LVP_OFF & _DATA_CP_OFF & _CP_OFF

INDF EQU 0x00
FSR EQU 0x04

s_0 EQU 0x20
s_1 EQU 0x21
m_0 EQU 0x22
m_1 EQU 0x23
h_0 EQU 0x24
h_1 EQU 0x25

TMP EQU 0x30
FLAG EQU 0x31
LED_DRIVER_C EQU 0x32

ORG 0x000
  goto init
ORG 0x004
ir:
  movwf TMP
  bsf FLAG, 0
  bcf INTCON, T0IF ; restart ricezione interrupt TMR0
  movlw 0x20
  movwf TMR0 ; reinizializzazione di TMR0
  movf TMP, 0
  retfie

led_driver_offset:
  addwf PCL, 1
  retlw b'10000000'
  retlw b'01000000'
  retlw b'00001000'
  retlw b'00000100'
  retlw b'00000010'
  retlw b'00000001'

to_led:
  movwf TMP
  sublw 0x09
  btfss STATUS, C
  retlw 0xFF
  movf TMP, 0
  addwf PCL, 1
  retlw b'10100000';b'01011111'
  retlw b'11110110'
  retlw b'10010001'
  retlw b'10010010'
  retlw b'11000110'
  retlw b'10001010';5
  retlw b'10001000'
  retlw b'10110110'
  retlw b'10000000'
  retlw b'10000010'

clock_values_update:
check_s0:
  movf s_0, 0
  sublw 0x09
  btfss STATUS, C
  goto res_s0
  ;incf s_0
  goto check_end
res_s0:
  clrf s_0
check_s1:
  movf s_1, 0
  sublw 0x04
  btfss STATUS, C
  goto res_s1
  incf s_1
  goto check_end
res_s1:
  clrf s_1
check_m0:
  movf m_0, 0
  sublw 0x08
  btfss STATUS, C
  goto res_m0
  incf m_0
  goto check_end
res_m0:
  clrf m_0
check_m1:
  movf m_1, 0
  sublw 0x04
  btfss STATUS, C
  goto res_m1
  incf m_1
  goto check_end
res_m1:
  clrf m_1
check_h0:
  movf h_0, 0
  sublw 0x03
  btfsc STATUS, 2
  goto check_h0h1
  movf h_0, 0
  sublw 0x09
  btfsc STATUS, 2
  goto res_h0
  incf h_0
  goto check_end
check_h0h1:
  movf h_1, 0
  sublw 0x02
  btfsc STATUS, 2
  goto res_h1
  incf h_0
  goto check_end
res_h0:
  clrf h_0
check_h1:
  movf h_1, 0
  sublw 0x02
  btfsc STATUS, 2
  goto res_h1
  incf h_1
  goto check_end
res_h1:
  clrf h_0
  clrf h_1
check_end:
  return

init:
  bsf STATUS, 5
  bcf PCON, 3 ; setta INTOSC a 48 KHz
  movlw 0x20
  movwf TMR0 ; inizializza TMR0
  movlw b'00000101' ; 1:64
  movwf OPTION_REG ; setta prescaler per TMR0
  bsf INTCON, T0IE
  bsf INTCON, GIE ; abilita gli interrupt
  movlw 0x00 ; usiamo tutte le linee come output
  movwf TRISA
  movwf TRISB
  bsf TRISA, 4 ; PORTA<4> come input
  bcf STATUS, 5
  
  clrf s_0
  clrf s_1
  clrf m_0
  clrf m_1
  clrf h_0
  clrf h_1

loop:
  movlw 0x00
  movwf LED_DRIVER_C ; inizializza il led driver
  movlw 0x20
  movwf FSR
  ; inizio controllo FLAG
  btfss FLAG, 0
  goto no_flag
  incf s_0 ; incremento unita' di secondo
  call clock_values_update
no_flag:
  bcf FLAG, 0
  ; fine controllo FLAG
  btfsc PORTA, 4 ; se PORTA<5> == 0 => aumenta di 10 secondi e aggiorna
  goto led_driver_loop
  movlw 0x50
  addwf s_0, 1
  call clock_values_update
led_driver_loop:
  movlw 0x00
  movwf PORTA
  movf LED_DRIVER_C, 0
  sublw 0x06
  btfss STATUS, C ; se LED_DRIVER_C < 6
  goto loop
  movf INDF, 0 ; lettura registro tramite indirizzamento indiretto
  call to_led
  movwf PORTB
  movf LED_DRIVER_C, 0
  call led_driver_offset
  movwf PORTA
  incf LED_DRIVER_C
  incf FSR
  goto led_driver_loop
END