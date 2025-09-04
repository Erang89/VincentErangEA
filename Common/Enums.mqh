
//+------------------------------------------------------------------+
//| Enums
//+------------------------------------------------------------------+
enum Enum_Position_Recomendation
{
   Buy,
   Sell,
   NotRecommend
};


enum Enum_PriceCodingState
  {
      Trading,
      JustMakeNewHigh,
      JustMakeNewLow,
      WaitForMakeNewHigh,
      WaitForMakeNewLow,
      PendigOrderOnEma20,
      PendigOrderOnEma50,
      PendigOrderOnEma100,
      PendigOrderOnEma200,
      None
  };

string PositionRecommendationToString(Enum_Position_Recomendation position)
{
   string positions[] = {"BUY", "SELL", "N/A"};
   return positions[(int)position];
}

string PriceCodingStateToString(Enum_PriceCodingState state)
{
   string states[] = {
      "Trading",
      "JustMakeNewHigh",
      "JustMakeNewLow",
      "WaitForMakeNewHigh",
      "WaitForMakeNewLow",
      "PendigOrderOnEma20",
      "PendigOrderOnEma50",
      "PendigOrderOnEma100",
      "PendigOrderOnEma200",
      "None"
  };
  
  return states[(int)state];
}