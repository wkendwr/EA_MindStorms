//+-----------------------------------------------------------------+
//|                                               SOL4LIVE_EA_V2.mq4 |
//|                                      rodolfo.leonardo@gmail.com. |
//+------------------------------------------------------------------+
#property copyright "SOL4LIVE_EA_V15"
#property link "http://goo.gl/9FoC8c"
#property version "1.45"
#property description "SOL4LIVE_EA_V1  "
#property description "This EA is 100% FREE "
#property description "Coder: rodolfo.leonardo@gmail.com "

#property description "Donation Link : http://goo.gl/9FoC8c"
#property strict

string vg_versao = " SOL4LIVE_EA_V2 2018-03-03 ";

//+------------------------------------------------------------------+
//|           ENUM                                   |
//+------------------------------------------------------------------+
enum ENUM_LOT_MODE
{
    LOT_MODE_FIXED = 1,     // Fixed Lot
    LOT_MODE_PERCENT = 2,   // Percent Lot
    LOT_MODE_EQUITY = 3,    // Equity Lot
    LOT_MODE_DECREMENT = 4, // Decrement Lot InpMaxLot - InpDiminuir
};

enum ENUM_SINAL_MODE
{
    SINAL_RSI = 1,    // RSI
    SINAL_MM = 2,     // Media Movel
    SINAL_MM_RSI = 3, // RSI + Media Movel
    SINAL_MM_BB = 4,  // BB + Media Movel
};

//+------------------------------------------------------------------+
//|  input parameters                                                |
//+------------------------------------------------------------------+

extern string Version__ = "-----------------------------------------------------------------";
extern string Version___ = "----------------- SOL4LIVE v2  -----------------------------------";
extern string Version____ = "-----------------------------------------------------------------";

extern string InpChartDisplay__ = "------------------------Display Info-----------------------------";
extern bool InpChartDisplay = FALSE;             // Display Info
extern bool InpDisplayInpBackgroundColor = TRUE; // Display background color
extern color InpBackgroundColor = MediumBlue;    // background color

extern string MagicNUMBER = "---------------------Magic Number Engine-------------------------";

string EAName1 = "SOL4LIVE 1";
extern int InpMagicNumber1 = 9898844; // Magic SOL4LIVE
extern string Config__ = "---------------------------Config------------------------------";
extern ENUM_LOT_MODE InpLotsMode = LOT_MODE_EQUITY; //Lots Mode
extern double InpLots = 0.01;                       //Lots if LOT_MODE_FIXED
extern int InpEquityPerLot = 15000;                 //Equity per lot if LOT_MODE_EQUITY
input double InpPercentLot = 0.02;                  //Equity per lot if LOT_MODE_PERCENT
extern int InpLotdecimal = 2;                       //Lotdecimal
extern double InpStoploss = 0.0;                  //InpStoploss
extern double InpTakeProfit = 0.0;                //InpTakeProfit
extern double IndivStoploss = 500.0;                  //Individual Order SL
extern double IndivTakeProfit = 500.0;                //Individual Order TP
extern double InpSlip = 3.0;                        //Slip
input double InpMaxLot = 3;                         // Max Lot to decrement
extern double InpDiminuir = 0.1;                    // decrement lot
extern int InpMaxTrades = 14;                       // Max Lot Open Simultaneo

input ENUM_TIMEFRAMES InpTimeframeBarOpen = PERIOD_H1; // Timeframe OpenOneCandle

extern string TrailingStop__ = "-------------------------Trailling Stop-------------------------";
extern bool InpUseTrailingStop = TRUE; // Use Trailling Stop´?
extern double InpTrailStart = 17.0;    // TraillingStart
extern double InpTrailStop = 29.0;     // Size Trailling stop
extern string _BB1_ = "-----------------------------Bollinger Bands--------------------";
input ENUM_TIMEFRAMES InpBBFrame = PERIOD_M5; // Bollinger Bands TimeFrame
input int InpperiodBB = 10;                   //averaging period
input int InpdeviationBB = 2;                 // standard deviations
input int Inpbands_shiftBB = 0;               // bands shift
extern int InppriceBBUP = PRICE_CLOSE;        //price BB UP
extern int InppriceBBDN = PRICE_CLOSE;        //price BB DOWN
input int InpCheckBarsBB = 10;                //Check Bars BB

extern string SINAL__ = "------------------------- SINAL NONLANG-------------------------";
input ENUM_TIMEFRAMES InpNLFrame = PERIOD_H1; // Moving Average TimeFrame
extern int Price = 0;                         //Apply to Price(0-Close;1-Open;2-High;3-Low;4-Median price;5-Typical price;6-Weighted Close)
extern int Length = 4;                        //Period of NonLagMA
extern int Displace = 0;                      //DispLace or Shift
extern double PctFilter = 0;                  //Dynamic filter in decimal
extern int Color = 1;                         //Switch of Color mode (1-color)
extern int ColorBarBack = 1;                  //Bar back for color mode
extern double Deviation = 0;                  //Up/down deviation
extern int AlertMode = 1;                     //Sound Alert switch (0-off,1-on)
extern int WarningMode = 1;                   //Sound Warning switch(0-off,1-on)

extern string TimeFilter__ = "-------------------------Filter DateTime--------------------------";
extern bool InpUtilizeTimeFilter = true;
extern bool InpTrade_in_Monday = true;
extern bool InpTrade_in_Tuesday = true;
extern bool InpTrade_in_Wednesday = true;
extern bool InpTrade_in_Thursday = true;
extern bool InpTrade_in_Friday = true;
extern string InpStartHour = "00:00";
extern string InpEndHour = "23:59";
extern int Start_Monday_Minuts = 5;
extern string Stop_Time_Friday = "18:00";
extern string Close_Time_Friday = "";

int SinalNonLagMA = 0;

//+------------------------------------------------------------------+
//|  VARIAVEIS                                   |
//+------------------------------------------------------------------+

//VAR MACH1
double PriceTarget1, StartEquity1, BuyTarget1, SellTarget1;
double SellStop, BuyStop;
double AveragePrice1, SellLimit1, BuyLimit1, v_sumLots1;
double CurrentPairProfit1;
double LastBuyPrice1, LastSellPrice1, Stopper1 = 0.0, iLots1, l1, ordprof1;
int NumOfTrades1 = 0, v_qtdOrdensOpen1, ticket1, timeprev1 = 0, expiration1, m_orders_count1;
bool TradeNow1 = FALSE, LongTrade1 = FALSE, ShortTrade1 = FALSE, flag1, NewOrdersPlaced1 = FALSE;
datetime m_time_equityrisk1, m_datetime_ultcandleopen1, recovery1;
bool equityrisk1, inrecovery1;

