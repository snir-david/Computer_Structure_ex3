#Snir David Nahari - 205686538
#used tests from Yanir Buznah and Aviv Dimri
#this run_func function - getting opt (number) and jump for case accordגing to it.
  .data 
  .align	8# we want all data to be save in an address that divise with their size.

  .section  .rodata
case_5060_first_str: .string "first pstring length: %d, "
case_5060_second_str: .string "second pstring length: %d\n"

case_52_oldChar: .string "old char: %c, "
case_52_newChar: .string "new char: %c, "
case_52_first_str: .string "first string: %s, "
case_52_second_str: .string "second string: %s\n"

case_53_str_len: .string "length: %d, "
case_53_str: .string "string: %s\n"

case_54_str_len: .string "length: %d, "
case_54_str: .string "string: %s\n"

case_55_comp_res: .string "compare result: %d\n"

case_56: .string "invalid option!\n"

int_format: .string "%d"
string_format:  .string "%s"

.start_jmptbl:
  .quad .case_50_60
  .quad .finish_code
  .quad .case_52
  .quad .case_53
  .quad .case_54
  .quad .case_55
  .quad .invalid_case

  .text
  .globl run_func
  .extern pstrlen,replaceChar, pstrijcpy, swapCase, pstrijcmp

#starting run_func function - getting user input and jumpting to the right case
  .type run_func, @function
run_func:
  #%rdi = opt, %rsi = &pstr1, %rdx = &pstr2
  push  %r12 # pushing r12 to use localy                                                                                                                                                                         
  leaq  -60(%rdi), %r12 #calculating %r12 = (user input) - 60
  cmpq  $0, %r12 # checking if r12 = 0
  je    .case_50_60 # if ZF=1 %rdi = 60 -> case_5060
  addq  $10, %r12 #calculating %r12 = (user input) - 60 + 10
  cmpq  $0, %r12 # if ZF=1 %rdi = 50 -> case_5060
  je    .case_50_60 #%rsi =0 -> case_5060
  cmpq  $1, %r12 # if %r12 =1 %rdi = 51 -> invalid_case
  je    .invalid_case
  cmpq  $6, %r12 # checking if r12 > 6
  ja    .invalid_case # if r12 > go to invalid_case label
  jmp   *.start_jmptbl(,%r12,8) # else, x < 6 go to the right case using start_jmptbl addres

 #printing 2 pstring length
.case_50_60:
  #getting first str length
  movq  %rsi, %rdi
  call  pstrlen
  mov   %rax, %rsi  #putting pstring1 len in %rsi fro printf
  #getting second str length
  movq  %rdx, %rdi
  call  pstrlen
  mov   %rax, %r12

  #print first str length
  mov   $case_5060_first_str, %rdi
  xor   %rax, %rax
  call  printf

  #print second str length
  movq  %r12, %rsi  #putting pstring2 len in %rsi fro printf
  mov   $case_5060_second_str, %rdi
  xor   %rax, %rax
  call  printf
  jmp   .finish_code

.case_52:  #replaceChar
#setup
  push  %rbp
  movq  %rsp, %rbp
  subq  $16, %rsp
  push  %r13
  push  %r14 #oldChar
  push  %r15  #newChar
  movq  %rsi, %r12  #pstr1
  movq  %rdx, %r13  #pstr2

  #getting old char
  leaq  -8(%rbp), %rsi #allocating 8 bytes for old char in -8(%rbp)
  mov   $string_format, %rdi
  xor   %rax, %rax
  call  scanf
  movzbq  -8(%rbp), %r14 #moving old char to %r14

  #getting new char
  leaq  -16(%rbp), %rsi #allocating 8 bytes for old char in -16(%rbp)
  mov   $string_format, %rdi
  xor   %rax, %rax
  call  scanf
  movzbq -16(%rbp), %r15  #moving new char to %r15

  #replacing in first string
  movq  %r15, %rdx  #newChar
  movq  %r14, %rsi  #oldChar
  movq  %r12, %rdi  #pstring1
  call  replaceChar
  movq  %rax, %r12  #saving result string in %r12

  #replacing in second string
  movq  %r15, %rdx  #newChar
  movq  %r14, %rsi  #oldChar
  movq  %r13, %rdi  #pstring2
  call  replaceChar
  movq  %rax, %r13  #saving result string in %r13

  #oldChar print
  movq  %r14, %rsi
  mov   $case_52_oldChar, %rdi
  xor   %rax, %rax
  call  printf

  #newChar print
  movq  %r15, %rsi
  mov   $case_52_newChar, %rdi
  xor   %rax, %rax
  call  printf

  #first string print
  addq  $1, %r12  #skipping lenght in string
  movq  %r12, %rsi
  mov   $case_52_first_str, %rdi
  xor   %rax, %rax
  call  printf

  #second string print
  addq  $1, %r13  #skipping lenght in string
  movq  %r13, %rsi
  mov   $case_52_second_str, %rdi
  xor   %rax, %rax
  call  printf

#finish
  pop   %r15
  pop   %r14
  pop   %r13
  addq  $16, %rsp
  movq  %rbp, %rsp
  pop   %rbp
  jmp   .finish_code

