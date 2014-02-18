//*******************************
// VPDポーズ用各種構造体定義
//*******************************

#ifndef	_VPDTYPES_H_
#define	_VPDTYPES_H_

#include	"VecMatQuat.h"

#pragma pack( push, 1 )

// ファイルヘッダ
struct VPD_Header
{
	char	szHeader[30];			// "Vocaloid Pose Data file"
	char	szBaseFile[30];			// 親ファイル名
	unsigned int unNumBones;		// ボーン数
};

// ボーンデータ
struct VPD_Bone
{
	char	szBoneName[15];			// ボーン名

	Vector3	vec3Position;			// 位置
	Vector4	vec4Rotation;			// 回転(クォータニオン)
};

#pragma pack( pop )

#endif	// _VPDTYPES_H_
