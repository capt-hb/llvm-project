//===------------- Implementation of the POSIX munmap function ------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "src/sys/mman/munmap.h"
#include "include/sys/syscall.h" // For syscall numbers.
#include "src/__support/common.h"
#include "src/errno/llvmlibc_errno.h"
#include "src/unistd/syscall.h" // For internal syscall function.

namespace __llvm_libc {

// This function is currently linux only. It has to be refactored suitably if
// mmap is to be supported on non-linux operating systems also.
int LLVM_LIBC_ENTRYPOINT(munmap)(void *addr, size_t size) {
  long ret_val =
      __llvm_libc::syscall(SYS_munmap, reinterpret_cast<long>(addr), size);

  // A negative return value indicates an error with the magnitude of the
  // value being the error code.
  if (ret_val < 0) {
    llvmlibc_errno = -ret_val;
    return -1;
  }

  return 0;
}

} // namespace __llvm_libc
