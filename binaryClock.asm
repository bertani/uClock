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

ORG 0x000
goto start

w_adjust:
  return

wait_l:
call wait
call wait
call wait
call wait
call wait
call wait
call wait
call wait
call wait
call wait
return
wait:
	movlw	0xBE
	movwf	R1
longloop1:
	movlw	0xBE
	movwf	R2
longloop2:
	decfsz	R2,1
	goto	longloop2
	decfsz	R1,1
	goto	longloop1
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

start:
  bsf STATUS, 5
  movlw 0x00 ;usiamo tutte le linee come output
  movwf TRISA
  movwf TRISB
  bcf STATUS, 5
  movlw 0x00
  movwf TMP




movlw 0x00
movwf s_0
movwf s_1
movwf m_0
movwf m_1
movwf h_0
movwf h_1


loop:
  ;movlw b'10000000';movlw 0xff
  ;movwf PORTA
  ;incf TMP, 0
  ;movwf TMP
  ;call to_led
  ;movwf TMP1
  ;comf TMP1, 0
  ;movwf PORTB
  ;call wait


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

  ;calcoli vari
  movlw 0x08
  subwf s_0, 0
  movwf CALIBRATOR
  decfsz CALIBRATOR, 0
  goto lol
  incf s_1
  movlw 0x00
  movwf s_0
lol:

  movlw 0x09
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

  movlw 0x09
  subwf m_1, 0
  movwf CALIBRATOR
  decfsz CALIBRATOR, 0
  goto lol___
  incf h_0
  movlw 0x00
  movwf m_1
lol___:

  movlw 0x09
  subwf h_0, 0
  movwf CALIBRATOR
  decfsz CALIBRATOR, 0
  goto lol____
  incf h_1
  movlw 0x00
  movwf h_0
lol____:

  incf s_0
  ;incf TMP, 0

  goto loop
END
