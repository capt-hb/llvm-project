; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=armv7-apple-darwin -mcpu=cortex-a8 | FileCheck %s
; Check if the f32 load / store pair are optimized to i32 load / store.
; rdar://8944252

define void @t(i32 %width, float* nocapture %src, float* nocapture %dst, i32 %index) nounwind {
; CHECK-LABEL: t:
; CHECK:       @ %bb.0: @ %entry
; CHECK-NEXT:    cmp r0, #0
; CHECK-NEXT:    bxeq lr
; CHECK-NEXT:  LBB0_1: @ %bb
; CHECK-NEXT:    @ =>This Inner Loop Header: Depth=1
; CHECK-NEXT:    ldr r9, [r1], r3
; CHECK-NEXT:    subs r0, r0, #1
; CHECK-NEXT:    str r9, [r2], #4
; CHECK-NEXT:    bne LBB0_1
; CHECK-NEXT:  @ %bb.2: @ %return
; CHECK-NEXT:    bx lr
entry:
  %src6 = bitcast float* %src to i8*
  %0 = icmp eq i32 %width, 0
  br i1 %0, label %return, label %bb

bb:
  %j.05 = phi i32 [ %2, %bb ], [ 0, %entry ]
  %tmp = mul i32 %j.05, %index
  %uglygep = getelementptr i8, i8* %src6, i32 %tmp
  %src_addr.04 = bitcast i8* %uglygep to float*
  %dst_addr.03 = getelementptr float, float* %dst, i32 %j.05
  %1 = load float, float* %src_addr.04, align 4
  store float %1, float* %dst_addr.03, align 4
  %2 = add i32 %j.05, 1
  %exitcond = icmp eq i32 %2, %width
  br i1 %exitcond, label %return, label %bb

return:
  ret void
}
