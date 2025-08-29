class RswPair
{
   public:
      string LeftCurrency;
      string RightCurrency;
      string Pair;
      
      RswPair(string leftCurrency, string rightCurrency)
      {
         Pair = StringFormat("%s%s%s%s%s", Pair_Prefix, leftCurrency, Pair_Separator, rightCurrency, Pair_Suffix);
      }
};