//VARIAVEIS GLOBAIS MACH
double vg_AccountEquityHighAmt, vg_PrevEquity, vg_Spread, vg_profit_all;
bool vg_news_time, vg_initpainel;
int vg_cnt = 0;
int vg_GridSize = 0;
string vg_filters_on;
datetime vg_time_equityriskstopall, vg_DailyTargetday;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    vg_Spread = MarketInfo(Symbol(), MODE_SPREAD) * Point;

    vg_filters_on = "";
    vg_initpainel = true;
    m_datetime_ultcandleopen1 = -1;

    printf(vg_versao + " - Grid Hedging Expert Advisor");

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
    Painel2("A");

    double account_balance, margin_required, risk_balance;

    vg_Spread = MarketInfo(Symbol(), MODE_SPREAD) * Point;

    RefreshRates();

    vg_filters_on = "";



        //FILTER DATETIME
        if (InpUtilizeTimeFilter && !TimeFilter())
    {
        vg_filters_on += "Filter TimeFilter ON \n";
    }

    if (Start_Monday_Minuts > 0)
        if (DayOfWeek() == 1 && TimeCurrent() - iTime(NULL, 1440, 0) < Start_Monday_Minuts * 60)
        {
            vg_filters_on += "Filter StartMondayMinuts  ON \n";

            return;
        }

    if (DayOfWeek() == 5)
    {

        if (Stop_Time_Friday != "")
            if (TimeCurrent() >= StrToTime(Stop_Time_Friday))
            {
                if (!LongTrade1 && !ShortTrade1)
                {
                    vg_filters_on += "Filter StopTime Friday ON \n";
                    Sleep(3000);
                    return;
                }
            }

        if (Close_Time_Friday != "" && LongTrade1 && ShortTrade1 && TimeCurrent() >= StrToTime(Close_Time_Friday))
        {
            CloseThisSymbolAll(InpMagicNumber1);
            return;
        }
    }

    double vLots = InpLots;

    if (!ShortTrade1 && !LongTrade1)
        vLots = InpMaxLot;
    else
        vLots = FindLastLot(InpMagicNumber1);

    //SINAL

    int Sinal = 0;
    double PrevCl = iClose(Symbol(), 0, 2);
    double CurrCl = iClose(Symbol(), 0, 1);

    SinalNonLagMA =
        (int)iCustom(NULL, InpNLFrame, "NonLagMA_v7.1", Price, Length, Displace, PctFilter,
                     Color, ColorBarBack, Deviation, AlertMode, WarningMode, 3, 1);

    int SinalBB = GetBB(1, InpperiodBB, InpdeviationBB, Inpbands_shiftBB, InppriceBBUP, InppriceBBDN, InpCheckBarsBB);

    if (SinalNonLagMA < 0 && SinalBB < 0)
    {

        Sinal = -1;
        if (LongTrade1)
            CloseThisSymbolAll(InpMagicNumber1);
    }

    if (SinalNonLagMA > 0 && SinalBB > 0)
    {
        Sinal = 1;

        if (ShortTrade1)
            CloseThisSymbolAll(InpMagicNumber1);
    }

    //if (PrevCl > CurrCl && iRSI(NULL, InpRsiFrame, InpperiodRSI, InppriceRSI, 1) > InpRsiMinimum) SinalRSI = 1;
    //if (PrevCl < CurrCl && iRSI(NULL, InpRsiFrame, InpperiodRSI, InppriceRSI, 1) < InpRsiMaximum) SinalRSI =  -1;

    SOL4LIVEx(EAName1, InpMagicNumber1, Sinal, recovery1, inrecovery1, equityrisk1, PriceTarget1, StartEquity1, BuyTarget1, SellTarget1,
              AveragePrice1, SellLimit1, BuyLimit1,
              LastBuyPrice1, LastSellPrice1, Stopper1, iLots1, l1, ordprof1,
              NumOfTrades1, v_qtdOrdensOpen1, ticket1, timeprev1, expiration1,
              TradeNow1, LongTrade1, ShortTrade1, flag1, NewOrdersPlaced1, m_time_equityrisk1,
              m_datetime_ultcandleopen1, v_sumLots1, vLots, CurrentPairProfit1);

    // SE ChartDisplay  ENABLE
    if (InpChartDisplay)
        Informacoes();
}

