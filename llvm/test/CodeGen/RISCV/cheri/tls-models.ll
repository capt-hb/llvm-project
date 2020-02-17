; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: %riscv32_cheri_purecap_llc -relocation-model=pic < %s \
; RUN:     | FileCheck -check-prefix=IL32PC64-PIC %s
; RUN: %riscv64_cheri_purecap_llc -relocation-model=pic < %s \
; RUN:     | FileCheck -check-prefix=L64PC128-PIC %s
; RUN: %riscv32_cheri_purecap_llc < %s \
; RUN:     | FileCheck -check-prefix=IL32PC64-NOPIC %s
; RUN: %riscv64_cheri_purecap_llc < %s \
; RUN:     | FileCheck -check-prefix=L64PC128-NOPIC %s

; Check that TLS symbols are lowered correctly based on the specified
; model. Make sure they're external to avoid them all being optimised to Local
; Exec for the executable.

@unspecified = external thread_local addrspace(200) global i32
@ld = external thread_local(localdynamic) addrspace(200) global i32
@ie = external thread_local(initialexec) addrspace(200) global i32
@le = external thread_local(localexec) addrspace(200) global i32


; No model specified

define i32 addrspace(200)* @f1() nounwind {
; IL32PC64-PIC-LABEL: f1:
; IL32PC64-PIC:       # %bb.0: # %entry
; IL32PC64-PIC-NEXT:    cincoffset csp, csp, -16
; IL32PC64-PIC-NEXT:    csc cra, 8(csp)
; IL32PC64-PIC-NEXT:  .LBB0_1: # %entry
; IL32PC64-PIC-NEXT:    # Label of block must be emitted
; IL32PC64-PIC-NEXT:    auipcc ca0, %tls_gd_captab_pcrel_hi(unspecified)
; IL32PC64-PIC-NEXT:    cincoffset ca0, ca0, %pcrel_lo(.LBB0_1)
; IL32PC64-PIC-NEXT:  .LBB0_2: # %entry
; IL32PC64-PIC-NEXT:    # Label of block must be emitted
; IL32PC64-PIC-NEXT:    auipcc ca1, %captab_pcrel_hi(__tls_get_addr)
; IL32PC64-PIC-NEXT:    clc ca1, %pcrel_lo(.LBB0_2)(ca1)
; IL32PC64-PIC-NEXT:    cjalr ca1
; IL32PC64-PIC-NEXT:    clc cra, 8(csp)
; IL32PC64-PIC-NEXT:    cincoffset csp, csp, 16
; IL32PC64-PIC-NEXT:    cret
;
; L64PC128-PIC-LABEL: f1:
; L64PC128-PIC:       # %bb.0: # %entry
; L64PC128-PIC-NEXT:    cincoffset csp, csp, -16
; L64PC128-PIC-NEXT:    csc cra, 0(csp)
; L64PC128-PIC-NEXT:  .LBB0_1: # %entry
; L64PC128-PIC-NEXT:    # Label of block must be emitted
; L64PC128-PIC-NEXT:    auipcc ca0, %tls_gd_captab_pcrel_hi(unspecified)
; L64PC128-PIC-NEXT:    cincoffset ca0, ca0, %pcrel_lo(.LBB0_1)
; L64PC128-PIC-NEXT:  .LBB0_2: # %entry
; L64PC128-PIC-NEXT:    # Label of block must be emitted
; L64PC128-PIC-NEXT:    auipcc ca1, %captab_pcrel_hi(__tls_get_addr)
; L64PC128-PIC-NEXT:    clc ca1, %pcrel_lo(.LBB0_2)(ca1)
; L64PC128-PIC-NEXT:    cjalr ca1
; L64PC128-PIC-NEXT:    clc cra, 0(csp)
; L64PC128-PIC-NEXT:    cincoffset csp, csp, 16
; L64PC128-PIC-NEXT:    cret
;
; IL32PC64-NOPIC-LABEL: f1:
; IL32PC64-NOPIC:       # %bb.0: # %entry
; IL32PC64-NOPIC-NEXT:  .LBB0_1: # %entry
; IL32PC64-NOPIC-NEXT:    # Label of block must be emitted
; IL32PC64-NOPIC-NEXT:    auipcc ca1, %tls_ie_captab_pcrel_hi(unspecified)
; IL32PC64-NOPIC-NEXT:    clw a0, %pcrel_lo(.LBB0_1)(ca1)
; IL32PC64-NOPIC-NEXT:    cincoffset ca0, ctp, a0
; IL32PC64-NOPIC-NEXT:    cret
;
; L64PC128-NOPIC-LABEL: f1:
; L64PC128-NOPIC:       # %bb.0: # %entry
; L64PC128-NOPIC-NEXT:  .LBB0_1: # %entry
; L64PC128-NOPIC-NEXT:    # Label of block must be emitted
; L64PC128-NOPIC-NEXT:    auipcc ca1, %tls_ie_captab_pcrel_hi(unspecified)
; L64PC128-NOPIC-NEXT:    cld a0, %pcrel_lo(.LBB0_1)(ca1)
; L64PC128-NOPIC-NEXT:    cincoffset ca0, ctp, a0
; L64PC128-NOPIC-NEXT:    cret
entry:
  ret i32 addrspace(200)* @unspecified
}


