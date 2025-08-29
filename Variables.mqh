#include "Helpers.mqh"
#include "Rsw.mqh"

//+------------------------------------------------------------------+
//| Input Variables
//+------------------------------------------------------------------+
input int Magic_Number = 28091989;
input string Pair_Prefix = "";
input string Pair_Separator = "";
input string Pair_Suffix = "";

//+------------------------------------------------------------------+
//| Static Variables
//+------------------------------------------------------------------+

static Helpers* HELPER = new Helpers();
static Rsw* RSW = new Rsw();