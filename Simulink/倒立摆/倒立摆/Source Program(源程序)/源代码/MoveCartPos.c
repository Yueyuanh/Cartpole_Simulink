///ÎÈ°Ú¿ØÖÆËã·¨
#define S_FUNCTION_NAME  MoveCartPos
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"
#include "MotionControlDLL.h"
#include "Pend.h"
#include "math.h"

#pragma  comment(lib,"MotionControlDLL.lib")
#pragma warning( disable: 4761 )
#pragma warning( disable: 4244 )

double v;
double cartpos1;
char strtt[20];
int cartpos;

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
    	
    if (!ssSetNumOutputPorts(S,0)) return;
    
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
	  v=*uPtrs[0];
	  if(v<=0.2&&v>=-0.2)
	  {
	  cartpos1 = v / 0.1117465*4000;
	  }
	  else
	  v=0;
	  cartpos=(int) cartpos1;
	  sprintf(strtt,"MA%d\r",cartpos);
	  Send_COM_String(strtt);
	  Send_COM_String("A10\r");
	  Send_COM_String("M\r");
	  
	  	 
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
