
// The following ifdef block is the standard way of creating macros which make exporting 
// from a DLL simpler. All files within this DLL are compiled with the MOTIONCONTROLDLL_EXPORTS
// symbol defined on the command line. this symbol should not be defined on any project
// that uses this DLL. This way any other project whose source files include this file see 
// MOTIONCONTROLDLL_API functions as being imported from a DLL, wheras this DLL sees symbols
// defined with this macro as being exported.


#ifdef MOTIONCONTROLDLL_EXPORTS
#define MOTIONCONTROLDLL_API __declspec(dllexport)
#else
#define MOTIONCONTROLDLL_API __declspec(dllimport)
#endif

// MOTIONCONTROLDLL_API int nMotionControlDLL;

///MOTIONCONTROLDLL_API int fnMotionControlDLL(void);

#ifdef __cplusplus
extern "C"
{
#endif

//�򿪿��ƿ���VerdorID��VersionID����
 MOTIONCONTROLDLL_API bool Open_Motion_Controller(unsigned long ProductID);
//�ر��˶����ƿ�
 MOTIONCONTROLDLL_API bool Close_Motion_Controller(unsigned long ProdectID);
//��ȡ��·���������������:1Ϊ���������ֵ,2Ϊ�ڸ˱�����ֵ
 MOTIONCONTROLDLL_API bool Read_Encoder(long *pulse1,long *pulse2);
//���ƶ��������ַ������͵��˿�
 MOTIONCONTROLDLL_API bool Send_COM_String(char *szCommand);
//����·�������������������
 MOTIONCONTROLDLL_API bool Zero_Encoder(void);
 
#ifdef __cplusplus
}
#endif
