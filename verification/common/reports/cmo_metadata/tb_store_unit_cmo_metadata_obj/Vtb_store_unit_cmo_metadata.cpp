// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vtb_store_unit_cmo_metadata__pch.h"

//============================================================
// Constructors

Vtb_store_unit_cmo_metadata::Vtb_store_unit_cmo_metadata(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vtb_store_unit_cmo_metadata__Syms(contextp(), _vcname__, this)}
    , m_evalLoop{*this, /*convergeLimit:*/ 10000}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vtb_store_unit_cmo_metadata::Vtb_store_unit_cmo_metadata(const char* _vcname__)
    : Vtb_store_unit_cmo_metadata(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vtb_store_unit_cmo_metadata::~Vtb_store_unit_cmo_metadata() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vtb_store_unit_cmo_metadata___024root___eval_debug_assertions(Vtb_store_unit_cmo_metadata___024root* vlSelf);
#endif  // VL_DEBUG
VL_ATTR_COLD void Vtb_store_unit_cmo_metadata___024root___eval_static(Vtb_store_unit_cmo_metadata___024root* vlSelf);
void Vtb_store_unit_cmo_metadata___024root___eval_initial(Vtb_store_unit_cmo_metadata___024root* vlSelf);
VL_ATTR_COLD bool Vtb_store_unit_cmo_metadata___024root___eval_stl(Vtb_store_unit_cmo_metadata___024root* vlSelf, CData/*0:0*/ firstIteration);
void Vtb_store_unit_cmo_metadata___024root___eval_sample(Vtb_store_unit_cmo_metadata___024root* vlSelf);
bool Vtb_store_unit_cmo_metadata___024root___eval_ico(Vtb_store_unit_cmo_metadata___024root* vlSelf, CData/*0:0*/ firstIteration);
bool Vtb_store_unit_cmo_metadata___024root___eval_act(Vtb_store_unit_cmo_metadata___024root* vlSelf);
bool Vtb_store_unit_cmo_metadata___024root___eval_inact(Vtb_store_unit_cmo_metadata___024root* vlSelf);
bool Vtb_store_unit_cmo_metadata___024root___eval_nba(Vtb_store_unit_cmo_metadata___024root* vlSelf);
bool Vtb_store_unit_cmo_metadata___024root___eval_obs(Vtb_store_unit_cmo_metadata___024root* vlSelf);
bool Vtb_store_unit_cmo_metadata___024root___eval_react(Vtb_store_unit_cmo_metadata___024root* vlSelf);
void Vtb_store_unit_cmo_metadata___024root___eval_postponed(Vtb_store_unit_cmo_metadata___024root* vlSelf);
VL_ATTR_COLD void Vtb_store_unit_cmo_metadata___024root___eval_final(Vtb_store_unit_cmo_metadata___024root* vlSelf);
VL_ATTR_COLD void Vtb_store_unit_cmo_metadata___024root___eval_dump_triggers__stl(Vtb_store_unit_cmo_metadata___024root* vlSelf);
VL_ATTR_COLD void Vtb_store_unit_cmo_metadata___024root___eval_dump_triggers__ico(Vtb_store_unit_cmo_metadata___024root* vlSelf);
VL_ATTR_COLD void Vtb_store_unit_cmo_metadata___024root___eval_dump_triggers__act(Vtb_store_unit_cmo_metadata___024root* vlSelf);
VL_ATTR_COLD void Vtb_store_unit_cmo_metadata___024root___eval_dump_triggers__nba(Vtb_store_unit_cmo_metadata___024root* vlSelf);
VL_ATTR_COLD void Vtb_store_unit_cmo_metadata___024root___eval_dump_triggers__obs(Vtb_store_unit_cmo_metadata___024root* vlSelf);
VL_ATTR_COLD void Vtb_store_unit_cmo_metadata___024root___eval_dump_triggers__react(Vtb_store_unit_cmo_metadata___024root* vlSelf);

void Vtb_store_unit_cmo_metadata::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vtb_store_unit_cmo_metadata::eval_step\n"); );
    m_evalLoop.eval();
}

void Vtb_store_unit_cmo_metadata::evalBegin() {
#ifdef VL_DEBUG
    // Debug assertions
    Vtb_store_unit_cmo_metadata___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_deleter.deleteAll();
}

void Vtb_store_unit_cmo_metadata::evalEnd() {
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
    vlSymsp->TOP.__VdlySched.cleanupForevered();
}

