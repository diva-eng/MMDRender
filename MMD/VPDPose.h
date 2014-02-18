//***************
// VPDポーズ
//  ただし0フレーム目だけのモーションとして読み込む
// 2009/08/10 Ru--en
//***************

#ifndef		_VPDPOSE_H_
#define		_VPDPOSE_H_

#include	"PMDTypes.h"

// ボーン毎の座標・回転
struct PoseDataList
{
	char	szBoneName[16];	// ボーン名

	Vector3	vecPosition;	// ボーン座標
	Vector4 vecRotation;	// ボーン回転クォータニオン

	PoseDataList	*pNext;
};

class cVPDPose
{
	private :
		PoseDataList	*m_pPoseDataList;
		int				m_unNumPoseBones;	// ボーン数

		static void trim( char *pStr );

	public :
		cVPDPose( void );
		~cVPDPose( void );

		bool initialize( FILE *pFile );
		void release( void );
		bool load( const char *szFilePath );
		inline PoseDataList *getPotionDataList( void ){ return m_pPoseDataList; }
};

#endif	// _VPDPOSE_H_
