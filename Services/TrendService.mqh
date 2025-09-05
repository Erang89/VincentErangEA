#include  "..\Models\RswCurrency.mqh"
#include  "..\Models\RswPair.mqh"
#include  "..\Models\Emas.mqh"

#include  "..\Common\Helpers.mqh"
#include  "..\Common\Variables.mqh"

class TrendService
{
   private:
      Emas* createdEmas[];
      
      Emas* GetEmas(Emas* &emas[], string pair)
      {
         int n = ArraySize(emas);
         for(int i=0; i<n; i++)
         {
            if(pair == emas[i].Pair)
            {
               return emas[i];
            }
         } 
         
         Emas* newEma = new Emas();
         newEma.Pair = pair;
         int newIndex = ArraySize(emas);
         ArrayResize(emas, newIndex + 1);
         emas[newIndex] = newEma;         
         
         newIndex = ArraySize(createdEmas);
         ArrayResize(createdEmas, newIndex + 1);
         createdEmas[newIndex] = newEma;
         
         return newEma;
      }
         
   //+--------------------------------------
   //| PUBLIC FUNCTIONS
   //+-------------------------------------- 
   public:
   
      //+--------------------------------------
      //| Chek if Pair can be traded (Valid Trend)
      //+--------------------------------------
       bool IsValidTrend(RswPair* &pair, Emas* &ema)
       {
         static Emas* emas[];
         static bool hasInitCheck;
         ema = GetEmas(emas, pair.Pair);
         
         if(!hasInitCheck || ema.LastTimeCheck != iTime(pair.Pair, TradingTimeFrame, 1))
         {
            Helpers helper = HELPER;
            hasInitCheck = true;
            ema.LastTimeCheck = iTime(pair.Pair, TradingTimeFrame, 1);            
            ema.Ema20 = helper.GetEmaPrice(pair.Pair, 20, TradingTimeFrame);
            ema.Ema50 = helper.GetEmaPrice(pair.Pair, 50, TradingTimeFrame);
            ema.Ema100 = helper.GetEmaPrice(pair.Pair, 100, TradingTimeFrame);
            ema.Ema200 = helper.GetEmaPrice(pair.Pair, 200, TradingTimeFrame);
         }
         
         return   (pair.RecommendPosition == Buy && ema.Ema20 > ema.Ema50 && ema.Ema50 > ema.Ema100 && ema.Ema100 > ema.Ema200) || 
                  (pair.RecommendPosition == Sell && ema.Ema20 < ema.Ema50 && ema.Ema50 < ema.Ema100 && ema.Ema100 < ema.Ema200);
       }
       
       
       void Release()
       {
         for(int i=0; i< ArraySize(createdEmas);i++)
         {
            delete createdEmas[i];
            createdEmas[i] = NULL;
         }
         ArrayResize(createdEmas, 0);
       }
       
      //+--------------------------------------
      //| On Timer
      //+--------------------------------------
      void OnTimer()
      {  
         
      }
      
      
      //+--------------------------------------
      //| On Tick
      //+--------------------------------------
      void OnTick()
      {
      
      }
   

};