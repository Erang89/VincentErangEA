#include "..\Services\Rsw.mqh"
#include "Helpers.mqh"

//+------------------------------------------------------------------+
//| Input Variables
//+------------------------------------------------------------------+
input int Magic_Number = 28091989;
input string Pair_Prefix = "";
input string Pair_Separator = "";
input string Pair_Suffix = "";
input bool Clear_Market_Watch_When_Init = false;

//+------------------------------------------------------------------+
//| Static Variables
//+------------------------------------------------------------------+