//+------------------------------------------------------------------+
//|           EA MACH x                                              |
//+------------------------------------------------------------------+
void SOL4LIVEx(string ID, int MagicNumber, int vSinal, datetime &recovery, bool &inrecovery, bool &equityrisk, double &PriceTarget, double &StartEquity, double &BuyTarget, double &SellTarget,
               double &AveragePrice, double &SellLimit, double &BuyLimit,
               double &LastBuyPrice, double &LastSellPrice, double &Stopper, double &iLots, double &l, double &ordprof,
               int &NumOfTrades, int &v_totalOrdensOpen, int &ticket, int &timeprev, int &expiration,
               bool &TradeNow, bool &LongTrade, bool &ShortTrade, bool &flag, bool &NewOrdersPlaced,
               datetime &m_time_equityrisk, datetime &vDatetimeUltCandleOpen, double &v_sumLots, double &Lots, double &CurrentPairProfit)
{

    color avgLine = Blue;
    if (ShortTrade)
        avgLine = Red;

    if (LongTrade || ShortTrade)
        SetHLine(avgLine, "Avg" + ID, AveragePrice, 0, 3);
    else
        ObjectDelete("Avg" + ID);

    //NORMALIZA LOT
    if (Lots < MarketInfo(Symbol(), 23))
        Lots = MarketInfo(Symbol(), 23);
    if (Lots > MarketInfo(Symbol(), 25))
        Lots = MarketInfo(Symbol(), 25);

    // SE TrailingStop  ENABLE
    if (InpUseTrailingStop)
        TrailingAlls(InpTrailStart, InpTrailStop, AveragePrice, MagicNumber);

    CurrentPairProfit = CalculateProfit(MagicNumber);

    //VERIFICA SE POSSUI TRADER ATIVO
    v_totalOrdensOpen = CountTrades(MagicNumber);
    if (v_totalOrdensOpen == 0)
        flag = FALSE;
    for (vg_cnt = OrdersTotal() - 1; vg_cnt >= 0; vg_cnt--)
    {
        OrderSelect(vg_cnt, SELECT_BY_POS, MODE_TRADES);
        if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber)
            continue;
        if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        {
            if (OrderType() == OP_BUY)
            {
                LongTrade = TRUE;
                ShortTrade = FALSE;
                break;
            }
        }
        if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        {
            if (OrderType() == OP_SELL)
            {
                LongTrade = FALSE;
                ShortTrade = TRUE;
                break;
            }
        }
    }

    //VERIFY GRID SPACE TO TRADE
    if (v_totalOrdensOpen > 0 && v_totalOrdensOpen <= InpMaxTrades)
    {
        RefreshRates();

        double l_lastlot1, l_lastlot2 = 0;
        LastBuyPrice = FindLastBuyPrice(MagicNumber, l_lastlot1);
        LastSellPrice = FindLastSellPrice(MagicNumber, l_lastlot2);
        v_sumLots = l_lastlot1 + l_lastlot2;

        if (vDatetimeUltCandleOpen != iTime(NULL, InpTimeframeBarOpen, 0))
            TradeNow = TRUE;
    }

    if (v_totalOrdensOpen < 1)
    {
        ShortTrade = FALSE;
        LongTrade = FALSE;
        TradeNow = TRUE;
        StartEquity = AccountEquity();
    }

    //if (timeprev == Time[0]) return;
    //    timeprev = Time[0];

    //  OpenOneCandle
    if (vDatetimeUltCandleOpen != iTime(NULL, InpTimeframeBarOpen, 0))
    {

        // 1ª ORDEM DO GRID
        if (TradeNow)
        {

            SellLimit = Bid;
            BuyLimit = Ask;

            NumOfTrades = v_totalOrdensOpen;

            iLots = NormalizeDouble(Lots - InpDiminuir, InpLotdecimal);

            if (iLots < MarketInfo(Symbol(), 23))
                iLots = MarketInfo(Symbol(), 23);
            if (iLots > MarketInfo(Symbol(), 25))
                iLots = MarketInfo(Symbol(), 25);

            //SELL
            if (vSinal == -1)
            {
                ticket = OpenPendingOrder(1, iLots, SellLimit, InpSlip, SellLimit, 0, 0, ID + "-" + NumOfTrades, MagicNumber, 0, HotPink);
                if (ticket < 0)
                {
                    Print("Error: ", GetLastError());
                    return;
                }

                LastSellPrice = FindLastSellPrice(MagicNumber, v_sumLots);
                TradeNow = FALSE;
                vDatetimeUltCandleOpen = iTime(NULL, InpTimeframeBarOpen, 0);
                NewOrdersPlaced = TRUE;
            }

            //BUY
            if (vSinal == 1)
            {

                ticket = OpenPendingOrder(0, iLots, BuyLimit, InpSlip, BuyLimit, 0, 0, ID + "-" + NumOfTrades, MagicNumber, 0, Lime);
                if (ticket < 0)
                {
                    Print("Error: ", GetLastError());
                    return;
                }
                LastBuyPrice = FindLastBuyPrice(MagicNumber, v_sumLots);
                TradeNow = FALSE;
                vDatetimeUltCandleOpen = iTime(NULL, InpTimeframeBarOpen, 0);
                NewOrdersPlaced = TRUE;
            }

            // if (ticket > 0) expiration = TimeCurrent() + 60.0 * (60.0 * InpMaxTradeOpenHours);
        }
    }

    //CALC AveragePrice / Count Total Lots
    v_totalOrdensOpen = CountTrades(MagicNumber);
    AveragePrice = 0;
    double Count = 0;
    for (vg_cnt = OrdersTotal() - 1; vg_cnt >= 0; vg_cnt--)
    {
        OrderSelect(vg_cnt, SELECT_BY_POS, MODE_TRADES);
        if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber)
            continue;
        if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
        {
            if (OrderType() == OP_BUY || OrderType() == OP_SELL)
            {
                AveragePrice += OrderOpenPrice() * OrderLots();
                Count += OrderLots();
            }
        }
    }
    if (v_totalOrdensOpen > 0)
        AveragePrice = NormalizeDouble(AveragePrice / Count, Digits);
    v_sumLots = Count;

    //CALC PriceTarget/BuyTarget/Stopper
    if (NewOrdersPlaced)
    {
		RefreshRates();
        for (vg_cnt = OrdersTotal() - 1; vg_cnt >= 0; vg_cnt--)
        {
            OrderSelect(vg_cnt, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber)
                continue;
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
            {
                if (OrderType() == OP_BUY)
                {
                    PriceTarget = AveragePrice + InpTakeProfit * Point;;
                    BuyTarget = PriceTarget;
                    Stopper = AveragePrice - InpStoploss * Point;
					BuyStop = Stopper;
                    flag = TRUE;
                }
            }
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
            {
                if (OrderType() == OP_SELL)
                {
                    PriceTarget = AveragePrice - InpTakeProfit * Point;
                    SellTarget = PriceTarget;
                    Stopper = AveragePrice + InpStoploss * Point;
					SellStop = Stopper;
                    flag = TRUE;
                }
            }
        }
    }

    //ADD TAKE PROFIT
    if (NewOrdersPlaced)
    {
		RefreshRates();
		double dSpread = MarketInfo(Symbol(), MODE_SPREAD);
        if (flag == TRUE)
        {
            for (vg_cnt = OrdersTotal() - 1; vg_cnt >= 0; vg_cnt--)
            {
                OrderSelect(vg_cnt, SELECT_BY_POS, MODE_TRADES);
                if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber)
                    continue;
                if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
					if (IndivStoploss!=0 | IndivTakeProfit !=0)
					{
						BuyTarget  = NormalizeDouble(OrderOpenPrice()+(IndivTakeProfit+dSpread)*Point,digits);
						SellTarget = NormalizeDouble(OrderOpenPrice()-(IndivTakeProfit+dSpread)*Point,digits);		
						BuyStop    = NormalizeDouble(OrderOpenPrice()-(IndivStoploss+dSpread)*Point,digits);
						SellStop   = NormalizeDouble(OrderOpenPrice()+(IndivStoploss+dSpread)*Point,digits);	
						if (OrderType() == OP_SELL && IndivStoploss!=0 && IndivTakeProfit !=0) OrderModify(OrderTicket(), 0, NormalizeDouble(SellStop, Digits), NormalizeDouble(SellTarget, Digits), 0, Yellow);
						if (OrderType() == OP_SELL && IndivStoploss==0 && IndivTakeProfit !=0) OrderModify(OrderTicket(), 0, NormalizeDouble(OrderStopLoss(), Digits), NormalizeDouble(SellTarget, Digits), 0, Yellow);					
						if (OrderType() == OP_SELL && IndivStoploss!=0 && IndivTakeProfit ==0) OrderModify(OrderTicket(), 0, NormalizeDouble(SellStop, Digits), NormalizeDouble(OrderTakeProfit(), Digits), 0, Yellow);					
						if (OrderType() == OP_BUY && IndivStoploss!=0 && IndivTakeProfit !=0) OrderModify(OrderTicket(), 0 , NormalizeDouble(BuyStop, Digits), NormalizeDouble(BuyTarget, Digits), 0, Yellow);
						if (OrderType() == OP_BUY && IndivStoploss==0 && IndivTakeProfit !=0) OrderModify(OrderTicket(), 0 , NormalizeDouble(OrderStopLoss(), Digits), NormalizeDouble(BuyTarget, Digits), 0, Yellow);					
						if (OrderType() == OP_BUY && IndivStoploss!=0 && IndivTakeProfit ==0) OrderModify(OrderTicket(), 0 , NormalizeDouble(BuyStop, Digits), NormalizeDouble(OrderTakeProfit(), Digits), 0, Yellow);					
					}
					if ((IndivStoploss==0 | IndivTakeProfit ==0) && (InpStoploss!=0 | InpTakeProfit !=0))
					{
						if (OrderType() == OP_SELL && InpStoploss!=0 && InpTakeProfit !=0) OrderModify(OrderTicket(), NormalizeDouble(AveragePrice, Digits), NormalizeDouble(SellStop, Digits), NormalizeDouble(SellTarget, Digits), 0, Yellow);
						if (OrderType() == OP_SELL && InpStoploss==0 && InpTakeProfit !=0) OrderModify(OrderTicket(), NormalizeDouble(AveragePrice, Digits), NormalizeDouble(OrderStopLoss(), Digits), NormalizeDouble(SellTarget, Digits), 0, Yellow);					
						if (OrderType() == OP_SELL && InpStoploss!=0 && InpTakeProfit ==0) OrderModify(OrderTicket(), NormalizeDouble(AveragePrice, Digits), NormalizeDouble(SellStop, Digits), NormalizeDouble(OrderTakeProfit(), Digits), 0, Yellow);					
						if (OrderType() == OP_BUY && InpStoploss!=0 && InpTakeProfit !=0) OrderModify(OrderTicket(), NormalizeDouble(AveragePrice, Digits), NormalizeDouble(BuyStop, Digits), NormalizeDouble(BuyTarget, Digits), 0, Yellow);
						if (OrderType() == OP_BUY && InpStoploss==0 && InpTakeProfit !=0) OrderModify(OrderTicket(), NormalizeDouble(AveragePrice, Digits), NormalizeDouble(OrderStopLoss(), Digits), NormalizeDouble(BuyTarget, Digits), 0, Yellow);					
						if (OrderType() == OP_BUY && InpStoploss!=0 && InpTakeProfit ==0) OrderModify(OrderTicket(), NormalizeDouble(AveragePrice, Digits), NormalizeDouble(BuyStop, Digits), NormalizeDouble(OrderTakeProfit(), Digits), 0, Yellow);					
					}


                NewOrdersPlaced = FALSE;
            }
        }
    }

    //CLOSE ALL IF MaxTrades
    if (v_totalOrdensOpen > InpMaxTrades)
    {
        for (int pos = 0; pos < OrdersTotal(); pos++)
        {
            OrderSelect(pos, SELECT_BY_POS);
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber)
                continue;
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
                if (OrderType() == OP_SELL)
                {
                    OrderClose(OrderTicket(), OrderLots(), Ask, 5, White);
                    ordprof = OrderSwap() + OrderProfit() + OrderCommission();
                    if (GetLastError() == 0)
                    {
                        SendNotification("SellOrder: " + Symbol() + ", " + OrderType() + ", " + DoubleToStr(Ask, Digits) + ", " + DoubleToStr(OrderLots(), 2) + ", " + DoubleToStr(ordprof, 2));
                    }
                    pos = OrdersTotal();
                }
            if (OrderType() == OP_BUY)
            {
                OrderClose(OrderTicket(), OrderLots(), Bid, 5, White);
                ordprof = OrderSwap() + OrderProfit() + OrderCommission();
                if (GetLastError() == 0)
                {
                    SendNotification("BuyOrder: " + Symbol() + ", " + OrderType() + ", " + DoubleToStr(Ask, Digits) + ", " + DoubleToStr(OrderLots(), 2) + ", " + DoubleToStr(ordprof, 2));
                }
                pos = OrdersTotal();
            }
        }
    }
}

