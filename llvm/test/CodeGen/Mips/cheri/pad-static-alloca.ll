; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: %cheri128_purecap_opt -cheri-bound-allocas -data-layout="E-m:m-pf200:128:128-i8:8:32-i16:16:32-i64:64-n32:64-S128-A200-P200-G200" -S < %s | FileCheck %s --check-prefix OPT128
; RUN: %cheri256_purecap_opt -cheri-bound-allocas -data-layout="E-m:m-pf200:256:256-i8:8:32-i16:16:32-i64:64-n32:64-S256-A200-P200-G200" -S < %s | FileCheck %s --check-prefix OPT256

declare void @keep_live(i8 addrspace(200)*) local_unnamed_addr addrspace(200)

define void @small() local_unnamed_addr addrspace(200) {
; OPT128-LABEL: @small(
; OPT128-NEXT:  entry:
; OPT128-NEXT:    [[TMP0:%.*]] = alloca [10 x i8], align 1, addrspace(200)
; OPT128-NEXT:    [[TMP1:%.*]] = bitcast [10 x i8] addrspace(200)* [[TMP0]] to i8 addrspace(200)*
; OPT128-NEXT:    [[TMP2:%.*]] = call i8 addrspace(200)* @llvm.cheri.bounded.stack.cap.i64(i8 addrspace(200)* [[TMP1]], i64 10)
; OPT128-NEXT:    [[TMP3:%.*]] = bitcast i8 addrspace(200)* [[TMP2]] to [10 x i8] addrspace(200)*
; OPT128-NEXT:    [[PTR:%.*]] = getelementptr inbounds [10 x i8], [10 x i8] addrspace(200)* [[TMP3]], i64 0, i64 0
; OPT128-NEXT:    call void @keep_live(i8 addrspace(200)* nonnull [[PTR]])
; OPT128-NEXT:    ret void
;
; OPT256-LABEL: @small(
; OPT256-NEXT:  entry:
; OPT256-NEXT:    [[TMP0:%.*]] = alloca [10 x i8], align 1, addrspace(200)
; OPT256-NEXT:    [[TMP1:%.*]] = bitcast [10 x i8] addrspace(200)* [[TMP0]] to i8 addrspace(200)*
; OPT256-NEXT:    [[TMP2:%.*]] = call i8 addrspace(200)* @llvm.cheri.bounded.stack.cap.i64(i8 addrspace(200)* [[TMP1]], i64 10)
; OPT256-NEXT:    [[TMP3:%.*]] = bitcast i8 addrspace(200)* [[TMP2]] to [10 x i8] addrspace(200)*
; OPT256-NEXT:    [[PTR:%.*]] = getelementptr inbounds [10 x i8], [10 x i8] addrspace(200)* [[TMP3]], i64 0, i64 0
; OPT256-NEXT:    call void @keep_live(i8 addrspace(200)* nonnull [[PTR]])
; OPT256-NEXT:    ret void
;
entry:
  %0 = alloca [10 x i8], align 1, addrspace(200)
  %ptr = getelementptr inbounds [10 x i8], [10 x i8] addrspace(200)* %0, i64 0, i64 0
  call void @keep_live(i8 addrspace(200)* nonnull %ptr)
  ret void
}

define void @pad_large() local_unnamed_addr addrspace(200) {
; OPT128-LABEL: @pad_large(
; OPT128-NEXT:  entry:
; OPT128-NEXT:    [[TMP0:%.*]] = alloca { [16388 x i8], [28 x i8] }, align 32, addrspace(200)
; OPT128-NEXT:    [[TMP1:%.*]] = bitcast { [16388 x i8], [28 x i8] } addrspace(200)* [[TMP0]] to [16388 x i8] addrspace(200)*
; OPT128-NEXT:    [[TMP2:%.*]] = bitcast { [16388 x i8], [28 x i8] } addrspace(200)* [[TMP0]] to i8 addrspace(200)*
; OPT128-NEXT:    [[TMP3:%.*]] = call i8 addrspace(200)* @llvm.cheri.bounded.stack.cap.i64(i8 addrspace(200)* [[TMP2]], i64 16416)
; OPT128-NEXT:    [[TMP4:%.*]] = bitcast i8 addrspace(200)* [[TMP3]] to [16388 x i8] addrspace(200)*
; OPT128-NEXT:    [[PTR:%.*]] = getelementptr inbounds [16388 x i8], [16388 x i8] addrspace(200)* [[TMP4]], i64 0, i64 0
; OPT128-NEXT:    call void @keep_live(i8 addrspace(200)* nonnull [[PTR]])
; OPT128-NEXT:    ret void
;
; OPT256-LABEL: @pad_large(
; OPT256-NEXT:  entry:
; OPT256-NEXT:    [[TMP0:%.*]] = alloca [16388 x i8], align 1, addrspace(200)
; OPT256-NEXT:    [[TMP1:%.*]] = bitcast [16388 x i8] addrspace(200)* [[TMP0]] to i8 addrspace(200)*
; OPT256-NEXT:    [[TMP2:%.*]] = call i8 addrspace(200)* @llvm.cheri.bounded.stack.cap.i64(i8 addrspace(200)* [[TMP1]], i64 16388)
; OPT256-NEXT:    [[TMP3:%.*]] = bitcast i8 addrspace(200)* [[TMP2]] to [16388 x i8] addrspace(200)*
; OPT256-NEXT:    [[PTR:%.*]] = getelementptr inbounds [16388 x i8], [16388 x i8] addrspace(200)* [[TMP3]], i64 0, i64 0
; OPT256-NEXT:    call void @keep_live(i8 addrspace(200)* nonnull [[PTR]])
; OPT256-NEXT:    ret void
;
entry:
  %0 = alloca [16388 x i8], align 1, addrspace(200)
  %ptr = getelementptr inbounds [16388 x i8], [16388 x i8] addrspace(200)* %0, i64 0, i64 0
  call void @keep_live(i8 addrspace(200)* nonnull %ptr)
  ret void
}

define void @nopad_large() local_unnamed_addr addrspace(200) {
; OPT128-LABEL: @nopad_large(
; OPT128-NEXT:  entry:
; OPT128-NEXT:    [[TMP0:%.*]] = alloca [16388 x i8], align 32, addrspace(200)
; OPT128-NEXT:    [[PTR:%.*]] = getelementptr inbounds [16388 x i8], [16388 x i8] addrspace(200)* [[TMP0]], i64 0, i64 0
; OPT128-NEXT:    store volatile i8 0, i8 addrspace(200)* [[PTR]]
; OPT128-NEXT:    ret void
;
; OPT256-LABEL: @nopad_large(
; OPT256-NEXT:  entry:
; OPT256-NEXT:    [[TMP0:%.*]] = alloca [16388 x i8], align 1, addrspace(200)
; OPT256-NEXT:    [[PTR:%.*]] = getelementptr inbounds [16388 x i8], [16388 x i8] addrspace(200)* [[TMP0]], i64 0, i64 0
; OPT256-NEXT:    store volatile i8 0, i8 addrspace(200)* [[PTR]]
; OPT256-NEXT:    ret void
;
entry:
  %0 = alloca [16388 x i8], align 1, addrspace(200)
  %ptr = getelementptr inbounds [16388 x i8], [16388 x i8] addrspace(200)* %0, i64 0, i64 0
  store volatile i8 0, i8 addrspace(200)* %ptr
  ret void
}
