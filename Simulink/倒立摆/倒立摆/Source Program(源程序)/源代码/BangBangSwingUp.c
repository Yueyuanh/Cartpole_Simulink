///Æð°Ú¿ØÖÆËã·¨
#define S_FUNCTION_NAME  BangBangSwingUp
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"
#include "Pend.h"
#include "math.h"

#pragma comment(lib,"MotionControlDLL.lib")    
#include "MotionControlDLL.h" 
#pragma warning( disable: 4761 )
#pragma warning( disable: 4244 )

double v;
double cartvel=0;
double roddegree,rodvel;
int vel=0;
double acc;
int acc1;

char strtt[10];

/* Function: mdlInitializeSizes ===============================================
 */
static void mdlInitializeSizes(SimStruct *S)
{	
	int j=0;	   
    ssSetNumSFcnParams(S, 0);
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
        //mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL) {
            return;
        }
    } else {
        return; /* Simulink will report a parameter mismatch error */
    }

    
    if(!ssSetNumInputPorts(S, 3)) return;
    for(j=0;j<3;j++)
    {
    	ssSetInputPortWidth(S,j,1);    
    	ssSetInputPortDirectFeedThrough(S,j,1);
    }	

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
	roddegree=*uPtrs[0];
	rodvel=*uPtrs[1];
        if(roddegree==0 && rodvel==0)
		{
			v=1;
			vel=200;

		}
		if(roddegree*rodvel<0 && roddegree<0)
		{
			v=-2.6;
			vel=-320;
		}
		if(roddegree*rodvel<0 && roddegree>0)
		{
			v=2.6;
			vel=320;
		}
		if(roddegree*rodvel>0 && roddegree>0)
		{
			v=0;
			//vel=-200;
		}
		if(roddegree*rodvel>0 && roddegree<0)
		{
			v=0;
			//vel=200;
		}
		
	acc= fabs (v/0.09145);
	acc1=(int)acc;
	
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