//+------------------------------------------------------------------+
//|           CountTrades                                   |
//+------------------------------------------------------------------+
int CountTrades(int MagicNumber)
{
    int count = 0;
    for (int trade = OrdersTotal() - 1; trade >= 0; trade--)
    {
        OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);
        if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber)
            continue;
        if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
            if (OrderType() == OP_SELL || OrderType() == OP_BUY)
                count++;
    }
    return (count);
}

//+------------------------------------------------------------------+
//|           CloseThisSymbolAll                                   |
//+------------------------------------------------------------------+
void CloseThisSymbolAll(int MagicNumber)
{
    for (int trade = OrdersTotal() - 1; trade >= 0; trade--)
    {
        OrderSelect(trade, SELECT_BY_POS, MODE_TRADES);
        if (OrderSymbol() == Symbol())
        {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
            {
                if (OrderType() == OP_BUY)
                    OrderClose(OrderTicket(), OrderLots(), Bid, InpSlip, Blue);
                if (OrderType() == OP_SELL)
                    OrderClose(OrderTicket(), OrderLots(), Ask, InpSlip, Red);
            }
            Sleep(1000);
        }
    }
}

//+------------------------------------------------------------------+
//|           OpenPendingOrder                                   |
//+------------------------------------------------------------------+
int OpenPendingOrder(int pType, double pLots, double pLevel, int sp, double pr, int sl, int tp, string pComment, int pMagic, int pDatetime, color pColor)
{
    int ticket = 0;
    int err = 0;
    int c = 0;
    int NumberOfTries = 100;
    switch (pType)
    {
    case 2:
        for (c = 0; c < NumberOfTries; c++)
        {
            ticket = OrderSend(Symbol(), OP_BUYLIMIT, pLots, pLevel, sp, StopLong(pr, sl), TakeLong(pLevel, tp), pComment, pMagic, pDatetime, pColor);
            err = GetLastError();
            if (err == 0 /* NO_ERROR */)
            {
                SendNotification("BUYLIMIT " + Symbol() + ", BuyLimit, " + DoubleToStr(pLevel, Digits) + ", " + DoubleToStr(pLots, 2));
                break;
            }
            if (!(err == 4 /* SERVER_BUSY */ || err == 137 /* BROKER_BUSY */ || err == 146 /* TRADE_CONTEXT_BUSY */ || err == 136 /* OFF_QUOTES */))
                break;
            Sleep(1000);
        }
        break;
    case 4:
        for (c = 0; c < NumberOfTries; c++)
        {
            ticket = OrderSend(Symbol(), OP_BUYSTOP, pLots, pLevel, sp, StopLong(pr, sl), TakeLong(pLevel, tp), pComment, pMagic, pDatetime, pColor);
            err = GetLastError();
            if (err == 0 /* NO_ERROR */)
            {
                SendNotification("BUYSTOP " + Symbol() + ", BuyStop, " + DoubleToStr(pLevel, Digits) + ", " + DoubleToStr(pLots, 2));
                break;
            }
            if (!(err == 4 /* SERVER_BUSY */ || err == 137 /* BROKER_BUSY */ || err == 146 /* TRADE_CONTEXT_BUSY */ || err == 136 /* OFF_QUOTES */))
                break;
            Sleep(5000);
        }
        break;
    case 0:
        for (c = 0; c < NumberOfTries; c++)
        {
            RefreshRates();
            ticket = OrderSend(Symbol(), OP_BUY, pLots, NormalizeDouble(Ask, Digits), sp, NormalizeDouble(StopLong(Bid, sl), Digits), NormalizeDouble(TakeLong(Ask, tp), Digits), pComment, pMagic, pDatetime, pColor);
            err = GetLastError();
            if (err == 0 /* NO_ERROR */)
            {
                SendNotification("BuyOrder: " + Symbol() + ", Buy, " + DoubleToStr(Ask, Digits) + ", " + DoubleToStr(pLots, 2));
                break;
            }
            if (!(err == 4 /* SERVER_BUSY */ || err == 137 /* BROKER_BUSY */ || err == 146 /* TRADE_CONTEXT_BUSY */ || err == 136 /* OFF_QUOTES */))
                break;
            Sleep(5000);
        }
        break;
    case 3:
        for (c = 0; c < NumberOfTries; c++)
        {
            ticket = OrderSend(Symbol(), OP_SELLLIMIT, pLots, pLevel, sp, StopShort(pr, sl), TakeShort(pLevel, tp), pComment, pMagic, pDatetime, pColor);
            err = GetLastError();
            if (err == 0 /* NO_ERROR */)
            {
                SendNotification("SELLLIMIT " + Symbol() + ", SellLimit, " + DoubleToStr(pLevel, Digits) + ", " + DoubleToStr(pLots, 2));
                break;
            }
            if (!(err == 4 /* SERVER_BUSY */ || err == 137 /* BROKER_BUSY */ || err == 146 /* TRADE_CONTEXT_BUSY */ || err == 136 /* OFF_QUOTES */))
                break;
            Sleep(5000);
        }
        break;
    case 5:
        for (c = 0; c < NumberOfTries; c++)
        {
            ticket = OrderSend(Symbol(), OP_SELLSTOP, pLots, pLevel, sp, StopShort(pr, sl), TakeShort(pLevel, tp), pComment, pMagic, pDatetime, pColor);
            err = GetLastError();
            if (err == 0 /* NO_ERROR */)
            {
                SendNotification("SELLSTOP " + Symbol() + ", SellStop, " + DoubleToStr(pLevel, Digits) + ", " + DoubleToStr(pLots, 2));
                break;
            }
            if (!(err == 4 /* SERVER_BUSY */ || err == 137 /* BROKER_BUSY */ || err == 146 /* TRADE_CONTEXT_BUSY */ || err == 136 /* OFF_QUOTES */))
                break;
            Sleep(5000);
        }
        break;
    case 1:
        for (c = 0; c < NumberOfTries; c++)
        {
            ticket = OrderSend(Symbol(), OP_SELL, pLots, NormalizeDouble(Bid, Digits), sp, NormalizeDouble(StopShort(Ask, sl), Digits), NormalizeDouble(TakeShort(Bid, tp), Digits), pComment, pMagic, pDatetime, pColor);
            err = GetLastError();
            if (err == 0 /* NO_ERROR */)
            {
                SendNotification("SELL " + Symbol() + ", Sell, " + DoubleToStr(Bid, Digits) + ", " + DoubleToStr(pLots, 2));
                break;
            }
            if (!(err == 4 /* SERVER_BUSY */ || err == 137 /* BROKER_BUSY */ || err == 146 /* TRADE_CONTEXT_BUSY */ || err == 136 /* OFF_QUOTES */))
                break;
            Sleep(5000);
        }
    }
    return (ticket);
}

