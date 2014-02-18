//***************
// VMDモーション
//***************

#ifndef		_VMDMOTION_H_
#define		_VMDMOTION_H_

#include	"PMDTypes.h"
#include	"PMDBone.h"
#include	"VMDTypes.h"
#include	"VMDBezier.h"
#include	"VPDPose.h"

// ボーン対象のキーフレームデータ
struct BoneKeyFrame
{
	float	fFrameNo;		// フレーム番号

	Vector3	vec3Position;	// 位置
	Vector4	vec4Rotation;	// 回転(クォータニオン)

	cVMDBezier	clPosXInterBezier;	// X軸移動補間
	cVMDBezier	clPosYInterBezier;	// Y軸移動補間
	cVMDBezier	clPosZInterBezier;	// Z軸移動補間
	cVMDBezier	clRotInterBezier;	// 回転補間
};

// ボーンごとのキーフレームデータのリスト
struct MotionDataList
{
	char	szBoneName[16];			// ボーン名

	unsigned int	ulNumKeyFrames;	// キーフレーム数
	BoneKeyFrame	*pKeyFrames;	// キーフレームデータ配列

	MotionDataList	*pNext;
};

// 表情のキーフレームデータ
struct FaceKeyFrame
{
	float	fFrameNo;		// フレーム番号
	float	fRate;			// フレンド率
};

// 表情ごとのキーフレームデータのリスト
struct FaceDataList
{
	char	szFaceName[16];	// 表情名

	unsigned int	ulNumKeyFrames;	// キーフレーム数
	FaceKeyFrame	*pKeyFrames;	// キーフレームデータ配列

	FaceDataList	*pNext;
};


class cVMDMotion
{
	private :
		MotionDataList		*m_pMotionDataList;	// ボーンごとのキーフレームデータのリスト
		unsigned int		m_ulNumMotionNodes;	// ボーンモーションのノード数

		FaceDataList		*m_pFaceDataList;	// 表情ごとのキーフレームデータのリスト
		unsigned int		m_ulNumFaceNodes;	// 表情モーションのノード数

		float				m_fMaxFrame;		// 最後のフレーム番号

	public :
		cVMDMotion( void );
		~cVMDMotion( void );

		bool load( const char *szFilePath );
		bool initialize( unsigned char *pData );

		void release( void );

		inline MotionDataList *getMotionDataList( void ){ return m_pMotionDataList; }
		inline unsigned int getNumMotionNodes( void ){ return m_ulNumMotionNodes; }

		inline FaceDataList *getFaceDataList( void ){ return m_pFaceDataList; }
		inline unsigned int getNumFaceNodes( void ){ return m_ulNumFaceNodes; }

		inline float getMaxFrame( void ){ return m_fMaxFrame; }

		void import( cVPDPose *pPose );
};

#endif	// _VMDMOTION_H_
