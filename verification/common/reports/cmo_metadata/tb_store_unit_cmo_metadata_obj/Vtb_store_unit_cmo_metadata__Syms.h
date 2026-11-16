// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VTB_STORE_UNIT_CMO_METADATA__SYMS_H_
#define VERILATED_VTB_STORE_UNIT_CMO_METADATA__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODEL CLASS

#include "Vtb_store_unit_cmo_metadata.h"

// INCLUDE MODULE CLASSES
#include "Vtb_store_unit_cmo_metadata___024root.h"

// SYMS CLASS (contains all model state)
class alignas(VL_CACHE_LINE_BYTES) Vtb_store_unit_cmo_metadata__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    Vtb_store_unit_cmo_metadata* const __Vm_modelp;
    VlDeleter __Vm_deleter;
    bool& __Vm_didInit;

    // MODULE INSTANCE STATE
    Vtb_store_unit_cmo_metadata___024root TOP;

    // CONSTRUCTORS
    Vtb_store_unit_cmo_metadata__Syms(VerilatedContext* contextp, const char* namep, Vtb_store_unit_cmo_metadata* modelp);
    ~Vtb_store_unit_cmo_metadata__Syms();

    // METHODS
    const char* name() const { return TOP.vlNamep; }
};

#endif  // guard
