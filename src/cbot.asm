; Reboots your linux system
; /usr/include/linux/reboot.h
; https://chromium.googlesource.com/chromiumos/docs/+/HEAD/constants/syscalls.md

; #define	LINUX_REBOOT_CMD_RESTART	0x01234567
; #define	LINUX_REBOOT_CMD_HALT		0xCDEF0123
; #define	LINUX_REBOOT_CMD_CAD_ON		0x89ABCDEF
; #define	LINUX_REBOOT_CMD_CAD_OFF	0x00000000
; #define	LINUX_REBOOT_CMD_POWER_OFF	0x4321FEDC
; #define	LINUX_REBOOT_CMD_RESTART2	0xA1B2C3D4
; #define	LINUX_REBOOT_CMD_KEXEC		0x45584543
; #define	LINUX_REBOOT_CMD_SW_SUSPEND	0xD000FCE2

; Stack:
; argc
; arg[n]

section .data
	shutdown_text db "shutdown", 0
	reboot_text db "reboot", 0
	suspend_text db "suspend", 0

	not_enough_args_text db "1 argument required: shutdown, reboot, suspend", 10

section .text
	global _start

_start:
	; Reqire 1 argument
	call .get_argcount
	cmp rax, 1
	je .not_enough_args

	call .arghandler
	call .exit

; Count lenght of rdi
.strlen:
	mov rax, 1				; Init counter
.loop:
	add rdi, 1				; Incr char pointer to next char
	add rax, 1				; Incr counter
	cmp byte [rdi], 0x00
	jne .loop
	ret

.not_enough_args:
	mov rsi, not_enough_args_text	; Text for print
	mov rdi, not_enough_args_text	; Copy text to rdi, for strlen
	call .strlen
	mov rdx, rax					; Ouput value of strlen in rax
	call .print
	call .exit
	ret

.get_argcount:
	pop r10
	pop rax
	push r10
	ret

.arghandler:
	; pop r11				; Temorary Remove
	;mov rsi, [rsp + 8]	; Stack pointer mem addr

	; Shutdown
	;cmp rsi, shutdown_text
	;je .arg_given
	; Reboot
	; cmp rsi, reboot_text
	; je .arg_given
	; Suspend
	; cmp rsi, suspend_text
	; je .arg_given

	;mov rdi, rsi	; Put arg in rdi 
	;call .strlen	; Return in rax
	;mov rdx, rax
	;push r11
	;call .print
	;mov rdx, 0x01234567
	; mov rdx, 0x01234567
	call .reboot
	call .exit
	ret

; .print_argcount:
; 	add rdi, 48
; 	push rdi
; 	mov rsi, rsp
; 	mov rdx, 8
; 	call .print
; 	pop rdi
; 	ret

; .arg_given:
; 	call .not_enough_args
; 	call .exit

; .set_shutdown:
; 	mov rdx, 0x4321FEDC
; 	ret
; .set_reboot:
; 	mov rdx, 0x01234567
; 	ret
; .set_suspend:
; 	mov rdx, 0xD000FCE2
; 	ret

; Takes rdx value
; https://man7.org/linux/man-pages/man2/reboot.2.html
.reboot:
	mov rax, 169
	mov rdi, 0xfee1dead
	mov rsi, 672274793
	mov rdx, 0x01234567
	syscall

	call .sync
	ret

; Needed, else data will be lost
; https://man7.org/linux/man-pages/man2/sync.2.html
.sync:
	mov rax, 162
	syscall
	ret

; Takes: rsi(text), rdx(lenght)
.print:
	mov rax, 1
	mov rdi, 1
	syscall
	ret

.exit:
	mov rax, 60		; Exit syscall
	mov rdi, 0
	syscall