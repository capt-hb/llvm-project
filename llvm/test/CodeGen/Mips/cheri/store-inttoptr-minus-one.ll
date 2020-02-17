; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: %cheri_purecap_llc %s -o - | %cheri_FileCheck %s

@global_minus_1 = local_unnamed_addr addrspace(200) global i8 addrspace(200)* inttoptr (i64 -1 to i8 addrspace(200)*), align 32
@global_minus_10 = local_unnamed_addr addrspace(200) global i8 addrspace(200)* inttoptr (i64 -10 to i8 addrspace(200)*), align 32
@global_123456 = local_unnamed_addr addrspace(200) global i8 addrspace(200)* inttoptr (i64 123456 to i8 addrspace(200)*), align 32
@b = common local_unnamed_addr addrspace(200) global i8 addrspace(200)* null, align 32

; Function Attrs: norecurse nounwind writeonly
define void @c() local_unnamed_addr addrspace(200) #0 {
; CHECK-LABEL: c:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lui $1, %pcrel_hi(_CHERI_CAPABILITY_TABLE_-8)
; CHECK-NEXT:    daddiu $1, $1, %pcrel_lo(_CHERI_CAPABILITY_TABLE_-4)
; CHECK-NEXT:    cgetpccincoffset $c1, $1
; CHECK-NEXT:    clcbi $c1, %captab20(b)($c1)
; CHECK-NEXT:    cincoffset $c2, $cnull, -1
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    csc $c2, $zero, 0($c1)
entry:
  store i8 addrspace(200)* inttoptr (i64 -1 to i8 addrspace(200)*), i8 addrspace(200)* addrspace(200)* @b, align 32
  ret void
}

define void @d() local_unnamed_addr addrspace(200) #0 {
; CHECK-LABEL: d:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lui $1, %pcrel_hi(_CHERI_CAPABILITY_TABLE_-8)
; CHECK-NEXT:    daddiu $1, $1, %pcrel_lo(_CHERI_CAPABILITY_TABLE_-4)
; CHECK-NEXT:    cgetpccincoffset $c1, $1
; CHECK-NEXT:    clcbi $c1, %captab20(b)($c1)
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    csc $cnull, $zero, 0($c1)
entry:
  store i8 addrspace(200)* inttoptr (i64 0 to i8 addrspace(200)*), i8 addrspace(200)* addrspace(200)* @b, align 32
  ret void
}

define void @e() local_unnamed_addr addrspace(200) #0 {
; CHECK-LABEL: e:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lui $1, %pcrel_hi(_CHERI_CAPABILITY_TABLE_-8)
; CHECK-NEXT:    daddiu $1, $1, %pcrel_lo(_CHERI_CAPABILITY_TABLE_-4)
; CHECK-NEXT:    cgetpccincoffset $c1, $1
; CHECK-NEXT:    clcbi $c1, %captab20(b)($c1)
; CHECK-NEXT:    cincoffset $c2, $cnull, 1
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    csc $c2, $zero, 0($c1)
entry:
  store i8 addrspace(200)* inttoptr (i64 1 to i8 addrspace(200)*), i8 addrspace(200)* addrspace(200)* @b, align 32
  ret void
}

define void @f() local_unnamed_addr addrspace(200) #0 {
; CHECK-LABEL: f:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    lui $1, %pcrel_hi(_CHERI_CAPABILITY_TABLE_-8)
; CHECK-NEXT:    daddiu $1, $1, %pcrel_lo(_CHERI_CAPABILITY_TABLE_-4)
; CHECK-NEXT:    cgetpccincoffset $c1, $1
; CHECK-NEXT:    lui $1, 1
; CHECK-NEXT:    clcbi $c1, %captab20(b)($c1)
; CHECK-NEXT:    ori $1, $1, 57920
; CHECK-NEXT:    cincoffset $c2, $cnull, $1
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    csc $c2, $zero, 0($c1)
entry:
  store i8 addrspace(200)* inttoptr (i64 123456 to i8 addrspace(200)*), i8 addrspace(200)* addrspace(200)* @b, align 32
  ret void
}

attributes #0 = { noinline nounwind  }

; CHECK-LABEL: global_minus_1:
; CHECK-NEXT:  .chericap	-1
; CHECK-NEXT:  .size	global_minus_1, [[#CAP_SIZE]]
; CHECK-LABEL: global_minus_10:
; CHECK-NEXT:  .chericap	-10
; CHECK-NEXT:  .size	global_minus_10, [[#CAP_SIZE]]
; CHECK-LABEL: global_123456:
; CHECK-NEXT:  .chericap	123456
; CHECK-NEXT:  .size	global_123456, [[#CAP_SIZE]]
