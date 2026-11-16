// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vtb_llc_pending__pch.h"

//============================================================
// Constructors

Vtb_llc_pending::Vtb_llc_pending(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vtb_llc_pending__Syms(contextp(), _vcname__, this)}
    , m_evalLoop{*this, /*convergeLimit:*/ 10000}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vtb_llc_pending::Vtb_llc_pending(const char* _vcname__)
    : Vtb_llc_pending(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vtb_llc_pending::~Vtb_llc_pending() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vtb_llc_pending___024root___eval_debug_assertions(Vtb_llc_pending___024root* vlSelf);
#endif  // VL_DEBUG
VL_ATTR_COLD void Vtb_llc_pending___024root___eval_static(Vtb_llc_pending___024root* vlSelf);
void Vtb_llc_pending___024root___eval_initial(Vtb_llc_pending___024root* vlSelf);
VL_ATTR_COLD bool Vtb_llc_pending___024root___eval_stl(Vtb_llc_pending___024root* vlSelf, CData/*0:0*/ firstIteration);
void Vtb_llc_pending___024root___eval_sample(Vtb_llc_pending___024root* vlSelf);
bool Vtb_llc_pending___024root___eval_ico(Vtb_llc_pending___024root* vlSelf, CData/*0:0*/ firstIteration);
bool Vtb_llc_pending___024root___eval_act(Vtb_llc_pending___024root* vlSelf);
bool Vtb_llc_pending___024root___eval_inact(Vtb_llc_pending___024root* vlSelf);
bool Vtb_llc_pending___024root___eval_nba(Vtb_llc_pending___024root* vlSelf);
bool Vtb_llc_pending___024root___eval_obs(Vtb_llc_pending___024root* vlSelf);
bool Vtb_llc_pending___024root___eval_react(Vtb_llc_pending___024root* vlSelf);
void Vtb_llc_pending___024root___eval_postponed(Vtb_llc_pending___024root* vlSelf);
VL_ATTR_COLD void Vtb_llc_pending___024root___eval_final(Vtb_llc_pending___024root* vlSelf);
VL_ATTR_COLD void Vtb_llc_pending___024root___eval_dump_triggers__stl(Vtb_llc_pending___024root* vlSelf);
VL_ATTR_COLD void Vtb_llc_pending___024root___eval_dump_triggers__ico(Vtb_llc_pending___024root* vlSelf);
VL_ATTR_COLD void Vtb_llc_pending___024root___eval_dump_triggers__act(Vtb_llc_pending___024root* vlSelf);
VL_ATTR_COLD void Vtb_llc_pending___024root___eval_dump_triggers__nba(Vtb_llc_pending___024root* vlSelf);
VL_ATTR_COLD void Vtb_llc_pending___024root___eval_dump_triggers__obs(Vtb_llc_pending___024root* vlSelf);
VL_ATTR_COLD void Vtb_llc_pending___024root___eval_dump_triggers__react(Vtb_llc_pending___024root* vlSelf);

void Vtb_llc_pending::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vtb_llc_pending::eval_step\n"); );
    m_evalLoop.eval();
}

void Vtb_llc_pending::evalBegin() {
#ifdef VL_DEBUG
    // Debug assertions
    Vtb_llc_pending___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_deleter.deleteAll();
}

void Vtb_llc_pending::evalEnd() {
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
    vlSymsp->TOP.__VdlySched.cleanupForevered();
}

void Vtb_llc_pending::evalStatic() {
    Vtb_llc_pending___024root___eval_static(&(vlSymsp->TOP));
}

void Vtb_llc_pending::evalInitial() {
    Vtb_llc_pending___024root___eval_initial(&(vlSymsp->TOP));
}

bool Vtb_llc_pending::evalStl(bool firstIteration) {
    return Vtb_llc_pending___024root___eval_stl(&(vlSymsp->TOP), firstIteration);
}

void Vtb_llc_pending::evalSample() {
    Vtb_llc_pending___024root___eval_sample(&(vlSymsp->TOP));
}

bool Vtb_llc_pending::evalIco(bool firstIteration) {
    return Vtb_llc_pending___024root___eval_ico(&(vlSymsp->TOP), firstIteration);
}

bool Vtb_llc_pending::evalAct() {
    return Vtb_llc_pending___024root___eval_act(&(vlSymsp->TOP));
}

bool Vtb_llc_pending::evalInact() {
    return Vtb_llc_pending___024root___eval_inact(&(vlSymsp->TOP));
}

bool Vtb_llc_pending::evalNba() {
    return Vtb_llc_pending___024root___eval_nba(&(vlSymsp->TOP));
}

bool Vtb_llc_pending::evalObs() {
    return Vtb_llc_pending___024root___eval_obs(&(vlSymsp->TOP));
}

bool Vtb_llc_pending::evalReact() {
    return Vtb_llc_pending___024root___eval_react(&(vlSymsp->TOP));
}

void Vtb_llc_pending::evalPostponed() {
    Vtb_llc_pending___024root___eval_postponed(&(vlSymsp->TOP));
}

void Vtb_llc_pending::evalFinal() {
    Vtb_llc_pending___024root___eval_final(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vtb_llc_pending::dumpTriggersStl() {
    Vtb_llc_pending___024root___eval_dump_triggers__stl(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vtb_llc_pending::dumpTriggersIco() {
    Vtb_llc_pending___024root___eval_dump_triggers__ico(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vtb_llc_pending::dumpTriggersAct() {
    Vtb_llc_pending___024root___eval_dump_triggers__act(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vtb_llc_pending::dumpTriggersNba() {
    Vtb_llc_pending___024root___eval_dump_triggers__nba(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vtb_llc_pending::dumpTriggersObs() {
    Vtb_llc_pending___024root___eval_dump_triggers__obs(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vtb_llc_pending::dumpTriggersReact() {
    Vtb_llc_pending___024root___eval_dump_triggers__react(&(vlSymsp->TOP));
}

//============================================================
// Events and timing
bool Vtb_llc_pending::eventsPending() { return !vlSymsp->TOP.__VdlySched.empty() && !contextp()->gotFinish(); }

uint64_t Vtb_llc_pending::nextTimeSlot() { return vlSymsp->TOP.__VdlySched.nextTimeSlot(); }

//============================================================
// Utilities

const char* Vtb_llc_pending::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

VL_ATTR_COLD void Vtb_llc_pending::final() {
    contextp()->executingFinal(true);
    evalFinal();
    contextp()->executingFinal(false);
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vtb_llc_pending::hierName() const { return vlSymsp->name(); }
const char* Vtb_llc_pending::modelName() const { return "Vtb_llc_pending"; }
unsigned Vtb_llc_pending::threads() const { return 1; }
void Vtb_llc_pending::prepareClone() const { contextp()->prepareClone(); }
void Vtb_llc_pending::atClone() const {
    contextp()->threadPoolpOnClone();
}
