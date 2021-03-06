//===-- ObjectFileWasm.cpp ------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "ObjectFileWasm.h"
#include "lldb/Core/Module.h"
#include "lldb/Core/ModuleSpec.h"
#include "lldb/Core/PluginManager.h"
#include "lldb/Core/Section.h"
#include "lldb/Target/Process.h"
#include "lldb/Target/SectionLoadList.h"
#include "lldb/Target/Target.h"
#include "lldb/Utility/DataBufferHeap.h"
#include "lldb/Utility/Log.h"
#include "llvm/ADT/ArrayRef.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/BinaryFormat/Magic.h"
#include "llvm/BinaryFormat/Wasm.h"
#include "llvm/Support/Endian.h"
#include "llvm/Support/Format.h"

using namespace lldb;
using namespace lldb_private;
using namespace lldb_private::wasm;

static const uint32_t kWasmHeaderSize =
    sizeof(llvm::wasm::WasmMagic) + sizeof(llvm::wasm::WasmVersion);

/// Checks whether the data buffer starts with a valid Wasm module header.
static bool ValidateModuleHeader(const DataBufferSP &data_sp) {
  if (!data_sp || data_sp->GetByteSize() < kWasmHeaderSize)
    return false;

  if (llvm::identify_magic(toStringRef(data_sp->GetData())) !=
      llvm::file_magic::wasm_object)
    return false;

  uint8_t *Ptr = data_sp->GetBytes() + sizeof(llvm::wasm::WasmMagic);

  uint32_t version = llvm::support::endian::read32le(Ptr);
  return version == llvm::wasm::WasmVersion;
}

static llvm::Optional<ConstString>
GetWasmString(llvm::DataExtractor &data, llvm::DataExtractor::Cursor &c) {
  // A Wasm string is encoded as a vector of UTF-8 codes.
  // Vectors are encoded with their u32 length followed by the element
  // sequence.
  uint64_t len = data.getULEB128(c);
  if (!c) {
    consumeError(c.takeError());
    return llvm::None;
  }

  if (len >= (uint64_t(1) << 32)) {
    return llvm::None;
  }

  llvm::SmallVector<uint8_t, 32> str_storage;
  data.getU8(c, str_storage, len);
  if (!c) {
    consumeError(c.takeError());
    return llvm::None;
  }

  llvm::StringRef str = toStringRef(makeArrayRef(str_storage));
  return ConstString(str);
}

char ObjectFileWasm::ID;

void ObjectFileWasm::Initialize() {
  PluginManager::RegisterPlugin(GetPluginNameStatic(),
                                GetPluginDescriptionStatic(), CreateInstance,
                                CreateMemoryInstance, GetModuleSpecifications);
}

void ObjectFileWasm::Terminate() {
  PluginManager::UnregisterPlugin(CreateInstance);
}

ConstString ObjectFileWasm::GetPluginNameStatic() {
  static ConstString g_name("wasm");
  return g_name;
}

ObjectFile *
ObjectFileWasm::CreateInstance(const ModuleSP &module_sp, DataBufferSP &data_sp,
                               offset_t data_offset, const FileSpec *file,
                               offset_t file_offset, offset_t length) {
  Log *log(GetLogIfAllCategoriesSet(LIBLLDB_LOG_OBJECT));

  if (!data_sp) {
    data_sp = MapFileData(*file, length, file_offset);
    if (!data_sp) {
      LLDB_LOGF(log, "Failed to create ObjectFileWasm instance for file %s",
                file->GetPath().c_str());
      return nullptr;
    }
    data_offset = 0;
  }

  assert(data_sp);
  if (!ValidateModuleHeader(data_sp)) {
    LLDB_LOGF(log,
              "Failed to create ObjectFileWasm instance: invalid Wasm header");
    return nullptr;
  }

  // Update the data to contain the entire file if it doesn't contain it
  // already.
  if (data_sp->GetByteSize() < length) {
    data_sp = MapFileData(*file, length, file_offset);
    if (!data_sp) {
      LLDB_LOGF(log,
                "Failed to create ObjectFileWasm instance: cannot read file %s",
                file->GetPath().c_str());
      return nullptr;
    }
    data_offset = 0;
  }

  std::unique_ptr<ObjectFileWasm> objfile_up(new ObjectFileWasm(
      module_sp, data_sp, data_offset, file, file_offset, length));
  ArchSpec spec = objfile_up->GetArchitecture();
  if (spec && objfile_up->SetModulesArchitecture(spec)) {
    LLDB_LOGF(log,
              "%p ObjectFileWasm::CreateInstance() module = %p (%s), file = %s",
              static_cast<void *>(objfile_up.get()),
              static_cast<void *>(objfile_up->GetModule().get()),
              objfile_up->GetModule()->GetSpecificationDescription().c_str(),
              file ? file->GetPath().c_str() : "<NULL>");
    return objfile_up.release();
  }

  LLDB_LOGF(log, "Failed to create ObjectFileWasm instance");
  return nullptr;
}