; localdynamic specified

define i32 addrspace(200)* @f2() nounwind {
; IL32PC64-PIC-LABEL: f2:
; IL32PC64-PIC:       # %bb.0: # %entry
; IL32PC64-PIC-NEXT:    cincoffset csp, csp, -16
; IL32PC64-PIC-NEXT:    csc cra, 8(csp)
; IL32PC64-PIC-NEXT:  .LBB1_1: # %entry
; IL32PC64-PIC-NEXT:    # Label of block must be emitted
; IL32PC64-PIC-NEXT:    auipcc ca0, %tls_gd_captab_pcrel_hi(ld)
; IL32PC64-PIC-NEXT:    cincoffset ca0, ca0, %pcrel_lo(.LBB1_1)
; IL32PC64-PIC-NEXT:  .LBB1_2: # %entry
; IL32PC64-PIC-NEXT:    # Label of block must be emitted
; IL32PC64-PIC-NEXT:    auipcc ca1, %captab_pcrel_hi(__tls_get_addr)
; IL32PC64-PIC-NEXT:    clc ca1, %pcrel_lo(.LBB1_2)(ca1)
; IL32PC64-PIC-NEXT:    cjalr ca1
; IL32PC64-PIC-NEXT:    clc cra, 8(csp)
; IL32PC64-PIC-NEXT:    cincoffset csp, csp, 16
; IL32PC64-PIC-NEXT:    cret
;
; L64PC128-PIC-LABEL: f2:
; L64PC128-PIC:       # %bb.0: # %entry
; L64PC128-PIC-NEXT:    cincoffset csp, csp, -16
; L64PC128-PIC-NEXT:    csc cra, 0(csp)
; L64PC128-PIC-NEXT:  .LBB1_1: # %entry
; L64PC128-PIC-NEXT:    # Label of block must be emitted
; L64PC128-PIC-NEXT:    auipcc ca0, %tls_gd_captab_pcrel_hi(ld)
; L64PC128-PIC-NEXT:    cincoffset ca0, ca0, %pcrel_lo(.LBB1_1)
; L64PC128-PIC-NEXT:  .LBB1_2: # %entry
; L64PC128-PIC-NEXT:    # Label of block must be emitted
; L64PC128-PIC-NEXT:    auipcc ca1, %captab_pcrel_hi(__tls_get_addr)
; L64PC128-PIC-NEXT:    clc ca1, %pcrel_lo(.LBB1_2)(ca1)
; L64PC128-PIC-NEXT:    cjalr ca1
; L64PC128-PIC-NEXT:    clc cra, 0(csp)
; L64PC128-PIC-NEXT:    cincoffset csp, csp, 16
; L64PC128-PIC-NEXT:    cret
;
; IL32PC64-NOPIC-LABEL: f2:
; IL32PC64-NOPIC:       # %bb.0: # %entry
; IL32PC64-NOPIC-NEXT:  .LBB1_1: # %entry
; IL32PC64-NOPIC-NEXT:    # Label of block must be emitted
; IL32PC64-NOPIC-NEXT:    auipcc ca1, %tls_ie_captab_pcrel_hi(ld)
; IL32PC64-NOPIC-NEXT:    clw a0, %pcrel_lo(.LBB1_1)(ca1)
; IL32PC64-NOPIC-NEXT:    cincoffset ca0, ctp, a0
; IL32PC64-NOPIC-NEXT:    cret
;
; L64PC128-NOPIC-LABEL: f2:
; L64PC128-NOPIC:       # %bb.0: # %entry
; L64PC128-NOPIC-NEXT:  .LBB1_1: # %entry
; L64PC128-NOPIC-NEXT:    # Label of block must be emitted
; L64PC128-NOPIC-NEXT:    auipcc ca1, %tls_ie_captab_pcrel_hi(ld)
; L64PC128-NOPIC-NEXT:    cld a0, %pcrel_lo(.LBB1_1)(ca1)
; L64PC128-NOPIC-NEXT:    cincoffset ca0, ctp, a0
; L64PC128-NOPIC-NEXT:    cret
entry:
  ret i32 addrspace(200)* @ld
}


; initialexec specified

