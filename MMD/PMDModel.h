//***********
// PMDモデル
//***********

#ifndef	_PMDMODEL_H_
#define	_PMDMODEL_H_

#import <OpenGL/CGLMacro.h>

#include	"PMDTypes.h"
#include	"PMDBone.h"
#include	"PMDIK.h"
#include	"PMDFace.h"
#include	"PMDRigidBody.h"
#include	"PMDConstraint.h"
#include	"MotionPlayer.h"

class cPMDModel
{
	private :
		char			m_szModelName[21];	// モデル名

		unsigned int	m_ulNumVertices;	// 頂点数

		Vector3			*m_pvec3OrgPositionArray;	// 座標配列
		Vector3			*m_pvec3OrgNormalArray;		// 法線配列
		TexUV			*m_puvOrgTexureUVArray;		// テクスチャ座標配列

		struct SkinInfo
		{
			float			fWeight;		// ウェイト
			unsigned short	unBoneNo[2];	// ボーン番号
		};
		SkinInfo		*m_pOrgSkinInfoArray;

		Vector3			*m_pvec3PositionArray;
		Vector3			*m_pvec3NormalArray;

		unsigned int	m_ulNumIndices;		// 頂点インデックス数
		unsigned short	*m_pIndices;		// 頂点インデックス配列

		enum type_TexFlags					// テクスチャとスフィアマップの使用を示すフラグ
		{
			TEXFLAG_NONE	= 0,			// テクスチャもスフィアマップも無し
			TEXFLAG_TEXTURE	= 1,			// テクスチャあり
			TEXFLAG_MAP		= 2,			// スフィアマップあり
			TEXFLAG_ADDMAP	= 4				// 加算型スフィアマップあり（TEXFLAG_MAPと併用不可）
		};

		struct Material
		{
			Color4			col4Diffuse,
							col4Specular,
							col4Ambient;
			float			fShininess;

			unsigned int	ulNumIndices;
			unsigned int	uiTexID;		// テクスチャID
			unsigned int	uiMapID;		// スフィアマップテクスチャID
			bool			bEdgeFlag;		// 輪郭・影の有無
			type_TexFlags	unTexFlag;		// テクスチャとスフィアマップの有無
		};

		unsigned int	m_ulNumMaterials;	// マテリアル数
		Material		*m_pMaterials;		// マテリアル配列

		unsigned short	m_unNumBones;		// ボーン数
		cPMDBone		*m_pBoneArray;		// ボーン配列

		cPMDBone		*m_pNeckBone;		// 首のボーン
		bool			m_bLookAt;			// 首をターゲットへ向けるかどうか

		cPMDBone		*m_pCenterBone;		// センターのボーン

		unsigned short	m_unNumIK;			// IK数
		cPMDIK			*m_pIKArray;		// IK配列

		unsigned short	m_unNumFaces;		// 表情数
		cPMDFace		*m_pFaceArray;		// 表情配列

		unsigned int	m_ulRigidBodyNum;	// 剛体数
		cPMDRigidBody	*m_pRigidBodyArray;	// 剛体配列

		unsigned int	m_ulConstraintNum;	// コンストレイント数
		cPMDConstraint	*m_pConstraintArray;// コンストレイント配列

		cMotionPlayer	m_clMotionPlayer;

		//bool			isSphereMapTexName( const char *szTextureName );	// スフィアマップならばtrue
		type_TexFlags	parseTexName( const char *szTextureName, char *szOutTexName, char *szOutMapName );		// テクスチャ名をテクスチャとスフィアマップに分解

		// p_g_
		id<QCPlugInContext> m_qc_context;
		NSString			*_dataFolderPath;
        cBulletPhysics      *g_clBulletPhysics;
    
	public :
		cPMDModel( void );
		~cPMDModel( void );

		bool load( const char *szFilePath );
		bool initialize( unsigned char *pData, unsigned int ulDataSize );

		cPMDBone *getBoneByName( const char *szBoneName );
		cPMDFace *getFaceByName( const char *szFaceName );

		void setMotion( cVMDMotion *pVMDMotion, bool bLoop = false, float fInterpolateFrame = 0.0f );
		void resetRigidBodyPos( void );

		bool updateMotion( float fElapsedFrame );
		void updateNeckBone( const Vector3 *pvec3LookTarget, float fLimitXD = -20.0f, float fLimitXU = 45.0f, float fLimitY = 80.0f );
		void updateSkinning( void );

		void render( void );
		void renderForShadow( void );

		void release( void );

		inline void toggleLookAtFlag( void ){ m_bLookAt = !m_bLookAt; } 
		inline void setLookAtFlag( bool bFlag ){ m_bLookAt = bFlag; } 

		inline const char *getModelName( void ){ return m_szModelName; } 

		// Ru--en added
		void rewind( void );												// モーションの先頭に戻る
		void setLoop( bool bLoop );											// モーション繰り返し On/Off
		void enablePhysics( bool bEnabled );								// 物理演算 On/Off
		void resetBones( void );											// ボーン位置を再設定
		void applyCentralImpulse( float fVelX, float fVelY, float fVelZ );	// 各剛体に速度を加える
		bool m_bPhysics;													// 物理演算を行うか
		int  m_iDebug;														// デバッグ表示切替
		void getModelPosition( Vector3* pvec3Pos );							// センターボーンの座標を取得

		// p_g_
		void setFace( unsigned int i );
		void blendFace( unsigned int i, float r );
		unsigned int getNumberOfFaces();
		const char *getFaceName(unsigned int i);
		float getCurrentFrame();
		void clearCurrentFrame();
        void setBulletPhysics( cBulletPhysics *bulletPhysics );
        void setQCPlugInContext( id<QCPlugInContext>context );

	friend class cMotionPlayer;
};

#endif	// _PMDMODEL_H_
