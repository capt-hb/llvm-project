# NOTE: Assertions have been autogenerated by utils/update_mca_test_checks.py
# RUN: llvm-mca -mtriple=x86_64-unknown-unknown -mcpu=btver2 -timeline -timeline-max-iterations=5 < %s | FileCheck %s

sete %r9b
movzbl %al, %eax
shll $2, %eax
imull %ecx, %eax
cmpl $1025, %eax

# CHECK:      Iterations:        100
# CHECK-NEXT: Instructions:      500
# CHECK-NEXT: Total Cycles:      504
# CHECK-NEXT: Total uOps:        500

# CHECK:      Dispatch Width:    2
# CHECK-NEXT: uOps Per Cycle:    0.99
# CHECK-NEXT: IPC:               0.99
# CHECK-NEXT: Block RThroughput: 2.5

# CHECK:      Instruction Info:
# CHECK-NEXT: [1]: #uOps
# CHECK-NEXT: [2]: Latency
# CHECK-NEXT: [3]: RThroughput
# CHECK-NEXT: [4]: MayLoad
# CHECK-NEXT: [5]: MayStore
# CHECK-NEXT: [6]: HasSideEffects (U)

# CHECK:      [1]    [2]    [3]    [4]    [5]    [6]    Instructions:
# CHECK-NEXT:  1      1     0.50                        sete	%r9b
# CHECK-NEXT:  1      1     0.50                        movzbl	%al, %eax
# CHECK-NEXT:  1      1     0.50                        shll	$2, %eax
# CHECK-NEXT:  1      3     1.00                        imull	%ecx, %eax
# CHECK-NEXT:  1      1     0.50                        cmpl	$1025, %eax

# CHECK:      Resources:
# CHECK-NEXT: [0]   - JALU0
# CHECK-NEXT: [1]   - JALU1
# CHECK-NEXT: [2]   - JDiv
# CHECK-NEXT: [3]   - JFPA
# CHECK-NEXT: [4]   - JFPM
# CHECK-NEXT: [5]   - JFPU0
# CHECK-NEXT: [6]   - JFPU1
# CHECK-NEXT: [7]   - JLAGU
# CHECK-NEXT: [8]   - JMul
# CHECK-NEXT: [9]   - JSAGU
# CHECK-NEXT: [10]  - JSTC
# CHECK-NEXT: [11]  - JVALU0
# CHECK-NEXT: [12]  - JVALU1
# CHECK-NEXT: [13]  - JVIMUL

# CHECK:      Resource pressure per iteration:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   [12]   [13]
# CHECK-NEXT: 2.00   3.00    -      -      -      -      -      -     1.00    -      -      -      -      -

# CHECK:      Resource pressure by instruction:
# CHECK-NEXT: [0]    [1]    [2]    [3]    [4]    [5]    [6]    [7]    [8]    [9]    [10]   [11]   [12]   [13]   Instructions:
# CHECK-NEXT: 0.99   0.01    -      -      -      -      -      -      -      -      -      -      -      -     sete	%r9b
# CHECK-NEXT: 0.01   0.99    -      -      -      -      -      -      -      -      -      -      -      -     movzbl	%al, %eax
# CHECK-NEXT:  -     1.00    -      -      -      -      -      -      -      -      -      -      -      -     shll	$2, %eax
# CHECK-NEXT:  -     1.00    -      -      -      -      -      -     1.00    -      -      -      -      -     imull	%ecx, %eax
# CHECK-NEXT: 1.00    -      -      -      -      -      -      -      -      -      -      -      -      -     cmpl	$1025, %eax

# CHECK:      Timeline view:
# CHECK-NEXT:                     0123456789
# CHECK-NEXT: Index     0123456789          012345678

# CHECK:      [0,0]     DeER .    .    .    .    .  .   sete	%r9b
# CHECK-NEXT: [0,1]     DeER .    .    .    .    .  .   movzbl	%al, %eax
# CHECK-NEXT: [0,2]     .DeER.    .    .    .    .  .   shll	$2, %eax
# CHECK-NEXT: [0,3]     .D=eeeER  .    .    .    .  .   imull	%ecx, %eax
# CHECK-NEXT: [0,4]     . D===eER .    .    .    .  .   cmpl	$1025, %eax
# CHECK-NEXT: [1,0]     . D====eER.    .    .    .  .   sete	%r9b
# CHECK-NEXT: [1,1]     .  D==eE-R.    .    .    .  .   movzbl	%al, %eax
# CHECK-NEXT: [1,2]     .  D===eE-R    .    .    .  .   shll	$2, %eax
# CHECK-NEXT: [1,3]     .   D===eeeER  .    .    .  .   imull	%ecx, %eax
# CHECK-NEXT: [1,4]     .   D======eER .    .    .  .   cmpl	$1025, %eax
# CHECK-NEXT: [2,0]     .    D======eER.    .    .  .   sete	%r9b
# CHECK-NEXT: [2,1]     .    D=====eE-R.    .    .  .   movzbl	%al, %eax
# CHECK-NEXT: [2,2]     .    .D=====eE-R    .    .  .   shll	$2, %eax
# CHECK-NEXT: [2,3]     .    .D======eeeER  .    .  .   imull	%ecx, %eax
# CHECK-NEXT: [2,4]     .    . D========eER .    .  .   cmpl	$1025, %eax
# CHECK-NEXT: [3,0]     .    . D=========eER.    .  .   sete	%r9b
# CHECK-NEXT: [3,1]     .    .  D=======eE-R.    .  .   movzbl	%al, %eax
# CHECK-NEXT: [3,2]     .    .  D========eE-R    .  .   shll	$2, %eax
# CHECK-NEXT: [3,3]     .    .   D========eeeER  .  .   imull	%ecx, %eax
# CHECK-NEXT: [3,4]     .    .   D===========eER .  .   cmpl	$1025, %eax
# CHECK-NEXT: [4,0]     .    .    D===========eER.  .   sete	%r9b
# CHECK-NEXT: [4,1]     .    .    D==========eE-R.  .   movzbl	%al, %eax
# CHECK-NEXT: [4,2]     .    .    .D==========eE-R  .   shll	$2, %eax
# CHECK-NEXT: [4,3]     .    .    .D===========eeeER.   imull	%ecx, %eax
# CHECK-NEXT: [4,4]     .    .    . D=============eER   cmpl	$1025, %eax

# CHECK:      Average Wait times (based on the timeline view):
# CHECK-NEXT: [0]: Executions
# CHECK-NEXT: [1]: Average time spent waiting in a scheduler's queue
# CHECK-NEXT: [2]: Average time spent waiting in a scheduler's queue while ready
# CHECK-NEXT: [3]: Average time elapsed from WB until retire stage

# CHECK:            [0]    [1]    [2]    [3]
# CHECK-NEXT: 0.     5     7.0    0.2    0.0       sete	%r9b
# CHECK-NEXT: 1.     5     5.8    0.2    0.8       movzbl	%al, %eax
# CHECK-NEXT: 2.     5     6.2    0.0    0.8       shll	$2, %eax
# CHECK-NEXT: 3.     5     6.8    0.0    0.0       imull	%ecx, %eax
# CHECK-NEXT: 4.     5     9.2    0.0    0.0       cmpl	$1025, %eax