define i32 addrspace(200)* @f3() nounwind {
; IL32PC64-PIC-LABEL: f3:
; IL32PC64-PIC:       # %bb.0: # %entry
; IL32PC64-PIC-NEXT:  .LBB2_1: # %entry
; IL32PC64-PIC-NEXT:    # Label of block must be emitted
; IL32PC64-PIC-NEXT:    auipcc ca1, %tls_ie_captab_pcrel_hi(ie)
; IL32PC64-PIC-NEXT:    clw a0, %pcrel_lo(.LBB2_1)(ca1)
; IL32PC64-PIC-NEXT:    cincoffset ca0, ctp, a0
; IL32PC64-PIC-NEXT:    cret
;
; L64PC128-PIC-LABEL: f3:
; L64PC128-PIC:       # %bb.0: # %entry
; L64PC128-PIC-NEXT:  .LBB2_1: # %entry
; L64PC128-PIC-NEXT:    # Label of block must be emitted
; L64PC128-PIC-NEXT:    auipcc ca1, %tls_ie_captab_pcrel_hi(ie)
; L64PC128-PIC-NEXT:    cld a0, %pcrel_lo(.LBB2_1)(ca1)
; L64PC128-PIC-NEXT:    cincoffset ca0, ctp, a0
; L64PC128-PIC-NEXT:    cret
;
; IL32PC64-NOPIC-LABEL: f3:
; IL32PC64-NOPIC:       # %bb.0: # %entry
; IL32PC64-NOPIC-NEXT:  .LBB2_1: # %entry
; IL32PC64-NOPIC-NEXT:    # Label of block must be emitted
; IL32PC64-NOPIC-NEXT:    auipcc ca1, %tls_ie_captab_pcrel_hi(ie)
; IL32PC64-NOPIC-NEXT:    clw a0, %pcrel_lo(.LBB2_1)(ca1)
; IL32PC64-NOPIC-NEXT:    cincoffset ca0, ctp, a0
; IL32PC64-NOPIC-NEXT:    cret
;
; L64PC128-NOPIC-LABEL: f3:
; L64PC128-NOPIC:       # %bb.0: # %entry
; L64PC128-NOPIC-NEXT:  .LBB2_1: # %entry
; L64PC128-NOPIC-NEXT:    # Label of block must be emitted
; L64PC128-NOPIC-NEXT:    auipcc ca1, %tls_ie_captab_pcrel_hi(ie)
; L64PC128-NOPIC-NEXT:    cld a0, %pcrel_lo(.LBB2_1)(ca1)
; L64PC128-NOPIC-NEXT:    cincoffset ca0, ctp, a0
; L64PC128-NOPIC-NEXT:    cret
entry:
  ret i32 addrspace(200)* @ie
}


; localexec specified

define i32 addrspace(200)* @f4() nounwind {
; IL32PC64-PIC-LABEL: f4:
; IL32PC64-PIC:       # %bb.0: # %entry
; IL32PC64-PIC-NEXT:    lui a0, %tprel_hi(le)
; IL32PC64-PIC-NEXT:    cincoffset ca0, ctp, a0, %tprel_cincoffset(le)
; IL32PC64-PIC-NEXT:    cincoffset ca0, ca0, %tprel_lo(le)
; IL32PC64-PIC-NEXT:    cret
;
; L64PC128-PIC-LABEL: f4:
; L64PC128-PIC:       # %bb.0: # %entry
; L64PC128-PIC-NEXT:    lui a0, %tprel_hi(le)
; L64PC128-PIC-NEXT:    cincoffset ca0, ctp, a0, %tprel_cincoffset(le)
; L64PC128-PIC-NEXT:    cincoffset ca0, ca0, %tprel_lo(le)
; L64PC128-PIC-NEXT:    cret
;
; IL32PC64-NOPIC-LABEL: f4:
; IL32PC64-NOPIC:       # %bb.0: # %entry
; IL32PC64-NOPIC-NEXT:    lui a0, %tprel_hi(le)
; IL32PC64-NOPIC-NEXT:    cincoffset ca0, ctp, a0, %tprel_cincoffset(le)
; IL32PC64-NOPIC-NEXT:    cincoffset ca0, ca0, %tprel_lo(le)
; IL32PC64-NOPIC-NEXT:    cret
;
; L64PC128-NOPIC-LABEL: f4:
; L64PC128-NOPIC:       # %bb.0: # %entry
; L64PC128-NOPIC-NEXT:    lui a0, %tprel_hi(le)
; L64PC128-NOPIC-NEXT:    cincoffset ca0, ctp, a0, %tprel_cincoffset(le)
; L64PC128-NOPIC-NEXT:    cincoffset ca0, ca0, %tprel_lo(le)
; L64PC128-NOPIC-NEXT:    cret
entry:
  ret i32 addrspace(200)* @le
}
