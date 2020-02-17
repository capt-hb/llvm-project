; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: %cheri_llc -frame-pointer=all %s -relocation-model=pic -o - | FileCheck %s
; ModuleID = 'call.c'
target datalayout = "E-pf200:256:256:256-p:64:64:64-i1:8:8-i8:8:32-i16:16:32-i32:32:32-i64:64:64-f32:32:32-f64:64:64-n32:64-S256"
target triple = "cheri-unknown-freebsd"

; Function Attrs: nounwind
define void @a(i8 addrspace(200)* %a1, i8 addrspace(200)* %a2, i64 %foo, i64 %bar) #0 {
; CHECK-LABEL: a:
; CHECK:       # %bb.0:
; CHECK-NEXT:    daddiu $sp, $sp, -32
; CHECK-NEXT:    sd $ra, 24($sp) # 8-byte Folded Spill
; CHECK-NEXT:    sd $fp, 16($sp) # 8-byte Folded Spill
; CHECK-NEXT:    sd $gp, 8($sp) # 8-byte Folded Spill
; CHECK-NEXT:    move $fp, $sp
; CHECK-NEXT:    move $1, $5
  ; Move the argument registers into the ccall registers
; CHECK-NEXT:    cmove $c2, $c4
; CHECK-NEXT:    cmove $c1, $c3
; CHECK-NEXT:    lui $2, %hi(%neg(%gp_rel(a)))
; CHECK-NEXT:    daddu $2, $2, $25
; CHECK-NEXT:    daddiu $gp, $2, %lo(%neg(%gp_rel(a)))
; CHECK-NEXT:    ld $25, %call16(b)($gp)
; Clear integer registers
; CHECK-NEXT:    daddiu $5, $zero, 0
; CHECK-NEXT:    daddiu $6, $zero, 0
; CHECK-NEXT:    daddiu $7, $zero, 0
; CHECK-NEXT:    daddiu $8, $zero, 0
; CHECK-NEXT:    daddiu $9, $zero, 0
; CHECK-NEXT:    daddiu $10, $zero, 0
; CHECK-NEXT:    daddiu $11, $zero, 0
; Move argument 0 from a0 to v0, arg 1 from a1 to a0.
; Then do the function call
; CHECK-NEXT:    move $2, $4
; CHECK-NEXT:    move $4, $1
; Clear cap registers
; CHECK-NEXT:    cgetnull $c3
; CHECK-NEXT:    cgetnull $c4
; CHECK-NEXT:    cgetnull $c5
; CHECK-NEXT:    cgetnull $c6
; CHECK-NEXT:    cgetnull $c7
; CHECK-NEXT:    cgetnull $c8
; CHECK-NEXT:    cgetnull $c9
; CHECK-NEXT:    .reloc .Ltmp0, R_MIPS_JALR, b
; CHECK-NEXT:  .Ltmp0:
; CHECK-NEXT:    jalr $25
; CHECK-NEXT:    cgetnull $c10
; CHECK-NEXT:    move $sp, $fp
; CHECK-NEXT:    ld $gp, 8($sp) # 8-byte Folded Reload
; CHECK-NEXT:    ld $fp, 16($sp) # 8-byte Folded Reload
; CHECK-NEXT:    ld $ra, 24($sp) # 8-byte Folded Reload
; CHECK-NEXT:    jr $ra
; CHECK-NEXT:    daddiu $sp, $sp, 32
  tail call chericcallcc void @b(i8 addrspace(200)* %a1, i8 addrspace(200)* %a2, i64 %foo, i64 %bar) #2
  ret void
}

declare chericcallcc void @b(i8 addrspace(200)*, i8 addrspace(200)*, i64, i64) #1

attributes #0 = { nounwind "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind }

!llvm.ident = !{!0}

!0 = !{!"clang version 3.4 "}
