/* DO NOT EDIT THIS FILE - it is machine generated */
#include <jni.h>
/* Header for class ch_cern_eos_XRootDFileSystem */

#ifndef _Included_ch_cern_eos_XRootDFileSystem
#define _Included_ch_cern_eos_XRootDFileSystem
#ifdef __cplusplus
extern "C" {
#endif
#undef ch_cern_eos_XRootDFileSystem_SHUTDOWN_HOOK_PRIORITY
#define ch_cern_eos_XRootDFileSystem_SHUTDOWN_HOOK_PRIORITY 10L
/*
 * Class:     ch_cern_eos_XRootDFileSystem
 * Method:    setenv
 * Signature: (Ljava/lang/String;Ljava/lang/String;)V
 */
JNIEXPORT void JNICALL Java_ch_cern_eos_XRootDFileSystem_setenv
  (JNIEnv *, jclass, jstring, jstring);

/*
 * Class:     ch_cern_eos_XRootDFileSystem
 * Method:    getenv
 * Signature: (Ljava/lang/String;)Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_ch_cern_eos_XRootDFileSystem_getenv
  (JNIEnv *, jclass, jstring);

/*
 * Class:     ch_cern_eos_XRootDFileSystem
 * Method:    initFileSystem
 * Signature: (Ljava/lang/String;)J
 */
JNIEXPORT jlong JNICALL Java_ch_cern_eos_XRootDFileSystem_initFileSystem
  (JNIEnv *, jobject, jstring);

/*
 * Class:     ch_cern_eos_XRootDFileSystem
 * Method:    getFileStatusS
 * Signature: (JLjava/lang/String;Lorg/apache/hadoop/fs/Path;)Lorg/apache/hadoop/fs/FileStatus;
 */
JNIEXPORT jobject JNICALL Java_ch_cern_eos_XRootDFileSystem_getFileStatusS
  (JNIEnv *, jobject, jlong, jstring, jobject);

/*
 * Class:     ch_cern_eos_XRootDFileSystem
 * Method:    listFileStatusS
 * Signature: (JLjava/lang/String;Lorg/apache/hadoop/fs/Path;)[Lorg/apache/hadoop/fs/FileStatus;
 */
JNIEXPORT jobjectArray JNICALL Java_ch_cern_eos_XRootDFileSystem_listFileStatusS
  (JNIEnv *, jobject, jlong, jstring, jobject);

/*
 * Class:     ch_cern_eos_XRootDFileSystem
 * Method:    Mv
 * Signature: (JLjava/lang/String;Ljava/lang/String;)J
 */
JNIEXPORT jlong JNICALL Java_ch_cern_eos_XRootDFileSystem_Mv
  (JNIEnv *, jobject, jlong, jstring, jstring);

/*
 * Class:     ch_cern_eos_XRootDFileSystem
 * Method:    Rm
 * Signature: (JLjava/lang/String;)J
 */
JNIEXPORT jlong JNICALL Java_ch_cern_eos_XRootDFileSystem_Rm
  (JNIEnv *, jobject, jlong, jstring);

/*
 * Class:     ch_cern_eos_XRootDFileSystem
 * Method:    MkDir
 * Signature: (JLjava/lang/String;S)J
 */
JNIEXPORT jlong JNICALL Java_ch_cern_eos_XRootDFileSystem_MkDir
  (JNIEnv *, jobject, jlong, jstring, jshort);

/*
 * Class:     ch_cern_eos_XRootDFileSystem
 * Method:    RmDir
 * Signature: (JLjava/lang/String;)J
 */
JNIEXPORT jlong JNICALL Java_ch_cern_eos_XRootDFileSystem_RmDir
  (JNIEnv *, jobject, jlong, jstring);

/*
 * Class:     ch_cern_eos_XRootDFileSystem
 * Method:    Prepare
 * Signature: (J[Ljava/lang/String;I)J
 */
JNIEXPORT jlong JNICALL Java_ch_cern_eos_XRootDFileSystem_Prepare
  (JNIEnv *, jobject, jlong, jobjectArray, jint);

/*
 * Class:     ch_cern_eos_XRootDFileSystem
 * Method:    getErrText
 * Signature: (J)Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_ch_cern_eos_XRootDFileSystem_getErrText
  (JNIEnv *, jobject, jlong);

#ifdef __cplusplus
}
#endif
#endif