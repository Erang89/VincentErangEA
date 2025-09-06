#include "..\Common\Variables.mqh"
#include  "..\Models\OrderModel.mqh"
#include  "..\Models\EntrySLTPModel.mqh"

class TradeService
{
   //+--------------------------------------
   //| Private Members
   //+--------------------------------------
   private:
      bool IsBussy, IsTrading;
      RswPair* rsw;
      Emas* emas;
      Enum_PriceCodingState chartState;
      RswPair* CurrentChartPair;
      datetime lastModifyPendingOrder;
      datetime lastCheckPosition;
 
      //+--------------------------------------
      //| Check if pair is recommended or not
      //| Means that a pair should in RSW List
      //+--------------------------------------
      
      bool IsPairRecommended(RswPair* &rswPair)
      {   
          if(MQLInfoInteger(MQL_TESTER) || !RSW.IsForexPair(_Symbol))
          {
            CurrentChartPair = CurrentChartPair != NULL? CurrentChartPair : new RswPair(_Symbol);
            rswPair = CurrentChartPair;
            return true;
          }
          
          RswPair* rswPairs[];
          if(Required_RSW) RSW.GetRecommendedPair(rswPairs);
          if(!Required_RSW) RSW.GetAllPairs(rswPairs);
          
          int n = ArraySize(rswPairs);
          
          for(int i=0; i<n; i++)
          {
            rswPair = rswPairs[i];
            if(rswPairs[i].Pair == _Symbol)
            {
               
               return true;
               break;
            }
          }
          
          rswPair = NULL;
          return false;
      }
      
      
      //+--------------------------------------
      //| Check if chart is align with RSW
      //| Means that: if RSW expect the buy, Then chart should support
      //| All EMA on the defined positions
      //+--------------------------------------
      bool IsValidTrend(RswPair* &rswPair)
      {
         return TRENDSERVICE.IsValidTrend(rswPair, emas);
      }
      
      
      //+--------------------------------------
      //| Check The cart status to be traded
      //| Wheather the status is ready to trade in ema20, ema50, ema100 or ema200 or do nothing
      //| 
      //+--------------------------------------
      bool IsValidChart(Enum_Position_Recomendation expectedPosition)
      {
         if(!(expectedPosition == Buy || expectedPosition == Sell))
            return false;
            
         chartState = CHARTSTATUS.GetChartStatus(expectedPosition, Min_Ema_Poin);
         if(chartState != None)
            return true;
            
         return false;
      }
      