ObjectFile *ObjectFileWasm::CreateMemoryInstance(const ModuleSP &module_sp,
                                                 DataBufferSP &data_sp,
                                                 const ProcessSP &process_sp,
                                                 addr_t header_addr) {
  if (!ValidateModuleHeader(data_sp))
    return nullptr;

  std::unique_ptr<ObjectFileWasm> objfile_up(
      new ObjectFileWasm(module_sp, data_sp, process_sp, header_addr));
  ArchSpec spec = objfile_up->GetArchitecture();
  if (spec && objfile_up->SetModulesArchitecture(spec))
    return objfile_up.release();
  return nullptr;
}

bool ObjectFileWasm::DecodeNextSection(lldb::offset_t *offset_ptr) {
  // Buffer sufficient to read a section header and find the pointer to the next
  // section.
  const uint32_t kBufferSize = 1024;
  DataExtractor section_header_data = ReadImageData(*offset_ptr, kBufferSize);

  llvm::DataExtractor data = section_header_data.GetAsLLVM();
  llvm::DataExtractor::Cursor c(0);

  // Each section consists of:
  // - a one-byte section id,
  // - the u32 size of the contents, in bytes,
  // - the actual contents.
  uint8_t section_id = data.getU8(c);
  uint64_t payload_len = data.getULEB128(c);
  if (!c)
    return !llvm::errorToBool(c.takeError());

  if (payload_len >= (uint64_t(1) << 32))
    return false;

  if (section_id == llvm::wasm::WASM_SEC_CUSTOM) {
    // Custom sections have the id 0. Their contents consist of a name
    // identifying the custom section, followed by an uninterpreted sequence
    // of bytes.
    lldb::offset_t prev_offset = c.tell();
    llvm::Optional<ConstString> sect_name = GetWasmString(data, c);
    if (!sect_name)
      return false;

    if (payload_len < c.tell() - prev_offset)
      return false;

    uint32_t section_length = payload_len - (c.tell() - prev_offset);
    m_sect_infos.push_back(section_info{*offset_ptr + c.tell(), section_length,
                                        section_id, *sect_name});
    *offset_ptr += (c.tell() + section_length);
  } else if (section_id <= llvm::wasm::WASM_SEC_EVENT) {
    m_sect_infos.push_back(section_info{*offset_ptr + c.tell(),
                                        static_cast<uint32_t>(payload_len),
                                        section_id, ConstString()});
    *offset_ptr += (c.tell() + payload_len);
  } else {
    // Invalid section id.
    return false;
  }
  return true;
}

bool ObjectFileWasm::DecodeSections() {
  lldb::offset_t offset = kWasmHeaderSize;
  if (IsInMemory()) {
    offset += m_memory_addr;
  }

  while (DecodeNextSection(&offset))
    ;
  return true;
}

size_t ObjectFileWasm::GetModuleSpecifications(
    const FileSpec &file, DataBufferSP &data_sp, offset_t data_offset,
    offset_t file_offset, offset_t length, ModuleSpecList &specs) {
  if (!ValidateModuleHeader(data_sp)) {
    return 0;
  }

  ModuleSpec spec(file, ArchSpec("wasm32-unknown-unknown-wasm"));
  specs.Append(spec);
  return 1;
}

ObjectFileWasm::ObjectFileWasm(const ModuleSP &module_sp, DataBufferSP &data_sp,
                               offset_t data_offset, const FileSpec *file,
                               offset_t offset, offset_t length)
    : ObjectFile(module_sp, file, offset, length, data_sp, data_offset),
      m_arch("wasm32-unknown-unknown-wasm"), m_code_section_offset(0) {
  m_data.SetAddressByteSize(4);
}

ObjectFileWasm::ObjectFileWasm(const lldb::ModuleSP &module_sp,
                               lldb::DataBufferSP &header_data_sp,
                               const lldb::ProcessSP &process_sp,
                               lldb::addr_t header_addr)
    : ObjectFile(module_sp, process_sp, header_addr, header_data_sp),
      m_arch("wasm32-unknown-unknown-wasm"), m_code_section_offset(0) {}

