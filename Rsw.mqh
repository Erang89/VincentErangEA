#include "RswPair.mqh"
#include "RswCurrency.mqh"
#include "Helpers.mqh"
#include "Variables.mqh"

class Rsw
{
   //+------------------------------------------------------------------+
   //| Private Methods
   //+------------------------------------------------------------------+
   private:
      RswCurrency* RswCurrencies[]; 
      RswPair* RswPairs[];
      bool FirstCount;
      int ReCountAfterSecond;
      
      void AddPairs()
      {
         AddPair("AUD", "CAD");
         AddPair("AUD", "CHF");
         AddPair("AUD", "JPY");
         AddPair("AUD", "NZD");
         AddPair("AUD", "USD");      
         AddPair("CAD", "CHF");
         AddPair("CAD", "JPY");      
         AddPair("CHF", "JPY");      
         AddPair("EUR", "AUD");
         AddPair("EUR", "CAD");
         AddPair("EUR", "CHF");
         AddPair("EUR", "GBP");
         AddPair("EUR", "JPY");
         AddPair("EUR", "NZD");
         AddPair("EUR", "USD");      
         AddPair("GBP", "AUD");
         AddPair("GBP", "CAD");
         AddPair("GBP", "CHF");
         AddPair("GBP", "JPY");
         AddPair("GBP", "NZD");
         AddPair("GBP", "USD");      
         AddPair("NZD", "CAD");
         AddPair("NZD", "CHF");
         AddPair("NZD", "JPY");
         AddPair("NZD", "USD");      
         AddPair("USD", "CAD");
         AddPair("USD", "CHF");
         AddPair("USD", "JPY");
         
         AddCurrency("AUD");
         AddCurrency("CAD");
         AddCurrency("CHF");
         AddCurrency("EUR");
         AddCurrency("GBP");
         AddCurrency("JPY");
         AddCurrency("NZD");
         AddCurrency("USD");
      }
      
      
      void AddPair(string leftCurrency, string rightCurrency)
      {
         int index = ArraySize(RswPairs);
         ArrayResize(RswPairs, index+1);
         RswPairs[index] = new RswPair(leftCurrency, rightCurrency); 
      }
      
      void AddCurrency(string currency)
      {
         int index = ArraySize(RswCurrencies);
         ArrayResize(RswCurrencies, index+1);
         RswCurrencies[index] = new RswCurrency(currency); 
      }
      
      RswCurrency* GetFirstTopPair(int highst)
      {
         RswCurrency* result; 
         for(int i=0; i<ArraySize(RswCurrencies);i++)
         {
           if(result == NULL) RswCurrencies[i];
           
           if(RswCurrencies[i].RswIndexValue >  result.RswIndexValue && RswCurrencies[i].RswIndexValue < highst)
               result = RswCurrencies[i];
         }
         
         return result;
      }
      
      
      RswCurrency* GetFirstWeakPair(int highst)
      {
         RswCurrency* result; 
         for(int i=0; i<ArraySize(RswCurrencies);i++)
         {
           if(result == NULL) RswCurrencies[i];
           
           if(RswCurrencies[i].RswIndexValue <  result.RswIndexValue && RswCurrencies[i].RswIndexValue > highst)
               result = RswCurrencies[i];
         }
         
         return result;
      }
      
      RswCurrency* GetCurrency(string currency)
      {
         for(int i=0;i<ArraySize(RswCurrencies);i++)
         {
            if(currency == RswCurrencies[i].Currency)
            {
               return RswCurrencies[i];
            }               
         }
         
         return NULL;
      }
      
      void ResetIndexValue()
      {
         for(int i=0;i<ArraySize(RswCurrencies);i++)
         {
            RswCurrencies[0].RswIndexValue = 0;
         }
      }
      
      
      
      void ReCountIndex()
      {
          ResetIndexValue();
          FirstCount = false;
          Print("RSW Start Counting: ", ArraySize(RswPairs));
          
          for(int i=0;i<ArraySize(RswPairs);i++)
          {
               RswPair* p = RswPairs[i];
               double ema4 = HELPER.GetEmaPrice(p.Pair);
               double price = HELPER.GetAskPrice(p.Pair);
               
               RswCurrency* leftCurrency = GetCurrency(p.LeftCurrency);
               RswCurrency* rightCurrency = GetCurrency(p.RightCurrency);
               
               if(leftCurrency == NULL || rightCurrency == NULL)
               {
                  Print("Ada yang Null ", p.Pair);
               }
               /*
               if(price > ema4)
               {
                  leftCurrency.AddIndex(1);
                  rightCurrency.AddIndex(-1);
               }else
               {
                  leftCurrency.AddIndex(-1);
                  rightCurrency.AddIndex(1);
               }*/
          }
      }
   
   
   
   //+------------------------------------------------------------------+
   //| Public Methods
   //+------------------------------------------------------------------+
   public:
          
      Rsw()
      {
         AddPairs();
         FirstCount = true;
         ReCountAfterSecond = 300;
      } 
      
      
      void GetTheStrongestCurrencies(RswCurrency &curs[])
      {
         ArrayFree(curs);
         curs[0] = GetFirstTopPair(100);
         curs[1] = GetFirstTopPair(curs[0].RswIndexValue);
         curs[2] = GetFirstTopPair(curs[1].RswIndexValue);
      }
      
      
      void GetTheWeakCurrencies(RswCurrency &curs[])
      {
         ArrayFree(curs);
         curs[0] = GetFirstWeakPair(-100);
         curs[1] = GetFirstWeakPair(curs[0].RswIndexValue);
         curs[2] = GetFirstWeakPair(curs[1].RswIndexValue);
      }

      
      
      void OnTimer()
      {
         Print("Rsw Timer");
         
         ReCountAfterSecond++;
         
         if(FirstCount || ReCountAfterSecond == 300)
         {
            ReCountIndex();
         }
         
         if(ReCountAfterSecond == 300)
            ReCountAfterSecond = 0;
      }
      
      void OnTick()
      {
      
      }
};      