      void NormalizeEntrySlTp(EntrySLTPModel &entrySlTp)
      {
         entrySlTp.Entry = NormalizeDouble(entrySlTp.Entry, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
         entrySlTp.SL = NormalizeDouble(entrySlTp.SL, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
         entrySlTp.TP = NormalizeDouble(entrySlTp.TP, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
      }
 
      bool GetEntrySLTP(ENUM_ORDER_TYPE orderType, int priceForEma, EntrySLTPModel &entrySlTp)
      {   
         double dailyAtr = HELPER.GetDailyATR(_Symbol);
         double slDailyAtr = dailyAtr * SL_Daily_ATR_Percentage / 100.00;
         
         if(priceForEma == 20)
         {
            entrySlTp.Entry = orderType == ORDER_TYPE_BUY_LIMIT? HELPER.GetAskPrice(emas.Ema20) : emas.Ema20;
            entrySlTp.TP = orderType == ORDER_TYPE_BUY_LIMIT? 
                     entrySlTp.Entry + HELPER.DiffPoints(emas.Ema20, emas.Ema50) * _Point : 
                     entrySlTp.Entry - HELPER.DiffPoints(emas.Ema50, emas.Ema20) * _Point;
            entrySlTp.SL = orderType == ORDER_TYPE_BUY_LIMIT?
                     entrySlTp.Entry - slDailyAtr : 
                     entrySlTp.Entry + slDailyAtr;
            NormalizeEntrySlTp(entrySlTp);
            return true;
         }
         
         if(priceForEma == 50)
         {
            entrySlTp.Entry = orderType == ORDER_TYPE_BUY_LIMIT? HELPER.GetAskPrice(emas.Ema50) : emas.Ema50;
            entrySlTp.TP = orderType == ORDER_TYPE_BUY_LIMIT? 
                     entrySlTp.Entry + HELPER.DiffPoints(emas.Ema50, emas.Ema100) * _Point : 
                     entrySlTp.Entry - HELPER.DiffPoints(emas.Ema50, emas.Ema100) * _Point;
            entrySlTp.SL = orderType == ORDER_TYPE_BUY_LIMIT?
                     entrySlTp.Entry - slDailyAtr: 
                     entrySlTp.Entry + slDailyAtr;
            NormalizeEntrySlTp(entrySlTp);
            return true;
         }
         
         if(priceForEma == 100)
         {
            entrySlTp.Entry = orderType == ORDER_TYPE_BUY_LIMIT? HELPER.GetAskPrice(emas.Ema100) : emas.Ema100;
            entrySlTp.TP = orderType == ORDER_TYPE_BUY_LIMIT? 
                     entrySlTp.Entry + HELPER.DiffPoints(emas.Ema100, emas.Ema200) * _Point : 
                     entrySlTp.Entry - HELPER.DiffPoints(emas.Ema100, emas.Ema200) * _Point;
            entrySlTp.SL = orderType == ORDER_TYPE_BUY_LIMIT?
                     entrySlTp.Entry - slDailyAtr : 
                     entrySlTp.Entry + slDailyAtr;
            NormalizeEntrySlTp(entrySlTp);            
            return true;
         }
         
         
         
         if(priceForEma == 200)
         {
            entrySlTp.Entry = orderType == ORDER_TYPE_BUY_LIMIT? HELPER.GetAskPrice(emas.Ema200) : emas.Ema200;
            entrySlTp.TP = orderType == ORDER_TYPE_BUY_LIMIT? 
                     entrySlTp.Entry + HELPER.DiffPoints(emas.Ema50, emas.Ema200) * _Point : 
                     entrySlTp.Entry - HELPER.DiffPoints(emas.Ema50, emas.Ema200) * _Point;
            entrySlTp.SL = orderType == ORDER_TYPE_BUY_LIMIT?
                     entrySlTp.Entry - slDailyAtr : 
                     entrySlTp.Entry + slDailyAtr;
            NormalizeEntrySlTp(entrySlTp);           
            return true;
         }
         
         
         
         
         return false;
      }
 
      //+--------------------------------------
      //| Open Position For Ema20
      //+--------------------------------------
      bool OpenPoisitionForEma20()
      {
         if(chartState != PendigOrderOnEma20)
            return false;
         
         double highestPrice = CHARTSTATUS.GetHighestPriceOnTheTrend();
         double lowestPrice = CHARTSTATUS.GetLowestPriceOnTheTrend();
         
         if(rsw.RecommendPosition == Buy && HELPER.DiffPoints(highestPrice, emas.Ema20) < Min_Ema_Poin)
            return false;
            
         if(rsw.RecommendPosition == Sell && HELPER.DiffPoints(emas.Ema20, lowestPrice) < Min_Ema_Poin)
            return false;
            
         if(HELPER.DiffPoints(emas.Ema20, emas.Ema50) < Minimum_TP_Point)
            return false;
         
         
         ENUM_ORDER_TYPE orderType = rsw.RecommendPosition == Buy? ORDER_TYPE_BUY_LIMIT : ORDER_TYPE_SELL_LIMIT;
         EntrySLTPModel entrySlTp;
         if(!GetEntrySLTP(orderType, 20, entrySlTp))
         {
            return false;
         }
         
         OrderModel order;         
         order.MagicNumber = Magic_Number;
         order.OrderComment = "Ema20";
         order.LotSize = Trade_Lot_Size;
         order.OrderSymbol = _Symbol;
         order.OrderType = rsw.RecommendPosition == Buy? ORDER_TYPE_BUY_LIMIT : ORDER_TYPE_SELL_LIMIT;         
         order.Entry = entrySlTp.Entry;
         order.TP = entrySlTp.TP;
         order.SL = entrySlTp.SL;
         
         return HELPER.LimitOrder(order);
      }
      
      
      //+--------------------------------------
      //| Open Position For Ema50
      //+--------------------------------------
      bool OpenPoisitionForEma50()
      {
         if(!(chartState == PendigOrderOnEma20 || chartState == PendigOrderOnEma50))
            return false;
            
         if(HELPER.DiffPoints(emas.Ema50, emas.Ema20) < Min_Ema_Poin)
            return false;
         
         if(HELPER.DiffPoints(emas.Ema50, emas.Ema100) < Minimum_TP_Point)
            return false;
            
            
         ENUM_ORDER_TYPE orderType = rsw.RecommendPosition == Buy? ORDER_TYPE_BUY_LIMIT : ORDER_TYPE_SELL_LIMIT;
         EntrySLTPModel entrySlTp;
         if(!GetEntrySLTP(orderType, 50, entrySlTp))
         {
            return false;
         }
         
         OrderModel order;
         order.MagicNumber = Magic_Number;
         order.OrderComment = "Ema50";
         order.LotSize = Trade_Lot_Size;
         order.OrderSymbol = _Symbol;
         order.OrderType = rsw.RecommendPosition == Buy? ORDER_TYPE_BUY_LIMIT : ORDER_TYPE_SELL_LIMIT;
         order.Entry = entrySlTp.Entry;
         order.TP = entrySlTp.TP;
         order.SL = entrySlTp.SL;
         
         return HELPER.LimitOrder(order);
      }
      
      
      //+--------------------------------------
      //| Open Position For Ema100
      //+--------------------------------------
      bool OpenPoisitionForEma100()
      {
         if(!(chartState == PendigOrderOnEma20 || chartState == PendigOrderOnEma50 || chartState == PendigOrderOnEma100))
            return false;
            
         if(HELPER.DiffPoints(emas.Ema50, emas.Ema100) < Min_Ema_Poin)
            return false;
         
         if(HELPER.DiffPoints(emas.Ema100, emas.Ema200) < Minimum_TP_Point)
            return false;
            
         ENUM_ORDER_TYPE orderType = rsw.RecommendPosition == Buy? ORDER_TYPE_BUY_LIMIT : ORDER_TYPE_SELL_LIMIT;
         EntrySLTPModel entrySlTp;
         if(!GetEntrySLTP(orderType, 100, entrySlTp))
         {
            return false;
         }
         
         
         OrderModel order;
         order.MagicNumber = Magic_Number;
         order.OrderComment = "Ema100";
         order.LotSize = Trade_Lot_Size;
         order.OrderSymbol = _Symbol;
         order.OrderType = rsw.RecommendPosition == Buy? ORDER_TYPE_BUY_LIMIT : ORDER_TYPE_SELL_LIMIT;
         order.Entry = entrySlTp.Entry;
         order.TP = entrySlTp.TP;
         order.SL = entrySlTp.SL;
         
         return HELPER.LimitOrder(order);
      }
      
      
      //+--------------------------------------
      //| Open Position For Ema200
      //+--------------------------------------
      bool OpenPoisitionForEma200()
      {
         if(!(chartState == PendigOrderOnEma20 || chartState == PendigOrderOnEma50 || chartState == PendigOrderOnEma100 || chartState == PendigOrderOnEma200))
            return false;
            
         if(HELPER.DiffPoints(emas.Ema100, emas.Ema200) < Min_Ema_Poin)
            return false;
         
         if(HELPER.DiffPoints(emas.Ema200, emas.Ema50) < Minimum_TP_Point)
            return false;
         
         
         ENUM_ORDER_TYPE orderType = rsw.RecommendPosition == Buy? ORDER_TYPE_BUY_LIMIT : ORDER_TYPE_SELL_LIMIT;
         EntrySLTPModel entrySlTp;
         if(!GetEntrySLTP(orderType, 200, entrySlTp))
         {
            return false;
         }
         
         OrderModel order;         
         order.MagicNumber = Magic_Number;
         order.OrderComment = "Ema200";
         order.LotSize = Trade_Lot_Size;
         order.OrderSymbol = _Symbol;
         order.OrderType = rsw.RecommendPosition == Buy? ORDER_TYPE_BUY_LIMIT : ORDER_TYPE_SELL_LIMIT;
         order.Entry = entrySlTp.Entry;
         order.TP = entrySlTp.TP;
         order.SL = entrySlTp.SL;
         
         return HELPER.LimitOrder(order);
      }
      
      
      
      void HandleTradingModify()
      {
         if(lastModifyPendingOrder == iTime(_Symbol, PERIOD_M1, 0))
            return;
         
         Print("Modifying Check Start");
         
         bool isRecommended = IsPairRecommended(rsw);
         bool isValidTrend = IsValidTrend(rsw);
         bool isValidChard = IsValidChart(rsw.RecommendPosition);
         
         EntrySLTPModel entrySlTp20, entrySlTp50, entrySlTp100, entrySlTp200;
         bool resultEntry20, resultEntry50, resultEntry100, resultEntry200;
         bool resultModify20, resultModify50, resultModify100, resultModify200;
         
         resultModify20 = true;
         resultModify50 = true;
         resultModify100 = true;
         resultModify200 = true;
         
         for(int i=0; i<OrdersTotal(); i++)
         {
            ulong ticket = OrderGetTicket(i);
            
            if(ticket > 0 && OrderSelect(ticket))
            {
               long orderId = OrderGetInteger(ORDER_TICKET);
               long   magic  = OrderGetInteger(ORDER_MAGIC);
               string symbol = OrderGetString(ORDER_SYMBOL);
               long orderType = OrderGetInteger(ORDER_TYPE);
               string comment = OrderGetString(ORDER_COMMENT);
               double entry = OrderGetDouble(ORDER_PRICE_OPEN);
               
               if(magic != Magic_Number || symbol != _Symbol)
                  continue;
               
               int trend = (emas.Ema20 > emas.Ema50 && emas.Ema50 > emas.Ema100 && emas.Ema100 > emas.Ema200)? 1 :
                           (emas.Ema20 < emas.Ema50 && emas.Ema50 < emas.Ema100 && emas.Ema100 < emas.Ema200)? 2 : 0;
                           
               
               // Delete Pending Order if not valid Any More
               if(
                  !isRecommended || !isValidTrend || (rsw.RecommendPosition == Buy && trend != 1) || (rsw.RecommendPosition == Sell && trend != 2) || (rsw.RecommendPosition == NotRecommend) ||
                  (comment == "Ema20" && chartState != PendigOrderOnEma20) ||
                  (comment == "Ema50" && (chartState != PendigOrderOnEma20 && chartState != PendigOrderOnEma50)) ||
                  (comment == "Ema100" && (chartState != PendigOrderOnEma20 && chartState != PendigOrderOnEma50 && chartState != PendigOrderOnEma100)) ||
                  (comment == "Ema200" && (chartState != PendigOrderOnEma20 && chartState != PendigOrderOnEma50 && chartState != PendigOrderOnEma100 && chartState != PendigOrderOnEma200))
               )
               {
                  HELPER.DeletePendingOrder(orderId);
                  continue;
               }
               
               bool isBuyOrderLimit = ((ENUM_ORDER_TYPE)orderType == ORDER_TYPE_BUY_LIMIT);
               ENUM_ORDER_TYPE orderLimitType = isBuyOrderLimit? ORDER_TYPE_BUY_LIMIT : ORDER_TYPE_SELL_LIMIT;
               
               resultEntry20 = GetEntrySLTP(orderLimitType, 20, entrySlTp20);
               resultEntry50 = GetEntrySLTP(orderLimitType, 50, entrySlTp50);
               resultEntry100 = GetEntrySLTP(orderLimitType, 100, entrySlTp100);
               resultEntry200 = GetEntrySLTP(orderLimitType, 200, entrySlTp200);
               
               
               if(comment == "Ema20")
               {
                  if(!resultEntry20 || entry == entrySlTp20.Entry)
                  {
                     Print("Modifying Check: No Difference");
                     continue;
                  }
                  
                  resultModify20 = HELPER.ModifyPendingOrder(_Symbol, orderId, entrySlTp20.Entry, entrySlTp20.SL, entrySlTp20.TP);
                  continue;
               }
               
               if(comment == "Ema50")
               {
                  if(!resultEntry50 || entry == entrySlTp50.Entry)
                  {
                     Print("Modifying Check: No Difference");
                     continue;
                  }
                  
                  resultModify50 = HELPER.ModifyPendingOrder(_Symbol, orderId, entrySlTp50.Entry, entrySlTp50.SL, entrySlTp50.TP);
                  continue;
               }
               
               if(comment == "Ema100")
               {
                  if(!resultEntry100 || entry == entrySlTp100.Entry)
                  {
                     Print("Modifying Check: No Difference");
                     continue;
                  }
                  
                  resultModify100 = HELPER.ModifyPendingOrder(_Symbol, orderId, entrySlTp100.Entry, entrySlTp100.SL, entrySlTp100.TP);
                  continue;
               }
               
               if(comment == "Ema200")
               {
                  if(!resultEntry200 || entry == entrySlTp200.Entry)
                  {
                     Print("Modifying Check: No Difference");
                     continue;
                  }
                  
                  resultModify200 = HELPER.ModifyPendingOrder(_Symbol, orderId, entrySlTp200.Entry, entrySlTp200.SL, entrySlTp200.TP);
                  continue;
               }
            }
         }
         
         
         if(resultModify20 && resultModify50 && resultModify100 && resultModify200)
         {
            lastModifyPendingOrder = iTime(_Symbol, PERIOD_M1, 0);
         }
      }
      
      
      void HandleCutTrading()
      {
         if(lastCheckPosition == iTime(_Symbol, PERIOD_M1, 0))
            return;
         
         
         bool isRecommended = IsPairRecommended(rsw);
         bool isValidTrend = IsValidTrend(rsw);
         bool isValidChard = IsValidChart(rsw.RecommendPosition);
         
      
         for(int i=0; i<PositionsTotal(); i++)
         {
            ulong ticket = PositionGetTicket(i);
            if(ticket > 0 && PositionSelectByTicket(ticket))
            {
               long positionId = PositionGetInteger(POSITION_TICKET);
               long   magic  = PositionGetInteger(POSITION_MAGIC);
               string symbol = PositionGetString(POSITION_SYMBOL);
               long orderType = PositionGetInteger(POSITION_TYPE);
               string comment = PositionGetString(POSITION_COMMENT);
               double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
               bool isBuyPosition = ((ENUM_POSITION_TYPE)orderType == POSITION_TYPE_BUY);
               bool isSellPosition = ((ENUM_POSITION_TYPE)orderType == POSITION_TYPE_SELL);
               
               if(magic != Magic_Number || symbol != _Symbol)
                  continue;
                  
               double lastClose = iClose(_Symbol, TradingTimeFrame, 1);
               
               if(comment == "Ema20" && ((isBuyPosition && lastClose < emas.Ema20) || (isSellPosition && lastClose > emas.Ema20)))
               {
                  HELPER.ClosePosition(positionId);
                  continue;
               }
               
               if(comment == "Ema50" && ((isBuyPosition && lastClose < emas.Ema50) || (isSellPosition && lastClose > emas.Ema50)))
               {
                  HELPER.ClosePosition(positionId);
                  continue;
               }
               
               if(comment == "Ema100" && ((isBuyPosition && lastClose < emas.Ema100) || (isSellPosition && lastClose > emas.Ema100)))
               {
                  HELPER.ClosePosition(positionId);
                  continue;
               }
               
               if(comment == "Ema200" && ((isBuyPosition && lastClose < emas.Ema200) || (isSellPosition && lastClose > emas.Ema200)))
               {
                  HELPER.ClosePosition(positionId);
                  continue;
               }
            }
         }
         
         lastCheckPosition = iTime(_Symbol, PERIOD_M1, 0);
         
      }
 
 
   //+--------------------------------------
   //| Public Members
   //+--------------------------------------
      
   public:
      TradeService()
      {
         chartState = None;
      }
      
      
      
   //+--------------------------------------
   //| Trade Function
   //| This Function should be executed OnTick
   //+--------------------------------------      
      void Trade()
      {
         if(IsBussy)
            return;
         
         IsBussy = true;             
         IsTrading = HELPER.IsTrading(_Symbol);
         
         if(IsTrading)
         {
            HandleTradingModify();
            HandleCutTrading();
         }
         

         if(IsTrading ||  !IsPairRecommended(rsw) || !IsValidTrend(rsw) || !IsValidChart(rsw.RecommendPosition))
         {
            //Release();
            IsBussy = false;
            return;
         }
            
            
          if(emas == NULL)
          {
            //Release();
            IsBussy = false;
            return;
          }
          
          Print("You are free to open position: ", chartState, " ", PriceCodingStateToString(chartState));
          OpenPoisitionForEma20();
          OpenPoisitionForEma50();
          OpenPoisitionForEma100();
          OpenPoisitionForEma200();
          lastModifyPendingOrder =  iTime(_Symbol, TradingTimeFrame, 0);
          Print("Handle Order Done");
          
          //Release();
          IsBussy = false;
      }
      
      void Release()
      {
         delete emas;
         delete rsw;
         emas = NULL;
         rsw = NULL;
         
         if(CurrentChartPair != NULL)
         {
            delete CurrentChartPair;
            CurrentChartPair = NULL;
         }
      }
};