//+------------------------------------------------------------------+
//|           StopLong                                   |
//+------------------------------------------------------------------+
double StopLong(double price, int stop)
{
    if (stop == 0)
        return (0);
    else
        return (price - stop * Point);
}

//+------------------------------------------------------------------+
//|           StopShort                                   |
//+------------------------------------------------------------------+
double StopShort(double price, int stop)
{
    if (stop == 0)
        return (0);
    else
        return (price + stop * Point);
}

//+------------------------------------------------------------------+
//|           TakeLong                                   |
//+------------------------------------------------------------------+
double TakeLong(double price, int stop)
{
    if (stop == 0)
        return (0);
    else
        return (price + stop * Point);
}

//+------------------------------------------------------------------+
//|           TakeShort                                   |
//+------------------------------------------------------------------+
double TakeShort(double price, int stop)
{
    if (stop == 0)
        return (0);
    else
        return (price - stop * Point);
}

//+------------------------------------------------------------------+
//|           CalculateProfit                                   |
//+------------------------------------------------------------------+
double CalculateProfit(int MagicNumber)
{
    double Profit = 0;
    for (vg_cnt = OrdersTotal() - 1; vg_cnt >= 0; vg_cnt--)
    {
        OrderSelect(vg_cnt, SELECT_BY_POS, MODE_TRADES);
        if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber)
            continue;
        if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
            if (OrderType() == OP_BUY || OrderType() == OP_SELL)
                Profit += OrderProfit() + OrderCommission() + OrderSwap();
    }
    return (Profit);
}
//+------------------------------------------------------------------+
//|           TrailingAlls                                   |
//+------------------------------------------------------------------+
void TrailingAlls(int pType, int stop, double AvgPrice, int MagicNumber)
{
    int profit;
    double stoptrade;
    double stopcal;
    if (stop != 0)
    {
        for (int trade = OrdersTotal() - 1; trade >= 0; trade--)
        {
            if (OrderSelect(trade, SELECT_BY_POS, MODE_TRADES))
            {
                if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber)
                    continue;
                if (OrderSymbol() == Symbol() || OrderMagicNumber() == MagicNumber)
                {
                    if (OrderType() == OP_BUY)
                    {
                        profit = NormalizeDouble((Bid - AvgPrice) / Point, 0);
                        if (profit < pType)
                            continue;
                        stoptrade = OrderStopLoss();
                        stopcal = Bid - stop * Point;
                        if (stoptrade == 0.0 || (stoptrade != 0.0 && stopcal > stoptrade))
                            OrderModify(OrderTicket(), AvgPrice, stopcal, OrderTakeProfit(), 0, Aqua);
                    }
                    if (OrderType() == OP_SELL)
                    {
                        profit = NormalizeDouble((AvgPrice - Ask) / Point, 0);
                        if (profit < pType)
                            continue;
                        stoptrade = OrderStopLoss();
                        stopcal = Ask + stop * Point;
                        if (stoptrade == 0.0 || (stoptrade != 0.0 && stopcal < stoptrade))
                            OrderModify(OrderTicket(), AvgPrice, stopcal, OrderTakeProfit(), 0, Red);
                    }
                }
                Sleep(1000);
            }
        }
    }
}
//+------------------------------------------------------------------+
//|           AccountEquityHigh                       |
//+------------------------------------------------------------------+
double AccountEquityHigh(int MagicNumber)
{
    if (CountTrades(MagicNumber) == 0)
        vg_AccountEquityHighAmt = AccountEquity();
    if (vg_AccountEquityHighAmt < vg_PrevEquity)
        vg_AccountEquityHighAmt = vg_PrevEquity;
    else
        vg_AccountEquityHighAmt = AccountEquity();
    vg_PrevEquity = AccountEquity();
    return (vg_AccountEquityHighAmt);
}

