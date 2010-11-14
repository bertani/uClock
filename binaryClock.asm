; binaryClock, just another binary clock written in 8-bit-microchip-Assembly
;
; Copyright (C) 2010 Thomas Bertani <sylar@anche.no>
; portions Copyright (C) 2010 Giacomo Mariani
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

H_ EQU 0x20
M_ EQU 0x21
S_ EQU 0x22

h_0 EQU 0x30
h_1 EQU 0x31
m_0 EQU 0x32
m_1 EQU 0x33
s_0 EQU 0x34
s_1 EQU 0x35

TMP EQU 0x40

R1 EQU 0x41
R2 EQU 0x42

TMP1 EQU 0x50
CALIBRATOR EQU 0x60
TMP2 EQU 0x51

ORG 0x000
goto init
ORG 0x004
ir:

bcf INTCON, T0IF
incf s_0

movlw 0x43
movwf TMR0
retfie


w_adjust:
  return

;FUNCTIONS

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
  addwf PCL, 1
  ;nop
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


init:
  bsf STATUS, 5
  bcf PCON, 3 ; setta INTOSC a 48 KHz
  movlw 0x43
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
  movwf TMP
  
  movlw 0x00
  movwf s_0
  movwf s_1
  movlw 0x06
  movwf m_0
  movlw 0x03
  movwf m_1
  movlw 0x01
  movwf h_0
  movlw 0x02
  movwf h_1

loop:
  movf s_0, 0
  call to_led
  movwf TMP1
  comf TMP1, 0
  movwf PORTB
  movlw b'10000000'
  movwf PORTA
  call w_adjust
  
  movlw b'00000000'
  movwf PORTA
  movf s_1, 0
  call to_led
  movwf TMP1
  comf TMP1, 0
  movwf PORTB
  movlw b'01000000'
  movwf PORTA
  call w_adjust
  
  movlw b'00000000'
  movwf PORTA
  movf m_0, 0
  call to_led
  movwf TMP1
  comf TMP1, 0
  movwf PORTB
  movlw b'00001000'
  movwf PORTA
  call w_adjust
  
  movlw b'00000000'
  movwf PORTA
  movf m_1, 0
  call to_led
  movwf TMP1
  comf TMP1, 0
  movwf PORTB
  movlw b'00000100'
  movwf PORTA
  call w_adjust
  
  movlw b'00000000'
  movwf PORTA
  movf h_0, 0
  call to_led
  movwf TMP1
  comf TMP1, 0
  movwf PORTB
  movlw b'00000010'
  movwf PORTA
  call w_adjust
  
  movlw b'00000000'
  movwf PORTA
  movf h_1, 0
  call to_led
  movwf TMP1
  comf TMP1, 0
  movwf PORTB
  movlw b'00000001'
  movwf PORTA
  call w_adjust
  
  movlw b'00000000'
  movwf PORTA
  
  
  movlw 0x09
  subwf s_0, 0
  movwf CALIBRATOR
  decfsz CALIBRATOR, 0
  goto lol
  incf s_1
  movlw 0x00
  movwf s_0
lol:
  movlw 0x05
  subwf s_1, 0
  movwf CALIBRATOR
  decfsz CALIBRATOR, 0
  goto lol_
  incf m_0
  movlw 0x00
  movwf s_1
lol_:
  movlw 0x09
  subwf m_0, 0
  movwf CALIBRATOR
  decfsz CALIBRATOR, 0
  goto lol__
  incf m_1
  movlw 0x00
  movwf m_0
lol__:
  movlw 0x05
  subwf m_1, 0
  movwf CALIBRATOR
  decfsz CALIBRATOR, 0
  goto lol___
  incf h_0
  movlw 0x00
  movwf m_1
lol___:
  movlw 0x03
  subwf h_0, 0
  movwf CALIBRATOR
  decfsz CALIBRATOR, 0
  goto lol____
  movf h_1
  movwf TMP1
  decfsz TMP1, 0
  goto lol____
  movlw 0x00
  movwf h_0
  movwf 0x00
lol____:
  movlw 0x09
  subwf h_0, 0
  movwf CALIBRATOR
  decfsz CALIBRATOR, 0
  goto lol_____
  incf h_1
  movlw 0x00
  movwf h_0
lol_____:
  goto loop
END
