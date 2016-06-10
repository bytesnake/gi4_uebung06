SECTION .data
	character_map db '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'
	message db "<debug> number in base %i is %s",10,0

SECTION .text
	global main
	extern malloc
	extern free
    extern printf
	global int_as_ascii
	global count_num_of_occurrence
	global write_as_ascii
	global print

main:
	push 53278901; variable for function
	call int_as_ascii
	add esp, 4 ; delete variable

	;; in eax is the pointer to a struct containing hex and dec representation of the number

    ;; delete struct
    push eax
    call free

end:	
	;; exit
	mov eax, 1
	mov ebx, 0
	int 0x80


int_as_ascii:
	;Stackframe
	push ebp
	mov ebp, esp

	;; alocate buffer for struct
	push 20; length of struct
	call malloc ; reserve memory
	add esp, 4

	;; cannot reserve memory
	cmp eax, 0
	je end

	;; save start adress in stack
	push eax
	
    ;; load our character map to the source register
	mov esi, character_map

	;; load pointer of malloc to the destination register
	mov edi, eax
	mov eax, dword [ebp+8] ; load first parameter (integer)

	;; as hex ascii
	mov ebx, 16
	call count_num_of_occurrence
	call write_as_ascii
	call print

	;; set correct memory adress
    mov edi, dword [esp]
	add edi, 10
	
    ;; as dec ascii
	mov ebx, 10
	call count_num_of_occurrence
	call write_as_ascii
	call print

	;; save struct pointer to eax as return value
    pop eax

	;; restore stack frame and returen
	mov esp, ebp
	pop ebp

	ret
	
;; count the amount of characters needed to represent number in ascii
;; after: EDI points to the end of number (in ascii) and will contain a close character
;; save&restore eax

count_num_of_occurrence:
	push eax
.L1:
	xor edx, edx
	div ebx
	
	inc edi

	cmp eax, 0
    jg .L1

	pop eax

	;; the current position is the end of our number in ascii format, therefore set a close character
	mov [edi], BYTE 0

	ret

;; decrements edi again and performs a lookup to get the ascii representation
;; save&restore eax

write_as_ascii:
	push eax
.L2:
	xor edx, edx
	div dword ebx

	;; decrement edi and set esi to address of lookup table + remainder
	dec edi
	push esi
	add esi, edx
	;; copy byte and decrement edi again
	movsb
	dec edi
	;; restore esi
	pop esi

	cmp eax, 0
    jg .L2

	pop eax

	ret

;; print result for debug purposes	
print:
	push eax
	push edi ; dec string
	push ebx
	push message
	call printf ; print both
	add esp, 12
	pop eax	

	ret