//+------------------------------------------------------------------+
//|           FindLastBuyPrice                                     |
//+------------------------------------------------------------------+
double FindLastBuyPrice(int MagicNumber, double &v_sumLots)
{

    v_sumLots = 0;
    double oldorderopenprice;
    int oldticketnumber;
    double unused = 0;
    int ticketnumber = 0;
    for (int vg_cnt = OrdersTotal() - 1; vg_cnt >= 0; vg_cnt--)
    {
        OrderSelect(vg_cnt, SELECT_BY_POS, MODE_TRADES);
        if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber)
            continue;
        if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_BUY)
        {
            oldticketnumber = OrderTicket();
            if (oldticketnumber > ticketnumber)
            {
                oldorderopenprice = OrderOpenPrice();
                //unused = oldorderopenprice;
                v_sumLots += OrderLots();
                ticketnumber = oldticketnumber;
            }
        }
    }
    return (oldorderopenprice);
}

//+------------------------------------------------------------------+
//|           FindLastSellPrice                                     |
//+------------------------------------------------------------------+
double FindLastSellPrice(int MagicNumber, double &v_sumLots)
{
    v_sumLots = 0;
    double oldorderopenprice;
    int oldticketnumber;
    double unused = 0;
    int ticketnumber = 0;
    for (int vg_cnt = OrdersTotal() - 1; vg_cnt >= 0; vg_cnt--)
    {
        OrderSelect(vg_cnt, SELECT_BY_POS, MODE_TRADES);
        if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber)
            continue;
        if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_SELL)
        {
            oldticketnumber = OrderTicket();
            if (oldticketnumber > ticketnumber)
            {
                oldorderopenprice = OrderOpenPrice();
                //unused = oldorderopenprice;
                v_sumLots += OrderLots();
                ticketnumber = oldticketnumber;
            }
        }
    }
    return (oldorderopenprice);
}

