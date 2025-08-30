#include "Helpers.mqh"
#include "..\Services\Rsw.mqh"
#include "..\Services\TrendService.mqh"

//+------------------------------------------------------------------+
//| Input Variables
//+------------------------------------------------------------------+
input int Magic_Number = 28091989;
input string Pair_Prefix = "";
input string Pair_Separator = "";
input string Pair_Suffix = "";
input bool Clear_Market_Watch_When_Init = false;
input ENUM_TIMEFRAMES TradingTimeFrame = PERIOD_H1;

//+------------------------------------------------------------------+
//| GLOBAL VARIABLES                                                          |
//+------------------------------------------------------------------+
static Rsw* RSW ;
static Helpers* HELPER;
static TrendService* TRENDSERVICE;