#include  "..\Models\OCHL.mqh"
#include  "..\Common\Helpers.mqh"

class ChartStatus
  {
   private:
      bool LoadChartStatus(Enum_Position_Recomendation expectedPosition)
      {
         static bool loaded;
         static datetime lastClosedCandleTime;
         static OCHL* ochls[];
         static double startPrice;
         static double priceFlags[];
         static double flags[];
         static double open[], close[], high[], low[];
         static bool isBussy;
         
         if(isBussy)
            return false;
         
         if(!loaded)
         {
            loaded = true;
            
            string lastStatus = "Start";
            double hightstPrice = 0.0;
            double lowestPrice = 0.0;
            int n = iBars(_Symbol, TradingTimeFrame);
            n = n > 210? 210 :n;
            
            CopyOpen(_Symbol, TradingTimeFrame, 0, n, open);
            CopyClose(_Symbol, TradingTimeFrame, 0, n, close);
            CopyHigh(_Symbol, TradingTimeFrame, 0, n, high);
            CopyLow(_Symbol, TradingTimeFrame, 0, n, low);
            
            for(int i=0; i<n;i++)
            {
                int newIndex = ArraySize(ochls);
                ArrayResize(ochls, newIndex+1);
                OCHL* ochl = new OCHL;
                Emas* ema = new Emas;
                Helpers* helper = HELPER;
                
                int shift = i+1;
                ema.Ema20 = helper.GetEmaPrice(_Symbol, 20, TradingTimeFrame, shift);
                ema.Ema50 = helper.GetEmaPrice(_Symbol, 50, TradingTimeFrame, shift);
                ema.Ema100 = helper.GetEmaPrice(_Symbol, 100, TradingTimeFrame, shift);
                ema.Ema200 = helper.GetEmaPrice(_Symbol, 200, TradingTimeFrame, shift);
                
                ochl.Open = open[i];
                ochl.Close = close[i];
                ochl.High = high[i];
                ochl.Low = low[i];
                
                ochl.Emas = ema;
                ochl.Expected = ema.GetRecommendPosition() == expectedPosition;
                if(!ochl.Expected)
                  break;
                  
                ochls[newIndex] = ochl; 
            }
         }
         
         
         
         if(lastClosedCandleTime != iTime(_Symbol, TradingTimeFrame, 1))
         {
            lastClosedCandleTime = iTime(_Symbol, TradingTimeFrame, 1);
         }
         
         return true;
         
      }
   
      public:
        
  };