#include "..\Common\Variables.mqh"
#include  "..\Models\OrderModel.mqh"

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
          RSW.GetRecommendedPair(rswPairs);
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
         chartState = CHARTSTATUS.GetChartStatus(expectedPosition, Min_Ema_Poin);
         if(chartState != None)
            return true;
            
         return true;
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
         
         OrderModel order;         
         order.MagicNumber = Magic_Number;
         order.OrderComment = "Ema20";
         order.LotSize = Trade_Lot_Size;
         order.OrderSymbol = _Symbol;
         order.OrderType = rsw.RecommendPosition == Buy? ORDER_TYPE_BUY_LIMIT : ORDER_TYPE_SELL_LIMIT;
         
         order.Entry = rsw.RecommendPosition == Buy? HELPER.GetAskPrice(emas.Ema20) : emas.Ema20;
         
         order.TP = rsw.RecommendPosition == Buy? 
            order.Entry + HELPER.DiffPoints(emas.Ema20, emas.Ema50) * _Point : 
            order.Entry - HELPER.DiffPoints(emas.Ema50, emas.Ema20) * _Point;
         
         double dailyAtr = HELPER.GetDailyATR(_Symbol);
         order.SL = rsw.RecommendPosition == Buy?  
                     order.Entry - dailyAtr * SL_Daily_ATR_Percentage : 
                     order.Entry + dailyAtr * SL_Daily_ATR_Percentage;
         
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
         
         OrderModel order;
         order.MagicNumber = Magic_Number;
         order.OrderComment = "Ema50";
         order.LotSize = Trade_Lot_Size;
         order.OrderSymbol = _Symbol;
         order.OrderType = rsw.RecommendPosition == Buy? ORDER_TYPE_BUY_LIMIT : ORDER_TYPE_SELL_LIMIT;
         
         order.Entry = rsw.RecommendPosition == Buy? HELPER.GetAskPrice(emas.Ema50) : emas.Ema50;
         
         order.TP = rsw.RecommendPosition == Buy? 
            order.Entry + HELPER.DiffPoints(emas.Ema50, emas.Ema100) * _Point : 
            order.Entry - HELPER.DiffPoints(emas.Ema50, emas.Ema100) * _Point;
            
         double dailyAtr = HELPER.GetDailyATR(_Symbol);
         order.SL = rsw.RecommendPosition == Buy?  
                     order.Entry - dailyAtr * SL_Daily_ATR_Percentage : 
                     order.Entry + dailyAtr * SL_Daily_ATR_Percentage;
         
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
         
         OrderModel order;
         order.MagicNumber = Magic_Number;
         order.OrderComment = "Ema100";
         order.LotSize = Trade_Lot_Size;
         order.OrderSymbol = _Symbol;
         order.OrderType = rsw.RecommendPosition == Buy? ORDER_TYPE_BUY_LIMIT : ORDER_TYPE_SELL_LIMIT;
         
         order.Entry = rsw.RecommendPosition == Buy? HELPER.GetAskPrice(emas.Ema100) : emas.Ema100;
         
         order.TP = rsw.RecommendPosition == Buy? 
            order.Entry + HELPER.DiffPoints(emas.Ema100, emas.Ema200) * _Point : 
            order.Entry - HELPER.DiffPoints(emas.Ema100, emas.Ema200) * _Point;
            
         double dailyAtr = HELPER.GetDailyATR(_Symbol);
         order.SL = rsw.RecommendPosition == Buy?  
                     order.Entry - dailyAtr * SL_Daily_ATR_Percentage : 
                     order.Entry + dailyAtr * SL_Daily_ATR_Percentage;
         
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
         
         OrderModel order;         
         order.MagicNumber = Magic_Number;
         order.OrderComment = "Ema200";
         order.LotSize = Trade_Lot_Size;
         order.OrderSymbol = _Symbol;
         order.OrderType = rsw.RecommendPosition == Buy? ORDER_TYPE_BUY_LIMIT : ORDER_TYPE_SELL_LIMIT;
         
         order.Entry = rsw.RecommendPosition == Buy? HELPER.GetAskPrice(emas.Ema200) : emas.Ema200;
         
         order.TP = rsw.RecommendPosition == Buy? 
            order.Entry + HELPER.DiffPoints(emas.Ema50, emas.Ema200) * _Point : 
            order.Entry - HELPER.DiffPoints(emas.Ema50, emas.Ema200) * _Point;
            
         double dailyAtr = HELPER.GetDailyATR(_Symbol);
         order.SL = rsw.RecommendPosition == Buy?  
                     order.Entry - dailyAtr * SL_Daily_ATR_Percentage : 
                     order.Entry + dailyAtr * SL_Daily_ATR_Percentage;
         
         return HELPER.LimitOrder(order);
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