; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: %cheri_purecap_llc -filetype=asm -O0 %s -o - | %cheri_FileCheck %s
; RUN: %cheri_purecap_llc -filetype=obj -O0 %s -o - | llvm-objdump -d - > /dev/null
; We were previously generating a csb with an immediate that was out of range, clobbering other values on the stack!


%"class.Webcore::Settings" = type {}

%"class.Webcore::URL" = type { i8, [300 x i8], i32, i32, i32, i32, i32, i32, i32, i32, i32, i32, [4 x i8] }

declare void @_BAR(%"class.Webcore::Settings" addrspace(200)*, %"class.Webcore::URL" addrspace(200)* dereferenceable(64)) local_unnamed_addr addrspace(200) #0

define hidden void @_ZN19QWebSettingsPrivate5applyEv() local_unnamed_addr addrspace(200) nounwind {
; CHECK-LABEL: _ZN19QWebSettingsPrivate5applyEv:
; CHECK:       # %bb.0:
; CHECK-NEXT:    cincoffset $c11, $c11, -[[#STACKFRAME_SIZE:]]
; CHECK-NEXT:    csc $c17, $zero, [[#STACKFRAME_SIZE - (CAP_SIZE)]]($c11)
; CHECK-NEXT:    lui $1, %pcrel_hi(_CHERI_CAPABILITY_TABLE_-8)
; CHECK-NEXT:    daddiu $1, $1, %pcrel_lo(_CHERI_CAPABILITY_TABLE_-4)
; CHECK-NEXT:    cgetpccincoffset $c1, $1
; CHECK-NEXT:    daddiu $1, $zero, 0
; CHECK-NEXT:    daddiu $2, $zero, {{396|444}}
; CHECK-NEXT:    csb $zero, $2, 0($c11)
; CHECK-NEXT:    csd $1, $zero, {{40|88}}($c11)
; CHECK-NEXT:    csc $c1, $zero, [[#CAP_SIZE * 1]]($c11)
; CHECK-NEXT:    b .LBB0_1
; CHECK-NEXT:    nop
; CHECK-NEXT:  .LBB0_1: # %_FOOOO.exit
; CHECK-NEXT:    cincoffset $c4, $c11, [[#CAP_SIZE * 3]]
; CHECK-NEXT:    csetbounds $c4, $c4, 348
; CHECK-NEXT:    clc $c1, $zero, [[#CAP_SIZE * 1]]($c11)
; CHECK-NEXT:    clcbi $c12, %capcall20(_BAR)($c1)
; CHECK-NEXT:    # implicit-def: $c3
; CHECK-NEXT:    cgetnull $c13
; CHECK-NEXT:    cjalr $c12, $c17
; CHECK-NEXT:    nop
  %ref.tmp38 = alloca i8, align 4, addrspace(200)
  %ref.tmp77 = alloca %"class.Webcore::URL", align 16, addrspace(200)
  store i8 0, i8 addrspace(200)* %ref.tmp38, align 4
  br label %_FOOOO.exit
_FOOOO.exit:       ; preds = %lor.lhs.false.i463, %entry
  call void @_BAR(%"class.Webcore::Settings" addrspace(200)* undef, %"class.Webcore::URL" addrspace(200)* nonnull dereferenceable(64) %ref.tmp77) #13
  unreachable
}
