; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: %cheri_purecap_llc -cheri-cap-table-abi=legacy %s -o - | FileCheck %s

declare signext i32 @nis_passwd(i8 addrspace(200)*, i8 addrspace(200)*, i8 addrspace(200)*) addrspace(0) #1

define i32 (i8 addrspace(200)*, i8 addrspace(200)*, i8 addrspace(200)*) addrspace(200)* @func() #0 {
; CHECK-LABEL: func:
; CHECK:       # %bb.0: # %entry
; CHECK-NEXT:    cgetoffset $25, $c12
; CHECK-NEXT:    lui $1, %hi(%neg(%gp_rel(func)))
; CHECK-NEXT:    daddu $1, $1, $25
; CHECK-NEXT:    daddiu $1, $1, %lo(%neg(%gp_rel(func)))
; CHECK-NEXT:    ld $1, %got_disp(nis_passwd)($1)
; CHECK-NEXT:    cjr $c17
; CHECK-NEXT:    cgetpccsetoffset $c3, $1
entry:
  ret i32 (i8 addrspace(200)*, i8 addrspace(200)*, i8 addrspace(200)*) addrspace(200)* addrspacecast (i32 (i8 addrspace(200)*, i8 addrspace(200)*, i8 addrspace(200)*)* @nis_passwd to i32 (i8 addrspace(200)*, i8 addrspace(200)*, i8 addrspace(200)*) addrspace(200)*)
}