bool ObjectFileWasm::ParseHeader() {
  // We already parsed the header during initialization.
  return true;
}

Symtab *ObjectFileWasm::GetSymtab() { return nullptr; }

void ObjectFileWasm::CreateSections(SectionList &unified_section_list) {
  if (m_sections_up)
    return;

  m_sections_up = std::make_unique<SectionList>();

  if (m_sect_infos.empty()) {
    DecodeSections();
  }

  for (const section_info &sect_info : m_sect_infos) {
    SectionType section_type = eSectionTypeOther;
    ConstString section_name;
    offset_t file_offset = 0;
    addr_t vm_addr = 0;
    size_t vm_size = 0;

    if (llvm::wasm::WASM_SEC_CODE == sect_info.id) {
      section_type = eSectionTypeCode;
      section_name = ConstString("code");
      m_code_section_offset = sect_info.offset & 0xffffffff;
      vm_size = sect_info.size;
    } else {
      section_type =
          llvm::StringSwitch<SectionType>(sect_info.name.GetStringRef())
              .Case(".debug_abbrev", eSectionTypeDWARFDebugAbbrev)
              .Case(".debug_addr", eSectionTypeDWARFDebugAddr)
              .Case(".debug_aranges", eSectionTypeDWARFDebugAranges)
              .Case(".debug_cu_index", eSectionTypeDWARFDebugCuIndex)
              .Case(".debug_frame", eSectionTypeDWARFDebugFrame)
              .Case(".debug_info", eSectionTypeDWARFDebugInfo)
              .Case(".debug_line", eSectionTypeDWARFDebugLine)
              .Case(".debug_line_str", eSectionTypeDWARFDebugLineStr)
              .Case(".debug_loc", eSectionTypeDWARFDebugLoc)
              .Case(".debug_loclists", eSectionTypeDWARFDebugLocLists)
              .Case(".debug_macinfo", eSectionTypeDWARFDebugMacInfo)
              .Case(".debug_macro", eSectionTypeDWARFDebugMacro)
              .Case(".debug_names", eSectionTypeDWARFDebugNames)
              .Case(".debug_pubnames", eSectionTypeDWARFDebugPubNames)
              .Case(".debug_pubtypes", eSectionTypeDWARFDebugPubTypes)
              .Case(".debug_ranges", eSectionTypeDWARFDebugRanges)
              .Case(".debug_rnglists", eSectionTypeDWARFDebugRngLists)
              .Case(".debug_str", eSectionTypeDWARFDebugStr)
              .Case(".debug_str_offsets", eSectionTypeDWARFDebugStrOffsets)
              .Case(".debug_types", eSectionTypeDWARFDebugTypes)
              .Default(eSectionTypeOther);
      if (section_type == eSectionTypeOther)
        continue;
      section_name = sect_info.name;
      file_offset = sect_info.offset & 0xffffffff;
      if (IsInMemory()) {
        vm_addr = sect_info.offset & 0xffffffff;
        vm_size = sect_info.size;
      }
    }

    SectionSP section_sp(
        new Section(GetModule(), // Module to which this section belongs.
                    this,        // ObjectFile to which this section belongs and
                                 // should read section data from.
                    section_type,   // Section ID.
                    section_name,   // Section name.
                    section_type,   // Section type.
                    vm_addr,        // VM address.
                    vm_size,        // VM size in bytes of this section.
                    file_offset,    // Offset of this section in the file.
                    sect_info.size, // Size of the section as found in the file.
                    0,              // Alignment of the section
                    0,              // Flags for this section.
                    1));            // Number of host bytes per target byte
    m_sections_up->AddSection(section_sp);
    unified_section_list.AddSection(section_sp);
  }
}

