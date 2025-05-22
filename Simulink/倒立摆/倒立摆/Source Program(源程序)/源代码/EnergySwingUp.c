///Æð°Ú¿ØÖÆËã·¨
#define S_FUNCTION_NAME  EnergySwingUp
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"
#include "MotionControlDLL.h"
#include "Pend.h"
#include "math.h"

#pragma comment(lib, "MotionControlDLL.lib")
#pragma warning( disable: 4761 )
#pragma warning( disable: 4244 )

double roddegree=0;
double rodvel=0;
double acc,vel;
double Invel;
double v;
double xishu;
int acc1,vel1;
char szStr[10];
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

    
    if(!ssSetNumInputPorts(S, 4)) return;
    for(j=0;j<4;j++)
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
	double Energy;
	double FlagSign;
	InputRealPtrsType uPtrs = ssGetInputPortRealSignalPtrs(S,0);
	roddegree=*uPtrs[0];
	rodvel=*uPtrs[1];
	xishu=*uPtrs[2];
	Invel=*uPtrs[3];
	Energy = 0.5 * 0.001182 * rodvel * rodvel + 
		0.0737 * 0.13 * 9.81 * (cos(roddegree) - 1.0);

	FlagSign =  Energy* rodvel * cos(roddegree);

	if( FlagSign < 0)
	{
		v = xishu*fabs(Energy);
		vel=Invel;
	}
	else if (FlagSign > 0)
	{
		v = -1*xishu *fabs(Energy);
		vel=-1*Invel;
	} 
	else
	{
		v = 0.1;
		vel=Invel;
	}
	

	acc = fabs(v / 0.09145);


			
	acc1=(int)acc;
	vel1=(int)vel;

    sprintf(szStr,"A%d\r",acc1);
	Send_COM_String(szStr);

	sprintf(szStr,"V%d\r",vel1);
	Send_COM_String(szStr);

  
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
