//+------------------------------------------------------------------+
//|                                                      b-clock.mq4 |
//|                                     Core time code by Nick Bilak |
//|        http://metatrader.50webs.com/         beluck[at]gmail.com |
//|                                  modified by adoleh2000 and dwt5 | 
//+------------------------------------------------------------------+

#property copyright "Copyright © 2005, Nick Bilak"
#property link      "http://metatrader.50webs.com/"

#property indicator_chart_window
extern color ClockColor = Black;

//---- buffers
double s1[];

//+------------------------------------------------------------------+
int deinit() {
   ObjectDelete("time");
return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init()

  {
   
  }
  
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {

	double i;
   int m,s,k;
   m=Time[0]+Period()*60-CurTime();
   i=m/60.0;
   s=m%60;
   m=(m-m%60)/60;
  Comment( m +" : "+ s );
	
	
   ObjectDelete("time");
   
   if(ObjectFind("time") != 0)
   {
   ObjectCreate("time", OBJ_TEXT, 0, Time[0], Close[0]+ 0.0005);
   ObjectSetText("time","                 "+m+":"+s, 12, "Arial", ClockColor);
   }
   else
   {
   ObjectMove("time", 0, Time[0], Close[0]+0.0005);
   }


   return(0);
  }
//+------------------------------------------------------------------+


