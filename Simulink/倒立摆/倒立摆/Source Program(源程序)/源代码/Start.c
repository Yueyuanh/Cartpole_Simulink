#include "windows.h"
#include "Mmsystem.h"

#pragma comment(lib, "MotionControlDLL.lib")
#pragma comment(lib, "Winmm.lib")
#pragma warning( disable: 4761 )
#pragma warning( disable: 4244 )

#define S_FUNCTION_NAME  Start
#define S_FUNCTION_LEVEL 2
#include "simstruc.h"
#include "MotionControlDLL.h"
#include "Pend.h"
int flag=0;
int Num;//选择的实验号
MMRESULT result;

void PASCAL OneMilliSecondProc(UINT wTimerID, UINT msg,DWORD dwUser,DWORD dwl,DWORD dw2)
{
	flag=1;
}
/* Function: mdlInitializeSizes ===============================================
 */
static void mdlInitializeSizes(SimStruct *S)
{			   
    ssSetNumSFcnParams(S, 1);
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) 
	{
        if (ssGetErrorStatus(S) != NULL)
		{
            return;
        }
    }
	else 
	{
        return; /* Simulink will report a parameter mismatch error */
    }
    
    if(!ssSetNumInputPorts(S, 0)) return;
    	//ssSetInputPortWidth(S,0,1);
    	//ssSetInputPortRequiredContiguous(S,0,true);
    	//ssSetInputPortDirectFeedThrough(S,0,1);
    	
    if (!ssSetNumOutputPorts(S,1)) return;
    ssSetOutputPortWidth(S, 0, 13);
    
    ssSetNumSampleTimes(S, 1);

    /* Take care when specifying exception free code - see sfuntmpl_doc.c */
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
}


/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:    Specifiy that we inherit our sample time from the driving block.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, 0.01);//INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}

#define MDL_START  /* Change to #undef to remove function */
#if defined(MDL_START)
  /* Function: mdlStart =======================================================
   * Abstract:
   *    This function is called once at start of model execution. If you
   *    have states that should be initialized once, this is the place
   *    to do it.   */
  static void mdlStart(SimStruct *S)
  {   
        Open_Motion_Controller(0x09251234);//打开数据读入卡
	Zero_Encoder();                //清零计数器
	Send_COM_String("ENA\r");           //驱动使能
	Send_COM_String("PO0\r");	
    //控制周期设置为常数10ms
 	result=timeSetEvent(10,1,(LPTIMECALLBACK)OneMilliSecondProc,0,TIME_PERIODIC);	
		
  }
#endif /*  MDL_START */
// Function: mdlOutputs =======================================================
 
static void mdlOutputs(SimStruct *S, int_T tid)
{   real_T *para0 = mxGetPr(ssGetSFcnParam(S,0));//参数传递，二次传递
    real_T *y = ssGetOutputPortRealSignal(S,0);	
    Num=(int)*para0;//类型强制转换			
    y[Num-1]=flag;//flag使能标志位，产生定时脉冲
    flag=0;
}

/* Function: mdlTerminate =====================================================
 * Abstract:
 *    No termination needed, but we are required to have this routine.
 */
static void mdlTerminate(SimStruct *S)
{
   timeKillEvent(result);
   Send_COM_String("A100\r");
   Send_COM_String("V0\r");
   Send_COM_String("DIS\r");
   Close_Motion_Controller(0x09251234);
}
#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
