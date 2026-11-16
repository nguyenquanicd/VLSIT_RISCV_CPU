// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table implementation internals

#include "Vtb_store_buffer_cmo_metadata__pch.h"

Vtb_store_buffer_cmo_metadata__Syms::Vtb_store_buffer_cmo_metadata__Syms(VerilatedContext* contextp, const char* namep, Vtb_store_buffer_cmo_metadata* modelp)
    : VerilatedSyms{contextp}
    // Setup internal state of the Syms class
    , __Vm_modelp{modelp}
    , __Vm_didInit{modelp->m_didInit}
    // Setup top module instance
    , TOP{this, namep}
{
    // Check resources
    Verilated::stackCheck(367);
    // Setup sub module instances
    // Configure time unit / time precision
    _vm_contextp__->timeunit(-12);
    _vm_contextp__->timeprecision(-12);
    // Setup each module's pointers to their submodules
}

Vtb_store_buffer_cmo_metadata__Syms::~Vtb_store_buffer_cmo_metadata__Syms() {
    // Tear down scopes
    // Tear down sub module instances
}
