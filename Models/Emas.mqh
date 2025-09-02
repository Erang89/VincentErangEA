class Emas
{
   public:
      double Ema20;
      double Ema50;
      double Ema100;
      double Ema200;
      string Pair;
      datetime LastTimeCheck;
      
      Enum_Position_Recomendation GetRecommendPosition()
      {
         return 
            Ema20 > Ema50 && Ema50 > Ema100 && Ema100 > Ema200 ? Buy :
            Ema20 < Ema50 && Ema50 < Ema100 && Ema100 < Ema200 ? Sell :
            NotRecommend;
      }
};