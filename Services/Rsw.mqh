#include "..\Models\RswPair.mqh"
#include "..\Models\RswCurrency.mqh"
#include "..\Common\Variables.mqh"
#include "..\Common\Helpers.mqh"
#include "..\Common\Enums.mqh"

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
      
      
      RswCurrency* GetCurrency(string currency)
      {
         int n = ArraySize(RswCurrencies);
         
         for(int i=0;i<n;i++)
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
         int n = ArraySize(RswCurrencies);
         for(int i=0; i<n; i++)
         {
            RswCurrencies[0].RswIndexValue = 0;
         }
      }
      
      
       //+--------------------------------------
       //| Calculate RSW
       //+--------------------------------------
      void ReCountRSW()
      {
          ResetIndexValue();
          FirstCount = false;
          
          for(int i=0;i<ArraySize(RswPairs);i++)
          {
               RswPair p = RswPairs[i];
               SymbolSelect(p.Pair, true); // Ensure the symbol exists in market watch
               
               Helpers helper = HELPER;
               double ema4 = helper.GetEmaPrice(p.Pair, 150);
               double price = helper.GetAskPrice(p.Pair);
               
               RswCurrency* leftCurrency = GetCurrency(p.LeftCurrency);
               RswCurrency* rightCurrency = GetCurrency(p.RightCurrency);
               
               if(leftCurrency == NULL || rightCurrency == NULL)
               {
                  Print("Ada yang Null ", p.Pair);
               }
               
               if(price > ema4)
               {
                  leftCurrency.AddIndex(1);
                  rightCurrency.AddIndex(-1);
               }else
               {
                  leftCurrency.AddIndex(-1);
                  rightCurrency.AddIndex(1);
               }
          }
          
          BubbleSort(RswCurrencies);
          
          SetRecommends();
          
          Print("Last Calculate Pair Ranking on Local Time : ", TimeToString(TimeLocal()));
      }
      
       //+------------------------------------------
       //| Reset Recommend Position for Each Pairs
       //| Base on Currency Ranking
       //+------------------------------------------
       void SetRecommends()
       {
         RswCurrency* strongCurrs[];
         RswCurrency* weakCurrs[];
         GetStrongeCurrencies(strongCurrs);
         GetWeakCurrencies(weakCurrs);
         
         int n = ArraySize(RswPairs);
         for(int i=0; i<n; i++)
         {
            RswPair* p = RswPairs[i];
            
            bool leftStrong = IsInTheList(strongCurrs, p.LeftCurrency);
            bool rightStrong = IsInTheList(strongCurrs, p.RightCurrency);
            
            bool leftWeak = IsInTheList(weakCurrs, p.LeftCurrency);
            bool rightWeak = IsInTheList(weakCurrs, p.RightCurrency);
            
            if(leftStrong && rightWeak)
               p.RecommendPosition = Buy;
            else if(rightStrong && leftWeak)
               p.RecommendPosition = Sell;
            else
               p.RecommendPosition = NotRecommend;
         }
       }
       
       bool IsInTheList(RswCurrency* &curs[], string cur)
       {
         for(int i=0; i<ArraySize(curs);i++)
         {
            if(curs[i].Currency == cur)
               return true;
         }
         return false;
       }
       
       
       //+--------------------------------------
       //| Short Currencies
       //+--------------------------------------
      void BubbleSort(RswCurrency* &arr[])
      {
         int n = ArraySize(arr);
         for(int i = 0; i < n - 1; i++)
         {
            for(int j = 0; j < n - i - 1; j++)
            {
               if(arr[j].RswIndexValue < arr[j+1].RswIndexValue) // descending
               {
                  RswCurrency* temp = arr[j];
                  arr[j] = arr[j+1];
                  arr[j+1] = temp;
               }
            }
         }
      }
      
      
      
      //+--------------------------------------
       //| Add Currency to Array
       //+--------------------------------------
      void AddCurrencyToArray(RswCurrency* &curs[], RswCurrency* curr)
      {
         int newIndex = ArraySize(curs);
         ArrayResize(curs, newIndex +1);
         curs[newIndex] = curr;
      }
      
         
   
   //+------------------------------------------------------------------+
   //| Public Methods
   //+------------------------------------------------------------------+
   public:
      
       //+--------------------------------------
       //| Constructor
       //+--------------------------------------
       
      Rsw()
      {
         if(Clear_Market_Watch_When_Init)
         {
            int total = SymbolsTotal(false);
            for(int i=total-1; i>=0; i--)
              SymbolSelect(SymbolName(i, false), false);
         }
               
         AddPairs();
         FirstCount = true;
         ReCountAfterSecond = 300;
         
         ReCountRSW();
      } 
      
      
       //+--------------------------------------
       //| Get Strong Currencies
       //+--------------------------------------
      void GetStrongeCurrencies(RswCurrency* &curs[])
      {
         int n = 3;
         for(int i=0; i<n; i++)
         {
             AddCurrencyToArray(curs, RswCurrencies[i]);
         }
      }
      
       //+--------------------------------------
       //| Get Weak Currencies
       //+--------------------------------------
      void GetWeakCurrencies(RswCurrency* &curs[])
      {
         int start = ArraySize(RswCurrencies) - 3;
         int n = ArraySize(RswCurrencies);
         
         for(int i=start; i<n; i++)
         {
            AddCurrencyToArray(curs, RswCurrencies[i]);
         }
      }
      
      
       //+--------------------------------------
       //| Get Recommended Pair
       //+--------------------------------------
       void GetRecommendedPair(RswPair* &pairs[])
       {
         ArrayFree(pairs);
         int n = ArraySize(RswPairs);
         for(int i=0; i<n; i++)
         {
            RswPair* p = RswPairs[i];
            
            //Print("Arr C : ", p.Pair, " ", p.RecommendPosition);
            
            if(RswPairs[i].RecommendPosition != NotRecommend)
            {
               int newIndex = ArraySize(pairs);
               ArrayResize(pairs, newIndex + 1);
               pairs[newIndex] = RswPairs[i];
            }
         }
       }

      
      //+--------------------------------------
      //| On Timer
      //+--------------------------------------
      void OnTimer()
      {  
         ReCountAfterSecond++;
         
         if(FirstCount || ReCountAfterSecond == 300)
         {
            ReCountRSW();
         }
         
         if(ReCountAfterSecond == 300)
            ReCountAfterSecond = 0;
      }
      
      
      //+--------------------------------------
       //| On Tick
       //+--------------------------------------
      void OnTick()
      {
      
      }
};      