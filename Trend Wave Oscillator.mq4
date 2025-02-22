//+------------------------------------------------------------------+
//|                                                       Trend Wave |
//|              Copyright 2011-2017, joker.com |
//|                        http://www.best-metatrader-indicators.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011-2017, joker.com"
#property link      "http://www.joker.com"
#property version   "2.02"
#property description "Risk Warning\nPlease note that forex trading entails substantial risk of loss, and may not\nbe suitable to everyone. Trading could lead to loss of your invested capital."

#property strict
#property indicator_buffers 8

#property indicator_separate_window
#property indicator_minimum               -80
#property indicator_maximum               80
#property indicator_levelcolor            clrBlack
#property indicator_levelstyle            2
#property indicator_color1                clrBlue
#property indicator_color2                clrRed
#property indicator_width1                1
#property indicator_level1                60.0
#property indicator_width2                1
#property indicator_level2                0
#property indicator_level3                0
#property indicator_level4                -60.0

//+------------------------------------------------------------------+
//| Externs                                                          |
//+------------------------------------------------------------------+
extern int        WavePeriod     = 10;       //Wave Period
extern int        AvgPeriod      = 21;       //Avg Period
extern bool       SoundAlert     = FALSE;    //Sound Alert
extern bool       EmailAlert     = FALSE;    //Sound Alert
//+------------------------------------------------------------------+
//| Buffers                                                          |
//+------------------------------------------------------------------+
double BullBuffer[];
double BearBuffer[];
double WaveMABuffer[];
double Buffer_4[];
double Buffer_5[];
double Buffer_6[];
double Buffer_7[];
double Buffer_8[];
//+------------------------------------------------------------------+
//| Variables                                                        |
//+------------------------------------------------------------------+
int BuyLevel      =  -50;
int SellLevel     =  53;
int LastSignalTime;
int gi_136 = 000000;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
   {
   IndicatorBuffers(8);
   IndicatorShortName("TrendWave");
   
   SetIndexBuffer(0, BullBuffer);
   SetIndexLabel(0, "Bull");
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 1, Blue);
   SetIndexDrawBegin(0, 0);
   SetIndexBuffer(1, BearBuffer);
   SetIndexLabel(1, "Bear");
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 1, Red);
   SetIndexDrawBegin(1, 0);
   
   
   
   SetIndexBuffer(2, WaveMABuffer);
   SetIndexLabel(2, "ESA");
   SetIndexStyle(2, DRAW_NONE);
   SetIndexDrawBegin(2, 0);
   SetIndexBuffer(3, Buffer_6);
   SetIndexLabel(3, "DD Values");
   SetIndexStyle(3, DRAW_NONE);
   SetIndexDrawBegin(3, 0);
   SetIndexBuffer(4, Buffer_4);
   SetIndexLabel(4, "DD");
   SetIndexStyle(4, DRAW_NONE);
   SetIndexDrawBegin(4, 0);
   SetIndexBuffer(5, Buffer_5);
   SetIndexLabel(5, "CI");
   SetIndexStyle(5, DRAW_NONE);
   SetIndexDrawBegin(5, 0);

   SetIndexBuffer(6, Buffer_7);
   SetIndexLabel(6, "Buy Dot");
   SetIndexStyle(6, DRAW_ARROW, STYLE_SOLID, 1, Aqua);
   SetIndexArrow(6, 108);
   SetIndexDrawBegin(6, 0);
   SetIndexBuffer(7, Buffer_8);
   SetIndexLabel(7, "Sell Dot");
   SetIndexStyle(7, DRAW_ARROW, STYLE_SOLID, 1, Yellow);
   SetIndexArrow(7, 108);
   SetIndexDrawBegin(7, 0);
   ArrayResize(WaveMABuffer, Bars);
   ArrayResize(Buffer_6, Bars);
   ArrayResize(Buffer_4, Bars);
   ArrayResize(Buffer_5, Bars);
   ArrayResize(BullBuffer, Bars);
   ArrayResize(BearBuffer, Bars);
   ArrayResize(Buffer_7, Bars);
   ArrayResize(Buffer_8, Bars);
   return (0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {

   double tempArr;
   int i;
   int counted = IndicatorCounted();
   if (counted < 0) return (-1);
   if (counted > 0) counted--;
   int limit = Bars - counted-1; //avil -1
   for (i = limit; i > 0; i--) {
      WaveMABuffer[i] = iMA(NULL, 0, WavePeriod, 0, MODE_EMA, PRICE_TYPICAL, i);
      ArraySetAsSeries(WaveMABuffer, TRUE);
   }
   for (i = limit; i > 0; i--) {
      Buffer_6[i] = MathAbs((iHigh(NULL, 0, i) + iClose(NULL, 0, i) + iLow(NULL, 0, i)) / 3.0 - WaveMABuffer[i]);
      ArraySetAsSeries(Buffer_6, TRUE);
   }
   for (i = limit; i > 0; i--) {
      tempArr = iMAOnArray(Buffer_6, 0, WavePeriod, 0, MODE_EMA, i);
      Buffer_4[i] = tempArr;
      ArraySetAsSeries(Buffer_4, TRUE);
   }
   for (i = limit; i > 0; i--) {
      if (Buffer_4[i] > 0.0) Buffer_5[i] = ((iHigh(NULL, 0, i) + iClose(NULL, 0, i) + iLow(NULL, 0, i)) / 3.0 - WaveMABuffer[i]) / (0.015 * Buffer_4[i]);
      else Buffer_5[i] = 0;
      ArraySetAsSeries(Buffer_5, TRUE);
   }
   for (i = limit; i > 0; i--) {
      tempArr = iMAOnArray(Buffer_5, 0, AvgPeriod, 0, MODE_EMA, i);
      BullBuffer[i] = tempArr;
      ArraySetAsSeries(BullBuffer, TRUE);
   }
   for (i = limit; i > 0; i--) {
      tempArr = iMAOnArray(BullBuffer, 0, 4, 0, MODE_SMA, i);
      BearBuffer[i] = tempArr;
      ArraySetAsSeries(BearBuffer, TRUE);
   }
    
//---- Signals
   for (i = limit-1; i > 0; i--) {
//--- Buy Signal    
      if (BullBuffer[i] >= BearBuffer[i] && BullBuffer[i + 1] <= BearBuffer[i + 1] && BullBuffer[i] < BuyLevel) {
         Buffer_7[i] = BullBuffer[i];
         SendAlert("buy");
      } else Buffer_7[i] = -1000;
      
//--- Sell Signal 
      if (BullBuffer[i] <= BearBuffer[i] && BullBuffer[i + 1] >= BearBuffer[i + 1] && BullBuffer[i] > SellLevel) {
         Buffer_8[i] = BearBuffer[i];
         SendAlert("sell");
      } else Buffer_8[i] = -1000;
   }
   return (0);
}

//+------------------------------------------------------------------+
//| SendAlert function                                               |
//+------------------------------------------------------------------+
void SendAlert(string SignalType) {
   if (Time[0] != LastSignalTime) {
      if (SoundAlert) {
         if (SignalType == "buy") Alert(Symbol() + " => " + TimeToStr(TimeCurrent()) + " buy");
         if (SignalType == "sell") Alert(Symbol() + " => " + TimeToStr(TimeCurrent()) + " sell");
      }
      if (EmailAlert) {
         if (SignalType == "buy") SendMail("TrendWave Alert", Symbol() + " => " + TimeToStr(TimeCurrent()) + " buy");
         if (SignalType == "sell") SendMail("TrendWave Alert", Symbol() + " => " + TimeToStr(TimeCurrent()) + " sell");
      }
      LastSignalTime = (int)Time[0];
   }
}