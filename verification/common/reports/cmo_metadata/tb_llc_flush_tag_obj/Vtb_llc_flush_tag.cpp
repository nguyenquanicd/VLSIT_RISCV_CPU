// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vtb_llc_flush_tag__pch.h"

//============================================================
// Constructors

Vtb_llc_flush_tag::Vtb_llc_flush_tag(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vtb_llc_flush_tag__Syms(contextp(), _vcname__, this)}
    , m_evalLoop{*this, /*convergeLimit:*/ 10000}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vtb_llc_flush_tag::Vtb_llc_flush_tag(const char* _vcname__)
    : Vtb_llc_flush_tag(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vtb_llc_flush_tag::~Vtb_llc_flush_tag() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vtb_llc_flush_tag___024root___eval_debug_assertions(Vtb_llc_flush_tag___024root* vlSelf);
#endif  // VL_DEBUG
VL_ATTR_COLD void Vtb_llc_flush_tag___024root___eval_static(Vtb_llc_flush_tag___024root* vlSelf);
void Vtb_llc_flush_tag___024root___eval_initial(Vtb_llc_flush_tag___024root* vlSelf);
VL_ATTR_COLD bool Vtb_llc_flush_tag___024root___eval_stl(Vtb_llc_flush_tag___024root* vlSelf, CData/*0:0*/ firstIteration);
void Vtb_llc_flush_tag___024root___eval_sample(Vtb_llc_flush_tag___024root* vlSelf);
bool Vtb_llc_flush_tag___024root___eval_ico(Vtb_llc_flush_tag___024root* vlSelf, CData/*0:0*/ firstIteration);
bool Vtb_llc_flush_tag___024root___eval_act(Vtb_llc_flush_tag___024root* vlSelf);
bool Vtb_llc_flush_tag___024root___eval_inact(Vtb_llc_flush_tag___024root* vlSelf);
bool Vtb_llc_flush_tag___024root___eval_nba(Vtb_llc_flush_tag___024root* vlSelf);
bool Vtb_llc_flush_tag___024root___eval_obs(Vtb_llc_flush_tag___024root* vlSelf);
bool Vtb_llc_flush_tag___024root___eval_react(Vtb_llc_flush_tag___024root* vlSelf);
void Vtb_llc_flush_tag___024root___eval_postponed(Vtb_llc_flush_tag___024root* vlSelf);
VL_ATTR_COLD void Vtb_llc_flush_tag___024root___eval_final(Vtb_llc_flush_tag___024root* vlSelf);
VL_ATTR_COLD void Vtb_llc_flush_tag___024root___eval_dump_triggers__stl(Vtb_llc_flush_tag___024root* vlSelf);
VL_ATTR_COLD void Vtb_llc_flush_tag___024root___eval_dump_triggers__ico(Vtb_llc_flush_tag___024root* vlSelf);
VL_ATTR_COLD void Vtb_llc_flush_tag___024root___eval_dump_triggers__act(Vtb_llc_flush_tag___024root* vlSelf);
VL_ATTR_COLD void Vtb_llc_flush_tag___024root___eval_dump_triggers__nba(Vtb_llc_flush_tag___024root* vlSelf);
VL_ATTR_COLD void Vtb_llc_flush_tag___024root___eval_dump_triggers__obs(Vtb_llc_flush_tag___024root* vlSelf);
VL_ATTR_COLD void Vtb_llc_flush_tag___024root___eval_dump_triggers__react(Vtb_llc_flush_tag___024root* vlSelf);

void Vtb_llc_flush_tag::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vtb_llc_flush_tag::eval_step\n"); );
    m_evalLoop.eval();
}

void Vtb_llc_flush_tag::evalBegin() {
#ifdef VL_DEBUG
    // Debug assertions
    Vtb_llc_flush_tag___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_deleter.deleteAll();
}

void Vtb_llc_flush_tag::evalEnd() {
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
    vlSymsp->TOP.__VdlySched.cleanupForevered();
}

