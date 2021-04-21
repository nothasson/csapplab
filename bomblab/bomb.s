	.file	"bomb.c"
	.text
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"r"
.LC1:
	.string	"%s: Error: Couldn't open %s\n"
.LC2:
	.string	"Usage: %s [<input_file>]\n"
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align 8
.LC3:
	.string	"Welcome to my fiendish little bomb. You have 6 phases with"
	.align 8
.LC4:
	.string	"which to blow yourself up. Have a nice day!"
	.align 8
.LC5:
	.string	"Phase 1 defused. How about the next one?"
	.section	.rodata.str1.1
.LC6:
	.string	"That's number 2.  Keep going!"
.LC7:
	.string	"Halfway there!"
	.section	.rodata.str1.8
	.align 8
.LC8:
	.string	"So you got that one.  Try this one."
	.section	.rodata.str1.1
.LC9:
	.string	"Good work!  On to the next..."
	.text
	.globl	main
	.type	main, @function
main:
.LFB39:
	.cfi_startproc
	endbr64
	pushq	%rbx
	.cfi_def_cfa_offset 16
	.cfi_offset 3, -16
	cmpl	$1, %edi
	je	.L6
	movq	%rsi, %rbx
	cmpl	$2, %edi
	jne	.L4
	movq	8(%rsi), %rdi
	leaq	.LC0(%rip), %rsi
	call	fopen@PLT
	movq	%rax, infile(%rip)
	testq	%rax, %rax
	je	.L7
.L3:
	movl	$0, %eax
	call	initialize_bomb@PLT
	leaq	.LC3(%rip), %rdi
	call	puts@PLT
	leaq	.LC4(%rip), %rdi
	call	puts@PLT
	movl	$0, %eax
	call	read_line@PLT
	movslq	%eax, %rdi
	movl	$0, %eax
	call	phase_1@PLT
	movl	$0, %eax
	call	phase_defused@PLT
	leaq	.LC5(%rip), %rdi
	call	puts@PLT
	movl	$0, %eax
	call	read_line@PLT
	movslq	%eax, %rdi
	movl	$0, %eax
	call	phase_2@PLT
	movl	$0, %eax
	call	phase_defused@PLT
	leaq	.LC6(%rip), %rdi
	call	puts@PLT
	movl	$0, %eax
	call	read_line@PLT
	movslq	%eax, %rdi
	movl	$0, %eax
	call	phase_3@PLT
	movl	$0, %eax
	call	phase_defused@PLT
	leaq	.LC7(%rip), %rdi
	call	puts@PLT
	movl	$0, %eax
	call	read_line@PLT
	movslq	%eax, %rdi
	movl	$0, %eax
	call	phase_4@PLT
	movl	$0, %eax
	call	phase_defused@PLT
	leaq	.LC8(%rip), %rdi
	call	puts@PLT
	movl	$0, %eax
	call	read_line@PLT
	movslq	%eax, %rdi
	movl	$0, %eax
	call	phase_5@PLT
	movl	$0, %eax
	call	phase_defused@PLT
	leaq	.LC9(%rip), %rdi
	call	puts@PLT
	movl	$0, %eax
	call	read_line@PLT
	movslq	%eax, %rdi
	movl	$0, %eax
	call	phase_6@PLT
	movl	$0, %eax
	call	phase_defused@PLT
	movl	$0, %eax
	popq	%rbx
	.cfi_remember_state
	.cfi_def_cfa_offset 8
	ret
.L6:
	.cfi_restore_state
	movq	stdin(%rip), %rax
	movq	%rax, infile(%rip)
	jmp	.L3
.L7:
	movq	8(%rbx), %rcx
	movq	(%rbx), %rdx
	leaq	.LC1(%rip), %rsi
	movl	$1, %edi
	call	__printf_chk@PLT
	movl	$8, %edi
	call	exit@PLT
.L4:
	movq	(%rsi), %rdx
	leaq	.LC2(%rip), %rsi
	movl	$1, %edi
	movl	$0, %eax
	call	__printf_chk@PLT
	movl	$8, %edi
	call	exit@PLT
	.cfi_endproc
.LFE39:
	.size	main, .-main
	.comm	infile,8,8
	.ident	"GCC: (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	 1f - 0f
	.long	 4f - 1f
	.long	 5
0:
	.string	 "GNU"
1:
	.align 8
	.long	 0xc0000002
	.long	 3f - 2f
2:
	.long	 0x3
3:
	.align 8
4:
