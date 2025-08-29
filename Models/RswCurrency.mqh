class RswCurrency
{
   public:
      string Currency;
      int RswIndexValue;
      
      RswCurrency(string currency)
      {
         this.Currency = currency;
      }
      
      void AddIndex(int value)
      {
         this.RswIndexValue = this.RswIndexValue + value;
      }
};