; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: %cheri_purecap_opt -cheri-bound-allocas -o - -S %s | FileCheck %s
; RUN: %cheri128_purecap_llc -O0 %s -cheri-stack-bounds-allow-remat=true -o - | FileCheck %s -check-prefix ASM '-D#CAP_SIZE=16'
; RUN: %cheri128_purecap_llc -O2 %s -cheri-stack-bounds-allow-remat=true -o - | FileCheck %s -check-prefix ASM-OPT '-D#CAP_SIZE=16'

; reduced C test case:
; __builtin_va_list a;
; char *b;
; void c() {
;   while (__builtin_va_arg(a, char))
;     b = __builtin_alloca(sizeof(b));
;   d(b);
; }
target datalayout = "Eme-pf200:128:128:128:64-A200-P200-G200"

declare i32 @use_alloca(i8 addrspace(200)*) local_unnamed_addr addrspace(200) #0


define i32 @alloca_in_entry(i1 %arg) local_unnamed_addr addrspace(200) #0 {
; CHECK-LABEL: @alloca_in_entry(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[ALLOCA:%.*]] = alloca [16 x i8], align 16, addrspace(200)
; CHECK-NEXT:    br i1 [[ARG:%.*]], label [[DO_ALLOCA:%.*]], label [[EXIT:%.*]]
; CHECK:       do_alloca:
; CHECK-NEXT:    br label [[USE_ALLOCA_NO_BOUNDS:%.*]]
; CHECK:       use_alloca_no_bounds:
; CHECK-NEXT:    [[PTR:%.*]] = bitcast [16 x i8] addrspace(200)* [[ALLOCA]] to i64 addrspace(200)*
; CHECK-NEXT:    [[PTR_PLUS_ONE:%.*]] = getelementptr i64, i64 addrspace(200)* [[PTR]], i64 1
; CHECK-NEXT:    store i64 1234, i64 addrspace(200)* [[PTR_PLUS_ONE]], align 8
; CHECK-NEXT:    br label [[USE_ALLOCA_NEED_BOUNDS:%.*]]
; CHECK:       use_alloca_need_bounds:
; CHECK-NEXT:    [[TMP0:%.*]] = bitcast [16 x i8] addrspace(200)* [[ALLOCA]] to i8 addrspace(200)*
; CHECK-NEXT:    [[TMP1:%.*]] = call i8 addrspace(200)* @llvm.cheri.bounded.stack.cap.i64(i8 addrspace(200)* [[TMP0]], i64 16)
; CHECK-NEXT:    [[TMP2:%.*]] = bitcast i8 addrspace(200)* [[TMP1]] to [16 x i8] addrspace(200)*
; CHECK-NEXT:    [[DOTSUB_LE:%.*]] = getelementptr inbounds [16 x i8], [16 x i8] addrspace(200)* [[TMP2]], i64 0, i64 0
; CHECK-NEXT:    [[CALL:%.*]] = call signext i32 @use_alloca(i8 addrspace(200)* [[DOTSUB_LE]]) #2
; CHECK-NEXT:    br label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    ret i32 123
; ASM-LABEL: alloca_in_entry:
; ASM:       # %bb.0: # %entry
; ASM-NEXT:    cincoffset $c11, $c11, -[[#STACKFRAME_SIZE:]]
; ASM-NEXT:    csc $c17, $zero, [[#STACKFRAME_SIZE - CAP_SIZE]]($c11)
; ASM-NEXT:    lui $1, %pcrel_hi(_CHERI_CAPABILITY_TABLE_-8)
; ASM-NEXT:    daddiu $1, $1, %pcrel_lo(_CHERI_CAPABILITY_TABLE_-4)
; ASM-NEXT:    cgetpccincoffset $c1, $1
; ASM-NEXT:    # kill: def $a0 killed $a0 killed $a0_64
; ASM-NEXT:    sll $2, $4, 0
; ASM-NEXT:    andi $2, $2, 1
; ASM-NEXT:    csc $c1, $zero, 0($c11)
; ASM-NEXT:    beqz $2, .LBB0_5
; ASM-NEXT:    nop
; ASM-NEXT:  # %bb.1: # %entry
; ASM-NEXT:    b .LBB0_2
; ASM-NEXT:    nop
; ASM-NEXT:  .LBB0_2: # %do_alloca
; ASM-NEXT:    b .LBB0_3
; ASM-NEXT:    nop
; ASM-NEXT:  .LBB0_3: # %use_alloca_no_bounds
; ASM-NEXT:    daddiu $1, $zero, 1234
; ASM-NEXT:    csd $1, $zero, 24($c11)
; ASM-NEXT:    b .LBB0_4
; ASM-NEXT:    nop
; ASM-NEXT:  .LBB0_4: # %use_alloca_need_bounds
; ASM-NEXT:    cincoffset $c3, $c11, 16
; ASM-NEXT:    csetbounds $c3, $c3, 16
; ASM-NEXT:    clc $c1, $zero, 0($c11)
; ASM-NEXT:    clcbi $c12, %capcall20(use_alloca)($c1)
; ASM-NEXT:    cgetnull $c13
; ASM-NEXT:    cjalr $c12, $c17
; ASM-NEXT:    nop
; ASM-NEXT:    b .LBB0_5
; ASM-NEXT:    nop
; ASM-NEXT:  .LBB0_5: # %exit
; ASM-NEXT:    addiu $2, $zero, 123
; ASM-NEXT:    clc $c17, $zero, [[#STACKFRAME_SIZE - CAP_SIZE]]($c11)
; ASM-NEXT:    cincoffset $c11, $c11, [[#STACKFRAME_SIZE]]
; ASM-NEXT:    cjr $c17
; ASM-NEXT:    nop
;
; ASM-OPT-LABEL: alloca_in_entry:
; ASM-OPT:       # %bb.0: # %entry
; ASM-OPT-NEXT:    sll $1, $4, 0
; ASM-OPT-NEXT:    andi $1, $1, 1
; ASM-OPT-NEXT:    beqz $1, .LBB0_2
; ASM-OPT-NEXT:    nop
; ASM-OPT-NEXT:  # %bb.1: # %do_alloca
; ASM-OPT-NEXT:    cincoffset $c11, $c11, -[[#STACKFRAME_SIZE:]]
; ASM-OPT-NEXT:    csc $c17, $zero, [[#STACKFRAME_SIZE - CAP_SIZE]]($c11)
; ASM-OPT-NEXT:    lui $1, %pcrel_hi(_CHERI_CAPABILITY_TABLE_-8)
; ASM-OPT-NEXT:    daddiu $1, $1, %pcrel_lo(_CHERI_CAPABILITY_TABLE_-4)
; ASM-OPT-NEXT:    cgetpccincoffset $c1, $1
; ASM-OPT-NEXT:    daddiu $1, $zero, 1234
; ASM-OPT-NEXT:    csd $1, $zero, 8($c11)
; ASM-OPT-NEXT:    clcbi $c12, %capcall20(use_alloca)($c1)
; ASM-OPT-NEXT:    cjalr $c12, $c17
; ASM-OPT-NEXT:    csetbounds $c3, $c11, 16
; ASM-OPT-NEXT:    clc $c17, $zero, [[#STACKFRAME_SIZE - CAP_SIZE]]($c11)
; ASM-OPT-NEXT:    cincoffset $c11, $c11, [[#STACKFRAME_SIZE]]
; ASM-OPT-NEXT:  .LBB0_2: # %exit
; ASM-OPT-NEXT:    cjr $c17
; ASM-OPT-NEXT:    addiu $2, $zero, 123


entry:                                       ; preds = %entry
  %alloca = alloca [16 x i8], align 16, addrspace(200)
  br i1 %arg, label %do_alloca, label %exit

do_alloca:
  br label %use_alloca_no_bounds

use_alloca_no_bounds:
  %ptr = bitcast [16 x i8] addrspace(200)* %alloca to i64 addrspace(200)*
  %ptr_plus_one = getelementptr i64, i64 addrspace(200)* %ptr, i64 1
  store i64 1234, i64 addrspace(200)* %ptr_plus_one, align 8
  br label %use_alloca_need_bounds

use_alloca_need_bounds:
  %.sub.le = getelementptr inbounds [16 x i8], [16 x i8] addrspace(200)* %alloca, i64 0, i64 0
  %call = call signext i32 @use_alloca(i8 addrspace(200)* %.sub.le) #1
  br label %exit

exit:
  ret i32 123
}


define i32 @alloca_not_in_entry(i1 %arg) local_unnamed_addr addrspace(200) #0 {
; CHECK-LABEL: @alloca_not_in_entry(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 [[ARG:%.*]], label [[DO_ALLOCA:%.*]], label [[EXIT:%.*]]
; CHECK:       do_alloca:
; CHECK-NEXT:    [[ALLOCA:%.*]] = alloca [16 x i8], align 16, addrspace(200)
; CHECK-NEXT:    [[TMP0:%.*]] = bitcast [16 x i8] addrspace(200)* [[ALLOCA]] to i8 addrspace(200)*
; CANNOT USE llvm.cheri.bounded.stack.cap.i64 here, since that only works for static allocas:
; CHECK-NEXT:    [[TMP1:%.*]] = call i8 addrspace(200)* @llvm.cheri.cap.bounds.set.i64(i8 addrspace(200)* [[TMP0]], i64 16)
; CHECK-NEXT:    [[TMP2:%.*]] = bitcast i8 addrspace(200)* [[TMP1]] to [16 x i8] addrspace(200)*
; CHECK-NEXT:    br label [[USE_ALLOCA_NO_BOUNDS:%.*]]
; CHECK:       use_alloca_no_bounds:
; CHECK-NEXT:    [[PTR:%.*]] = bitcast [16 x i8] addrspace(200)* [[ALLOCA]] to i64 addrspace(200)*
; CHECK-NEXT:    [[PTR_PLUS_ONE:%.*]] = getelementptr i64, i64 addrspace(200)* [[PTR]], i64 1
; CHECK-NEXT:    store i64 1234, i64 addrspace(200)* [[PTR_PLUS_ONE]], align 8
; CHECK-NEXT:    br label [[USE_ALLOCA_NEED_BOUNDS:%.*]]
; CHECK:       use_alloca_need_bounds:
; CHECK-NEXT:    [[DOTSUB_LE:%.*]] = getelementptr inbounds [16 x i8], [16 x i8] addrspace(200)* [[TMP2]], i64 0, i64 0
; CHECK-NEXT:    [[CALL:%.*]] = call signext i32 @use_alloca(i8 addrspace(200)* [[DOTSUB_LE]]) #2
; CHECK-NEXT:    br label [[EXIT]]
; CHECK:       exit:
; CHECK-NEXT:    ret i32 123
;
; ASM-LABEL: alloca_not_in_entry:
; ASM:       # %bb.0: # %entry
; ASM-NEXT:    cincoffset $c11, $c11, -[[#STACKFRAME_SIZE:]]
; ASM-NEXT:    csc $c24, $zero, [[#STACKFRAME_SIZE - CAP_SIZE]]($c11)
; ASM-NEXT:    csc $c17, $zero, [[#STACKFRAME_SIZE - (2 * CAP_SIZE)]]($c11)
; ASM-NEXT:    cincoffset $c24, $c11, $zero
; ASM-NEXT:    lui $1, %pcrel_hi(_CHERI_CAPABILITY_TABLE_-8)
; ASM-NEXT:    daddiu $1, $1, %pcrel_lo(_CHERI_CAPABILITY_TABLE_-4)
; ASM-NEXT:    cgetpccincoffset $c1, $1
; ASM-NEXT:    # kill: def $a0 killed $a0 killed $a0_64
; ASM-NEXT:    sll $2, $4, 0
; ASM-NEXT:    andi $2, $2, 1
; ASM-NEXT:    csc $c1, $zero, 32($c24) # 16-byte Folded Spill
; ASM-NEXT:    beqz $2, .LBB1_5
; ASM-NEXT:    nop
; ASM-NEXT:  # %bb.1: # %entry
; ASM-NEXT:    b .LBB1_2
; ASM-NEXT:    nop
; ASM-NEXT:  .LBB1_2: # %do_alloca
; ASM-NEXT:    cmove $c1, $c11
; ASM-NEXT:    cgetaddr $1, $c1
; ASM-NEXT:    daddiu $1, $1, -16
; ASM-NEXT:    csetaddr $c1, $c1, $1
; ASM-NEXT:    csetbounds $c2, $c1, 16
; ASM-NEXT:    cmove $c11, $c1
; ASM-NEXT:    cmove $c1, $c2
; ASM-NEXT:    csc $c2, $zero, 16($c24) # 16-byte Folded Spill
; ASM-NEXT:    csc $c1, $zero, 0($c24) # 16-byte Folded Spill
; ASM-NEXT:    b .LBB1_3
; ASM-NEXT:    nop
; ASM-NEXT:  .LBB1_3: # %use_alloca_no_bounds
; ASM-NEXT:    daddiu $1, $zero, 1234
; ASM-NEXT:    clc $c1, $zero, 0($c24) # 16-byte Folded Reload
; ASM-NEXT:    csd $1, $zero, 8($c1)
; ASM-NEXT:    b .LBB1_4
; ASM-NEXT:    nop
; ASM-NEXT:  .LBB1_4: # %use_alloca_need_bounds
; ASM-NEXT:    clc $c1, $zero, 32($c24) # 16-byte Folded Reload
; ASM-NEXT:    clcbi $c12, %capcall20(use_alloca)($c1)
; ASM-NEXT:    clc $c3, $zero, 16($c24) # 16-byte Folded Reload
; ASM-NEXT:    cgetnull $c13
; ASM-NEXT:    cjalr $c12, $c17
; ASM-NEXT:    nop
; ASM-NEXT:    b .LBB1_5
; ASM-NEXT:    nop
; ASM-NEXT:  .LBB1_5: # %exit
; ASM-NEXT:    addiu $2, $zero, 123
; ASM-NEXT:    cincoffset $c11, $c24, $zero
; ASM-NEXT:    clc $c17, $zero, [[#STACKFRAME_SIZE - (2 * CAP_SIZE)]]($c11)
; ASM-NEXT:    clc $c24, $zero, [[#STACKFRAME_SIZE - CAP_SIZE]]($c11)
; ASM-NEXT:    cincoffset $c11, $c11, [[#STACKFRAME_SIZE]]
; ASM-NEXT:    cjr $c17
; ASM-NEXT:    nop
;
; ASM-OPT-LABEL: alloca_not_in_entry:
; ASM-OPT:       # %bb.0: # %entry
; ASM-OPT-NEXT:    sll $1, $4, 0
; ASM-OPT-NEXT:    andi $1, $1, 1
; ASM-OPT-NEXT:    beqz $1, .LBB1_2
; ASM-OPT-NEXT:    nop
; ASM-OPT-NEXT:  # %bb.1: # %do_alloca
; ASM-OPT-NEXT:    cincoffset $c11, $c11, -[[#STACKFRAME_SIZE:]]
; ASM-OPT-NEXT:    csc $c24, $zero, [[#STACKFRAME_SIZE - CAP_SIZE]]($c11)
; ASM-OPT-NEXT:    csc $c17, $zero, 0($c11)
; ASM-OPT-NEXT:    cincoffset $c24, $c11, $zero
; ASM-OPT-NEXT:    lui $1, %pcrel_hi(_CHERI_CAPABILITY_TABLE_-8)
; ASM-OPT-NEXT:    daddiu $1, $1, %pcrel_lo(_CHERI_CAPABILITY_TABLE_-4)
; ASM-OPT-NEXT:    cgetpccincoffset $c1, $1
; ASM-OPT-NEXT:    cgetaddr $1, $c11
; ASM-OPT-NEXT:    daddiu $1, $1, -16
; ASM-OPT-NEXT:    csetaddr $c2, $c11, $1
; ASM-OPT-NEXT:    csetbounds $c3, $c2, 16
; ASM-OPT-NEXT:    daddiu $1, $zero, 1234
; ASM-OPT-NEXT:    csd $1, $zero, 8($c3)
; ASM-OPT-NEXT:    clcbi $c12, %capcall20(use_alloca)($c1)
; ASM-OPT-NEXT:    cjalr $c12, $c17
; ASM-OPT-NEXT:    cmove $c11, $c2
; ASM-OPT-NEXT:    cincoffset $c11, $c24, $zero
; ASM-OPT-NEXT:    clc $c17, $zero, 0($c11)
; ASM-OPT-NEXT:    clc $c24, $zero, [[#STACKFRAME_SIZE - CAP_SIZE]]($c11)
; ASM-OPT-NEXT:    cincoffset $c11, $c11, [[#STACKFRAME_SIZE]]
; ASM-OPT-NEXT:  .LBB1_2: # %exit
; ASM-OPT-NEXT:    cjr $c17
; ASM-OPT-NEXT:    addiu $2, $zero, 123


entry:                                       ; preds = %entry
  br i1 %arg, label %do_alloca, label %exit

do_alloca:
  %alloca = alloca [16 x i8], align 16, addrspace(200)
  br label %use_alloca_no_bounds

use_alloca_no_bounds:
  %ptr = bitcast [16 x i8] addrspace(200)* %alloca to i64 addrspace(200)*
  %ptr_plus_one = getelementptr i64, i64 addrspace(200)* %ptr, i64 1
  store i64 1234, i64 addrspace(200)* %ptr_plus_one, align 8
  br label %use_alloca_need_bounds

use_alloca_need_bounds:
  %.sub.le = getelementptr inbounds [16 x i8], [16 x i8] addrspace(200)* %alloca, i64 0, i64 0
  %call = call signext i32 @use_alloca(i8 addrspace(200)* %.sub.le) #1
  br label %exit

exit:
  ret i32 123
}


; The original reduced test case from libc/gen/exec.c
define i32 @crash_reproducer(i1 %arg) local_unnamed_addr addrspace(200) #0 {
; CHECK-LABEL: @crash_reproducer(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br i1 [[ARG:%.*]], label [[ENTRY_WHILE_END_CRIT_EDGE:%.*]], label [[WHILE_BODY:%.*]]
; CHECK:       entry.while.end_crit_edge:
; CHECK-NEXT:    unreachable
; CHECK:       while.body:
; CHECK-NEXT:    [[TMP0:%.*]] = alloca [16 x i8], align 16, addrspace(200)
; CHECK-NEXT:    [[TMP1:%.*]] = bitcast [16 x i8] addrspace(200)* [[TMP0]] to i8 addrspace(200)*
; CANNOT USE llvm.cheri.bounded.stack.cap.i64 here, since that only works for static allocas:
; CHECK-NEXT:    [[TMP2:%.*]] = call i8 addrspace(200)* @llvm.cheri.cap.bounds.set.i64(i8 addrspace(200)* [[TMP1]], i64 16)
; CHECK-NEXT:    [[TMP3:%.*]] = bitcast i8 addrspace(200)* [[TMP2]] to [16 x i8] addrspace(200)*
; CHECK-NEXT:    br label [[WHILE_END_LOOPEXIT:%.*]]
; CHECK:       while.end.loopexit:
; CHECK-NEXT:    [[DOTSUB_LE:%.*]] = getelementptr inbounds [16 x i8], [16 x i8] addrspace(200)* [[TMP3]], i64 0, i64 0
; CHECK-NEXT:    br label [[WHILE_END:%.*]]
; CHECK:       while.end:
; CHECK-NEXT:    [[CALL:%.*]] = call signext i32 @use_alloca(i8 addrspace(200)* [[DOTSUB_LE]]) #2
; CHECK-NEXT:    [[RESULT:%.*]] = add i32 [[CALL]], 1234
; CHECK-NEXT:    ret i32 [[RESULT]]
;
; ASM-LABEL: crash_reproducer:
; ASM:       # %bb.0: # %entry
; ASM-NEXT:    cincoffset $c11, $c11, -[[#STACKFRAME_SIZE:]]
; ASM-NEXT:    csc $c24, $zero, [[#STACKFRAME_SIZE - CAP_SIZE]]($c11)
; ASM-NEXT:    csc $c17, $zero, [[#STACKFRAME_SIZE - (2 * CAP_SIZE)]]($c11)
; ASM-NEXT:    cincoffset $c24, $c11, $zero
; ASM-NEXT:    lui $1, %pcrel_hi(_CHERI_CAPABILITY_TABLE_-8)
; ASM-NEXT:    daddiu $1, $1, %pcrel_lo(_CHERI_CAPABILITY_TABLE_-4)
; ASM-NEXT:    cgetpccincoffset $c1, $1
; ASM-NEXT:    # kill: def $a0 killed $a0 killed $a0_64
; ASM-NEXT:    sll $2, $4, 0
; ASM-NEXT:    andi $2, $2, 1
; ASM-NEXT:    csc $c1, $zero, 32($c24) # 16-byte Folded Spill
; ASM-NEXT:    beqz $2, .LBB2_3
; ASM-NEXT:    nop
; ASM-NEXT:  # %bb.1: # %entry
; ASM-NEXT:    b .LBB2_2
; ASM-NEXT:    nop
; ASM-NEXT:  .LBB2_2: # %entry.while.end_crit_edge
; ASM-NEXT:    .insn
; ASM-NEXT:  .LBB2_3: # %while.body
; ASM-NEXT:    cmove $c1, $c11
; ASM-NEXT:    cgetaddr $1, $c1
; ASM-NEXT:    daddiu $1, $1, -16
; ASM-NEXT:    csetaddr $c1, $c1, $1
; ASM-NEXT:    csetbounds $c2, $c1, 16
; ASM-NEXT:    cmove $c11, $c1
; ASM-NEXT:    csc $c2, $zero, 16($c24) # 16-byte Folded Spill
; ASM-NEXT:    b .LBB2_4
; ASM-NEXT:    nop
; ASM-NEXT:  .LBB2_4: # %while.end.loopexit
; ASM-NEXT:    clc $c1, $zero, 16($c24) # 16-byte Folded Reload
; ASM-NEXT:    csc $c1, $zero, 0($c24) # 16-byte Folded Spill
; ASM-NEXT:    b .LBB2_5
; ASM-NEXT:    nop
; ASM-NEXT:  .LBB2_5: # %while.end
; ASM-NEXT:    clc $c1, $zero, 32($c24) # 16-byte Folded Reload
; ASM-NEXT:    clcbi $c12, %capcall20(use_alloca)($c1)
; ASM-NEXT:    clc $c3, $zero, 0($c24) # 16-byte Folded Reload
; ASM-NEXT:    cgetnull $c13
; ASM-NEXT:    cjalr $c12, $c17
; ASM-NEXT:    nop
; ASM-NEXT:    addiu $2, $2, 1234
; ASM-NEXT:    cincoffset $c11, $c24, $zero
; ASM-NEXT:    clc $c17, $zero, [[#STACKFRAME_SIZE - (2 * CAP_SIZE)]]($c11)
; ASM-NEXT:    clc $c24, $zero, [[#STACKFRAME_SIZE - CAP_SIZE]]($c11)
; ASM-NEXT:    cincoffset $c11, $c11, [[#STACKFRAME_SIZE]]
; ASM-NEXT:    cjr $c17
; ASM-NEXT:    nop
;
; ASM-OPT-LABEL: crash_reproducer:
; ASM-OPT:       # %bb.0: # %entry
; ASM-OPT-NEXT:    sll $1, $4, 0
; ASM-OPT-NEXT:    andi $1, $1, 1
; ASM-OPT-NEXT:    bnez $1, .LBB2_2
; ASM-OPT-NEXT:    nop
; ASM-OPT-NEXT:  # %bb.1: # %while.body
; ASM-OPT-NEXT:    cincoffset $c11, $c11, -[[#STACKFRAME_SIZE:]]
; ASM-OPT-NEXT:    csc $c24, $zero, [[#STACKFRAME_SIZE - CAP_SIZE]]($c11)
; ASM-OPT-NEXT:    csc $c17, $zero, 0($c11)
; ASM-OPT-NEXT:    cincoffset $c24, $c11, $zero
; ASM-OPT-NEXT:    lui $1, %pcrel_hi(_CHERI_CAPABILITY_TABLE_-8)
; ASM-OPT-NEXT:    daddiu $1, $1, %pcrel_lo(_CHERI_CAPABILITY_TABLE_-4)
; ASM-OPT-NEXT:    cgetpccincoffset $c1, $1
; ASM-OPT-NEXT:    cgetaddr $1, $c11
; ASM-OPT-NEXT:    daddiu $1, $1, -16
; ASM-OPT-NEXT:    csetaddr $c2, $c11, $1
; ASM-OPT-NEXT:    csetbounds $c3, $c2, 16
; ASM-OPT-NEXT:    clcbi $c12, %capcall20(use_alloca)($c1)
; ASM-OPT-NEXT:    cjalr $c12, $c17
; ASM-OPT-NEXT:    cmove $c11, $c2
; ASM-OPT-NEXT:    addiu $2, $2, 1234
; ASM-OPT-NEXT:    cincoffset $c11, $c24, $zero
; ASM-OPT-NEXT:    clc $c17, $zero, 0($c11)
; ASM-OPT-NEXT:    clc $c24, $zero, [[#STACKFRAME_SIZE - CAP_SIZE]]($c11)
; ASM-OPT-NEXT:    cjr $c17
; ASM-OPT-NEXT:    cincoffset $c11, $c11, [[#STACKFRAME_SIZE]]
; ASM-OPT-NEXT:  .LBB2_2: # %entry.while.end_crit_edge
; ASM-OPT-NEXT:    .insn



entry:
  br i1 %arg, label %entry.while.end_crit_edge, label %while.body

entry.while.end_crit_edge:                        ; preds = %entry
  unreachable

while.body:                                       ; preds = %entry
  %0 = alloca [16 x i8], align 16, addrspace(200)
  br label %while.end.loopexit

while.end.loopexit:                               ; preds = %while.body
  %.sub.le = getelementptr inbounds [16 x i8], [16 x i8] addrspace(200)* %0, i64 0, i64 0
  br label %while.end

while.end:                                        ; preds = %while.end.loopexit
  %call = call signext i32 @use_alloca(i8 addrspace(200)* %.sub.le) #1
  %result = add i32 %call, 1234
  ret i32 %result
}

attributes #0 = { "use-soft-float"="false" nounwind }
attributes #1 = { nounwind }