void Vtb_llc_flush_tag::evalStatic() {
    Vtb_llc_flush_tag___024root___eval_static(&(vlSymsp->TOP));
}

void Vtb_llc_flush_tag::evalInitial() {
    Vtb_llc_flush_tag___024root___eval_initial(&(vlSymsp->TOP));
}

bool Vtb_llc_flush_tag::evalStl(bool firstIteration) {
    return Vtb_llc_flush_tag___024root___eval_stl(&(vlSymsp->TOP), firstIteration);
}

void Vtb_llc_flush_tag::evalSample() {
    Vtb_llc_flush_tag___024root___eval_sample(&(vlSymsp->TOP));
}

bool Vtb_llc_flush_tag::evalIco(bool firstIteration) {
    return Vtb_llc_flush_tag___024root___eval_ico(&(vlSymsp->TOP), firstIteration);
}

bool Vtb_llc_flush_tag::evalAct() {
    return Vtb_llc_flush_tag___024root___eval_act(&(vlSymsp->TOP));
}

bool Vtb_llc_flush_tag::evalInact() {
    return Vtb_llc_flush_tag___024root___eval_inact(&(vlSymsp->TOP));
}

bool Vtb_llc_flush_tag::evalNba() {
    return Vtb_llc_flush_tag___024root___eval_nba(&(vlSymsp->TOP));
}

bool Vtb_llc_flush_tag::evalObs() {
    return Vtb_llc_flush_tag___024root___eval_obs(&(vlSymsp->TOP));
}

bool Vtb_llc_flush_tag::evalReact() {
    return Vtb_llc_flush_tag___024root___eval_react(&(vlSymsp->TOP));
}

void Vtb_llc_flush_tag::evalPostponed() {
    Vtb_llc_flush_tag___024root___eval_postponed(&(vlSymsp->TOP));
}

void Vtb_llc_flush_tag::evalFinal() {
    Vtb_llc_flush_tag___024root___eval_final(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vtb_llc_flush_tag::dumpTriggersStl() {
    Vtb_llc_flush_tag___024root___eval_dump_triggers__stl(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vtb_llc_flush_tag::dumpTriggersIco() {
    Vtb_llc_flush_tag___024root___eval_dump_triggers__ico(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vtb_llc_flush_tag::dumpTriggersAct() {
    Vtb_llc_flush_tag___024root___eval_dump_triggers__act(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vtb_llc_flush_tag::dumpTriggersNba() {
    Vtb_llc_flush_tag___024root___eval_dump_triggers__nba(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vtb_llc_flush_tag::dumpTriggersObs() {
    Vtb_llc_flush_tag___024root___eval_dump_triggers__obs(&(vlSymsp->TOP));
}

VL_ATTR_COLD void Vtb_llc_flush_tag::dumpTriggersReact() {
    Vtb_llc_flush_tag___024root___eval_dump_triggers__react(&(vlSymsp->TOP));
}

//============================================================
// Events and timing
bool Vtb_llc_flush_tag::eventsPending() { return !vlSymsp->TOP.__VdlySched.empty() && !contextp()->gotFinish(); }

uint64_t Vtb_llc_flush_tag::nextTimeSlot() { return vlSymsp->TOP.__VdlySched.nextTimeSlot(); }

//============================================================
// Utilities

const char* Vtb_llc_flush_tag::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

VL_ATTR_COLD void Vtb_llc_flush_tag::final() {
    contextp()->executingFinal(true);
    evalFinal();
    contextp()->executingFinal(false);
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vtb_llc_flush_tag::hierName() const { return vlSymsp->name(); }
const char* Vtb_llc_flush_tag::modelName() const { return "Vtb_llc_flush_tag"; }
unsigned Vtb_llc_flush_tag::threads() const { return 1; }
void Vtb_llc_flush_tag::prepareClone() const { contextp()->prepareClone(); }
void Vtb_llc_flush_tag::atClone() const {
    contextp()->threadPoolpOnClone();
}
