//***************
// VMDモーション
//***************

#include	<stdio.h>
#include	<stdlib.h>
//#include	<stdlib.h>
#include	<string.h>
#include	"VPDPose.h"

//================
// コンストラクタ
//================
cVPDPose::cVPDPose( void ) : m_pPoseDataList( NULL )
{
}

//==============
// デストラクタ
//==============
cVPDPose::~cVPDPose( void )
{
	release();
}

//================
// ファイルの読込
//================
bool cVPDPose::load( const char *szFilePath )
{
	FILE	*pFile;

	//if (_wfopen_s( &pFile, wszFilePath, L"rt" )) {
    /*
     * Updated by: r1cebank
     * Reason: assignment without a (
     * if (pFile= fopen( szFilePath, "rt" ))
     */
	if ((pFile= fopen( szFilePath, "rt" ))) {
		return false;	// ファイルが開けない
	}

	// 読み込み
	bool	bRet = initialize( pFile );
	fclose( pFile );

	return bRet;
}

//=======================================
// データ中の空白文字とコメントを取り除く
//=======================================
void cVPDPose::trim( char *szStr )
{
	char szRet[256];
	int  iR = 0;
	memset( szRet, '\0', sizeof( szRet ) );

	for ( int i = 0; i < sizeof( szRet ); i++ ) {
		if ( szStr[i] == '\0' || szStr[i] == '\r' || szStr[i] == '\n' ) break;	// 文字列の最後か改行
		if ( szStr[i] == ';' ) break;											// セミコロンも文字列の最後と見なす
		if ( szStr[i] == '/' && szStr[i+1] == '/' ) break;						// これ以降コメント
		if ( iR < 1 && ( szStr[i] == ' ' || szStr[i] == '\t' ) ) continue;		// 先頭の空白文字は飛ばす

		// それ以外の文字は残す
		szRet[iR] = szStr[i];
		iR++;
	}
	
	strcpy( szStr, szRet );
}

//====================
// ポーズデータの読込
//====================
bool cVPDPose::initialize( FILE *pFile )
{
	char buf[256];
	int  nBone = 0;					// 読込済みボーン番号
	int  phase = 0;					// 現在何を読込んでいるかを表す
	PoseDataList *pBone = NULL;

	// ヘッダのチェック
	fgets( buf, 256, pFile );
	trim( buf );

	if( strncmp( buf, "Vocaloid Pose Data file", 30 ) != 0 )
		return false;	// ファイル形式が違う

	// 新データが読み込めそうならば過去のデータ解放
	release();

	//-----------------------------------------------------
	// 読込
	while ( !feof( pFile ) ) {
		fgets( buf, 256, pFile );
		trim( buf );

		if ( strlen( buf ) < 1 ) continue;	// 空行なら飛ばす

		if ( phase == 0 ) {
			// 親ファイル名
			//strcpy( szBaseFile, buf );
			phase++;
			continue;
		} else if ( phase == 1 ) {
			// ボーン数
			m_unNumPoseBones = (unsigned int) atoi( buf );
			phase++;
			continue;
		} else if ( phase == 2 ) {
			// 読込み済みボーン数がヘッダーの数以上になったら、終了
			if (nBone >= m_unNumPoseBones) {
				phase++;
				break;	// continue;
			}

			// ボーン構造体作成
			if (pBone == NULL) {
				// 最初のボーンだった場合
				pBone = new PoseDataList();
				m_pPoseDataList = pBone;
			} else {
				// 2番目以降だった場合
				pBone->pNext = new PoseDataList();
				pBone = pBone->pNext;
			}

			// ボーン名
			char* pName = strchr( buf, '{' );
			memset( pBone->szBoneName, '\0', sizeof( pBone->szBoneName ) );
			strncpy( pBone->szBoneName, pName + 1, sizeof( pBone->szBoneName ));

			// ボーン座標
			fgets( buf, 256, pFile );
			trim( buf );
			sscanf(buf, "%f,%f,%f", &(pBone->vecPosition.x), &(pBone->vecPosition.y), &(pBone->vecPosition.z));

			// ボーン回転
			fgets( buf, 256, pFile );
			trim( buf );
			sscanf(buf, "%f,%f,%f,%f", &(pBone->vecRotation.x), &(pBone->vecRotation.y), &(pBone->vecRotation.z), &(pBone->vecRotation.w));

			// 閉じ括弧
			fgets( buf, 256, pFile );

			nBone++;
		} else {
			break;
		}
	}
	return true;
}

//======
// 解放
//======
void cVPDPose::release( void )
{
	// ポーズデータの解放
	PoseDataList	*pPoseTemp = m_pPoseDataList,
					*pNextPoseTemp;

	while( pPoseTemp )
	{
		pNextPoseTemp = pPoseTemp->pNext;

		delete pPoseTemp;

		pPoseTemp = pNextPoseTemp;
	}

	m_pPoseDataList = NULL;
}
