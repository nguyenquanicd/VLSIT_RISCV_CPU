// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table implementation internals

#include "Vtb_llc_pending__pch.h"

extern const VlScopeTableEntry Vtb_llc_pending__Syms__VpiScopeTable[];


// VPI VARIABLE/SCOPE TABLES
#if defined(__GNUC__)
# pragma GCC diagnostic push
# pragma GCC diagnostic ignored "-Winvalid-offsetof"
#endif
extern const VlScopeTableEntry Vtb_llc_pending__Syms__VpiScopeTable[] = {
    {offsetof(Vtb_llc_pending__Syms, __Vscopep_tb_llc_pending), "tb_llc_pending", "tb_llc_pending", "<null>", -9, VerilatedScope::SCOPE_OTHER},
    {offsetof(Vtb_llc_pending__Syms, __Vscopep_tb_llc_pending__receive), "tb_llc_pending.receive", "receive", "<null>", -9, VerilatedScope::SCOPE_OTHER},
    {offsetof(Vtb_llc_pending__Syms, __Vscopep_tb_llc_pending__unnamedblk2), "tb_llc_pending.unnamedblk2", "unnamedblk2", "<null>", -9, VerilatedScope::SCOPE_OTHER},
    {offsetof(Vtb_llc_pending__Syms, __Vscopep_tb_llc_pending__unnamedblk2__unnamedblk1_2), "tb_llc_pending.unnamedblk2.unnamedblk1_2", "unnamedblk1_2", "<null>", -9, VerilatedScope::SCOPE_OTHER},
};
#if defined(__GNUC__)
# pragma GCC diagnostic pop
#endif
Vtb_llc_pending__Syms::Vtb_llc_pending__Syms(VerilatedContext* contextp, const char* namep, Vtb_llc_pending* modelp)
    : VerilatedSyms{contextp}
    // Setup internal state of the Syms class
    , __Vm_modelp{modelp}
    , __Vm_didInit{modelp->m_didInit}
    // Setup top module instance
    , TOP{this, namep}
{
    // Check resources
    Verilated::stackCheck(737);
    // Setup sub module instances
    // Configure time unit / time precision
    _vm_contextp__->timeunit(-9);
    _vm_contextp__->timeprecision(-12);
    // Setup each module's pointers to their submodules
    // Setup scopes
    VerilatedScope::scopesConstructFromTable(Vtb_llc_pending__Syms__VpiScopeTable, 4, this);
    // Setup export functions - final: 0
    // Setup export functions - final: 1
}

Vtb_llc_pending__Syms::~Vtb_llc_pending__Syms() {
    // Tear down scopes
    VL_DO_CLEAR(delete __Vscopep_tb_llc_pending, __Vscopep_tb_llc_pending = nullptr);
    VL_DO_CLEAR(delete __Vscopep_tb_llc_pending__receive, __Vscopep_tb_llc_pending__receive = nullptr);
    VL_DO_CLEAR(delete __Vscopep_tb_llc_pending__unnamedblk2, __Vscopep_tb_llc_pending__unnamedblk2 = nullptr);
    VL_DO_CLEAR(delete __Vscopep_tb_llc_pending__unnamedblk2__unnamedblk1_2, __Vscopep_tb_llc_pending__unnamedblk2__unnamedblk1_2 = nullptr);
    // Tear down sub module instances
}
