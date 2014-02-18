//*********************************
// PMDコンストレイント(ジョイント)
//*********************************

#ifndef		_PMDCONSTRAINT_H_
#define		_PMDCONSTRAINT_H_

#include	"PMDTypes.h"
#include	"PMDRigidBody.h"
#include	"../BulletPhysics/BulletPhysics.h"


class cPMDConstraint
{
	private :
		btGeneric6DofSpringConstraint	*m_pbtcConstraint;
        
        // p_g_
        cBulletPhysics  *g_clBulletPhysics;

	public :
		cPMDConstraint( void );
		~cPMDConstraint( void );

		bool initialize( const PMD_Constraint *pPMDConstraint, cPMDRigidBody *pRigidBodyA, cPMDRigidBody *pRigidBodyB, cBulletPhysics *bulletPhysics );

		void release( void );
};

#endif	// _PMDCONSTRAINT_H_
