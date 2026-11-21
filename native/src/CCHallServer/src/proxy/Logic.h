#include "global.h"

#ifndef __H_LOGIC_H__
#define __H_LOGIC_H__

#define RANDOM(x) (rand()%(x))
#define TIME_INTR_VAL (5*60)

#define STATIC_BUFF_LEN (512)
//char g_strbuff[STATIC_BUFF_LEN];

class CLogic
{
    public:
        CLogic(){;}
        ~CLogic(){;}

        static void InitLog()
        {
            char logfile[256];
            char logpath[256];
            time_t curtime=time(NULL);
            snprintf(logpath,sizeof(logpath),"%s/%s/",TGlobal::_log_path.c_str(),GetDateString(curtime).c_str());
            snprintf(logfile,sizeof(logfile),"HallServer-s%d.%d.log",TGlobal::_svid,getpid());
            set_log_level(TGlobal::_log_level);
            init_log (logfile,logpath,TGlobal::_log_max_num,TGlobal::_log_maxsize);
            return;
        }

        static string TimeStamp2String(time_t tt)
        {
            struct tm * timeinfo;
            timeinfo = localtime ((time_t*)&tt);
            return asctime(timeinfo);
        }

        static time_t GetLeastTimeStamp()
        {
#ifdef __DEBUG__
            time_t current=1405267200;
            static int idx=0;
            int cur_timestamp=current+idx*300;
            idx++;
#else
            time_t current=time(NULL);
            int cur_timestamp=current-current%TIME_INTR_VAL;
#endif

            return cur_timestamp;
        }

        static string GetDateString(time_t tstamp)
        {
            struct tm* timeinfo;
            timeinfo=localtime(&tstamp);
			char g_strbuff[STATIC_BUFF_LEN];
            strftime(g_strbuff,STATIC_BUFF_LEN,"%Y%m%d",timeinfo);

            return g_strbuff;
        }

        static string GetWeekString(time_t tstamp)
        {
            struct tm* timeinfo;
            timeinfo=localtime(&tstamp);
			char g_strbuff[STATIC_BUFF_LEN];
            strftime(g_strbuff,STATIC_BUFF_LEN,"%Y%m",timeinfo);

            return g_strbuff;
        }

        static int GetDateLeastTime(time_t tstamp)
        {
            struct tm timeinfo;
            localtime_r(&tstamp, &timeinfo);
            int now_time_second = timeinfo.tm_hour*3600 + timeinfo.tm_min*60 + timeinfo.tm_sec;
            int total_time_second = 24 * 3600 + 1;

            int intrval=total_time_second-now_time_second;
            if(intrval<=0)
            {
                intrval=0;
            }

            return intrval;
        }

        static int GetWeekLeastTime(time_t tstamp)
        {
            struct tm timeinfo;
            localtime_r(&tstamp, &timeinfo);
            int wday=(timeinfo.tm_wday==0)?7:timeinfo.tm_wday;
            int now_time_second = (wday-1)*24*3600 + timeinfo.tm_hour*3600 + timeinfo.tm_min*60 + timeinfo.tm_sec;
            int total_time_second = 7*24 * 3600 + 1;

            int intrval=total_time_second-now_time_second;
            if(intrval<=0)
            {
                intrval=0;
            }

            return intrval;
        }

        static int GetTwoWeekExpire(){return 2*7*86400;}
        static int GetMeiliExpireTime(){return 86400;}
        static int GetWeekMeiliExpireTime()
        {
            time_t tstamp=time(NULL);
            struct tm timeinfo;
            localtime_r(&tstamp, &timeinfo);

            int wday=(timeinfo.tm_wday==0)?7:timeinfo.tm_wday;
            int now_time_second = (wday-1)*24*3600 + timeinfo.tm_hour*3600 + timeinfo.tm_min*60 + timeinfo.tm_sec;
            int total_time_second = 7*24 * 3600 + 1;

            int intrval=total_time_second-now_time_second;
            if(intrval<=0)
            {
                intrval=0;
            }

            return intrval;
        }
 
        static int TimeToMidnight()
        {
            time_t now;
            struct tm midnight;

            time(&now);  /* get current time; same as: now = time(NULL)  */
            midnight = *localtime(&now);
            midnight.tm_hour = 0; midnight.tm_min = 0; midnight.tm_sec = 0;
            midnight.tm_mday += 1;

            return (int)difftime(mktime(&midnight),now);
        }
};


#endif


