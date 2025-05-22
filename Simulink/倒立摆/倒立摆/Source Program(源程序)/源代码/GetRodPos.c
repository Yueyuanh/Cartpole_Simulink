#define S_FUNCTION_NAME  GetRodPos
#define S_FUNCTION_LEVEL 2

#include <stdio.h>
#include "simstruc.h"
#include "Pend.h"



#include "MotionControlDLL.h"
#pragma  comment(lib,"MotionControlDLL.lib")



#pragma warning( disable: 4761 )
#pragma warning( disable: 4244 )

//--------------------------------------------------------------------------
#define ERR_INVALID_PARAM \
 "Parameter must be an number between 1 and 2."

enum {PARAM = 0, NUM_PARAMS};

#define ENC_AUX_NUM  (ssGetSFcnParam(S, 0))
#define MDL_CHECK_PARAMETERS
static void mdlCheckParameters(SimStruct *S)		
{
    uint8_T enc_aux_num;
    enc_aux_num  = (uint8_T) *(mxGetPr(ENC_AUX_NUM));
  
    if( enc_aux_num < 1 || enc_aux_num > 2 )
	{
        ssSetErrorStatus(S, ERR_INVALID_PARAM);
	    return;
    }
}

/* Function: mdlInitializeSizes ===============================================
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 1);
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) 
	{
        mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL) 
		{
            return;
        }
    } 
	else
	{
        return; /* Simulink will report a parameter mismatch error */
    }

    if (!ssSetNumInputPorts(S, 0)) return;

    if (!ssSetNumOutputPorts(S,1)) return;
    ssSetOutputPortWidth(S, 0, 1);
    
    
    ssSetNumSampleTimes(S, 1);

    /* Take care when specifying exception free code - see sfuntmpl_doc.c */
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);
}


/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:    Specifiy that we inherit our sample time from the driving block.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, CONTINUOUS_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}


 // Function: mdlOutputs =======================================================
static void mdlOutputs(SimStruct *S, int_T tid)
{
    real_T            *y    = ssGetOutputPortRealSignal(S,0);

    uint8_T enc_aux_num;
    long cartcoder,rodcoder;

    enc_aux_num  =	(uint8_T) *(mxGetPr(ENC_AUX_NUM));
   	Read_Encoder(&cartcoder,&rodcoder); 
    
 	
 	
 	*y = rodcoder;
 	
}
static void mdlTerminate(SimStruct *S)
{
}
#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