//+------------------------------------------------------------------+
//|           FindLastLot                                    |
//+------------------------------------------------------------------+
double FindLastLot(int MagicNumber)
{

    double oldorderopenprice;
    int oldticketnumber;
    double unused = 0;
    int ticketnumber = 0;
    for (int vg_cnt = OrdersTotal() - 1; vg_cnt >= 0; vg_cnt--)
    {
        OrderSelect(vg_cnt, SELECT_BY_POS, MODE_TRADES);
        if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber)
            continue;
        if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_SELL)
        {
            oldticketnumber = OrderTicket();
            if (oldticketnumber > ticketnumber)
            {
                oldorderopenprice = OrderLots();
                //unused = oldorderopenprice;
                // v_sumLots += OrderLots();
                ticketnumber = oldticketnumber;
            }
        }
    }
    return (oldorderopenprice);
}
//+------------------------------------------------------------------+
//|           Informacoes                                     |
//+------------------------------------------------------------------+
void Informacoes()
{

    string Ls_64;

    int Li_84;

    if (!IsOptimization())
    {

        Ls_64 = "==========================\n";
        Ls_64 = Ls_64 + " " + vg_versao + "\n";
        Ls_64 = Ls_64 + "==========================\n";
        // Ls_64 = Ls_64 + "  Broker:  " + AccountCompany() + "\n";
        Ls_64 = Ls_64 + "  Time of Broker:" + TimeToStr(TimeCurrent(), TIME_DATE | TIME_SECONDS) + "\n";
        // Ls_64 = Ls_64 + "  Currenci: " + AccountCurrency() + "\n";
        //Ls_64 = Ls_64 + "==========================\n";
        Ls_64 = Ls_64 + "  Grid Size : " + (string)vg_GridSize + " Pips \n";
      //  Ls_64 = Ls_64 + "  InpTakeProfit: " + (string)InpTakeProfit + " Pips \n";
        Ls_64 = Ls_64 + "  Lot Mode : " + (string)InpLotsMode + "  \n";
        //Ls_64 = Ls_64 + "  Exponent Factor: " + (string)InpLotExponent + " pips\n";

        Ls_64 = Ls_64 + "==========================\n";
        Ls_64 = Ls_64 + "  Spread: " + (string)MarketInfo(Symbol(), MODE_SPREAD) + " \n";
        Ls_64 = Ls_64 + "  Equity:      " + DoubleToStr(AccountEquity(), 2) + " \n";
        Ls_64 = Ls_64 + "  Last Lot :     | 1 : " + DoubleToStr(v_sumLots1, 2) + " \n";
        Ls_64 = Ls_64 + "  Orders Opens : | 1 : " + (string)v_qtdOrdensOpen1 + " \n";
        Ls_64 = Ls_64 + "  Profit/Loss:   | 1 : " + DoubleToStr(CurrentPairProfit1, 2) + " \n";
        Ls_64 = Ls_64 + " ==========================\n";
        Ls_64 = Ls_64 + " Sinal NonLagMA  " + SinalNonLagMA + " \n";
        Ls_64 = Ls_64 + " ==========================\n";

        Ls_64 = Ls_64 + vg_filters_on;

        Comment(Ls_64);
        Li_84 = 16;
        if (InpDisplayInpBackgroundColor)
        {
            if (vg_initpainel || Seconds() % 5 == 0)
            {
                vg_initpainel = FALSE;
                for (int count_88 = 0; count_88 < 12; count_88++)
                {
                    for (int count_92 = 0; count_92 < Li_84; count_92++)
                    {
                        ObjectDelete("background" + (string)count_88 + (string)count_92);
                        ObjectDelete("background" + (string)count_88 + ((string)(count_92 + 1)));
                        ObjectDelete("background" + (string)count_88 + ((string)(count_92 + 2)));
                        ObjectCreate("background" + (string)count_88 + (string)count_92, OBJ_LABEL, 0, 0, 0);
                        ObjectSetText("background" + (string)count_88 + (string)count_92, "n", 30, "Wingdings", InpBackgroundColor);
                        ObjectSet("background" + (string)count_88 + (string)count_92, OBJPROP_XDISTANCE, 20 * count_88);
                        ObjectSet("background" + (string)count_88 + (string)count_92, OBJPROP_YDISTANCE, 23 * count_92 + 9);
                    }
                }
            }
        }
        else
        {
            if (vg_initpainel || Seconds() % 5 == 0)
            {
                vg_initpainel = FALSE;
                for (int count_88 = 0; count_88 < 9; count_88++)
                {
                    for (int count_92 = 0; count_92 < Li_84; count_92++)
                    {
                        ObjectDelete("background" + (string)count_88 + (string)count_92);
                        ObjectDelete("background" + (string)count_88 + ((string)(count_92 + 1)));
                        ObjectDelete("background" + (string)count_88 + ((string)(count_92 + 2)));
                    }
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//|           TimeFilter                                     |
//+------------------------------------------------------------------+
bool TimeFilter()
{

    bool _res = false;
    datetime _time_curent = TimeCurrent();
    datetime _time_start = StrToTime(DoubleToStr(Year(), 0) + "." + DoubleToStr(Month(), 0) + "." + DoubleToStr(Day(), 0) + " " + InpStartHour);
    datetime _time_stop = StrToTime(DoubleToStr(Year(), 0) + "." + DoubleToStr(Month(), 0) + "." + DoubleToStr(Day(), 0) + " " + InpEndHour);
    if (((InpTrade_in_Monday == true) && (TimeDayOfWeek(Time[0]) == 1)) ||
        ((InpTrade_in_Tuesday == true) && (TimeDayOfWeek(Time[0]) == 2)) ||
        ((InpTrade_in_Wednesday == true) && (TimeDayOfWeek(Time[0]) == 3)) ||
        ((InpTrade_in_Thursday == true) && (TimeDayOfWeek(Time[0]) == 4)) ||
        ((InpTrade_in_Friday == true) && (TimeDayOfWeek(Time[0]) == 5)))

        if (_time_start > _time_stop)
        {
            if (_time_curent >= _time_start || _time_curent <= _time_stop)
                _res = true;
        }
        else if (_time_curent >= _time_start && _time_curent <= _time_stop)
            _res = true;

    return (_res);
}

//+------------------------------------------------------------------+
//|           CalculateProfit                                   |
//+------------------------------------------------------------------+
double CalculateProfit(int InpMagic, int InpMagic2)
{
    double ld_ret_0 = 0;
    for (int g_pos_344 = OrdersTotal() - 1; g_pos_344 >= 0; g_pos_344--)
    {
        if (!OrderSelect(g_pos_344, SELECT_BY_POS, MODE_TRADES))
        {
            continue;
        }
        if (OrderSymbol() != Symbol() || (OrderMagicNumber() != InpMagic && OrderMagicNumber() != InpMagic2))
            continue;
        if (OrderSymbol() == Symbol() && (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2))
            if (OrderType() == OP_BUY || OrderType() == OP_SELL)
                ld_ret_0 += OrderProfit() + OrderSwap() + OrderCommission();
    }
    return (ld_ret_0);
}

//+------------------------------------------------------------------+
//|           CloseThisSymbolAll                                   |
//+------------------------------------------------------------------+
void CloseThisSymbolAll(int InpMagic, int InpMagic2)
{
    for (int trade = OrdersTotal() - 1; trade >= 0; trade--)
    {
        if (!OrderSelect(trade, SELECT_BY_POS, MODE_TRADES))
        {
            continue;
        }
        if (OrderSymbol() != Symbol() || (OrderMagicNumber() != InpMagic && OrderMagicNumber() != InpMagic2))
            continue;
        if (OrderSymbol() == Symbol() && (OrderMagicNumber() == InpMagic || OrderMagicNumber() == InpMagic2))
        {
            if (OrderType() == OP_BUY)
                OrderClose(OrderTicket(), OrderLots(), Bid, InpSlip, Blue);
            if (OrderType() == OP_SELL)
                OrderClose(OrderTicket(), OrderLots(), Ask, InpSlip, Red);
        }
        Sleep(1000);
    }
}

double MathRound(double x, double m) { return m * MathRound(x / m); }
double MathFloor(double x, double m) { return m * MathFloor(x / m); }
double MathCeil(double x, double m) { return m * MathCeil(x / m); }

void ValidStop(string asymbol, double aprice, double &asl)
{
    // Return if no S/L
    if (asl == 0)
        return;

    double servers_min_stop = MarketInfo(asymbol, MODE_STOPLEVEL) * MarketInfo(asymbol, MODE_POINT);

    if (MathAbs(aprice - asl) <= servers_min_stop)
    {
        // we have to adjust the stop.
        if (aprice > asl)
            asl = aprice - servers_min_stop; // we are long

        else if (aprice < asl)
            asl = aprice + servers_min_stop; // we are short

        else
            Print("EnsureValidStop: error, passed in aprice == sl, cannot adjust");

        asl = NormalizeDouble(asl, MarketInfo(asymbol, MODE_DIGITS));
    }
}

//---------------------------------------------------------------------
double GetProfitOpenPosInCurrency(string as_0 = "", int a_cmd_8 = -1, int a_magic_12 = -1)
{
    double ld_ret_16 = 0;
    int l_ord_total_24 = OrdersTotal();
    if (as_0 == "0")
        as_0 = Symbol();
    for (int l_pos_28 = 0; l_pos_28 < l_ord_total_24; l_pos_28++)
    {
        if (OrderSelect(l_pos_28, SELECT_BY_POS, MODE_TRADES))
        {
            if (OrderSymbol() == as_0 || as_0 == "" && a_cmd_8 < OP_BUY || OrderType() == a_cmd_8)
            {
                if (OrderType() == OP_BUY || OrderType() == OP_SELL)
                    if (a_magic_12 < 0 || OrderMagicNumber() == a_magic_12)
                        ld_ret_16 += OrderProfit() + OrderCommission() + OrderSwap();
            }
        }
    }
    return (ld_ret_16);
}
//-----------------------------------------------------------------------------------
void SetHLine(color vColorSetHLine, string vNomeSetHLine = "", double vBidSetHLine = 0.0, int vStyleSetHLine = 0, int vTamanhoSetHLine = 1)
{
    if (vNomeSetHLine == "")
        vNomeSetHLine = DoubleToStr(Time[0], 0);
    if (vBidSetHLine <= 0.0)
        vBidSetHLine = Bid;
    if (ObjectFind(vNomeSetHLine) < 0)
        ObjectCreate(vNomeSetHLine, OBJ_HLINE, 0, 0, 0);
    ObjectSet(vNomeSetHLine, OBJPROP_PRICE1, vBidSetHLine);
    ObjectSet(vNomeSetHLine, OBJPROP_COLOR, vColorSetHLine);
    ObjectSet(vNomeSetHLine, OBJPROP_STYLE, vStyleSetHLine);
    ObjectSet(vNomeSetHLine, OBJPROP_WIDTH, vTamanhoSetHLine);
}

//------------------------------------------------------------------
void Painel2(string Ygs_104)
{
    string name_0 = Ygs_104 + "L_1";
    if (ObjectFind(name_0) == -1)
    {
        ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
        ObjectSet(name_0, OBJPROP_CORNER, 0);
        ObjectSet(name_0, OBJPROP_XDISTANCE, 500);
        ObjectSet(name_0, OBJPROP_YDISTANCE, 10);
    }
    ObjectSetText(name_0, vg_versao, 12, "Arial", White);
}

//+------------------------------------------------------------------+
int OrdersScaner(int vMAGIC, int &orders_buy, int &orders_sell, int &profit, int &MinPriceBuy, int &MaxPriceSell, int &pending)
{

    orders_buy = 0;
    orders_sell = 0;
    profit = 0;
    MinPriceBuy = 0;
    MaxPriceSell = 0;
    pending = 0;
    for (int i = OrdersTotal(); i >= 1; i--)
    {
        if (OrderSelect(i - 1, SELECT_BY_POS, MODE_TRADES) == FALSE)
            break;
        if (OrderSymbol() != Symbol())
            continue;
        if (OrderMagicNumber() != vMAGIC)
            continue;
        if (OrderType() > 1)
            pending++;
        if (OrderType() == OP_BUY)
        {
            orders_buy++;
            if (orders_buy == 1)
                MinPriceBuy = OrderOpenPrice();
            if (orders_buy > 1 && OrderOpenPrice() < MinPriceBuy)
                MinPriceBuy = OrderOpenPrice();
            profit += OrderProfit() + OrderSwap();
        }
        if (OrderType() == OP_SELL)
        {
            orders_sell++;
            if (orders_sell == 1)
                MaxPriceSell = OrderOpenPrice();
            if (orders_sell > 1 && OrderOpenPrice() > MaxPriceSell)
                MaxPriceSell = OrderOpenPrice();
            profit += OrderProfit() + OrderSwap();
        }
    }
    int status = orders_buy + orders_sell;
    return (status);
}
//-----------------------------------------------
int GetBB(int ii, int periodBB, int deviationBB, int bands_shiftBB, int uppr, int dnpr, int CheckBarsBB)
{
    double bh, bl;
    int dn = 0, up = 0;
    int j;
    for (j = ii; j <= ii + CheckBarsBB; j++)
    {
        bh = iBands(NULL, InpBBFrame, periodBB, deviationBB, bands_shiftBB, uppr, MODE_UPPER, j);
        bl = iBands(NULL, InpBBFrame, periodBB, deviationBB, bands_shiftBB, dnpr, MODE_LOWER, j);
        if (Close[j] >= bh)
        {
            dn++;
            break;
        }
        if (Close[j] <= bl)
        {
            up++;
            break;
        }
    }
    if (dn > 0)
        return (-1);
    if (up > 0)
        return (1);
    return (0);
}
