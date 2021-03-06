//             P L E A S E   -   D O    N O T    D E L E T E    A N Y T H I N G ! ! ! 
// -------------------------------------------------------------------------------------------------
//                                   EA_MindStorms v1.01 
//
//                       				  	  by Rodolfo
//                             rodolfo.leonardo@gmail.com
//
//--------------------------------------------------------------------------------------------------
//   THIS EA IS 100 % FREE OPENSOURCE, WHICH MEANS THAT IT'S NOT A COMMERCIAL PRODUCT
// -------------------------------------------------------------------------------------------------


#property copyright " EA_MindStorms_v1.01"
#property link "rodolfo.leonardo@gmail.com"
#property version "1.01"
#property description "EA_MindStorms_v1"
#property description "This EA is 100% FREE "
#property description "Coder: rodolfo.leonardo@gmail.com "
#property strict



extern string Version__ = "-----------------------------------------------------------------";
extern string vg_versao = "            EA_MindStorms_v1 2018-03-04  DEVELOPER EDITION             ";
extern string Version____ = "-----------------------------------------------------------------";

#include "SDK/EAframework.mqh"
#include "SDK/TrailingStop.mqh"

#include "Engines/macx.mqh"
#include "Engines/macx2.mqh"
#include "Engines/xbest.mqh"

#include "Sinal/SinalMA.mqh"
#include "Sinal/SinalBB.mqh"
#include "Sinal/SinalRSI.mqh"
//#include "Sinal/SinalNONLANG.mqh"

#include "Filter/FFCallNews.mqh"
#include "Filter/FilterTime.mqh"
#include "Filter/FilterVolatility.mqh"
#include "Filter/FilterStopOut.mqh"

double vg_Spread = 0;
string vg_filters_on = "";
string vg_initpainel = false;
//+------------------------------------------------------------------+
//|  input parameters                                                |
//+------------------------------------------------------------------+

extern string Filter_Spread__ = "----------------------------Filter Max Spread----------------";
input int InpMaxvg_Spread = 24; // Max Spread



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    DrawLABEL("cm L","XBEST",95,30,clrBlack,ANCHOR_CENTER);
   RectLabelCreate(0,"cm F"    ,0,229,19 ,220,225);
    ButtonCreate(0,"cm Buy Stop"     ,0,225,40,100,20,"Buy Stop","Arial",8,clrBlack,clrLightGray,clrLightGray,clrNONE,1);
   ButtonCreate(0,"cm Sell Stop"    ,0,225,62,100,20,"Sell Stop","Arial",8,clrBlack,clrLightGray,clrLightGray,clrNONE,1);

    vg_Spread = MarketInfo(Symbol(), MODE_SPREAD) * Point;

    vg_filters_on = "";
    vg_initpainel = true;
 
    printf(vg_versao + " - INIT");

    XBEST_OnInit();

    return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{

    PainelUPER(vg_versao);
    RefreshRates();

    //FILTER SPREAD
    if (vg_Spread > InpMaxvg_Spread)
    {
        vg_filters_on += "Filter InpMaxvg_Spread ON \n";
        return;
    }

    //FILTER NEWS
    if (InpUseFFCall)
    {
        NewsHandling();

        if (vg_news_time)
        {
            vg_filters_on += "Filter News ON \n";
            return;
        }
    }

    //FILTER DATETIME
   if (TimeFilter())
    {
        vg_filters_on += "Filter TimeFilter ON \n";

        return;
    }


    
    if(FilterStopOut(MACH_CurrentPairProfit,MACH_MagicNumber)
     || FilterStopOut(MACH2_CurrentPairProfit,MACH2_MagicNumber)
    ) return;
   
    int Sinal = (GetSinalMA() + GetSinalBB() + GetSinalRSI()) / ( DivSinalMA() + DivSinalBB()+ DivSinalRSI() ) ;


 
     MACHx(Sinal, false, 0.01);

     

     XBEST_OnTick(Sinal);

    // SE TrailingStop  ENABLE
    if (InpUseTrailingStop)
        TrailingAlls(InpTrailStart, InpTrailStep, XBEST_m_mediaprice1, XBEST_Magic);
  

    // SE TrailingStop  ENABLE
    if (InpUseTrailingStop)
        TrailingAlls(InpTrailStart, InpTrailStep, MACH_AveragePrice, MACH_MagicNumber);
    if (InpUseTrailingStop)
        TrailingAlls(InpTrailStart, InpTrailStep, MACH2_AveragePrice, MACH2_MagicNumber);

        
  

}