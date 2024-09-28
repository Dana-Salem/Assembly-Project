;You must download the emulator to try the code
;final assembly project 
;Ask the user to enter a number in base-5 form
; Afterwards, print the decimal, hexadecimal and binary equivalent of the number
;The user input can be up to 5 digits. No leading zeros should be added to the number
;Since the input is in base-5, each digit should range from 0 to 4. If the user sends an invalid input, an
;error message should appear and the program should restart


;20220177
;dana rami salem 

org 100h
.stack 1000
;----------------------------------------------
.data 

asking_user db "enter base-5 number (up to 5 digits),then press "=" to have the conversions:",0ah,0dh ;78

f db 0                         ;flag for indicating state
fnz  db 0                      ; flag if the input non-zero
base5_input dw 0               ;store base-5 input
indecnum  dw 0                 ;store value after convert to decimal 
                         
hex_value  db 4 dup(0)         ;store hexa 
dec_value  db 4 dup(0)         ;store decimal 
bin_value  db 16 dup(0)        ;store binary 

hexa_msg db "Hexadecimal= "           ;13 
decimal_msg db "Decimal= "            ;9  
binary_msg db "Binary= "              ;8 

error_msg db 0dh,0ah,"error"

mod dw 0                      ;store the reminder from division instruction
;---------------------------------------------- 
.code
mov ax,@data
mov ds,ax
;----------------------------------------------
;label to jump back to here in case of error(restart_program) 
restart_program:
mov base5_input,0             ;reset input and the fnz flag
mov f,0
mov fnz,0 

;print on screen asking user
mov di,0
LL1:
mov cx,78                     ;number of characters on asking users variable
mov si,0
mov ah,2                      

L1:
mov dl,asking_user[si]
int 21h
inc si
loop L1
;----------------------------------------------        
;enter number 
taking_input: 
call read_input  

cmp ax,0
je print_error                ;if input is invalid,jump to error

cmp f,0
je taking_input              ;if not finished,continue taking input
;---------------------------------------------- 
;conversion from base 5 to decimal                  
mov f,0
push base5_input

mov bx,0
mov cx,0 

base5_base10:
push cx 
mov dx,0
mov di,10
mov ax,base5_input 

;use div 
;store result (ax)
;store mod(dx)    

div di                    ;dividing the input by 10
                     
mov base5_input,ax        ;put the result back in base5_input
mov di,5
mov ax,1
mov mod,dx                ;put the reminder in mod (from dx to mod)

cmp cx,0
je mulno

multiplication:
mul di                    ;multiply by base 5
loop multiplication

mulno:
pop cx
inc cx
mov dx,mod                ;multiply remainder(mod) by power of 5
mul dx                 
add bx,ax                 ;add to total

cmp base5_input,0
jne base5_base10          ;loop to repeat untill fully convert


decimal_printing:    
mov si,0
mov indecnum,bx           ;store decimal value in indecnum variable
push indecnum             ;push the decimal number onto the stack
                        
dec_str:                  
mov dx,0                  ;clearing dx to store remainder
mov di,10                 ;set divisor to 10(base 10)
mov ax,indecnum 

div di              
                          
mov indecnum,ax           
add dl,30h                
mov dec_value[si],dl
inc si
cmp indecnum,0            ;check if result is zero
jne dec_str               ;if not zero continue

pop indecnum              ;pop the original decimal number from the stack
mov cx,si                 ;store the number of digits in cx
dec si  

mov ah,2
mov dl,0dh
int 21h
mov dl,0ah
int 21h  

push cx 

decimal:
mov cx,9
mov di,0

;;load message character 

decimalL:
mov dl,decimal_msg[di]
int 21h
inc di
loop decimalL
        
pop cx                ;pop the number of digits from the stack

printLD:
mov dl,dec_value[si]
int 21h
dec si
loop printLD
;----------------------------------------------
;conversion from decimal to hexa (using base 10 not base 5)
 
hexa_printing:
mov si,0
mov indecnum,bx           ; store the decimal value in indecnum
push indecnum             ;push the decimal number onto the stack 

