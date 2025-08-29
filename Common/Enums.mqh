
//+------------------------------------------------------------------+
//| Enums
//+------------------------------------------------------------------+
enum Enum_Position_Recomendation
{
   Buy,
   Sell,
   NotRecommend
};

string PositionRecommendationToString(Enum_Position_Recomendation position)
{
   string positions[] = {"BUY", "SELL", "N/A"};
   return positions[(int)position];
}