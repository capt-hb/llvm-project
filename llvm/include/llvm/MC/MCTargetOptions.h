//===- MCTargetOptions.h - MC Target Options --------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_MC_MCTARGETOPTIONS_H
#define LLVM_MC_MCTARGETOPTIONS_H

#include <string>
#include <vector>

namespace llvm {

enum class ExceptionHandling {
  None,     ///< No exception support
  DwarfCFI, ///< DWARF-like instruction based exceptions
  SjLj,     ///< setjmp/longjmp based exceptions
  ARM,      ///< ARM EHABI
  WinEH,    ///< Windows Exception Handling
  Wasm,     ///< WebAssembly Exception Handling
};

enum class DebugCompressionType {
  None, ///< No compression
  GNU,  ///< zlib-gnu style compression
  Z,    ///< zlib style complession
};

enum class CheriCapabilityTableABI {
  Legacy, /// Use legacy ABI instead (load from got and use .size.foo to get the
          /// size)
  PLT, /// Use PLT stubs to set reserved register $cgp (functions assume $cgp is
       /// set correctly)
  Pcrel, /// Derive register $cgp from $pcc (does not need to be set on function
         /// entry)
  FunctionDescriptor /// Use function descriptors to get $cgp (functions assume
                     /// $cgp is set correctly) (TODO: different approaches
                     /// possible here)
};

enum class CheriCapabilityTlsABI {
  Legacy, /// Use legacy ABI instead (thread pointer is normal integer register
          /// and capability is derived from DDC)
  CapEquiv /// Use an equivalent setup to MIPS, but with pointers replaced by
           /// capabilities and using a capability thread pointer register
};

class StringRef;

class MCTargetOptions {
public:
  enum AsmInstrumentation {
    AsmInstrumentationNone,
    AsmInstrumentationAddress
  };

  bool MCRelaxAll : 1;
  bool MCNoExecStack : 1;
  bool MCFatalWarnings : 1;
  bool MCNoWarn : 1;
  bool MCNoDeprecatedWarn : 1;
  bool MCSaveTempLabels : 1;
  bool MCUseDwarfDirectory : 1;
  bool MCIncrementalLinkerCompatible : 1;
  bool ShowMCEncoding : 1;
  bool ShowMCInst : 1;
  bool AsmVerbose : 1;

  /// Preserve Comments in Assembly.
  bool PreserveAsmComments : 1;

  int DwarfVersion = 0;

  std::string ABIName;
  std::string SplitDwarfFile;

  /// Additional paths to search for `.include` directives when using the
  /// integrated assembler.
  std::vector<std::string> IASSearchPaths;

  MCTargetOptions();

  /// getABIName - If this returns a non-empty string this represents the
  /// textual name of the ABI that we want the backend to use, e.g. o32, or
  /// aapcs-linux.
  StringRef getABIName() const;

  // HACK to make the cheri cap table setting visible to clang:
  static bool cheriUsesCapabilityTable();
  static CheriCapabilityTableABI cheriCapabilityTableABI();

  // Ditto for cheri cap tls setting
  static bool cheriUsesCapabilityTls();
  static CheriCapabilityTlsABI cheriCapabilityTlsABI();
};

} // end namespace llvm

#endif // LLVM_MC_MCTARGETOPTIONS_H
