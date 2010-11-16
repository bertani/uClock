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
TMP0 EQU 0x31
TMP1 EQU 0x32
TMPX EQU 0x33

I EQU 0x40
J EQU 0x41

LED_DRIVER_C EQU 0x42

ORG 0x000
  goto init
ORG 0x004
ir:
  movwf TMPX
  movlw 0x00
  movwf PORTB
  incf s_0 ; incremento unita' di secondo
  call clock_values_update
  bcf INTCON, T0IF ; restart ricezione interrupt TMR0
  movlw 0x20
  movwf TMR0 ; reinizializzazione di TMR0
  movf TMPX, 0
  retfie

;FUNCTIONS
is_min: ; I < J ? W = 1 : W = 0
  movf J, 0
  subwf I, 0
  btfss STATUS, C
  goto is_min_y
  goto is_min_f
is_min_y:
  movlw 0x01
  return
is_min_f:
  movlw 0x00
  return

led_driver_offset:
  addwf PCL, 1
  retlw b'10000000'
  retlw b'01000000'
  retlw b'00001000'
  retlw b'00000100'
  retlw b'00000010'
  retlw b'00000001'

to_led:
;12345678
;1 = none
;2 = sopra
;3 = centrale
;4 = sinistra alto
;5 = destra alto
;6 = sotto
;7 = sinistra basso
;8 = destra basso
  movwf I
  movlw 0x0A
  movwf J
  call is_min
  movwf TMP0
  btfss TMP0, 0
  retlw b'00000000'
  movf I, 0
  addwf PCL, 1
  retlw b'01011111'
  retlw b'00001001'
  retlw b'01101110'
  retlw b'01101101'
  retlw b'00111001'
  retlw b'01110101';5
  retlw b'01110111'
  retlw b'01001001'
  retlw b'01111111'
  retlw b'01111101'

clock_values_update:
check_s0:
  movf s_0, 0
  movwf J
  movlw 0x09
  movwf I
  call is_min
  movwf TMP0
  btfss TMP0, 0
  goto check_s1
  movlw 0x00
  movwf s_0
  incf s_1
check_s1:
  movf s_1, 0
  movwf J
  movlw 0x05
  movwf I
  call is_min
  movwf TMP0
  btfss TMP0, 0
  goto check_m0
  movlw 0x00
  movwf s_1
  incf m_0
check_m0:
  movf m_0, 0
  movwf J
  movlw 0x09
  movwf I
  call is_min
  movwf TMP0
  btfss TMP0, 0
  goto check_m1
  movlw 0x00
  movwf m_0
  incf m_1
check_m1:
  movf m_1, 0
  movwf J
  movlw 0x05
  movwf I
  call is_min
  movwf TMP0
  btfss TMP0, 0
  goto check_h0h1
  movlw 0x00
  movwf m_1
  incf h_0
check_h0h1:
  movf h_0, 0
  movwf J
  movlw 0x03
  movwf I
  call is_min
  movwf TMP0
  btfss TMP0, 0
  goto check_h0
  movf h_1, 0
  movwf J
  movlw 0x01
  movwf I
  call is_min
  movwf TMP0
  btfss TMP0, 0
  goto check_h0
  movlw 0x00
  movwf h_0
  movwf h_1
check_h0:
  movf h_0, 0
  movwf J
  movlw 0x09
  movwf I
  call is_min
  movwf TMP0
  btfss TMP0, 0
  goto check_h1
  movlw 0x00
  movwf h_0
  incf h_1
check_h1:
  nop
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
  bcf STATUS, 5
  
  movlw 0x00
  movwf s_0
  movwf s_1
  movlw 0x07
  movwf m_0
  movlw 0x03
  movwf m_1
  movlw 0x01
  movwf h_0
  movlw 0x02
  movwf h_1

loop:
  movlw 0x00
  movwf LED_DRIVER_C ; inizializza il led driver
  movlw 0x20
  movwf FSR
led_driver_loop:
  movf LED_DRIVER_C, 0
  movwf I
  movlw 0x06
  movwf J
  call is_min
  movwf TMP0
  btfss TMP0, 0 ; se LED_DRIVER_C < 6
  goto loop
  movlw b'00000000'
  movwf PORTA
  movf INDF, 0 ; lettura registro tramite indirizzamento indiretto
  call to_led
  movwf TMP1
  comf TMP1, 0
  movwf PORTB
  movf LED_DRIVER_C, 0
  call led_driver_offset
  movwf PORTA
  incf LED_DRIVER_C
  incf FSR
  goto led_driver_loop
END
