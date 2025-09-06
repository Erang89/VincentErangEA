#include "Helpers.mqh"
#include "..\Services\Rsw.mqh"
#include "..\Services\TrendService.mqh"
#include "..\Services\ChartStatusService.mqh"
#include "..\Services\TradeService.mqh"

//+------------------------------------------------------------------+
//| Input Variables
//+------------------------------------------------------------------+
input int Magic_Number = 2809;
input string Pair_Prefix = "";
input string Pair_Separator = "";
input string Pair_Suffix = "";
input bool Clear_Market_Watch_When_Init = false;
input ENUM_TIMEFRAMES TradingTimeFrame = PERIOD_H1;
input int Min_Ema_Poin = 10;
input double SL_Daily_ATR_Percentage = 50.0;
input double Risk_Percent_PerTrade = 0.5;
input double Trade_Lot_Size = 0.01;
input double Minimum_TP_Point = 30;

//+------------------------------------------------------------------+
//| GLOBAL VARIABLES                                                          |
//+------------------------------------------------------------------+
static Rsw* RSW ;
static Helpers* HELPER;
static TrendService* TRENDSERVICE;
static ChartStatus* CHARTSTATUS;
static TradeService* TRADESERVICE;