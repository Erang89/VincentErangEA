#include "..\Common\Enums.mqh"

class RswPair
{
   public:
      string LeftCurrency;
      string RightCurrency;
      string Pair;
      Enum_Position_Recomendation RecommendPosition;
      
      RswPair(string leftCurrency, string rightCurrency)
      {
         this.LeftCurrency = leftCurrency;
         this.RightCurrency = rightCurrency;
         this.Pair = StringFormat("%s%s%s%s%s", Pair_Prefix, leftCurrency, Pair_Separator, rightCurrency, Pair_Suffix);
      }
};