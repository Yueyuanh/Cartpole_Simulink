///ÎÈ°Ú¿ØÖÆËã·¨
#define S_FUNCTION_NAME  SetMotorAcc
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"
#include "MotionControlDLL.h"
#include "Pend.h"
#include "math.h"

#pragma  comment(lib,"MotionControlDLL.lib")
#pragma warning( disable: 4761 )
#pragma warning( disable: 4244 )

double v;
double acc;
int vel;
char strtt[20];
int acc1;

/* Function: mdlInitializeSizes ===============================================
 */
static void mdlInitializeSizes(SimStruct *S)
{			   
    ssSetNumSFcnParams(S, 0);
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
        //mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL) {
            return;
        }
    } else {
        return; /* Simulink will report a parameter mismatch error */
    }
    
    if(!ssSetNumInputPorts(S, 1)) return;
   	ssSetInputPortWidth(S,0,1);
    	
   	ssSetInputPortDirectFeedThrough(S,0,1);
    	
    if (!ssSetNumOutputPorts(S,1)) return;
     ssSetOutputPortWidth(S,0,1);
    ssSetNumSampleTimes(S, 1);

    /* Take care when specifying exception free code - see sfuntmpl_doc.c */
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
}


/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:    Specifiy that we inherit our sample time from the driving block.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}

// Function: mdlOutputs =======================================================
 
static void mdlOutputs(SimStruct *S, int_T tid)
{
	  InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S,0);
	  real_T            *y1    = ssGetOutputPortRealSignal(S,0);
	  v=*uPtrs[0];
	  acc = v / 0.1117465;
	  acc = fabs (acc);
	  
	  if(v < 0)    vel = -400;
	  if(v >= 0)   vel = 400;
	  acc1=(int) acc;
	  *y1=acc;	  
	  sprintf(strtt,"A%d\r",acc1);
	  Send_COM_String(strtt);
	  sprintf(strtt,"V%d\r",vel);
	  Send_COM_String(strtt);
	  

	 
}
/* Function: mdlTerminate =====================================================
 * Abstract:
 *    No termination needed, but we are required to have this routine.
 */
static void mdlTerminate(SimStruct *S)
{
	
}
#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
