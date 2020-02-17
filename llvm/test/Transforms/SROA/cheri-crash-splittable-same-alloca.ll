; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; This test case previously triggered assertions in SROA ("Splittable transfers cannot reach the same alloca on both ends.")
; RUN: %cheri_purecap_opt -S -inline -sroa -early-cse-memssa %s -o - | FileCheck %s
source_filename = "/Users/alex/cheri/llvm-project/libcxx/test/std/containers/sequences/deque/deque.cons/iter_iter.pass.cpp"
target datalayout = "E-m:e-pf200:128:128:128:64-i8:8:32-i16:16:32-i64:64-n32:64-S128-A200-P200-G200"
target triple = "mips64c128-unknown-freebsd13-purecap"

%struct.a = type { %struct.b, %struct.b }
%struct.b = type { i32 addrspace(200)* }
declare i32 @baz(...) addrspace(200)
define void @d() addrspace(200) personality i8 addrspace(200)* bitcast (i32 (...) addrspace(200)* @baz to i8 addrspace(200)*) {
; CHECK-LABEL: define {{[^@]+}}@d() addrspace(200) #0 personality i8 addrspace(200)* bitcast (i32 (...) addrspace(200)* @baz to i8 addrspace(200)*)
; CHECK-NEXT:    [[L:%.*]] = alloca [[STRUCT_A:%.*]], addrspace(200)
; CHECK-NEXT:    [[L_0_L_I_SROA_CAST:%.*]] = bitcast [[STRUCT_A]] addrspace(200)* [[L]] to i8 addrspace(200)*
; CHECK-NEXT:    [[L_16_K_I_SROA_IDX:%.*]] = getelementptr inbounds [[STRUCT_A]], [[STRUCT_A]] addrspace(200)* [[L]], i64 0, i32 1
; CHECK-NEXT:    [[L_16_K_I_SROA_CAST:%.*]] = bitcast [[STRUCT_B:%.*]] addrspace(200)* [[L_16_K_I_SROA_IDX]] to i8 addrspace(200)*
; CHECK-NEXT:    call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)* align 16 [[L_0_L_I_SROA_CAST]], i8 addrspace(200)* align 16 [[L_16_K_I_SROA_CAST]], i64 32, i1 false)
; CHECK-NEXT:    unreachable
;
  %l = alloca %struct.a, addrspace(200)
  call void @e(%struct.a addrspace(200)* %l)
  unreachable
}
define void @e(%struct.a addrspace(200)* %arg) addrspace(200) {
; CHECK-LABEL: define {{[^@]+}}@e
; CHECK-SAME: (%struct.a addrspace(200)* [[ARG:%.*]]) addrspace(200) #0
; CHECK-NEXT:    [[H:%.*]] = getelementptr [[STRUCT_A:%.*]], [[STRUCT_A]] addrspace(200)* [[ARG]], i32 0, i32 0
; CHECK-NEXT:    [[I:%.*]] = getelementptr inbounds [[STRUCT_A]], [[STRUCT_A]] addrspace(200)* [[ARG]], i32 0, i32 1
; CHECK-NEXT:    [[L:%.*]] = bitcast [[STRUCT_B:%.*]] addrspace(200)* [[H]] to i8 addrspace(200)*
; CHECK-NEXT:    [[K:%.*]] = bitcast [[STRUCT_B]] addrspace(200)* [[I]] to i8 addrspace(200)*
; CHECK-NEXT:    call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)* [[L]], i8 addrspace(200)* [[K]], i64 32, i1 false)
; CHECK-NEXT:    ret void
;
  %f = alloca %struct.a addrspace(200)*, addrspace(200)
  store %struct.a addrspace(200)* %arg, %struct.a addrspace(200)* addrspace(200)* %f
  %g = load %struct.a addrspace(200)*, %struct.a addrspace(200)* addrspace(200)* %f
  %h = getelementptr %struct.a, %struct.a addrspace(200)* %g, i32 0, i32 0
  %1 = getelementptr %struct.b, %struct.b addrspace(200)* %h
  %i = getelementptr inbounds %struct.a, %struct.a addrspace(200)* %g, i32 0, i32 1
  %j = getelementptr %struct.a, %struct.a addrspace(200)* %g, i32 0, i32 0
  %l = bitcast %struct.b addrspace(200)* %j to i8 addrspace(200)*
  %k = bitcast %struct.b addrspace(200)* %i to i8 addrspace(200)*
  call void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)* %l, i8 addrspace(200)* %k, i64 32, i1 false)
  ret void
}
; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p200i8.p200i8.i64(i8 addrspace(200)* noalias nocapture writeonly, i8 addrspace(200)* noalias nocapture readonly, i64, i1 immarg) addrspace(200) #0

attributes #0 = { argmemonly nounwind willreturn }