bool ObjectFileWasm::SetLoadAddress(Target &target, lldb::addr_t load_address,
                                    bool value_is_offset) {
  /// In WebAssembly, linear memory is disjointed from code space. The VM can
  /// load multiple instances of a module, which logically share the same code.
  /// We represent a wasm32 code address with 64-bits, like:
  /// 63            32 31             0
  /// +---------------+---------------+
  /// +   module_id   |     offset    |
  /// +---------------+---------------+
  /// where the lower 32 bits represent a module offset (relative to the module
  /// start not to the beginning of the code section) and the higher 32 bits
  /// uniquely identify the module in the WebAssembly VM.
  /// In other words, we assume that each WebAssembly module is loaded by the
  /// engine at a 64-bit address that starts at the boundary of 4GB pages, like
  /// 0x0000000400000000 for module_id == 4.
  /// These 64-bit addresses will be used to request code ranges for a specific
  /// module from the WebAssembly engine.
  ModuleSP module_sp = GetModule();
  if (!module_sp)
    return false;

  DecodeSections();

  size_t num_loaded_sections = 0;
  SectionList *section_list = GetSectionList();
  if (!section_list)
    return false;

  const size_t num_sections = section_list->GetSize();
  size_t sect_idx = 0;

  for (sect_idx = 0; sect_idx < num_sections; ++sect_idx) {
    SectionSP section_sp(section_list->GetSectionAtIndex(sect_idx));
    if (target.GetSectionLoadList().SetSectionLoadAddress(
            section_sp, load_address | section_sp->GetFileAddress())) {
      ++num_loaded_sections;
    }
  }

  return num_loaded_sections > 0;
}

DataExtractor ObjectFileWasm::ReadImageData(uint64_t offset, size_t size) {
  DataExtractor data;
  if (m_file) {
    if (offset < GetByteSize()) {
      size = std::min(size, (size_t) (GetByteSize() - offset));
      auto buffer_sp = MapFileData(m_file, size, offset);
      return DataExtractor(buffer_sp, GetByteOrder(), GetAddressByteSize());
    }
  } else {
    ProcessSP process_sp(m_process_wp.lock());
    if (process_sp) {
      auto data_up = std::make_unique<DataBufferHeap>(size, 0);
      Status readmem_error;
      size_t bytes_read = process_sp->ReadMemory(
          offset, data_up->GetBytes(), data_up->GetByteSize(), readmem_error);
      if (bytes_read > 0) {
        DataBufferSP buffer_sp(data_up.release());
        data.SetData(buffer_sp, 0, buffer_sp->GetByteSize());
      }
    }
  }

  data.SetByteOrder(GetByteOrder());
  return data;
}

llvm::Optional<FileSpec> ObjectFileWasm::GetExternalDebugInfoFileSpec() {
  static ConstString g_sect_name_external_debug_info("external_debug_info");

  for (const section_info &sect_info : m_sect_infos) {
    if (g_sect_name_external_debug_info == sect_info.name) {
      const uint32_t kBufferSize = 1024;
      DataExtractor section_header_data =
          ReadImageData(sect_info.offset, kBufferSize);
      llvm::DataExtractor data = section_header_data.GetAsLLVM();
      llvm::DataExtractor::Cursor c(0);
      llvm::Optional<ConstString> symbols_url = GetWasmString(data, c);
      if (symbols_url)
        return FileSpec(symbols_url->GetStringRef());
    }
  }
  return llvm::None;
}

void ObjectFileWasm::Dump(Stream *s) {
  ModuleSP module_sp(GetModule());
  if (!module_sp)
    return;

  std::lock_guard<std::recursive_mutex> guard(module_sp->GetMutex());

  llvm::raw_ostream &ostream = s->AsRawOstream();
  ostream << static_cast<void *>(this) << ": ";
  s->Indent();
  ostream << "ObjectFileWasm, file = '";
  m_file.Dump(ostream);
  ostream << "', arch = ";
  ostream << GetArchitecture().GetArchitectureName() << "\n";

  SectionList *sections = GetSectionList();
  if (sections) {
    sections->Dump(s, nullptr, true, UINT32_MAX);
  }
  ostream << "\n";
  DumpSectionHeaders(ostream);
  ostream << "\n";
}

void ObjectFileWasm::DumpSectionHeader(llvm::raw_ostream &ostream,
                                       const section_info_t &sh) {
  ostream << llvm::left_justify(sh.name.GetStringRef(), 16) << " "
          << llvm::format_hex(sh.offset, 10) << " "
          << llvm::format_hex(sh.size, 10) << " " << llvm::format_hex(sh.id, 6)
          << "\n";
}

void ObjectFileWasm::DumpSectionHeaders(llvm::raw_ostream &ostream) {
  ostream << "Section Headers\n";
  ostream << "IDX  name             addr       size       id\n";
  ostream << "==== ---------------- ---------- ---------- ------\n";

  uint32_t idx = 0;
  for (auto pos = m_sect_infos.begin(); pos != m_sect_infos.end();
       ++pos, ++idx) {
    ostream << "[" << llvm::format_decimal(idx, 2) << "] ";
    ObjectFileWasm::DumpSectionHeader(ostream, *pos);
  }
}