.case_53: #pstrijcpy
  #setup
  push  %rbp
  movq  %rsp, %rbp
  subq  $16, %rsp
  push  %r13
  push  %r14
  push  %r15
  #moving pstrings to registers
  movq  %rsi, %r13  #pstr1
  movq  %rdx, %r14  #pstr2

  #getting first str length
  mov   %rsi, %rdi
  call  pstrlen
  movq  %rax, %r12  #moving pstring1 lenght in %r12

  #getting second str length
  mov   %rdx, %rdi
  call  pstrlen
  movq  %rax, %r15  #moving pstring2 lenght in %r15

  #getting first index - i
  leaq  -4(%rbp), %rsi  #allocating 4 bytes for i index in -4(%rbp)
  mov   $int_format, %rdi
  xor   %rax, %rax
  call  scanf

  #getting second index - j
  leaq  -8(%rbp), %rsi  #allocating 4 bytes for j index in -8(%rbp)
  mov   $int_format, %rdi
  xor   %rax, %rax
  call  scanf

  #setting up for function call
  movl  -4(%rbp), %edx #rdx = i
  movl  -8(%rbp), %ecx #rcx = j
  movq  %r13, %rdi  #pstr1
  movq  %r14, %rsi  #pstr2
  call  pstrijcpy
  movq  %rax, %r13  #moving result string to %r13

  #first print
  movq  %r12, %rsi
  mov   $case_53_str_len, %rdi
  xor   %rax, %rax
  call  printf

  addq  $1, %r13 #starting from text in str (not len)
  movq  %r13, %rsi
  mov   $case_53_str, %rdi
  xor   %rax, %rax
  call  printf

  #second print
  movq  %r15, %rsi
  mov   $case_53_str_len, %rdi
  xor   %rax, %rax
  call  printf

  addq  $1, %r14 #starting from text in str (not len)
  movq  %r14, %rsi
  mov   $case_53_str, %rdi
  xor   %rax, %rax
  call  printf

  #finish
  pop   %r15
  pop   %r14
  pop   %r13
  addq  $16, %rsp
  movq  %rbp, %rsp
  pop   %rbp
  jmp   .finish_code

.case_54:  #swapCase
  #setup
  push  %rbp
  movq  %rsp,%rbp
  push  %r12
  push  %r13
  push  %r14
  push  %r15

  movq  %rsi, %r12 #r12 = pstr1
  movq  %rdx, %r13 #r13 = pstr2
  movzbq (%r12), %r14 #pstr1 -> len
  movzbq (%r13), %r15 #pstr2 -> len

  movq  %r12, %rdi #moving pstring1 to function
  call  swapCase
  movq  %rax, %r12 #moving result string to %r12

  movq  %r13, %rdi  #moving pstring2 to function
  call  swapCase
  movq  %rax, %r13  #moving result string to %r13

  #print first string
  movq  %r14, %rsi
  mov   $case_54_str_len, %rdi
  xor   %rax, %rax
  call  printf

  addq  $1, %r12  #moving %r12 one address forward to skip lenght in printing
  movq  %r12, %rsi
  mov   $case_54_str, %rdi
  xor   %rax, %rax
  call  printf

  #print second string
  movq  %r15, %rsi
  mov   $case_54_str_len, %rdi
  xor   %rax, %rax
  call  printf

  addq  $1, %r13  #moving %r13 one address forward to skip lenght in printing
  movq  %r13, %rsi
  mov   $case_54_str, %rdi
  xor   %rax, %rax
  call  printf

  #finish
  pop   %r15
  pop   %r14
  pop   %r13
  pop   %r12
  movq  %rbp, %rsp
  pop   %rbp
  jmp   .finish_code

.case_55: #pstrijcmp
  #setup
  push  %rbp
  movq  %rsp, %rbp
  subq  $16, %rsp

  push  %r13
  push  %r14
  push  %r15
  movq  %rsi, %r13  #pstr1
  movq  %rdx, %r14  #pstr2

  #getting first index - i
  leaq  -4(%rbp), %rsi  #allocating 4 bytes for i index in -4(%rbp)
  mov   $int_format, %rdi
  xor   %rax, %rax
  call  scanf

  #getting second index - j
  leaq  -8(%rbp), %rsi  #allocating 4 bytes for j index in -8(%rbp)
  mov   $int_format, %rdi
  xor   %rax, %rax
  call  scanf

  movl -4(%rbp), %edx #rdx = i
  movl  -8(%rbp), %ecx #rcx = j
  movq  %r13, %rdi #pstr1
  movq  %r14, %rsi  #pstr2
  call  pstrijcmp

  #print compare result
  movq  %rax, %rsi
  mov   $case_55_comp_res, %rdi
  xor   %rax, %rax
  call  printf

  pop   %r15
  pop   %r14
  pop   %r13
  addq  $16, %rsp
  movq  %rbp, %rsp
  pop   %rbp
  jmp   .finish_code

.invalid_case: #defualte case
  mov   $case_56, %rdi
  xor   %rax, %rax
  call  printf

.finish_code:
  pop   %r12
  ret
