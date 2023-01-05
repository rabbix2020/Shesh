section .data
exit_command db "exit"
cd_command db "cd "
prompt db "# ", 0
dir db "test"

section .bss
currentDirectory resb 5024
command resb 1024
command_args resb 1024

section .text

global _start:

_start:

_loop:
call get_cwd

mov rax, currentDirectory
call print

mov rax, prompt
call print

call read_command

jmp exec_command

jmp _loop

get_cwd:
mov rax, 79
mov rdi, currentDirectory
mov rsi, 5024
syscall

ret

read_command:
mov rax, 0
mov rdi, 0
mov rsi, command
mov rdx, 1024
syscall

ret

print:
push rax
mov rbx, 0

_printLoop:
inc rax
inc rbx
mov cl, [rax]
cmp cl, 0
jne _printLoop
 
mov rax, 1
mov rdi, 1
pop rsi
mov rdx, rbx
syscall
 
ret

add_zero_at_end_of_string:

push rax
mov rbx, 0

_add_zero_at_end_of_string_loop:

inc rax
inc rbx
mov cl, [rax]
cmp cl, 10
jne _add_zero_at_end_of_string_loop
je _add_zero_at_end_of_string_return_result

_add_zero_at_end_of_string_return_result:

pop rax
mov [rax+rbx], byte 0

ret

exec_command:

cld
mov rcx, 4
lea     rsi, exit_command
lea     rdi, command
repe    cmpsb 
je     _exit

cld
mov rcx, 3
lea     rsi, cd_command
lea     rdi, command
repe    cmpsb 
je     _cd

jmp _loop

_exit:

mov rax, 60
mov rdi, 0
syscall

_cd:
mov rax, [command + 3]
mov [command_args], rax

mov rax, command_args
call add_zero_at_end_of_string

push rax

mov rax, 80
pop rdi
syscall

jmp _loop