//**********************
// テクスチャリスト管理
//**********************

#ifndef	_TEXTURELIST_H_
#define	_TEXTURELIST_H_

#import <OpenGL/CGLMacro.h>
#import <OpenGL/gluMacro.h>

class cTextureList
{
	private :
		struct TextureData
		{
			unsigned int	uiTexID;
			unsigned int	uiRefCount;

			TextureData		*pNext;

			char			szFileName[2048];//[32];
		};

		TextureData		*m_pTextureList;

		bool findTexture( const char *szFileName, unsigned int *puiTexID );

		bool createTexture( const char *szFileName, unsigned int *puiTexID );
		bool createFromBMP( const unsigned char *pData, unsigned int *puiTexID );
		bool createFromTGA( const unsigned char *pData, unsigned int *puiTexID );

		// 2009/07/09 Ru--en
		int  ceilToPowerOfTwo( int number );
		void fitTextureSize( unsigned char **pData, int *width, int *height ); 

		// p_g_
		id<QCPlugInContext> m_qc_context;

	public :
		cTextureList( void );
		~cTextureList( void );

		unsigned int getTexture( const char *szFileName );

		void debugDraw( void );

		void releaseTexture( unsigned int uiTexID );
	
		//p_g_
		void setQCPlugInContext( id<QCPlugInContext>context );
		bool createFromOther( const char *path, unsigned int *puiTexID );

};

#endif	// _TEXTURELIST_H_