void Vtb_store_unit_cmo_metadata::evalStatic() {
    Vtb_store_unit_cmo_metadata___024root___eval_static(&(vlSymsp->TOP));
}

void Vtb_store_unit_cmo_metadata::evalInitial() {
    Vtb_store_unit_cmo_metadata___024root___eval_initial(&(vlSymsp->TOP));
}

bool Vtb_store_unit_cmo_metadata::evalStl(bool firstIteration) {
    return Vtb_store_unit_cmo_metadata___024root___eval_stl(&(vlSymsp->TOP), firstIteration);
}

void Vtb_store_unit_cmo_metadata::evalSample() {
    Vtb_store_unit_cmo_metadata___024root___eval_sample(&(vlSymsp->TOP));
}

bool Vtb_store_unit_cmo_metadata::evalIco(bool firstIteration) {
    return Vtb_store_unit_cmo_metadata___024root___eval_ico(&(vlSymsp->TOP), firstIteration);
}

bool Vtb_store_unit_cmo_metadata::evalAct() {
    return Vtb_store_unit_cmo_metadata___024root___eval_act(&(vlSymsp->TOP));
}

bool Vtb_store_unit_cmo_metadata::evalInact() {
    return Vtb_store_unit_cmo_metadata___024root___eval_inact(&(vlSymsp->TOP));
}

bool Vtb_store_unit_cmo_metadata::evalNba() {
    return Vtb_store_unit_cmo_metadata___024root___eval_nba(&(vlSymsp->TOP));
}

bool Vtb_store_unit_cmo_metadata::evalObs() {
    return Vtb_store_unit_cmo_metadata___024root___eval_obs(&(vlSymsp->TOP));
}

bool Vtb_store_unit_cmo_metadata::evalReact() {
    return Vtb_store_unit_cmo_metadata___024root___eval_react(&(vlSymsp->TOP));
}

void Vtb_store_unit_cmo_metadata::evalPostponed() {
    Vtb_store_unit_cmo_metadata___024root___eval_postponed(&(vlSymsp->TOP));
}

void Vtb_store_unit_cmo_metadata::evalFinal() {
    Vtb_store_unit_cmo_metadata___024root___eval_final(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vtb_store_unit_cmo_metadata::dumpTriggersStl() {
    Vtb_store_unit_cmo_metadata___024root___eval_dump_triggers__stl(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vtb_store_unit_cmo_metadata::dumpTriggersIco() {
    Vtb_store_unit_cmo_metadata___024root___eval_dump_triggers__ico(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vtb_store_unit_cmo_metadata::dumpTriggersAct() {
    Vtb_store_unit_cmo_metadata___024root___eval_dump_triggers__act(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vtb_store_unit_cmo_metadata::dumpTriggersNba() {
    Vtb_store_unit_cmo_metadata___024root___eval_dump_triggers__nba(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vtb_store_unit_cmo_metadata::dumpTriggersObs() {
    Vtb_store_unit_cmo_metadata___024root___eval_dump_triggers__obs(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vtb_store_unit_cmo_metadata::dumpTriggersReact() {
    Vtb_store_unit_cmo_metadata___024root___eval_dump_triggers__react(&(vlSymsp->TOP));
}

//============================================================
// Events and timing
bool Vtb_store_unit_cmo_metadata::eventsPending() { return !vlSymsp->TOP.__VdlySched.empty() && !contextp()->gotFinish(); }

uint64_t Vtb_store_unit_cmo_metadata::nextTimeSlot() { return vlSymsp->TOP.__VdlySched.nextTimeSlot(); }

//============================================================
// Utilities

const char* Vtb_store_unit_cmo_metadata::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

VL_ATTR_COLD void Vtb_store_unit_cmo_metadata::final() {
    contextp()->executingFinal(true);
    evalFinal();
    contextp()->executingFinal(false);
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vtb_store_unit_cmo_metadata::hierName() const { return vlSymsp->name(); }
const char* Vtb_store_unit_cmo_metadata::modelName() const { return "Vtb_store_unit_cmo_metadata"; }
unsigned Vtb_store_unit_cmo_metadata::threads() const { return 1; }
void Vtb_store_unit_cmo_metadata::prepareClone() const { contextp()->prepareClone(); }
void Vtb_store_unit_cmo_metadata::atClone() const {
    contextp()->threadPoolpOnClone();
}
