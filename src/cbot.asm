; Reboot or shutdown your system
; https://chromium.googlesource.com/chromiumos/docs/+/HEAD/constants/syscalls.md

; /usr/include/linux/reboot.h
; #define	LINUX_REBOOT_CMD_RESTART	0x01234567
; #define	LINUX_REBOOT_CMD_HALT		0xCDEF0123
; #define	LINUX_REBOOT_CMD_CAD_ON		0x89ABCDEF
; #define	LINUX_REBOOT_CMD_CAD_OFF	0x00000000
; #define	LINUX_REBOOT_CMD_POWER_OFF	0x4321FEDC
; #define	LINUX_REBOOT_CMD_RESTART2	0xA1B2C3D4
; #define	LINUX_REBOOT_CMD_KEXEC		0x45584543
; #define	LINUX_REBOOT_CMD_SW_SUSPEND	0xD000FCE2

section .data
	newline db 10
	; Args
	shutdown_text db "shutdown", 0
	reboot_text db "reboot", 0
	; Help messages
	not_enough_args_text db "1 argument required: shutdown, reboot", 0
	root_required_text db "You cannot perform this operation unless you are root", 0

section .text
	global _start

_start:
	; Reqire 1 argument
	call .get_argcount
	cmp rax, 1
	je .not_enough_args
	
	; Check if ran as root
	call .get_uid
	cmp rax, 0
	jg .not_root

	call .arghandler
	call .exit

.not_enough_args:
	mov rsi, not_enough_args_text	; Text for print
	call .printf
	ret

.get_argcount:
	pop r10
	pop rax
	push r10
	ret

.not_root:
	mov rsi, root_required_text
	call .printf
	ret

; Return in rax
; https://man7.org/linux/man-pages/man2/geteuid.2.html
.get_uid:
	mov rax, 107
	syscall
	ret

; Success & fail for argchecker
.success:
	mov rax, 1
	ret
.fail:
	ret

; Takes rdi(text)
.argchecker:
	; Why is there so much in stack? 8-> 16-> 24->
	mov rsi, [rsp + 24]	; Stack pointer mem addr (rsp: Register Stack Pointer), arg[1]
	xor rax, rax		; Rax = 0
	xor rdx, rdx		; Rdx = 0
.argloop:
	; Loop trough characters and compare
	mov al, [rsi + rdx]
	mov bl, [rdi + rdx]
	inc rdx
	cmp al, bl
	jne .fail
	; jne .printf
	cmp al, 0
	je .success
	jmp .argloop
	ret

.arghandler:
	; Shutdown
	mov rdi, shutdown_text
	call .argchecker
	cmp rax, 1
	je .do_shutdown
	; Suspend
	mov rdi, reboot_text
	call .argchecker
	cmp rax, 1
	je .do_reboot

	call .not_enough_args
	call .exit
	ret

.do_shutdown:
	mov rdx, 0x4321FEDC
	call .reboot;
	ret
.do_reboot:
	mov rdx, 0x01234567
	call .reboot;
	ret

; Takes rdx value
; https://man7.org/linux/man-pages/man2/reboot.2.html
.reboot:
	mov rax, 169
	mov rdi, 0xfee1dead
	mov rsi, 672274793
	syscall

	call .sync
	call .exit
	ret

; Needed, else data will be lost
; https://man7.org/linux/man-pages/man2/sync.2.html
.sync:
	mov rax, 162
	syscall
	ret

; Count length of rdi
.strlen:
	xor rax, rax				; Init counter
.strloop:
	inc rdi					; Incr char pointer to next char
	add rax, 1				; Incr counter
	cmp byte [rdi], 0x00
	jne .strloop
	ret
	
; Takes rsi(text)
.printf:
	; mov rsi, root_required_text
	mov rdi, rsi
	call .strlen
	mov rdx, rax
	call .print
	call .exit
	ret

; Print new line
.printnln:
	mov rax, 1
	mov rdi, 1
	mov rsi, newline
	mov rdx, 1
	syscall
	ret

; Takes: rsi(text), rdx(length)
.print:
	mov rax, 1
	mov rdi, 1
	syscall

	call .printnln
	ret

.exit:
	mov rax, 60		; Exit syscall
	xor rdi, rdi	; Set to 0
	syscall