hex_str:
mov dx,0
mov di,16                 ;set divisor to 16(base 16 for hexadecimal
mov ax,indecnum 

div di               ; so this should store the result in AX and the remainder in DX   

mov indecnum,ax 

;check if remainder(dl) is less than 10

cmp dl,10                 ;if remainder<10,jump to HexDigitToChar  
jb HexDigitToChar

;check if remainder(dl) is greater than 9

cmp dl,9 
ja HexAlphaToChar         ;if remainder>9,jump to HexAlphaToChar
         
HexAlphaToChar:
add dl,55                 ;convert remainder(10-15) to ASCII(A-F) -> (add 55)
jmp ending_hex_conversion
        
HexDigitToChar:
add dl,30h                ;convert remainder(0-9) to ASCII(0-9)
        
ending_hex_conversion:
mov hex_value[si],dl
inc si   

cmp indecnum,0            ;check if result is zero
jne hex_str               ;if not zero continue


pop indecnum              ;pop the original decimal number from the stack   
mov cx,si                 ;store the number of digits in cx 
dec si

mov ah,2
mov dl,0ah
int 21h
mov dl,0dh
int 21h
push cx 

hexa: 
mov cx,13
mov di,0
 
;;load message character
hexaL:
mov dl,hexa_msg[di]
int 21h
inc di
loop hexaL
        
pop cx                   ;pop the number of digits from the stack

printLH:
mov dl,hex_value[si]
int 21h
dec si
loop printLH

;---------------------------------------------- 
;conversion from decimal to bin(using base 10 not base 5)

bin_printing: 
mov si,0
mov indecnum,bx          ;store the decimal value in indecnum
push indecnum            ;push the decimal number onto the stack

bin_str:
mov dx,0                 ;clear dx to store remainder
mov di,2                 ;set divisor to 2(base 2 for binary)
mov ax,indecnum 

div di              

mov indecnum,ax
add dl,30h        
mov bin_value[si],dl
inc si 

cmp indecnum,0
jne bin_str

pop indecnum             ;pop the original decimal number from the stack    
mov cx,si                ;store the number of digits in cx
dec si

mov ah,2
mov dl,0dh
int 21h
mov dl,0ah
int 21h
push cx 

bin: 
mov cx,8
mov di,0
 

;;load message character 

binL:
mov dl,binary_msg[di]
int 21h
inc di
loop binL
        
pop cx                  ;pop the number of digits from the stack

printLB:
mov dl,bin_value[si]
int 21h
dec si
loop printLB
;---------------------------------------------- 
;print error 
;1-if the digit not 0,1,2,3,4
;2-more than 5 digits entered
print_error:
mov si,0
mov cx,7              ;set loop counter to the length of the error message
mov ah,2

cmp f,0               ;check if f is zero
je noprinting         ;no error printing if f is zero

print_errorloop:
mov dl,error_msg[si]
int 21h
inc si
loop print_errorloop

mov ah,2
int 21h
mov dl,0ah
int 21h
mov dl,0dh
int 21h
mov dl,0ah

;if f is zero no error message printed -> just restart the program
jmp restart_program

noprinting:      


;----------------------------------------------
;read user input
read_input proc
    
mov ah,1
int 21h  

;check validation 

cmp al,"="               ;check "=" key 
je equal 

sub al,30h 

cmp al,4                ;invalid input if digit>4
ja error                ;if the number is greater than 4 jump to error

cmp al,0                ;invalid input if digit<0
jb error                ;if the number is less than 0 jump to error

cmp al,0
je neglect

cmp di,4                 ;compare the input length with 4(cause max 5 digits)
ja error                 ;if the input length exceeds 5 digits jump to error

;if input is valid
    
done:
mov fnz,1                ;set the flag fnz to 1 indicating a non zero input
inc di                   ;increment length counter
        
                        
mov cx,10                 ;cx=10 times multiplication
mov ah,0 
mov bx,0                ;clear to store the summation in bx

;base5_input*10 
looping:
add bx,base5_input
loop looping

;add the new digit to base5_input        
add bx,ax
mov base5_input,bx
mov ah,1 
ret   
    
error:
mov ax,0
mov f,2           
ret
            
equal:
mov f,1                ;set the flag f -> = was pressed
ret 

neglect:
cmp fnz,0
jne done
ret 
 

ret
;----------------------------------------------      

ret

