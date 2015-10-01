/*
 
 Copyright (c) 2010.
 Lawrence Livermore National Security, LLC.
 Produced at the Lawrence Livermore National Laboratory.
 LLNL-CODE-461231
 All rights reserved.
 
 This file is part of LULESH, Version 1.0.
 Please also read this link -- http://www.opensource.org/licenses/index.php
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the disclaimer below.
 
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the disclaimer (as noted below)
 in the documentation and/or other materials provided with the
 distribution.
 
 * Neither the name of the LLNS/LLNL nor the names of its contributors
 may be used to endorse or promote products derived from this software
 without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL LAWRENCE LIVERMORE NATIONAL SECURITY, LLC,
 THE U.S. DEPARTMENT OF ENERGY OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 
 Additional BSD Notice
 
 1. This notice is required to be provided under our contract with the U.S.
 Department of Energy (DOE). This work was produced at Lawrence Livermore
 National Laboratory under Contract No. DE-AC52-07NA27344 with the DOE.
 
 2. Neither the United States Government nor Lawrence Livermore National
 Security, LLC nor any of their employees, makes any warranty, express
 or implied, or assumes any liability or responsibility for the accuracy,
 completeness, or usefulness of any information, apparatus, product, or
 process disclosed, or represents that its use would not infringe
 privately-owned rights.
 
 3. Also, reference herein to any specific commercial products, process, or
 services by trade name, trademark, manufacturer or otherwise does not
 necessarily constitute or imply its endorsement, recommendation, or
 favoring by the United States Government or Lawrence Livermore National
 Security, LLC. The views and opinions of authors expressed herein do not
 necessarily state or reflect those of the United States Government or
 Lawrence Livermore National Security, LLC, and shall not be used for
 advertising or product endorsement purposes.
 
 
 
 Additional Algorithm Notice
   
 This version also reduces the number of OpenMP parallel loops (to reduce
 start and stop overhead) by merging what were disparate loops spread across
 multiple functions.  There are six parallel loops for the nodal step and 
 six for the Element step.    

Also the code increases the amount of vectorization to upto 88%, simulates 
using a global scratch pad and merges 10 sets of arrays as array of structs
 
 */

#include <vector>
#include "cycle.h"
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <string.h>
#include <ctype.h>

#ifdef _OPENMP
#include <omp.h>
#else
int omp_get_thread_num() { return 0; }
int omp_get_max_threads() { return 1; }
#endif


#define LULESH_SHOW_PROGRESS 1
#define GATHER_MICRO_TIMING 0
#define VEC_LEN 4

enum { VolumeError  = -1, 
	   QStopError   = -2, 
	   FaceError    = -3,
	   MatMultError = -4,
	   PhiCalcError = -5,
	   FindPosError = -6,
       GetBCError   = -7  } ;

enum { X_Dir  = 0,
	   Y_Dir  = 1,
	   Z_Dir  = 2    } ;

enum  { X_BC = 1,
	    Y_BC = 2,
	    Z_BC = 4    } ;

/****************************************************/
/* Allow flexibility for arithmetic representations */
/****************************************************/

/* Could also support fixed point and interval arithmetic types */
typedef float        real4 ;
typedef double       real8 ;
typedef long double  real10 ;  /* 10 bytes on x86 */

typedef int    Index_t ; /* array subscript and loop index */
typedef real8  Real_t ;  /* floating point representation */
typedef int    Int_t ;   /* integer representation */

inline real4  SQRT(real4  arg) { return sqrtf(arg) ; }
inline real8  SQRT(real8  arg) { return sqrt(arg) ; }
inline real10 SQRT(real10 arg) { return sqrtl(arg) ; }

inline real4  CBRT(real4  arg) { return cbrtf(arg) ; }
inline real8  CBRT(real8  arg) { return cbrt(arg) ; }
inline real10 CBRT(real10 arg) { return cbrtl(arg) ; }

inline real4  FABS(real4  arg) { return fabsf(arg) ; }
inline real8  FABS(real8  arg) { return fabs(arg) ; }
inline real10 FABS(real10 arg) { return fabsl(arg) ; }

#ifdef GATHER_MICRO_TIMING
double elapsed_time[12];
#endif


/************************************************************/
/* Allow for flexible data layout experiments by separating */
/* array interface from underlying implementation.          */
/************************************************************/

struct Domain {
	
	/* This first implementation allows for runnable code */
	/* and is not meant to be optimal. Final implementation */
	/* should separate declaration and allocation phases */
	/* so that allocation can be scheduled in a cache conscious */
	/* manner. */
	
public:
	
	/**************/
	/* Allocation */
	/**************/
	struct Vec2Init { Real_t x, y ; Vec2Init(Real_t init_val) { x = y = init_val ; } } ;
        struct Vec3Init { Real_t x, y, z ; Vec3Init() { x = y = z = Real_t(0.0) ; } } ;
        struct Vec3Init_2 { Real_t x1, y1, z1, x2, y2, z2 ; Vec3Init_2() { x1 = y1 = z1 = x2 = y2 = z2 = Real_t(0.0) ; } } ;
	
	void AllocateNodalPersistent(size_t size)
	{
	//	m_coord_vel.resize(size, Vec3Init_2());        /*  Combined Coord  and velocity   */
		m_coord.resize(size);
                m_vel.resize(size, Vec3Init());
		m_acc.resize(size,       Vec3Init());          /*  x, y, z Accelerations          */
                m_force.resize(size);                          /*  x, y, z Froces                 */

		

/*		m_x.resize(size) ;
                m_y.resize(size) ;
                m_z.resize(size) ;

                m_xd.resize(size, Real_t(0.)) ;
                m_yd.resize(size, Real_t(0.)) ;
                m_zd.resize(size, Real_t(0.)) ;*/

              /*  m_xdd.resize(size, Real_t(0.)) ;
                m_ydd.resize(size, Real_t(0.)) ;
                m_zdd.resize(size, Real_t(0.)) ;

                m_fx.resize(size) ;
                m_fy.resize(size) ;
                m_fz.resize(size) ;*/

	
		m_nodalMass.resize(size, Real_t(0.)) ;
	}
	
	void AllocateElemPersistent(size_t size)
	{
		m_matElemlist.resize(size) ;
		m_nodelist.resize(8*size) ;
		
		m_lxim.resize(size) ;
		m_lxip.resize(size) ;
		m_letam.resize(size) ;
		m_letap.resize(size) ;
		m_lzetam.resize(size) ;
		m_lzetap.resize(size) ;
		
		m_elemBC.resize(size) ;
		
		m_e.resize(size, Real_t(0.)) ;

		/*m_p.resize(size, Real_t(0.)) ;
                m_q.resize(size) ;
                m_ql.resize(size) ;
                m_qq.resize(size) ;		*/

		m_p_q.resize(size, Vec2Init(Real_t(0.))) ;     /*  Combined p  and q      */
                m_ql_qq.resize(size) ;                         /*  Combined ql and qq     */
		
		m_v.resize(size, 1.0) ;
		m_volo.resize(size) ;
		m_delv.resize(size) ;
		m_vdov.resize(size) ;
		
		m_arealg.resize(size) ;
		
		m_ss.resize(size) ;
		
		m_elemMass.resize(size) ;
	}
	
	/* Temporaries should not be initialized in bulk but */
	/* this is a runnable placeholder for now */
	void AllocateElemTemporary(size_t size)
	{

		/* m_dxx.resize(size) ;
                m_dyy.resize(size) ;
                m_dzz.resize(size) ;

                m_delv_xi.resize(size) ;
                m_delv_eta.resize(size) ;
                m_delv_zeta.resize(size) ;

                m_delx_xi.resize(size) ;
                m_delx_eta.resize(size) ;
                m_delx_zeta.resize(size) ;*/

		 m_Prin_Strains.resize(size) ;

                  m_delv_xez.resize(size) ;

                m_delx_xez.resize(size) ;
	
		m_vnew.resize(size) ;

		

		m_f_elem.resize(size*8);
                //m_fy_elem.resize(size*8);
                //m_fz_elem.resize(size*8);

                m_determ.resize(size);
	}
	
	void AllocateNodesets(size_t size)
	{
		m_symmX.resize(size) ;
		m_symmY.resize(size) ;
		m_symmZ.resize(size) ;
	}
	
	void AllocateNodeElemIndexes()
	{
		Index_t m;
		Index_t numElem = this->numElem() ;
		Index_t numNode = this->numNode() ;
		
		/* set up node-centered indexing of elements */
		m_nodeElemCount.resize(numNode);
		
		for (Index_t i=0;i<numNode;++i) {
			nodeElemCount(i)=0;
		}
		
		for (Index_t i=0; i<numElem; ++i) {
			Index_t *nl = nodelist(i) ;
			for (Index_t j=0; j < 8; ++j) {
				++nodeElemCount(nl[j]);
			}
		}
		
		m_nodeElemStart.resize(numNode);
		
		nodeElemStart(0)=0;
		
		for (Index_t i=1; i < numNode; ++i) {
			nodeElemStart(i) = nodeElemStart(i-1) + nodeElemCount(i-1) ;
		}
		
		//       m_nodeElemList.resize(nodeElemStart(numNode-1) +
		//                             nodeElemCount(numNode-1));
		
		m_nodeElemCornerList.resize(nodeElemStart(numNode-1) +
									nodeElemCount(numNode-1));
		
		for (Index_t i=0; i < numNode; ++i) {
			nodeElemCount(i)=0;
		}
		
		for (Index_t i=0; i < numElem; ++i) {
			Index_t *nl = nodelist(i) ;
			for (Index_t j=0; j < 8; ++j) {
				Index_t m = nl[j];
				Index_t k = i*8 + j ;
				Index_t offset = nodeElemStart(m)+nodeElemCount(m) ;
				//             nodeElemList(offset) = i;
				nodeElemCornerList(offset) = k;
				++nodeElemCount(m);
			}
		}
		
		Index_t clSize = m_nodeElemCornerList.size() ;
		for (Index_t i=0; i < clSize; ++i) {
			Index_t clv = nodeElemCornerList(i) ;
			if ((clv < 0) || (clv > numElem*8)) {
				fprintf(stderr,
						"AllocateNodeElemIndexes(): nodeElemCornerList entry out of range!\n");
				exit(1);
			}
		}
	}
	
	
	/**********/
	/* Access */
	/**********/
	
	/* Node-centered */

	Real_t& x(Index_t idx)    { return m_coord[idx].x ; }
        Real_t& y(Index_t idx)    { return m_coord[idx].y ; }
        Real_t& z(Index_t idx)    { return m_coord[idx].z ; }

        Real_t& xd(Index_t idx)   { return m_vel[idx].x ; }
        Real_t& yd(Index_t idx)   { return m_vel[idx].y ; }
        Real_t& zd(Index_t idx)   { return m_vel[idx].z ; }

	Real_t& xdd(Index_t idx)  { return m_acc[idx].x ; }
        Real_t& ydd(Index_t idx)  { return m_acc[idx].y ; }
        Real_t& zdd(Index_t idx)  { return m_acc[idx].z ; }

        Real_t& fx(Index_t idx)   { return m_force[idx].x ; }
        Real_t& fy(Index_t idx)   { return m_force[idx].y ; }
        Real_t& fz(Index_t idx)   { return m_force[idx].z ; }


/*	Real_t& x(Index_t idx)    { return m_x[idx] ; }
        Real_t& y(Index_t idx)    { return m_y[idx] ; }
        Real_t& z(Index_t idx)    { return m_z[idx] ; }

        Real_t& xd(Index_t idx)   { return m_xd[idx] ; }
        Real_t& yd(Index_t idx)   { return m_yd[idx] ; }
        Real_t& zd(Index_t idx)   { return m_zd[idx] ; }

        Real_t& xdd(Index_t idx)  { return m_xdd[idx] ; }
        Real_t& ydd(Index_t idx)  { return m_ydd[idx] ; }
        Real_t& zdd(Index_t idx)  { return m_zdd[idx] ; }

        Real_t& fx(Index_t idx)   { return m_fx[idx] ; }
        Real_t& fy(Index_t idx)   { return m_fy[idx] ; }
        Real_t& fz(Index_t idx)   { return m_fz[idx] ; }*/
	
	Real_t& nodalMass(Index_t idx) { return m_nodalMass[idx] ; }
	
	Index_t& symmX(Index_t idx) { return m_symmX[idx] ; }
	Index_t& symmY(Index_t idx) { return m_symmY[idx] ; }
	Index_t& symmZ(Index_t idx) { return m_symmZ[idx] ; }
	
	Index_t& nodeElemCount(Index_t idx) { return m_nodeElemCount[idx] ; }
	Index_t& nodeElemStart(Index_t idx) { return m_nodeElemStart[idx] ; }
	//   Index_t& nodeElemList(Index_t idx)  { return m_nodeElemList[idx] ; }
	Index_t& nodeElemCornerList(Index_t i) { return m_nodeElemCornerList[i] ; }
	
	/* Element-centered */
	
	Index_t&  matElemlist(Index_t idx) { return m_matElemlist[idx] ; }
	Index_t*  nodelist(Index_t idx)    { return &m_nodelist[Index_t(8)*idx] ; }
	
	Index_t&  lxim(Index_t idx) { return m_lxim[idx] ; }
	Index_t&  lxip(Index_t idx) { return m_lxip[idx] ; }
	Index_t&  letam(Index_t idx) { return m_letam[idx] ; }
	Index_t&  letap(Index_t idx) { return m_letap[idx] ; }
	Index_t&  lzetam(Index_t idx) { return m_lzetam[idx] ; }
	Index_t&  lzetap(Index_t idx) { return m_lzetap[idx] ; }
	
	Int_t&  elemBC(Index_t idx) { return m_elemBC[idx] ; }

	/*Real_t& dxx(Index_t idx)  { return m_dxx[idx] ; }
        Real_t& dyy(Index_t idx)  { return m_dyy[idx] ; }
        Real_t& dzz(Index_t idx)  { return m_dzz[idx] ; }

        Real_t& delv_xi(Index_t idx)    { return m_delv_xi[idx] ; }
        Real_t& delv_eta(Index_t idx)   { return m_delv_eta[idx] ; }
        Real_t& delv_zeta(Index_t idx)  { return m_delv_zeta[idx] ; }

        Real_t& delx_xi(Index_t idx)    { return m_delx_xi[idx] ; }
        Real_t& delx_eta(Index_t idx)   { return m_delx_eta[idx] ; }
        Real_t& delx_zeta(Index_t idx)  { return m_delx_zeta[idx] ; }*/

	Real_t& dxx(Index_t idx)  { return m_Prin_Strains[idx].x ; }
        Real_t& dyy(Index_t idx)  { return m_Prin_Strains[idx].y ; }
        Real_t& dzz(Index_t idx)  { return m_Prin_Strains[idx].z ; }

        Real_t& delv_xi(Index_t idx)    { return m_delv_xez[idx].x ; }
        Real_t& delv_eta(Index_t idx)   { return m_delv_xez[idx].y ; }
        Real_t& delv_zeta(Index_t idx)  { return m_delv_xez[idx].z ; }

        Real_t& delx_xi(Index_t idx)    { return m_delx_xez[idx].x ; }
        Real_t& delx_eta(Index_t idx)   { return m_delx_xez[idx].y ; }
        Real_t& delx_zeta(Index_t idx)  { return m_delx_xez[idx].z ; }
	
	Real_t& e(Index_t idx)          { return m_e[idx] ; }

/*	Real_t& p(Index_t idx)          { return m_p[idx] ; }
        Real_t& q(Index_t idx)          { return m_q[idx] ; }
        Real_t& ql(Index_t idx)         { return m_ql[idx] ; }
        Real_t& qq(Index_t idx)         { return m_qq[idx] ; }	*/
	
	Real_t& p(Index_t idx)          { return m_p_q[idx].x ; }
        Real_t& q(Index_t idx)          { return m_p_q[idx].y ; }

        Real_t& ql(Index_t idx)         { return m_ql_qq[idx].x ; }
        Real_t& qq(Index_t idx)         { return m_ql_qq[idx].y ;  }
	
	Real_t& v(Index_t idx)          { return m_v[idx] ; }
	Real_t& volo(Index_t idx)       { return m_volo[idx] ; }
	Real_t& vnew(Index_t idx)       { return m_vnew[idx] ; }
	Real_t& delv(Index_t idx)       { return m_delv[idx] ; }
	Real_t& vdov(Index_t idx)       { return m_vdov[idx] ; }

/*	Real_t& fx_elem(Index_t idx)       { return m_fx_elem[idx] ; }
        Real_t& fy_elem(Index_t idx)       { return m_fy_elem[idx] ; }
        Real_t& fz_elem(Index_t idx)       { return m_fz_elem[idx] ; }*/
	Real_t& fx_elem(Index_t idx)       { return m_f_elem[idx].x ; }
        Real_t& fy_elem(Index_t idx)       { return m_f_elem[idx].y ; }
        Real_t& fz_elem(Index_t idx)       { return m_f_elem[idx].z ; }
        Real_t& determ(Index_t idx)       { return m_determ[idx] ; }

	
	Real_t& arealg(Index_t idx)     { return m_arealg[idx] ; }
	
	Real_t& ss(Index_t idx)         { return m_ss[idx] ; }
	
	Real_t& elemMass(Index_t idx)  { return m_elemMass[idx] ; }
	
	/* Params */
	
	Real_t& dtfixed()              { return m_dtfixed ; }
	Real_t& time()                 { return m_time ; }
	Real_t& deltatime()            { return m_deltatime ; }
	Real_t& deltatimemultlb()      { return m_deltatimemultlb ; }
	Real_t& deltatimemultub()      { return m_deltatimemultub ; }
	Real_t& stoptime()             { return m_stoptime ; }
	
	Real_t& u_cut()                { return m_u_cut ; }
	Real_t& hgcoef()               { return m_hgcoef ; }
	Real_t& qstop()                { return m_qstop ; }
	Real_t& monoq_max_slope()      { return m_monoq_max_slope ; }
	Real_t& monoq_limiter_mult()   { return m_monoq_limiter_mult ; }
	Real_t& e_cut()                { return m_e_cut ; }
	Real_t& p_cut()                { return m_p_cut ; }
	Real_t& ss4o3()                { return m_ss4o3 ; }
	Real_t& q_cut()                { return m_q_cut ; }
	Real_t& v_cut()                { return m_v_cut ; }
	Real_t& qlc_monoq()            { return m_qlc_monoq ; }
	Real_t& qqc_monoq()            { return m_qqc_monoq ; }
	Real_t& qqc()                  { return m_qqc ; }
	Real_t& eosvmax()              { return m_eosvmax ; }
	Real_t& eosvmin()              { return m_eosvmin ; }
	Real_t& pmin()                 { return m_pmin ; }
	Real_t& emin()                 { return m_emin ; }
	Real_t& dvovmax()              { return m_dvovmax ; }
	Real_t& refdens()              { return m_refdens ; }
	
	Real_t& dtcourant()            { return m_dtcourant ; }
	Real_t& dthydro()              { return m_dthydro ; }
	Real_t& dtmax()                { return m_dtmax ; }
	
	Int_t&  cycle()                { return m_cycle ; }
	
	Index_t&  sizeX()              { return m_sizeX ; }
	Index_t&  sizeY()              { return m_sizeY ; }
	Index_t&  sizeZ()              { return m_sizeZ ; }
	Index_t&  numElem()            { return m_numElem ; }
	Index_t&  numNode()            { return m_numNode ; }
	
private:
	
	/******************/
	/* Implementation */
	/******************/
	
	/* Node-centered */

	struct Vec3 { Real_t x[8],y[8],z[8];};
        struct Vec3_2 { Real_t x,y,z;};
        struct Vec2 { Real_t x,y;};

        std::vector<Vec3_2> m_coord;      /* coordinates and velocities   */
        std::vector<Vec3Init> m_vel;      /* coordinates and velocities   */
	std::vector<Vec3Init>   m_acc;            /* accelerations                */
        std::vector<Vec3Init>   m_force;          /* forces                       */
	
        //std::vector<Real_t> m_x ;  /* coordinates */
        //std::vector<Real_t> m_y ;
        //std::vector<Real_t> m_z ;

        //std::vector<Real_t> m_xd ; /* velocities */
        //std::vector<Real_t> m_yd ;
        //std::vector<Real_t> m_zd ;

        //std::vector<Real_t> m_xdd ; /* accelerations */
        //std::vector<Real_t> m_ydd ;
        //std::vector<Real_t> m_zdd ;

        //std::vector<Real_t> m_fx ;  /* forces */
        //std::vector<Real_t> m_fy ;
        //std::vector<Real_t> m_fz ;
	
	std::vector<Real_t> m_nodalMass ;  /* mass */
	
	std::vector<Index_t> m_symmX ;  /* symmetry plane nodesets */
	std::vector<Index_t> m_symmY ;
	std::vector<Index_t> m_symmZ ;
	
	std::vector<Index_t> m_nodeElemCount ;
	std::vector<Index_t> m_nodeElemStart ;
	//   std::vector<Index_t> m_nodeElemList ;
	std::vector<Index_t> m_nodeElemCornerList ;
	
	/* Element-centered */
	
	std::vector<Index_t>  m_matElemlist ;  /* material indexset */
	std::vector<Index_t>  m_nodelist ;     /* elemToNode connectivity */
	
	std::vector<Index_t>  m_lxim ;  /* element connectivity across each face */
	std::vector<Index_t>  m_lxip ;
	std::vector<Index_t>  m_letam ;
	std::vector<Index_t>  m_letap ;
	std::vector<Index_t>  m_lzetam ;
	std::vector<Index_t>  m_lzetap ;
	
	std::vector<Int_t>    m_elemBC ;  /* symmetry/free-surface flags for each elem face */

  	//std::vector<Real_t> m_dxx ;  /* principal strains -- temporary */
        //std::vector<Real_t> m_dyy ;
        //std::vector<Real_t> m_dzz ;

        //std::vector<Real_t> m_delv_xi ;    /* velocity gradient -- temporary */
        //std::vector<Real_t> m_delv_eta ;
        //std::vector<Real_t> m_delv_zeta ;

        //std::vector<Real_t> m_delx_xi ;    /* coordinate gradient -- temporary */
        //std::vector<Real_t> m_delx_eta ;
        //std::vector<Real_t> m_delx_zeta ;
        
	std::vector<Vec3_2>   m_Prin_Strains ;  /* principal strains -- old dxx, dyy, dzz */

        std::vector<Vec3_2> m_delv_xez ;    /* velocity gradient -- temporary */

        std::vector<Vec3_2> m_delx_xez ;    /* coordinate gradient -- temporary */
	
	std::vector<Real_t> m_e ;   /* energy */
	
//	std::vector<Real_t> m_p ;   /* pressure */
  //      std::vector<Real_t> m_q ;   /* q */
    //    std::vector<Real_t> m_ql ;  /* linear term for q */
      //  std::vector<Real_t> m_qq ;  /* quadratic term for q */
      //
        std::vector<Vec2Init> m_p_q   ;    /* pressure  and q                        */
        std::vector<Vec2> m_ql_qq ;        /* linear and quadratic terms for q       */
	
	std::vector<Real_t> m_v ;     /* relative volume */
	std::vector<Real_t> m_volo ;  /* reference volume */
	std::vector<Real_t> m_vnew ;  /* new relative volume -- temporary */
	std::vector<Real_t> m_delv ;  /* m_vnew - m_v */
	std::vector<Real_t> m_vdov ;  /* volume derivative over volume */

//	std::vector<Real_t> m_fx_elem;
//	std::vector<Real_t> m_fy_elem;
//	std::vector<Real_t> m_fz_elem;
	std::vector<Vec3_2> m_f_elem;

        std::vector<Real_t> m_determ;

	
	std::vector<Real_t> m_arealg ;  /* characteristic length of an element */
	
	std::vector<Real_t> m_ss ;      /* "sound speed" */
	
	std::vector<Real_t> m_elemMass ;  /* mass */
	
	/* Parameters */
	
	Real_t  m_dtfixed ;           /* fixed time increment */
	Real_t  m_time ;              /* current time */
	Real_t  m_deltatime ;         /* variable time increment */
	Real_t  m_deltatimemultlb ;
	Real_t  m_deltatimemultub ;
	Real_t  m_stoptime ;          /* end time for simulation */
	
	Real_t  m_u_cut ;             /* velocity tolerance */
	Real_t  m_hgcoef ;            /* hourglass control */
	Real_t  m_qstop ;             /* excessive q indicator */
	Real_t  m_monoq_max_slope ;
	Real_t  m_monoq_limiter_mult ;
	Real_t  m_e_cut ;             /* energy tolerance */
	Real_t  m_p_cut ;             /* pressure tolerance */
	Real_t  m_ss4o3 ;
	Real_t  m_q_cut ;             /* q tolerance */
	Real_t  m_v_cut ;             /* relative volume tolerance */
	Real_t  m_qlc_monoq ;         /* linear term coef for q */
	Real_t  m_qqc_monoq ;         /* quadratic term coef for q */
	Real_t  m_qqc ;
	Real_t  m_eosvmax ;
	Real_t  m_eosvmin ;
	Real_t  m_pmin ;              /* pressure floor */
	Real_t  m_emin ;              /* energy floor */
	Real_t  m_dvovmax ;           /* maximum allowable volume change */
	Real_t  m_refdens ;           /* reference density */
	
	Real_t  m_dtcourant ;         /* courant constraint */
	Real_t  m_dthydro ;           /* volume change constraint */
	Real_t  m_dtmax ;             /* maximum allowable time increment */
	
	Int_t   m_cycle ;             /* iteration count for simulation */
	
	Index_t   m_sizeX ;           /* X,Y,Z extent of this block */
	Index_t   m_sizeY ;
	Index_t   m_sizeZ ;
	
	Index_t   m_numElem ;         /* Elements/Nodes in this domain */
	Index_t   m_numNode ;
} domain ;


template <typename T>
T *Allocate(size_t size)
{
	return static_cast<T *>(malloc(sizeof(T)*size)) ;
}

template <typename T>
void Release(T **ptr)
{
	if (*ptr != NULL) {
		free(*ptr) ;
		*ptr = NULL ;
	}
}


/* Stuff needed for boundary conditions */
/* 2 BCs on each of 6 hexahedral faces (12 bits) */
#define XI_M        0x003
#define XI_M_SYMM   0x001
#define XI_M_FREE   0x002

#define XI_P        0x00c
#define XI_P_SYMM   0x004
#define XI_P_FREE   0x008

#define ETA_M       0x030
#define ETA_M_SYMM  0x010
#define ETA_M_FREE  0x020

#define ETA_P       0x0c0
#define ETA_P_SYMM  0x040
#define ETA_P_FREE  0x080

#define ZETA_M      0x300
#define ZETA_M_SYMM 0x100
#define ZETA_M_FREE 0x200

#define ZETA_P      0xc00
#define ZETA_P_SYMM 0x400
#define ZETA_P_FREE 0x800

/* Constant array needed in HourGlass calcuations */

Real_t  Gamma[4][8];



static inline
void CollectElemPositions(const Index_t*  elemToNode,
						  Real_t    ElemPos[8][3]  )
{
	for( Index_t lnode=0 ; lnode<8 ; ++lnode )
    {
		Index_t  gnode    = elemToNode[lnode];
		ElemPos[lnode][0] = domain.x(gnode);
		ElemPos[lnode][1] = domain.y(gnode);
		ElemPos[lnode][2] = domain.z(gnode);
	}
}


static inline
void CollectElemVelocities(const Index_t*  elemToNode,
						   Real_t    ElemVel[8][3]  )
{
	for( Index_t lnode=0 ; lnode<8 ; ++lnode )
    {
		Index_t  gnode    = elemToNode[lnode];
		ElemVel[lnode][0] = domain.xd(gnode);
		ElemVel[lnode][1] = domain.yd(gnode);
		ElemVel[lnode][2] = domain.zd(gnode);
	}
}



static inline
void TimeIncrement()
{
	Real_t targetdt = domain.stoptime() - domain.time() ;
	
	if ((domain.dtfixed() <= Real_t(0.0)) && (domain.cycle() != Int_t(0))) {
		Real_t ratio ;
		Real_t olddt = domain.deltatime() ;
		
		/* This will require a reduction in parallel */
		Real_t newdt = Real_t(1.0e+20) ;
		if (domain.dtcourant() < newdt) {
			newdt = domain.dtcourant() / Real_t(2.0) ;
		}
		if (domain.dthydro() < newdt) {
			newdt = domain.dthydro() * Real_t(2.0) / Real_t(3.0) ;
		}
		
		ratio = newdt / olddt ;
		if (ratio >= Real_t(1.0)) {
			if (ratio < domain.deltatimemultlb()) {
				newdt = olddt ;
			}
			else if (ratio > domain.deltatimemultub()) {
				newdt = olddt*domain.deltatimemultub() ;
			}
		}
		
		if (newdt > domain.dtmax()) {
			newdt = domain.dtmax() ;
		}
		domain.deltatime() = newdt ;
	}
	
	/* TRY TO PREVENT VERY SMALL SCALING ON THE NEXT CYCLE */
	if ((targetdt > domain.deltatime()) &&
		(targetdt < (Real_t(4.0) * domain.deltatime() / Real_t(3.0))) ) {
		targetdt = Real_t(2.0) * domain.deltatime() / Real_t(3.0) ;
	}
	
	if (targetdt < domain.deltatime()) {
		domain.deltatime() = targetdt ;
	}
	
	domain.time() += domain.deltatime() ;
	
	++domain.cycle() ;
}

static inline
void InitStressTermsForElems(Index_t ElemId, 
                             Real_t *sigxx, Real_t *sigyy, Real_t *sigzz)
{
	//
	// pull in the stresses appropriate to the hydro integration
	//
		*sigxx =  *sigyy = *sigzz =  - domain.p(ElemId) - domain.q(ElemId) ;
}

static inline
void CalcElemShapeFunctionDerivatives( const Real_t* const x,
									  const Real_t* const y,
									  const Real_t* const z,
									  Real_t b[][8],
									  Real_t* const volume )
{
	const Real_t x0 = x[0] ;   const Real_t x1 = x[1] ;
	const Real_t x2 = x[2] ;   const Real_t x3 = x[3] ;
	const Real_t x4 = x[4] ;   const Real_t x5 = x[5] ;
	const Real_t x6 = x[6] ;   const Real_t x7 = x[7] ;
	
	const Real_t y0 = y[0] ;   const Real_t y1 = y[1] ;
	const Real_t y2 = y[2] ;   const Real_t y3 = y[3] ;
	const Real_t y4 = y[4] ;   const Real_t y5 = y[5] ;
	const Real_t y6 = y[6] ;   const Real_t y7 = y[7] ;
	
	const Real_t z0 = z[0] ;   const Real_t z1 = z[1] ;
	const Real_t z2 = z[2] ;   const Real_t z3 = z[3] ;
	const Real_t z4 = z[4] ;   const Real_t z5 = z[5] ;
	const Real_t z6 = z[6] ;   const Real_t z7 = z[7] ;
	
	Real_t fjxxi, fjxet, fjxze;
	Real_t fjyxi, fjyet, fjyze;
	Real_t fjzxi, fjzet, fjzze;
	Real_t cjxxi, cjxet, cjxze;
	Real_t cjyxi, cjyet, cjyze;
	Real_t cjzxi, cjzet, cjzze;
	
	fjxxi = .125 * ( (x6-x0) + (x5-x3) - (x7-x1) - (x4-x2) );
	fjxet = .125 * ( (x6-x0) - (x5-x3) + (x7-x1) - (x4-x2) );
	fjxze = .125 * ( (x6-x0) + (x5-x3) + (x7-x1) + (x4-x2) );
	
	fjyxi = .125 * ( (y6-y0) + (y5-y3) - (y7-y1) - (y4-y2) );
	fjyet = .125 * ( (y6-y0) - (y5-y3) + (y7-y1) - (y4-y2) );
	fjyze = .125 * ( (y6-y0) + (y5-y3) + (y7-y1) + (y4-y2) );
	
	fjzxi = .125 * ( (z6-z0) + (z5-z3) - (z7-z1) - (z4-z2) );
	fjzet = .125 * ( (z6-z0) - (z5-z3) + (z7-z1) - (z4-z2) );
	fjzze = .125 * ( (z6-z0) + (z5-z3) + (z7-z1) + (z4-z2) );
	
	/* compute cofactors */
	cjxxi =    (fjyet * fjzze) - (fjzet * fjyze);
	cjxet =  - (fjyxi * fjzze) + (fjzxi * fjyze);
	cjxze =    (fjyxi * fjzet) - (fjzxi * fjyet);
	
	cjyxi =  - (fjxet * fjzze) + (fjzet * fjxze);
	cjyet =    (fjxxi * fjzze) - (fjzxi * fjxze);
	cjyze =  - (fjxxi * fjzet) + (fjzxi * fjxet);
	
	cjzxi =    (fjxet * fjyze) - (fjyet * fjxze);
	cjzet =  - (fjxxi * fjyze) + (fjyxi * fjxze);
	cjzze =    (fjxxi * fjyet) - (fjyxi * fjxet);
	
	/* calculate partials :
     this need only be done for l = 0,1,2,3   since , by symmetry ,
     (6,7,4,5) = - (0,1,2,3) .
	 */
	b[0][0] =   -  cjxxi  -  cjxet  -  cjxze;
	b[0][1] =      cjxxi  -  cjxet  -  cjxze;
	b[0][2] =      cjxxi  +  cjxet  -  cjxze;
	b[0][3] =   -  cjxxi  +  cjxet  -  cjxze;
	b[0][4] = -b[0][2];
	b[0][5] = -b[0][3];
	b[0][6] = -b[0][0];
	b[0][7] = -b[0][1];
	
	b[1][0] =   -  cjyxi  -  cjyet  -  cjyze;
	b[1][1] =      cjyxi  -  cjyet  -  cjyze;
	b[1][2] =      cjyxi  +  cjyet  -  cjyze;
	b[1][3] =   -  cjyxi  +  cjyet  -  cjyze;
	b[1][4] = -b[1][2];
	b[1][5] = -b[1][3];
	b[1][6] = -b[1][0];
	b[1][7] = -b[1][1];
	
	b[2][0] =   -  cjzxi  -  cjzet  -  cjzze;
	b[2][1] =      cjzxi  -  cjzet  -  cjzze;
	b[2][2] =      cjzxi  +  cjzet  -  cjzze;
	b[2][3] =   -  cjzxi  +  cjzet  -  cjzze;
	b[2][4] = -b[2][2];
	b[2][5] = -b[2][3];
	b[2][6] = -b[2][0];
	b[2][7] = -b[2][1];
	
	/* calculate jacobian determinant (volume) */
	*volume = Real_t(8.) * ( fjxet * cjxet + fjyet * cjyet + fjzet * cjzet);
}

static inline
void SumElemFaceNormal(Real_t *normalX0, Real_t *normalY0, Real_t *normalZ0,
                       Real_t *normalX1, Real_t *normalY1, Real_t *normalZ1,
                       Real_t *normalX2, Real_t *normalY2, Real_t *normalZ2,
                       Real_t *normalX3, Real_t *normalY3, Real_t *normalZ3,
                       const Real_t x0, const Real_t y0, const Real_t z0,
                       const Real_t x1, const Real_t y1, const Real_t z1,
                       const Real_t x2, const Real_t y2, const Real_t z2,
                       const Real_t x3, const Real_t y3, const Real_t z3)
{
	Real_t bisectX0 = Real_t(0.5) * (x3 + x2 - x1 - x0);
	Real_t bisectY0 = Real_t(0.5) * (y3 + y2 - y1 - y0);
	Real_t bisectZ0 = Real_t(0.5) * (z3 + z2 - z1 - z0);
	Real_t bisectX1 = Real_t(0.5) * (x2 + x1 - x3 - x0);
	Real_t bisectY1 = Real_t(0.5) * (y2 + y1 - y3 - y0);
	Real_t bisectZ1 = Real_t(0.5) * (z2 + z1 - z3 - z0);
	Real_t areaX = Real_t(0.25) * (bisectY0 * bisectZ1 - bisectZ0 * bisectY1);
	Real_t areaY = Real_t(0.25) * (bisectZ0 * bisectX1 - bisectX0 * bisectZ1);
	Real_t areaZ = Real_t(0.25) * (bisectX0 * bisectY1 - bisectY0 * bisectX1);
	
	*normalX0 += areaX;
	*normalX1 += areaX;
	*normalX2 += areaX;
	*normalX3 += areaX;
	
	*normalY0 += areaY;
	*normalY1 += areaY;
	*normalY2 += areaY;
	*normalY3 += areaY;
	
	*normalZ0 += areaZ;
	*normalZ1 += areaZ;
	*normalZ2 += areaZ;
	*normalZ3 += areaZ;
}

static inline
void CalcElemNodeNormals(Real_t pfx[8],
                         Real_t pfy[8],
                         Real_t pfz[8],
                         const Real_t x[8],
                         const Real_t y[8],
                         const Real_t z[8])
{
/*	for (Index_t i = 0 ; i < 8 ; ++i) {
		pfx[i] = Real_t(0.0);
		pfy[i] = Real_t(0.0);
		pfz[i] = Real_t(0.0);
	}*/
	pfx[0] = Real_t(0.0);
	pfy[0] = Real_t(0.0);
	pfz[0] = Real_t(0.0);
	pfx[1] = Real_t(0.0);
	pfx[1] = Real_t(0.0);
	pfx[1] = Real_t(0.0);
	pfx[2] = Real_t(0.0);
	pfx[2] = Real_t(0.0);
	pfx[2] = Real_t(0.0);
	pfx[3] = Real_t(0.0);
	pfy[3] = Real_t(0.0);
	pfz[3] = Real_t(0.0);
	pfy[4] = Real_t(0.0);
	pfz[4] = Real_t(0.0);
	pfy[4] = Real_t(0.0);
	pfz[5] = Real_t(0.0);
	pfy[5] = Real_t(0.0);
	pfz[5] = Real_t(0.0);
	pfy[6] = Real_t(0.0);
	pfz[6] = Real_t(0.0);
	pfy[6] = Real_t(0.0);
	pfz[7] = Real_t(0.0);
	pfy[7] = Real_t(0.0);
	pfz[7] = Real_t(0.0);
	/* evaluate face one: nodes 0, 1, 2, 3 */
	SumElemFaceNormal(&pfx[0], &pfy[0], &pfz[0],
					  &pfx[1], &pfy[1], &pfz[1],
					  &pfx[2], &pfy[2], &pfz[2],
					  &pfx[3], &pfy[3], &pfz[3],
					  x[0], y[0], z[0], x[1], y[1], z[1],
					  x[2], y[2], z[2], x[3], y[3], z[3]);
	/* evaluate face two: nodes 0, 4, 5, 1 */
	SumElemFaceNormal(&pfx[0], &pfy[0], &pfz[0],
					  &pfx[4], &pfy[4], &pfz[4],
					  &pfx[5], &pfy[5], &pfz[5],
					  &pfx[1], &pfy[1], &pfz[1],
					  x[0], y[0], z[0], x[4], y[4], z[4],
					  x[5], y[5], z[5], x[1], y[1], z[1]);
	/* evaluate face three: nodes 1, 5, 6, 2 */
	SumElemFaceNormal(&pfx[1], &pfy[1], &pfz[1],
					  &pfx[5], &pfy[5], &pfz[5],
					  &pfx[6], &pfy[6], &pfz[6],
					  &pfx[2], &pfy[2], &pfz[2],
					  x[1], y[1], z[1], x[5], y[5], z[5],
					  x[6], y[6], z[6], x[2], y[2], z[2]);
	/* evaluate face four: nodes 2, 6, 7, 3 */
	SumElemFaceNormal(&pfx[2], &pfy[2], &pfz[2],
					  &pfx[6], &pfy[6], &pfz[6],
					  &pfx[7], &pfy[7], &pfz[7],
					  &pfx[3], &pfy[3], &pfz[3],
					  x[2], y[2], z[2], x[6], y[6], z[6],
					  x[7], y[7], z[7], x[3], y[3], z[3]);
	/* evaluate face five: nodes 3, 7, 4, 0 */
	SumElemFaceNormal(&pfx[3], &pfy[3], &pfz[3],
					  &pfx[7], &pfy[7], &pfz[7],
					  &pfx[4], &pfy[4], &pfz[4],
					  &pfx[0], &pfy[0], &pfz[0],
					  x[3], y[3], z[3], x[7], y[7], z[7],
					  x[4], y[4], z[4], x[0], y[0], z[0]);
	/* evaluate face six: nodes 4, 7, 6, 5 */
	SumElemFaceNormal(&pfx[4], &pfy[4], &pfz[4],
					  &pfx[7], &pfy[7], &pfz[7],
					  &pfx[6], &pfy[6], &pfz[6],
					  &pfx[5], &pfy[5], &pfz[5],
					  x[4], y[4], z[4], x[7], y[7], z[7],
					  x[6], y[6], z[6], x[5], y[5], z[5]);
}

static inline
void SumElemStressesToNodeForces( const Real_t B[][8],
								 const Real_t stress_xx,
								 const Real_t stress_yy,
								 const Real_t stress_zz,
								 Real_t* const fx,
								 Real_t* const fy,
								 Real_t* const fz )
{
	Real_t pfx0 = B[0][0] ;   Real_t pfx1 = B[0][1] ;
	Real_t pfx2 = B[0][2] ;   Real_t pfx3 = B[0][3] ;
	Real_t pfx4 = B[0][4] ;   Real_t pfx5 = B[0][5] ;
	Real_t pfx6 = B[0][6] ;   Real_t pfx7 = B[0][7] ;
	
	Real_t pfy0 = B[1][0] ;   Real_t pfy1 = B[1][1] ;
	Real_t pfy2 = B[1][2] ;   Real_t pfy3 = B[1][3] ;
	Real_t pfy4 = B[1][4] ;   Real_t pfy5 = B[1][5] ;
	Real_t pfy6 = B[1][6] ;   Real_t pfy7 = B[1][7] ;
	
	Real_t pfz0 = B[2][0] ;   Real_t pfz1 = B[2][1] ;
	Real_t pfz2 = B[2][2] ;   Real_t pfz3 = B[2][3] ;
	Real_t pfz4 = B[2][4] ;   Real_t pfz5 = B[2][5] ;
	Real_t pfz6 = B[2][6] ;   Real_t pfz7 = B[2][7] ;
	
	fx[0] = -( stress_xx * pfx0 );
	fx[1] = -( stress_xx * pfx1 );
	fx[2] = -( stress_xx * pfx2 );
	fx[3] = -( stress_xx * pfx3 );
	fx[4] = -( stress_xx * pfx4 );
	fx[5] = -( stress_xx * pfx5 );
	fx[6] = -( stress_xx * pfx6 );
	fx[7] = -( stress_xx * pfx7 );
	
	fy[0] = -( stress_yy * pfy0  );
	fy[1] = -( stress_yy * pfy1  );
	fy[2] = -( stress_yy * pfy2  );
	fy[3] = -( stress_yy * pfy3  );
	fy[4] = -( stress_yy * pfy4  );
	fy[5] = -( stress_yy * pfy5  );
	fy[6] = -( stress_yy * pfy6  );
	fy[7] = -( stress_yy * pfy7  );
	
	fz[0] = -( stress_zz * pfz0 );
	fz[1] = -( stress_zz * pfz1 );
	fz[2] = -( stress_zz * pfz2 );
	fz[3] = -( stress_zz * pfz3 );
	fz[4] = -( stress_zz * pfz4 );
	fz[5] = -( stress_zz * pfz5 );
	fz[6] = -( stress_zz * pfz6 );
	fz[7] = -( stress_zz * pfz7 );
}

static inline
void IntegrateStressForElems( Index_t numElem)
{
	Index_t numElem8 = numElem * 8 ;
	
	// loop over all elements
#ifdef GATHER_MICRO_TIMING
	//timeval start, end;
	//gettimeofday(&start, NULL);
	ticks t1, t2;
	t1=getticks();
#endif
#pragma omp parallel for firstprivate(numElem)
	for( Index_t k=0 ; k<numElem ; k=k+VEC_LEN)
	{
		Real_t b[3][8][VEC_LEN] ;// shape function derivatives
		Real_t x_local[8][VEC_LEN] ;
		Real_t y_local[8][VEC_LEN] ;
		Real_t z_local[8][VEC_LEN] ;
		
		const Index_t* const elemNodes = domain.nodelist(k);
		
	  for(Index_t i3 = 0; i3 < VEC_LEN; i3++) {
		// get nodal coordinates from global arrays and copy into local arrays.
		for( Index_t lnode=0 ; lnode<8 ; ++lnode )
		{
			Index_t gnode = elemNodes[lnode+(8*i3)];
			x_local[lnode][i3] = domain.x(gnode);
			y_local[lnode][i3] = domain.y(gnode);
			z_local[lnode][i3] = domain.z(gnode);
		}
	   }
		Real_t sigxx[VEC_LEN];
		Real_t sigyy[VEC_LEN];
		Real_t sigzz[VEC_LEN];
	 Real_t bisectX0[VEC_LEN];
	 Real_t bisectY0[VEC_LEN];
	 Real_t bisectZ0[VEC_LEN];
	 Real_t bisectX1[VEC_LEN];
	 Real_t bisectY1[VEC_LEN];
	 Real_t bisectZ1[VEC_LEN];
	Real_t areaX[VEC_LEN];
	Real_t areaY[VEC_LEN];
	Real_t areaZ[VEC_LEN];
	Real_t fjxxi[VEC_LEN], fjxet[VEC_LEN], fjxze[VEC_LEN];
	Real_t fjyxi[VEC_LEN], fjyet[VEC_LEN], fjyze[VEC_LEN];
	Real_t fjzxi[VEC_LEN], fjzet[VEC_LEN], fjzze[VEC_LEN];
	Real_t cjxxi[VEC_LEN], cjxet[VEC_LEN], cjxze[VEC_LEN];
	Real_t cjyxi[VEC_LEN], cjyet[VEC_LEN], cjyze[VEC_LEN];
	Real_t cjzxi[VEC_LEN], cjzet[VEC_LEN], cjzze[VEC_LEN];
	Real_t temp[VEC_LEN];
	  for(Index_t i3 = 0; i3 < VEC_LEN; i3++) {
		
		// Volume calculation involves extra work for numerical consistency. 
		//CalcElemShapeFunctionDerivatives(x_local[i3], y_local[i3], z_local[i3],
                  //                       B, &domain.determ(k+i3));
	
	fjxxi[i3] = .125 * ( (x_local[6][i3]-x_local[0][i3]) + (x_local[5][i3]-x_local[3][i3]) - (x_local[7][i3]-x_local[1][i3]) - (x_local[4][i3]-x_local[2][i3]) );
	fjxet[i3] = .125 * ( (x_local[6][i3]-x_local[0][i3]) - (x_local[5][i3]-x_local[3][i3]) + (x_local[7][i3]-x_local[1][i3]) - (x_local[4][i3]-x_local[2][i3]) );
	fjxze[i3] = .125 * ( (x_local[6][i3]-x_local[0][i3]) + (x_local[5][i3]-x_local[3][i3]) + (x_local[7][i3]-x_local[1][i3]) + (x_local[4][i3]-x_local[2][i3]) );
	
	fjyxi[i3] = .125 * ( (y_local[6][i3]-y_local[0][i3]) + (y_local[5][i3]-y_local[3][i3]) - (y_local[7][i3]-y_local[1][i3]) - (y_local[4][i3]-y_local[2][i3]) );
	fjyet[i3] = .125 * ( (y_local[6][i3]-y_local[0][i3]) - (y_local[5][i3]-y_local[3][i3]) + (y_local[7][i3]-y_local[1][i3]) - (y_local[4][i3]-y_local[2][i3]) );
	fjyze[i3] = .125 * ( (y_local[6][i3]-y_local[0][i3]) + (y_local[5][i3]-y_local[3][i3]) + (y_local[7][i3]-y_local[1][i3]) + (y_local[4][i3]-y_local[2][i3]) );
	
	fjzxi[i3] = .125 * ( (z_local[6][i3]-z_local[0][i3]) + (z_local[5][i3]-z_local[3][i3]) - (z_local[7][i3]-z_local[1][i3]) - (z_local[4][i3]-z_local[2][i3]) );
	fjzet[i3] = .125 * ( (z_local[6][i3]-z_local[0][i3]) - (z_local[5][i3]-z_local[3][i3]) + (z_local[7][i3]-z_local[1][i3]) - (z_local[4][i3]-z_local[2][i3]) );
	fjzze[i3] = .125 * ( (z_local[6][i3]-z_local[0][i3]) + (z_local[5][i3]-z_local[3][i3]) + (z_local[7][i3]-z_local[1][i3]) + (z_local[4][i3]-z_local[2][i3]) );
	
	/* compute cofactors */
	cjxxi[i3] =    (fjyet[i3] * fjzze[i3]) - (fjzet[i3] * fjyze[i3]);
	cjxet[i3] =  - (fjyxi[i3] * fjzze[i3]) + (fjzxi[i3] * fjyze[i3]);
	cjxze[i3] =    (fjyxi[i3] * fjzet[i3]) - (fjzxi[i3] * fjyet[i3]);
	
	cjyxi[i3] =  - (fjxet[i3] * fjzze[i3]) + (fjzet[i3] * fjxze[i3]);
	cjyet[i3] =    (fjxxi[i3] * fjzze[i3]) - (fjzxi[i3] * fjxze[i3]);
	cjyze[i3] =  - (fjxxi[i3] * fjzet[i3]) + (fjzxi[i3] * fjxet[i3]);
	
	cjzxi[i3] =    (fjxet[i3] * fjyze[i3]) - (fjyet[i3] * fjxze[i3]);
	cjzet[i3] =  - (fjxxi[i3] * fjyze[i3]) + (fjyxi[i3] * fjxze[i3]);
	cjzze[i3] =    (fjxxi[i3] * fjyet[i3]) - (fjyxi[i3] * fjxet[i3]);
	
	/* calculate partials :
     this need only be done for l = 0,1,2,3   since , by symmetry ,
     (6,7,4,5) = - (0,1,2,3) .
	 */
	b[0][0][i3] =   -  cjxxi[i3]  -  cjxet[i3]  -  cjxze[i3];
	b[0][1][i3] =      cjxxi[i3]  -  cjxet[i3]  -  cjxze[i3];
	b[0][2][i3] =      cjxxi[i3]  +  cjxet[i3]  -  cjxze[i3];
	b[0][3][i3] =   -  cjxxi[i3]  +  cjxet[i3]  -  cjxze[i3];
	b[0][4][i3] = -b[0][2][i3];
	b[0][5][i3] = -b[0][3][i3];
	b[0][6][i3] = -b[0][0][i3];
	b[0][7][i3] = -b[0][1][i3];
	
	b[1][0][i3] =   -  cjyxi[i3]  -  cjyet[i3]  -  cjyze[i3];
	b[1][1][i3] =      cjyxi[i3]  -  cjyet[i3]  -  cjyze[i3];
	b[1][2][i3] =      cjyxi[i3]  +  cjyet[i3]  -  cjyze[i3];
	b[1][3][i3] =   -  cjyxi[i3]  +  cjyet[i3]  -  cjyze[i3];
	b[1][4][i3] = -b[1][2][i3];
	b[1][5][i3] = -b[1][3][i3];
	b[1][6][i3] = -b[1][0][i3];
	b[1][7][i3] = -b[1][1][i3];
	
	b[2][0][i3] =   -  cjzxi[i3]  -  cjzet[i3]  -  cjzze[i3];
	b[2][1][i3] =      cjzxi[i3]  -  cjzet[i3]  -  cjzze[i3];
	b[2][2][i3] =      cjzxi[i3]  +  cjzet[i3]  -  cjzze[i3];
	b[2][3][i3] =   -  cjzxi[i3]  +  cjzet[i3]  -  cjzze[i3];
	b[2][4][i3] = -b[2][2][i3];
	b[2][5][i3] = -b[2][3][i3];
	b[2][6][i3] = -b[2][0][i3];
	b[2][7][i3] = -b[2][1][i3];
	}
	  for(Index_t i3 = 0; i3 < VEC_LEN; i3++) {
	
	/* calculate jacobian determinant (volume) */
	
	domain.determ(k+i3) = Real_t(8.)*( fjxet[i3] * cjxet[i3] + fjyet[i3] * cjyet[i3] + fjzet[i3] * cjzet[i3]);
         }
	  for(Index_t i3 = 0; i3 < VEC_LEN; i3++) {
		
//		CalcElemNodeNormals( B[0] , B[1], B[2],
//							x_local[i3], y_local[i3], z_local[i3] );
	b[0][0][i3] = Real_t(0.0);
	b[0][1][i3] = Real_t(0.0);
	b[0][2][i3] = Real_t(0.0);
	b[0][3][i3] = Real_t(0.0);
	b[0][4][i3] = Real_t(0.0);
	b[0][5][i3] = Real_t(0.0);
	b[0][6][i3] = Real_t(0.0);
	b[0][0][i3] = Real_t(0.0);
	b[0][7][i3] = Real_t(0.0);
	b[1][0][i3] = Real_t(0.0);
	b[1][1][i3] = Real_t(0.0);
	b[1][2][i3] = Real_t(0.0);
	b[1][3][i3] = Real_t(0.0);
	b[1][4][i3] = Real_t(0.0);
	b[1][5][i3] = Real_t(0.0);
	b[1][6][i3] = Real_t(0.0);
	b[1][7][i3] = Real_t(0.0);
	b[2][0][i3] = Real_t(0.0);
	b[2][1][i3] = Real_t(0.0);
	b[2][2][i3] = Real_t(0.0);
	b[2][3][i3] = Real_t(0.0);
	b[2][4][i3] = Real_t(0.0);
	b[2][5][i3] = Real_t(0.0);
	b[2][6][i3] = Real_t(0.0);
	b[2][7][i3] = Real_t(0.0);
	/* evaluate face one: nodes 0, 1, 2, 3 */
/*	SumElemFaceNormal(&pfx[0], &pfy[0], &pfz[0],
					  &pfx[1], &pfy[1], &pfz[1],
					  &pfx[2], &pfy[2], &pfz[2],
					  &pfx[3], &pfy[3], &pfz[3],
					  x[0], y[0], z[0], x[1], y[1], z[1],
					  x[2], y[2], z[2], x[3], y[3], z[3]);*/
	bisectX0[i3] = Real_t(0.5) * (x_local[3][i3] + x_local[2][i3] - x_local[1][i3] - x_local[0][i3]);
        bisectY0[i3] = Real_t(0.5) * (y_local[3][i3] + y_local[2][i3] - y_local[1][i3] - y_local[0][i3]);
        bisectZ0[i3] = Real_t(0.5) * (z_local[3][i3] + z_local[2][i3] - z_local[1][i3] - z_local[0][i3]);
        bisectX1[i3] = Real_t(0.5) * (x_local[2][i3] + x_local[1][i3] - x_local[3][i3] - x_local[0][i3]);
        bisectY1[i3] = Real_t(0.5) * (y_local[2][i3] + y_local[1][i3] - y_local[3][i3] - y_local[0][i3]);
        bisectZ1[i3] = Real_t(0.5) * (z_local[2][i3] + z_local[1][i3] - z_local[3][i3] - z_local[0][i3]);
        areaX[i3] = Real_t(0.25) * (bisectY0[i3] * bisectZ1[i3] - bisectZ0[i3] * bisectY1[i3]);
        areaY[i3] = Real_t(0.25) * (bisectZ0[i3] * bisectX1[i3] - bisectX0[i3] * bisectZ1[i3]);
        areaZ[i3] = Real_t(0.25) * (bisectX0[i3] * bisectY1[i3] - bisectY0[i3] * bisectX1[i3]);

        b[0][0][i3] += areaX[i3];
        b[0][1][i3] += areaX[i3];
        b[0][2][i3] += areaX[i3];
        b[0][3][i3] += areaX[i3];

	b[1][0][i3] += areaY[i3];
        b[1][1][i3] += areaY[i3];
        b[1][2][i3] += areaY[i3];
        b[1][3][i3] += areaY[i3];
	
	b[2][0][i3] += areaZ[i3];
        b[2][1][i3] += areaZ[i3];
        b[2][2][i3] += areaZ[i3];
        b[2][3][i3] += areaZ[i3];

	/* evaluate face two: nodes 0, 4, 5, 1 */
/*	SumElemFaceNormal(&pfx[0], &pfy[0], &pfz[0],
					  &pfx[4], &pfy[4], &pfz[4],
					  &pfx[5], &pfy[5], &pfz[5],
					  &pfx[1], &pfy[1], &pfz[1],
					  x[0], y[0], z[0], x[4], y[4], z[4],
					  x[5], y[5], z[5], x[1], y[1], z[1]);*/
	bisectX0[i3] = Real_t(0.5) * (x_local[1][i3] + x_local[5][i3] - x_local[4][i3] - x_local[0][i3]);
        bisectY0[i3] = Real_t(0.5) * (y_local[1][i3] + y_local[5][i3] - y_local[4][i3] - y_local[0][i3]);
        bisectZ0[i3] = Real_t(0.5) * (z_local[1][i3] + z_local[5][i3] - z_local[4][i3] - z_local[0][i3]);
        bisectX1[i3] = Real_t(0.5) * (x_local[5][i3] + x_local[4][i3] - x_local[1][i3] - x_local[0][i3]);
        bisectY1[i3] = Real_t(0.5) * (y_local[5][i3] + y_local[4][i3] - y_local[1][i3] - y_local[0][i3]);
        bisectZ1[i3] = Real_t(0.5) * (z_local[5][i3] + z_local[4][i3] - z_local[1][i3] - z_local[0][i3]);
        areaX[i3] = Real_t(0.25) * (bisectY0[i3] * bisectZ1[i3] - bisectZ0[i3] * bisectY1[i3]);
        areaY[i3] = Real_t(0.25) * (bisectZ0[i3] * bisectX1[i3] - bisectX0[i3] * bisectZ1[i3]);
        areaZ[i3] = Real_t(0.25) * (bisectX0[i3] * bisectY1[i3] - bisectY0[i3] * bisectX1[i3]);

        b[0][0][i3] += areaX[i3];
        b[0][4][i3] += areaX[i3];
        b[0][5][i3] += areaX[i3];
        b[0][1][i3] += areaX[i3];
	
 	b[1][0][i3] += areaY[i3];
        b[1][4][i3] += areaY[i3];
        b[1][5][i3] += areaY[i3];
        b[1][1][i3] += areaY[i3];
	
	b[2][0][i3] += areaZ[i3];
        b[2][4][i3] += areaZ[i3];
        b[2][5][i3] += areaZ[i3];
        b[2][1][i3] += areaZ[i3];
	/* evaluate face three: nodes 1, 5, 6, 2 */
	/*SumElemFaceNormal(&pfx[1], &pfy[1], &pfz[1],
					  &pfx[5], &pfy[5], &pfz[5],
					  &pfx[6], &pfy[6], &pfz[6],
					  &pfx[2], &pfy[2], &pfz[2],
					  x[1], y[1], z[1], x[5], y[5], z[5],
					  x[6], y[6], z[6], x[2], y[2], z[2]);*/
	bisectX0[i3] = Real_t(0.5) * (x_local[2][i3] + x_local[6][i3] - x_local[5][i3] - x_local[1][i3]);
        bisectY0[i3] = Real_t(0.5) * (y_local[2][i3] + y_local[6][i3] - y_local[5][i3] - y_local[1][i3]);
        bisectZ0[i3] = Real_t(0.5) * (z_local[2][i3] + z_local[6][i3] - z_local[5][i3] - z_local[1][i3]);
        bisectX1[i3] = Real_t(0.5) * (x_local[6][i3] + x_local[5][i3] - x_local[2][i3] - x_local[1][i3]);
        bisectY1[i3] = Real_t(0.5) * (y_local[6][i3] + y_local[5][i3] - y_local[2][i3] - y_local[1][i3]);
        bisectZ1[i3] = Real_t(0.5) * (z_local[6][i3] + z_local[5][i3] - z_local[2][i3] - z_local[1][i3]);
        areaX[i3] = Real_t(0.25) * (bisectY0[i3] * bisectZ1[i3] - bisectZ0[i3] * bisectY1[i3]);
        areaY[i3] = Real_t(0.25) * (bisectZ0[i3] * bisectX1[i3] - bisectX0[i3] * bisectZ1[i3]);
        areaZ[i3] = Real_t(0.25) * (bisectX0[i3] * bisectY1[i3] - bisectY0[i3] * bisectX1[i3]);

        b[0][1][i3] += areaX[i3];
        b[0][5][i3] += areaX[i3];
        b[0][6][i3] += areaX[i3];
        b[0][2][i3] += areaX[i3];
	
 	b[1][1][i3] += areaY[i3];
        b[1][5][i3] += areaY[i3];
        b[1][6][i3] += areaY[i3];
        b[1][2][i3] += areaY[i3];
	
	b[2][1][i3] += areaZ[i3];
        b[2][5][i3] += areaZ[i3];
        b[2][6][i3] += areaZ[i3];
        b[2][2][i3] += areaZ[i3];
	/* evaluate face four: nodes 2, 6, 7, 3 */
	/*SumElemFaceNormal(&pfx[2], &pfy[2], &pfz[2],
					  &pfx[6], &pfy[6], &pfz[6],
					  &pfx[7], &pfy[7], &pfz[7],
					  &pfx[3], &pfy[3], &pfz[3],
					  x[2], y[2], z[2], x[6], y[6], z[6],
					  x[7], y[7], z[7], x[3], y[3], z[3]);*/
	bisectX0[i3] = Real_t(0.5) * (x_local[3][i3] + x_local[7][i3] - x_local[6][i3] - x_local[2][i3]);
        bisectY0[i3] = Real_t(0.5) * (y_local[3][i3] + y_local[7][i3] - y_local[6][i3] - y_local[2][i3]);
        bisectZ0[i3] = Real_t(0.5) * (z_local[3][i3] + z_local[7][i3] - z_local[6][i3] - z_local[2][i3]);
        bisectX1[i3] = Real_t(0.5) * (x_local[7][i3] + x_local[6][i3] - x_local[3][i3] - x_local[2][i3]);
        bisectY1[i3] = Real_t(0.5) * (y_local[7][i3] + y_local[6][i3] - y_local[3][i3] - y_local[2][i3]);
        bisectZ1[i3] = Real_t(0.5) * (z_local[7][i3] + z_local[6][i3] - z_local[3][i3] - z_local[2][i3]);
        areaX[i3] = Real_t(0.25) * (bisectY0[i3] * bisectZ1[i3] - bisectZ0[i3] * bisectY1[i3]);
        areaY[i3] = Real_t(0.25) * (bisectZ0[i3] * bisectX1[i3] - bisectX0[i3] * bisectZ1[i3]);
        areaZ[i3] = Real_t(0.25) * (bisectX0[i3] * bisectY1[i3] - bisectY0[i3] * bisectX1[i3]);

        b[0][2][i3] += areaX[i3];
        b[0][6][i3] += areaX[i3];
        b[0][7][i3] += areaX[i3];
        b[0][3][i3] += areaX[i3];
	
 	b[1][2][i3] += areaY[i3];
        b[1][6][i3] += areaY[i3];
        b[1][7][i3] += areaY[i3];
        b[1][3][i3] += areaY[i3];
	
	b[2][2][i3] += areaZ[i3];
        b[2][6][i3] += areaZ[i3];
        b[2][7][i3] += areaZ[i3];
        b[2][3][i3] += areaZ[i3];
	/* evaluate face five: nodes 3, 7, 4, 0 */
	/*SumElemFaceNormal(&pfx[3], &pfy[3], &pfz[3],
					  &pfx[7], &pfy[7], &pfz[7],
					  &pfx[4], &pfy[4], &pfz[4],
					  &pfx[0], &pfy[0], &pfz[0],
					  x[3], y[3], z[3], x[7], y[7], z[7],
					  x[4], y[4], z[4], x[0], y[0], z[0]);*/
	bisectX0[i3] = Real_t(0.5) * (x_local[0][i3] + x_local[4][i3] - x_local[7][i3] - x_local[3][i3]);
        bisectY0[i3] = Real_t(0.5) * (y_local[0][i3] + y_local[4][i3] - y_local[7][i3] - y_local[3][i3]);
        bisectZ0[i3] = Real_t(0.5) * (z_local[0][i3] + z_local[4][i3] - z_local[7][i3] - z_local[3][i3]);
        bisectX1[i3] = Real_t(0.5) * (x_local[4][i3] + x_local[7][i3] - x_local[0][i3] - x_local[3][i3]);
        bisectY1[i3] = Real_t(0.5) * (y_local[4][i3] + y_local[7][i3] - y_local[0][i3] - y_local[3][i3]);
        bisectZ1[i3] = Real_t(0.5) * (z_local[4][i3] + z_local[7][i3] - z_local[0][i3] - z_local[3][i3]);
        areaX[i3] = Real_t(0.25) * (bisectY0[i3] * bisectZ1[i3] - bisectZ0[i3] * bisectY1[i3]);
        areaY[i3] = Real_t(0.25) * (bisectZ0[i3] * bisectX1[i3] - bisectX0[i3] * bisectZ1[i3]);
        areaZ[i3] = Real_t(0.25) * (bisectX0[i3] * bisectY1[i3] - bisectY0[i3] * bisectX1[i3]);

        b[0][3][i3] += areaX[i3];
        b[0][7][i3] += areaX[i3];
        b[0][4][i3] += areaX[i3];
        b[0][0][i3] += areaX[i3];
	
 	b[1][3][i3] += areaY[i3];
        b[1][7][i3] += areaY[i3];
        b[1][4][i3] += areaY[i3];
        b[1][0][i3] += areaY[i3];
	
	b[2][3][i3] += areaZ[i3];
        b[2][7][i3] += areaZ[i3];
        b[2][4][i3] += areaZ[i3];
        b[2][0][i3] += areaZ[i3];
	/* evaluate face six: nodes 4, 7, 6, 5 */
	/*SumElemFaceNormal(&pfx[4], &pfy[4], &pfz[4],
					  &pfx[7], &pfy[7], &pfz[7],
					  &pfx[6], &pfy[6], &pfz[6],
					  &pfx[5], &pfy[5], &pfz[5],
					  x[4], y[4], z[4], x[7], y[7], z[7],
					  x[6], y[6], z[6], x[5], y[5], z[5]);*/
	bisectX0[i3] = Real_t(0.5) * (x_local[5][i3] + x_local[6][i3] - x_local[7][i3] - x_local[4][i3]);
        bisectY0[i3] = Real_t(0.5) * (y_local[5][i3] + y_local[6][i3] - y_local[7][i3] - y_local[4][i3]);
        bisectZ0[i3] = Real_t(0.5) * (z_local[5][i3] + z_local[6][i3] - z_local[7][i3] - z_local[4][i3]);
        bisectX1[i3] = Real_t(0.5) * (x_local[6][i3] + x_local[7][i3] - x_local[5][i3] - x_local[4][i3]);
        bisectY1[i3] = Real_t(0.5) * (y_local[6][i3] + y_local[7][i3] - y_local[5][i3] - y_local[4][i3]);
        bisectZ1[i3] = Real_t(0.5) * (z_local[6][i3] + z_local[7][i3] - z_local[5][i3] - z_local[4][i3]);
        areaX[i3] = Real_t(0.25) * (bisectY0[i3] * bisectZ1[i3] - bisectZ0[i3] * bisectY1[i3]);
        areaY[i3] = Real_t(0.25) * (bisectZ0[i3] * bisectX1[i3] - bisectX0[i3] * bisectZ1[i3]);
        areaZ[i3] = Real_t(0.25) * (bisectX0[i3] * bisectY1[i3] - bisectY0[i3] * bisectX1[i3]);

        b[0][4][i3] += areaX[i3];
        b[0][7][i3] += areaX[i3];
        b[0][6][i3] += areaX[i3];
        b[0][5][i3] += areaX[i3];

 	b[1][4][i3] += areaY[i3];
        b[1][7][i3] += areaY[i3];
        b[1][6][i3] += areaY[i3];
        b[1][5][i3] += areaY[i3];
	
	b[2][4][i3] += areaZ[i3];
        b[2][7][i3] += areaZ[i3];
        b[2][6][i3] += areaZ[i3];
        b[2][5][i3] += areaZ[i3];

		// Get Initial stress terms
		//InitStressTermsForElems(k+i3, &sigxx, &sigyy, &sigzz);
		
	//	SumElemStressesToNodeForces( B, sigxx, sigyy, sigzz,
	//								&domain.fx_elem((k+i3)*8), &domain.fy_elem((k+i3)*8), &domain.fz_elem((k+i3)*8) ) ;
	}
	for(Index_t i3 = 0; i3 < VEC_LEN; i3++) {
		sigxx[i3] =  sigyy[i3] = sigzz[i3] =  - domain.p(k+i3) - domain.q(k+i3) ;

        domain.fx_elem((k+i3)*8) = -( sigxx[i3] * b[0][0][i3] );
        domain.fx_elem((k+i3)*8+1) = -( sigxx[i3] * b[0][1][i3] );
        domain.fx_elem((k+i3)*8+2) = -( sigxx[i3] * b[0][2][i3] );
        domain.fx_elem((k+i3)*8+3) = -( sigxx[i3] * b[0][3][i3] );
        domain.fx_elem((k+i3)*8+4) = -( sigxx[i3] * b[0][4][i3] );
        domain.fx_elem((k+i3)*8+5) = -( sigxx[i3] * b[0][5][i3] );
        domain.fx_elem((k+i3)*8+6) = -( sigxx[i3] * b[0][6][i3] );
        domain.fx_elem((k+i3)*8+7) = -( sigxx[i3] * b[0][7][i3] );

        domain.fy_elem((k+i3)*8) = -( sigyy[i3] * b[1][0][i3] );
        domain.fy_elem((k+i3)*8+1) = -( sigyy[i3] * b[1][1][i3] );
        domain.fy_elem((k+i3)*8+2) = -( sigyy[i3] * b[1][2][i3] );
        domain.fy_elem((k+i3)*8+3) = -( sigyy[i3] * b[1][3][i3] );
        domain.fy_elem((k+i3)*8+4) = -( sigyy[i3] * b[1][4][i3] );
        domain.fy_elem((k+i3)*8+5) = -( sigyy[i3] * b[1][5][i3] );
        domain.fy_elem((k+i3)*8+6) = -( sigyy[i3] * b[1][6][i3] );
        domain.fy_elem((k+i3)*8+7) = -( sigyy[i3] * b[1][7][i3] );
        
	domain.fz_elem((k+i3)*8) = -( sigzz[i3] * b[2][0][i3] );
        domain.fz_elem((k+i3)*8+1) = -( sigzz[i3] * b[2][1][i3] );
        domain.fz_elem((k+i3)*8+2) = -( sigzz[i3] * b[2][2][i3] );
        domain.fz_elem((k+i3)*8+3) = -( sigzz[i3] * b[2][3][i3] );
        domain.fz_elem((k+i3)*8+4) = -( sigzz[i3] * b[2][4][i3] );
        domain.fz_elem((k+i3)*8+5) = -( sigzz[i3] * b[2][5][i3] );
        domain.fz_elem((k+i3)*8+6) = -( sigzz[i3] * b[2][6][i3] );
        domain.fz_elem((k+i3)*8+7) = -( sigzz[i3] * b[2][7][i3] );

	    }
		
	}
#ifdef GATHER_MICRO_TIMING
	//gettimeofday(&end, NULL);
	//elapsed[0] += double(end.tv_sec - start.tv_sec) + double(end.tv_usec - start.tv_usec) *1e-6;
	t2=getticks();
	elapsed_time[0] += elapsed(t2, t1);
#endif
	
	{
		Index_t numNode = domain.numNode() ;
		
#ifdef GATHER_MICRO_TIMING
	//timeval start, end;
	//gettimeofday(&start, NULL);
	ticks t1, t2;
	t1=getticks();
#endif
#pragma omp parallel for firstprivate(numNode)
		for( Index_t gnode=0 ; gnode<numNode ; ++gnode )
		{
			Index_t count = domain.nodeElemCount(gnode) ;
			Index_t start = domain.nodeElemStart(gnode) ;
			Real_t fx = Real_t(0.0) ;
			Real_t fy = Real_t(0.0) ;
			Real_t fz = Real_t(0.0) ;
			for (Index_t i=0 ; i < count ; ++i) {
				Index_t elem = domain.nodeElemCornerList(start+i) ;
				fx += domain.fx_elem(elem) ;
				fy += domain.fy_elem(elem) ;
				fz += domain.fz_elem(elem) ;
			}
			domain.fx(gnode) = fx ;
			domain.fy(gnode) = fy ;
			domain.fz(gnode) = fz ;
		}
#ifdef GATHER_MICRO_TIMING
	t2=getticks();
	elapsed_time[1] += elapsed(t2, t1);
	//gettimeofday(&end, NULL);
	//elapsed[1] += double(end.tv_sec - start.tv_sec) + double(end.tv_usec - start.tv_usec) *1e-6;
#endif
	}
}


static inline
void CollectDomainNodesToElemNodes(const Index_t* elemToNode,
                                   Real_t elemX[8],
                                   Real_t elemY[8],
                                   Real_t elemZ[8])
{
	Index_t nd0i = elemToNode[0] ;
	Index_t nd1i = elemToNode[1] ;
	Index_t nd2i = elemToNode[2] ;
	Index_t nd3i = elemToNode[3] ;
	Index_t nd4i = elemToNode[4] ;
	Index_t nd5i = elemToNode[5] ;
	Index_t nd6i = elemToNode[6] ;
	Index_t nd7i = elemToNode[7] ;
	
	elemX[0] = domain.x(nd0i);
	elemX[1] = domain.x(nd1i);
	elemX[2] = domain.x(nd2i);
	elemX[3] = domain.x(nd3i);
	elemX[4] = domain.x(nd4i);
	elemX[5] = domain.x(nd5i);
	elemX[6] = domain.x(nd6i);
	elemX[7] = domain.x(nd7i);
	
	elemY[0] = domain.y(nd0i);
	elemY[1] = domain.y(nd1i);
	elemY[2] = domain.y(nd2i);
	elemY[3] = domain.y(nd3i);
	elemY[4] = domain.y(nd4i);
	elemY[5] = domain.y(nd5i);
	elemY[6] = domain.y(nd6i);
	elemY[7] = domain.y(nd7i);
	
	elemZ[0] = domain.z(nd0i);
	elemZ[1] = domain.z(nd1i);
	elemZ[2] = domain.z(nd2i);
	elemZ[3] = domain.z(nd3i);
	elemZ[4] = domain.z(nd4i);
	elemZ[5] = domain.z(nd5i);
	elemZ[6] = domain.z(nd6i);
	elemZ[7] = domain.z(nd7i);
	
}

static inline
void VoluDer(const Real_t x0, const Real_t x1, const Real_t x2,
             const Real_t x3, const Real_t x4, const Real_t x5,
             const Real_t y0, const Real_t y1, const Real_t y2,
             const Real_t y3, const Real_t y4, const Real_t y5,
             const Real_t z0, const Real_t z1, const Real_t z2,
             const Real_t z3, const Real_t z4, const Real_t z5,
             Real_t* dvdx, Real_t* dvdy, Real_t* dvdz)
{
	const Real_t twelfth = Real_t(1.0) / Real_t(12.0) ;
	
	*dvdx =
	(y1 + y2) * (z0 + z1) - (y0 + y1) * (z1 + z2) +
	(y0 + y4) * (z3 + z4) - (y3 + y4) * (z0 + z4) -
	(y2 + y5) * (z3 + z5) + (y3 + y5) * (z2 + z5);
	*dvdy =
	- (x1 + x2) * (z0 + z1) + (x0 + x1) * (z1 + z2) -
	(x0 + x4) * (z3 + z4) + (x3 + x4) * (z0 + z4) +
	(x2 + x5) * (z3 + z5) - (x3 + x5) * (z2 + z5);
	
	*dvdz =
	- (y1 + y2) * (x0 + x1) + (y0 + y1) * (x1 + x2) -
	(y0 + y4) * (x3 + x4) + (y3 + y4) * (x0 + x4) +
	(y2 + y5) * (x3 + x5) - (y3 + y5) * (x2 + x5);
	
	*dvdx *= twelfth;
	*dvdy *= twelfth;
	*dvdz *= twelfth;
}

static inline
void CalcElemVolumeDerivative(Real_t dvdx[8],
                              Real_t dvdy[8],
                              Real_t dvdz[8],
                              const Real_t x[8],
                              const Real_t y[8],
                              const Real_t z[8])
{
	VoluDer(x[1], x[2], x[3], x[4], x[5], x[7],
			y[1], y[2], y[3], y[4], y[5], y[7],
			z[1], z[2], z[3], z[4], z[5], z[7],
			&dvdx[0], &dvdy[0], &dvdz[0]);
	VoluDer(x[0], x[1], x[2], x[7], x[4], x[6],
			y[0], y[1], y[2], y[7], y[4], y[6],
			z[0], z[1], z[2], z[7], z[4], z[6],
			&dvdx[3], &dvdy[3], &dvdz[3]);
	VoluDer(x[3], x[0], x[1], x[6], x[7], x[5],
			y[3], y[0], y[1], y[6], y[7], y[5],
			z[3], z[0], z[1], z[6], z[7], z[5],
			&dvdx[2], &dvdy[2], &dvdz[2]);
	VoluDer(x[2], x[3], x[0], x[5], x[6], x[4],
			y[2], y[3], y[0], y[5], y[6], y[4],
			z[2], z[3], z[0], z[5], z[6], z[4],
			&dvdx[1], &dvdy[1], &dvdz[1]);
	VoluDer(x[7], x[6], x[5], x[0], x[3], x[1],
			y[7], y[6], y[5], y[0], y[3], y[1],
			z[7], z[6], z[5], z[0], z[3], z[1],
			&dvdx[4], &dvdy[4], &dvdz[4]);
	VoluDer(x[4], x[7], x[6], x[1], x[0], x[2],
			y[4], y[7], y[6], y[1], y[0], y[2],
			z[4], z[7], z[6], z[1], z[0], z[2],
			&dvdx[5], &dvdy[5], &dvdz[5]);
	VoluDer(x[5], x[4], x[7], x[2], x[1], x[3],
			y[5], y[4], y[7], y[2], y[1], y[3],
			z[5], z[4], z[7], z[2], z[1], z[3],
			&dvdx[6], &dvdy[6], &dvdz[6]);
	VoluDer(x[6], x[5], x[4], x[3], x[2], x[0],
			y[6], y[5], y[4], y[3], y[2], y[0],
			z[6], z[5], z[4], z[3], z[2], z[0],
			&dvdx[7], &dvdy[7], &dvdz[7]);
}

static inline
void CalcElemFBHourglassForce(Real_t *xd, Real_t *yd, Real_t *zd,  Real_t *hourgam0,
                              Real_t *hourgam1, Real_t *hourgam2, Real_t *hourgam3,
                              Real_t *hourgam4, Real_t *hourgam5, Real_t *hourgam6,
                              Real_t *hourgam7, Real_t coefficient,
                              Real_t *hgfx, Real_t *hgfy, Real_t *hgfz )
{
	Index_t i00=0;
	Index_t i01=1;
	Index_t i02=2;
	Index_t i03=3;
	
	Real_t h00 =
	hourgam0[i00] * xd[0] + hourgam1[i00] * xd[1] +
	hourgam2[i00] * xd[2] + hourgam3[i00] * xd[3] +
	hourgam4[i00] * xd[4] + hourgam5[i00] * xd[5] +
	hourgam6[i00] * xd[6] + hourgam7[i00] * xd[7];
	
	Real_t h01 =
	hourgam0[i01] * xd[0] + hourgam1[i01] * xd[1] +
	hourgam2[i01] * xd[2] + hourgam3[i01] * xd[3] +
	hourgam4[i01] * xd[4] + hourgam5[i01] * xd[5] +
	hourgam6[i01] * xd[6] + hourgam7[i01] * xd[7];
	
	Real_t h02 =
	hourgam0[i02] * xd[0] + hourgam1[i02] * xd[1]+
	hourgam2[i02] * xd[2] + hourgam3[i02] * xd[3]+
	hourgam4[i02] * xd[4] + hourgam5[i02] * xd[5]+
	hourgam6[i02] * xd[6] + hourgam7[i02] * xd[7];
	
	Real_t h03 =
	hourgam0[i03] * xd[0] + hourgam1[i03] * xd[1] +
	hourgam2[i03] * xd[2] + hourgam3[i03] * xd[3] +
	hourgam4[i03] * xd[4] + hourgam5[i03] * xd[5] +
	hourgam6[i03] * xd[6] + hourgam7[i03] * xd[7];
	
	hgfx[0] = coefficient *
	(hourgam0[i00] * h00 + hourgam0[i01] * h01 +
	 hourgam0[i02] * h02 + hourgam0[i03] * h03);
	
	hgfx[1] = coefficient *
	(hourgam1[i00] * h00 + hourgam1[i01] * h01 +
	 hourgam1[i02] * h02 + hourgam1[i03] * h03);
	
	hgfx[2] = coefficient *
	(hourgam2[i00] * h00 + hourgam2[i01] * h01 +
	 hourgam2[i02] * h02 + hourgam2[i03] * h03);
	
	hgfx[3] = coefficient *
	(hourgam3[i00] * h00 + hourgam3[i01] * h01 +
	 hourgam3[i02] * h02 + hourgam3[i03] * h03);
	
	hgfx[4] = coefficient *
	(hourgam4[i00] * h00 + hourgam4[i01] * h01 +
	 hourgam4[i02] * h02 + hourgam4[i03] * h03);
	
	hgfx[5] = coefficient *
	(hourgam5[i00] * h00 + hourgam5[i01] * h01 +
	 hourgam5[i02] * h02 + hourgam5[i03] * h03);
	
	hgfx[6] = coefficient *
	(hourgam6[i00] * h00 + hourgam6[i01] * h01 +
	 hourgam6[i02] * h02 + hourgam6[i03] * h03);
	
	hgfx[7] = coefficient *
	(hourgam7[i00] * h00 + hourgam7[i01] * h01 +
	 hourgam7[i02] * h02 + hourgam7[i03] * h03);
	
	h00 =
	hourgam0[i00] * yd[0] + hourgam1[i00] * yd[1] +
	hourgam2[i00] * yd[2] + hourgam3[i00] * yd[3] +
	hourgam4[i00] * yd[4] + hourgam5[i00] * yd[5] +
	hourgam6[i00] * yd[6] + hourgam7[i00] * yd[7];
	
	h01 =
	hourgam0[i01] * yd[0] + hourgam1[i01] * yd[1] +
	hourgam2[i01] * yd[2] + hourgam3[i01] * yd[3] +
	hourgam4[i01] * yd[4] + hourgam5[i01] * yd[5] +
	hourgam6[i01] * yd[6] + hourgam7[i01] * yd[7];
	
	h02 =
	hourgam0[i02] * yd[0] + hourgam1[i02] * yd[1]+
	hourgam2[i02] * yd[2] + hourgam3[i02] * yd[3]+
	hourgam4[i02] * yd[4] + hourgam5[i02] * yd[5]+
	hourgam6[i02] * yd[6] + hourgam7[i02] * yd[7];
	
	h03 =
	hourgam0[i03] * yd[0] + hourgam1[i03] * yd[1] +
	hourgam2[i03] * yd[2] + hourgam3[i03] * yd[3] +
	hourgam4[i03] * yd[4] + hourgam5[i03] * yd[5] +
	hourgam6[i03] * yd[6] + hourgam7[i03] * yd[7];
	
	
	hgfy[0] = coefficient *
	(hourgam0[i00] * h00 + hourgam0[i01] * h01 +
	 hourgam0[i02] * h02 + hourgam0[i03] * h03);
	
	hgfy[1] = coefficient *
	(hourgam1[i00] * h00 + hourgam1[i01] * h01 +
	 hourgam1[i02] * h02 + hourgam1[i03] * h03);
	
	hgfy[2] = coefficient *
	(hourgam2[i00] * h00 + hourgam2[i01] * h01 +
	 hourgam2[i02] * h02 + hourgam2[i03] * h03);
	
	hgfy[3] = coefficient *
	(hourgam3[i00] * h00 + hourgam3[i01] * h01 +
	 hourgam3[i02] * h02 + hourgam3[i03] * h03);
	
	hgfy[4] = coefficient *
	(hourgam4[i00] * h00 + hourgam4[i01] * h01 +
	 hourgam4[i02] * h02 + hourgam4[i03] * h03);
	
	hgfy[5] = coefficient *
	(hourgam5[i00] * h00 + hourgam5[i01] * h01 +
	 hourgam5[i02] * h02 + hourgam5[i03] * h03);
	
	hgfy[6] = coefficient *
	(hourgam6[i00] * h00 + hourgam6[i01] * h01 +
	 hourgam6[i02] * h02 + hourgam6[i03] * h03);
	
	hgfy[7] = coefficient *
	(hourgam7[i00] * h00 + hourgam7[i01] * h01 +
	 hourgam7[i02] * h02 + hourgam7[i03] * h03);
	
	h00 =
	hourgam0[i00] * zd[0] + hourgam1[i00] * zd[1] +
	hourgam2[i00] * zd[2] + hourgam3[i00] * zd[3] +
	hourgam4[i00] * zd[4] + hourgam5[i00] * zd[5] +
	hourgam6[i00] * zd[6] + hourgam7[i00] * zd[7];
	
	h01 =
	hourgam0[i01] * zd[0] + hourgam1[i01] * zd[1] +
	hourgam2[i01] * zd[2] + hourgam3[i01] * zd[3] +
	hourgam4[i01] * zd[4] + hourgam5[i01] * zd[5] +
	hourgam6[i01] * zd[6] + hourgam7[i01] * zd[7];
	
	h02 =
	hourgam0[i02] * zd[0] + hourgam1[i02] * zd[1]+
	hourgam2[i02] * zd[2] + hourgam3[i02] * zd[3]+
	hourgam4[i02] * zd[4] + hourgam5[i02] * zd[5]+
	hourgam6[i02] * zd[6] + hourgam7[i02] * zd[7];
	
	h03 =
	hourgam0[i03] * zd[0] + hourgam1[i03] * zd[1] +
	hourgam2[i03] * zd[2] + hourgam3[i03] * zd[3] +
	hourgam4[i03] * zd[4] + hourgam5[i03] * zd[5] +
	hourgam6[i03] * zd[6] + hourgam7[i03] * zd[7];
	
	
	hgfz[0] = coefficient *
	(hourgam0[i00] * h00 + hourgam0[i01] * h01 +
	 hourgam0[i02] * h02 + hourgam0[i03] * h03);
	
	hgfz[1] = coefficient *
	(hourgam1[i00] * h00 + hourgam1[i01] * h01 +
	 hourgam1[i02] * h02 + hourgam1[i03] * h03);
	
	hgfz[2] = coefficient *
	(hourgam2[i00] * h00 + hourgam2[i01] * h01 +
	 hourgam2[i02] * h02 + hourgam2[i03] * h03);
	
	hgfz[3] = coefficient *
	(hourgam3[i00] * h00 + hourgam3[i01] * h01 +
	 hourgam3[i02] * h02 + hourgam3[i03] * h03);
	
	hgfz[4] = coefficient *
	(hourgam4[i00] * h00 + hourgam4[i01] * h01 +
	 hourgam4[i02] * h02 + hourgam4[i03] * h03);
	
	hgfz[5] = coefficient *
	(hourgam5[i00] * h00 + hourgam5[i01] * h01 +
	 hourgam5[i02] * h02 + hourgam5[i03] * h03);
	
	hgfz[6] = coefficient *
	(hourgam6[i00] * h00 + hourgam6[i01] * h01 +
	 hourgam6[i02] * h02 + hourgam6[i03] * h03);
	
	hgfz[7] = coefficient *
	(hourgam7[i00] * h00 + hourgam7[i01] * h01 +
	 hourgam7[i02] * h02 + hourgam7[i03] * h03);
}

static inline
void CalcFBHourglassForceForElems( Real_t hourg)
{
	/*************************************************
	 *
	 *     FUNCTION: Calculates the Flanagan-Belytschko anti-hourglass
	 *               force.
	 *
	 *************************************************/
	
	Index_t numElem = domain.numElem() ;
	Index_t numElem8 = numElem * 8 ;
	
	/*************************************************/
	/*    compute the hourglass modes */
	
	
#ifdef GATHER_MICRO_TIMING
	ticks t1, t2;
	t1=getticks();
	//timeval start, end;
	//gettimeofday(&start, NULL);
#endif
#pragma omp parallel for firstprivate(numElem, hourg) 
	for(Index_t i2=0; i2<numElem; i2=i2 +VEC_LEN){
		Real_t   x1[8][VEC_LEN],   y1[8][VEC_LEN],   z1[8][VEC_LEN] ;
		Real_t dvdx[8][VEC_LEN], dvdy[8][VEC_LEN], dvdz[8][VEC_LEN] ;
		//const Index_t* elemToNode = domain.nodelist(i2);
		Real_t xd1[8][VEC_LEN], yd1[8][VEC_LEN], zd1[8][VEC_LEN] ;
	  for(Index_t i3 = 0; i3 < VEC_LEN; i3++) {
                
		const Index_t* elemToNode2 = domain.nodelist(i2+i3);

		

	//	CollectDomainNodesToElemNodes( elemToNode2, x1[i3], y1[i3], z1[i3]);
	
	x1[0][i3] = domain.x(elemToNode2[0]);
	x1[1][i3] = domain.x(elemToNode2[1]);
	x1[2][i3] = domain.x(elemToNode2[2]);
	x1[3][i3] = domain.x(elemToNode2[3]);
	x1[4][i3] = domain.x(elemToNode2[4]);
	x1[5][i3] = domain.x(elemToNode2[5]);
	x1[6][i3] = domain.x(elemToNode2[6]);
	x1[7][i3] = domain.x(elemToNode2[7]);
	
	y1[0][i3] = domain.y(elemToNode2[0]);
	y1[1][i3] = domain.y(elemToNode2[1]);
	y1[2][i3] = domain.y(elemToNode2[2]);
	y1[3][i3] = domain.y(elemToNode2[3]);
	y1[4][i3] = domain.y(elemToNode2[4]);
	y1[5][i3] = domain.y(elemToNode2[5]);
	y1[6][i3] = domain.y(elemToNode2[6]);
	y1[7][i3] = domain.y(elemToNode2[7]);
	
	z1[0][i3] = domain.z(elemToNode2[0]);
	z1[1][i3] = domain.z(elemToNode2[1]);
	z1[2][i3] = domain.z(elemToNode2[2]);
	z1[3][i3] = domain.z(elemToNode2[3]);
	z1[4][i3] = domain.z(elemToNode2[4]);
	z1[5][i3] = domain.z(elemToNode2[5]);
	z1[6][i3] = domain.z(elemToNode2[6]);
	z1[7][i3] = domain.z(elemToNode2[7]);
		
	xd1[0][i3] = domain.xd(elemToNode2[0]);
	xd1[1][i3] = domain.xd(elemToNode2[1]);
	xd1[2][i3] = domain.xd(elemToNode2[2]);
	xd1[3][i3] = domain.xd(elemToNode2[3]);
	xd1[4][i3] = domain.xd(elemToNode2[4]);
	xd1[5][i3] = domain.xd(elemToNode2[5]);
	xd1[6][i3] = domain.xd(elemToNode2[6]);
	xd1[7][i3] = domain.xd(elemToNode2[7]);
	
	yd1[0][i3] = domain.yd(elemToNode2[0]);
	yd1[1][i3] = domain.yd(elemToNode2[1]);
	yd1[2][i3] = domain.yd(elemToNode2[2]);
	yd1[3][i3] = domain.yd(elemToNode2[3]);
	yd1[4][i3] = domain.yd(elemToNode2[4]);
	yd1[5][i3] = domain.yd(elemToNode2[5]);
	yd1[6][i3] = domain.yd(elemToNode2[6]);
	yd1[7][i3] = domain.yd(elemToNode2[7]);
	
	zd1[0][i3] = domain.zd(elemToNode2[0]);
	zd1[1][i3] = domain.zd(elemToNode2[1]);
	zd1[2][i3] = domain.zd(elemToNode2[2]);
	zd1[3][i3] = domain.zd(elemToNode2[3]);
	zd1[4][i3] = domain.zd(elemToNode2[4]);
	zd1[5][i3] = domain.zd(elemToNode2[5]);
	zd1[6][i3] = domain.zd(elemToNode2[6]);
	zd1[7][i3] = domain.zd(elemToNode2[7]);
           }
		Real_t *fx_local, *fy_local, *fz_local ;
		Real_t hgfx[8][VEC_LEN], hgfy[8][VEC_LEN], hgfz[8][VEC_LEN] ;
		Real_t coefficient[VEC_LEN];
		Real_t hourgam0[4][VEC_LEN], hourgam1[4][VEC_LEN], hourgam2[4][VEC_LEN], hourgam3[4][VEC_LEN] ;
		Real_t hourgam4[4][VEC_LEN], hourgam5[4][VEC_LEN], hourgam6[4][VEC_LEN], hourgam7[4][VEC_LEN];
		Real_t ss1[VEC_LEN], mass1[VEC_LEN], volume13[VEC_LEN], determ[VEC_LEN], volinv[VEC_LEN] ;
                Real_t hourmodx[4][VEC_LEN];
                Real_t hourmody[4][VEC_LEN];
                Real_t hourmodz[4][VEC_LEN];
	const Real_t twelfth = Real_t(1.0) / Real_t(12.0) ;
	  for(Index_t i3 = 0; i3 < VEC_LEN; i3++) {

		//CalcElemVolumeDerivative(dvdx[i3], dvdy[i3], dvdz[i3], x1[i3], y1[i3], z1[i3]);
	/*VoluDer(x1[i3][1], x1[i3][2], x1[i3][3], x1[i3][4], x1[i3][5], x1[i3][7],
			y1[i3][1], y1[i3][2], y1[i3][3], y1[i3][4], y1[i3][5], y1[i3][7],
			z1[i3][1], z1[i3][2], z1[i3][3], z1[i3][4], z1[i3][5], z1[i3][7],
			&dvdx[i3][0], &dvdy[i3][0], &dvdz[i3][0]);*/
	
	dvdx[0][i3] =
	(y1[2][i3] + y1[3][i3]) * (z1[1][i3] + z1[2][i3]) - (y1[1][i3] + y1[2][i3]) * (z1[2][i3] + z1[3][i3]) +
	(y1[1][i3] + y1[5][i3]) * (z1[4][i3] + z1[5][i3]) - (y1[4][i3] + y1[5][i3]) * (z1[1][i3] + z1[5][i3]) -
	(y1[3][i3] + y1[7][i3]) * (z1[4][i3] + z1[7][i3]) + (y1[4][i3] + y1[7][i3]) * (z1[3][i3] + z1[7][i3]);
	dvdy[0][i3] =
	- (x1[2][i3] + x1[3][i3]) * (z1[1][i3] + z1[2][i3]) + (x1[1][i3] + x1[2][i3]) * (z1[2][i3] + z1[3][i3]) -
	(x1[1][i3] + x1[5][i3]) * (z1[4][i3] + z1[5][i3]) + (x1[4][i3] + x1[5][i3]) * (z1[1][i3] + z1[5][i3]) +
	(x1[3][i3] + x1[7][i3]) * (z1[4][i3] + z1[7][i3]) - (x1[4][i3] + x1[7][i3]) * (z1[3][i3] + z1[7][i3]);
	
	dvdz[0][i3] =
	- (y1[2][i3] + y1[3][i3]) * (x1[1][i3] + x1[2][i3]) + (y1[1][i3] + y1[2][i3]) * (x1[2][i3] + x1[3][i3]) -
	(y1[1][i3] + y1[5][i3]) * (x1[4][i3] + x1[5][i3]) + (y1[4][i3] + y1[5][i3]) * (x1[1][i3] + x1[5][i3]) +
	(y1[3][i3] + y1[7][i3]) * (x1[4][i3] + x1[7][i3]) - (y1[4][i3] + y1[7][i3]) * (x1[3][i3] + x1[7][i3]);
	
	dvdx[0][i3] *= twelfth;
	dvdy[0][i3] *= twelfth;
	dvdz[0][i3] *= twelfth;
   

	/*VoluDer(x[0], x[1], x[2], x[7], x[4], x[6],
			y[0], y[1], y[2], y[7], y[4], y[6],
			z[0], z[1], z[2], z[7], z[4], z[6],
			&dvdx[3], &dvdy[3], &dvdz[3]); */
        dvdx[3][i3] =
        (y1[1][i3] + y1[2][i3]) * (z1[0][i3] + z1[1][i3]) - (y1[0][i3] + y1[1][i3]) * (z1[1][i3] + z1[2][i3]) +
        (y1[0][i3] + y1[4][i3]) * (z1[7][i3] + z1[4][i3]) - (y1[7][i3] + y1[4][i3]) * (z1[0][i3] + z1[4][i3]) -
        (y1[2][i3] + y1[6][i3]) * (z1[7][i3] + z1[6][i3]) + (y1[7][i3] + y1[6][i3]) * (z1[2][i3] + z1[6][i3]);
        dvdy[3][i3] =
        - (x1[1][i3] + x1[2][i3]) * (z1[0][i3] + z1[1][i3]) + (x1[0][i3] + x1[1][i3]) * (z1[1][i3] + z1[2][i3]) -
        (x1[0][i3] + x1[4][i3]) * (z1[7][i3] + z1[4][i3]) + (x1[7][i3] + x1[4][i3]) * (z1[0][i3] + z1[4][i3]) +
        (x1[2][i3] + x1[6][i3]) * (z1[7][i3] + z1[6][i3]) - (x1[7][i3] + x1[6][i3]) * (z1[2][i3] + z1[6][i3]);
        
        dvdz[3][i3] =
        - (y1[1][i3] + y1[2][i3]) * (x1[0][i3] + x1[1][i3]) + (y1[0][i3] + y1[1][i3]) * (x1[1][i3] + x1[2][i3]) -
        (y1[0][i3] + y1[4][i3]) * (x1[7][i3] + x1[4][i3]) + (y1[7][i3] + y1[4][i3]) * (x1[0][i3] + x1[4][i3]) +
        (y1[2][i3] + y1[6][i3]) * (x1[7][i3] + x1[6][i3]) - (y1[7][i3] + y1[6][i3]) * (x1[2][i3] + x1[6][i3]);
        
        dvdx[3][i3] *= twelfth;
        dvdy[3][i3] *= twelfth;
        dvdz[3][i3] *= twelfth;

/*	VoluDer(x[3], x[0], x[1], x[6], x[7], x[5],
			y[3], y[0], y[1], y[6], y[7], y[5],
			z[3], z[0], z[1], z[6], z[7], z[5],
			&dvdx[2], &dvdy[2], &dvdz[2]);*/
        dvdx[2][i3] =
        (y1[0][i3] + y1[1][i3]) * (z1[3][i3] + z1[0][i3]) - (y1[3][i3] + y1[0][i3]) * (z1[0][i3] + z1[1][i3]) +
        (y1[3][i3] + y1[7][i3]) * (z1[6][i3] + z1[7][i3]) - (y1[6][i3] + y1[7][i3]) * (z1[3][i3] + z1[7][i3]) -
        (y1[1][i3] + y1[5][i3]) * (z1[6][i3] + z1[5][i3]) + (y1[6][i3] + y1[5][i3]) * (z1[1][i3] + z1[5][i3]);
        dvdy[2][i3] =
        - (x1[0][i3] + x1[1][i3]) * (z1[3][i3] + z1[0][i3]) + (x1[3][i3] + x1[0][i3]) * (z1[0][i3] + z1[1][i3]) -
        (x1[3][i3] + x1[7][i3]) * (z1[6][i3] + z1[7][i3]) + (x1[6][i3] + x1[7][i3]) * (z1[3][i3] + z1[7][i3]) +
        (x1[1][i3] + x1[5][i3]) * (z1[6][i3] + z1[5][i3]) - (x1[6][i3] + x1[5][i3]) * (z1[1][i3] + z1[5][i3]);
        
        dvdz[2][i3] =
        - (y1[0][i3] + y1[1][i3]) * (x1[3][i3] + x1[0][i3]) + (y1[3][i3] + y1[0][i3]) * (x1[0][i3] + x1[1][i3]) -
        (y1[3][i3] + y1[7][i3]) * (x1[6][i3] + x1[7][i3]) + (y1[6][i3] + y1[7][i3]) * (x1[3][i3] + x1[7][i3]) +
        (y1[1][i3] + y1[5][i3]) * (x1[6][i3] + x1[5][i3]) - (y1[6][i3] + y1[5][i3]) * (x1[1][i3] + x1[5][i3]);
        
        dvdx[2][i3] *= twelfth;
        dvdy[2][i3] *= twelfth;
        dvdz[2][i3] *= twelfth;

/*	VoluDer(x[2], x[3], x[0], x[5], x[6], x[4],
			y[2], y[3], y[0], y[5], y[6], y[4],
			z[2], z[3], z[0], z[5], z[6], z[4],
			&dvdx[1], &dvdy[1], &dvdz[1]); */
        dvdx[1][i3] =
        (y1[3][i3] + y1[0][i3]) * (z1[2][i3] + z1[3][i3]) - (y1[2][i3] + y1[3][i3]) * (z1[3][i3] + z1[0][i3]) +
        (y1[2][i3] + y1[6][i3]) * (z1[5][i3] + z1[6][i3]) - (y1[5][i3] + y1[6][i3]) * (z1[2][i3] + z1[6][i3]) -
        (y1[0][i3] + y1[4][i3]) * (z1[5][i3] + z1[4][i3]) + (y1[5][i3] + y1[4][i3]) * (z1[0][i3] + z1[4][i3]);
        dvdy[1][i3] =
        - (x1[3][i3] + x1[0][i3]) * (z1[2][i3] + z1[3][i3]) + (x1[2][i3] + x1[3][i3]) * (z1[3][i3] + z1[0][i3]) -
        (x1[2][i3] + x1[6][i3]) * (z1[5][i3] + z1[6][i3]) + (x1[5][i3] + x1[6][i3]) * (z1[2][i3] + z1[6][i3]) +
        (x1[0][i3] + x1[4][i3]) * (z1[5][i3] + z1[4][i3]) - (x1[5][i3] + x1[4][i3]) * (z1[0][i3] + z1[4][i3]);
        
        dvdz[1][i3] =
        - (y1[3][i3] + y1[0][i3]) * (x1[2][i3] + x1[3][i3]) + (y1[2][i3] + y1[3][i3]) * (x1[3][i3] + x1[0][i3]) -
        (y1[2][i3] + y1[6][i3]) * (x1[5][i3] + x1[6][i3]) + (y1[5][i3] + y1[6][i3]) * (x1[2][i3] + x1[6][i3]) +
        (y1[0][i3] + y1[4][i3]) * (x1[5][i3] + x1[4][i3]) - (y1[5][i3] + y1[4][i3]) * (x1[0][i3] + x1[4][i3]);
        
        dvdx[1][i3] *= twelfth;
        dvdy[1][i3] *= twelfth;
        dvdz[1][i3] *= twelfth;

/*	VoluDer(x[7], x[6], x[5], x[0], x[3], x[1],
			y[7], y[6], y[5], y[0], y[3], y[1],
			z[7], z[6], z[5], z[0], z[3], z[1],
			&dvdx[4], &dvdy[4], &dvdz[4]); */
        dvdx[4][i3] =
        (y1[6][i3] + y1[5][i3]) * (z1[7][i3] + z1[6][i3]) - (y1[7][i3] + y1[6][i3]) * (z1[6][i3] + z1[5][i3]) +
        (y1[7][i3] + y1[3][i3]) * (z1[0][i3] + z1[3][i3]) - (y1[0][i3] + y1[3][i3]) * (z1[7][i3] + z1[3][i3]) -
        (y1[5][i3] + y1[1][i3]) * (z1[0][i3] + z1[1][i3]) + (y1[0][i3] + y1[1][i3]) * (z1[5][i3] + z1[1][i3]);
        dvdy[4][i3] =
        - (x1[6][i3] + x1[5][i3]) * (z1[7][i3] + z1[6][i3]) + (x1[7][i3] + x1[6][i3]) * (z1[6][i3] + z1[5][i3]) -
        (x1[7][i3] + x1[3][i3]) * (z1[0][i3] + z1[3][i3]) + (x1[0][i3] + x1[3][i3]) * (z1[7][i3] + z1[3][i3]) +
        (x1[5][i3] + x1[1][i3]) * (z1[0][i3] + z1[1][i3]) - (x1[0][i3] + x1[1][i3]) * (z1[5][i3] + z1[1][i3]);
        
        dvdz[4][i3] =
        - (y1[6][i3] + y1[5][i3]) * (x1[7][i3] + x1[6][i3]) + (y1[7][i3] + y1[6][i3]) * (x1[6][i3] + x1[5][i3]) -
        (y1[7][i3] + y1[3][i3]) * (x1[0][i3] + x1[3][i3]) + (y1[0][i3] + y1[3][i3]) * (x1[7][i3] + x1[3][i3]) +
        (y1[5][i3] + y1[1][i3]) * (x1[0][i3] + x1[1][i3]) - (y1[0][i3] + y1[1][i3]) * (x1[5][i3] + x1[1][i3]);
        
        dvdx[4][i3] *= twelfth;
        dvdy[4][i3] *= twelfth;
        dvdz[4][i3] *= twelfth;

/*	VoluDer(x[4], x[7], x[6], x[1], x[0], x[2],
			y[4], y[7], y[6], y[1], y[0], y[2],
			z[4], z[7], z[6], z[1], z[0], z[2],
			&dvdx[5], &dvdy[5], &dvdz[5]); */
        dvdx[5][i3] =
        (y1[7][i3] + y1[6][i3]) * (z1[4][i3] + z1[7][i3]) - (y1[4][i3] + y1[7][i3]) * (z1[7][i3] + z1[6][i3]) +
        (y1[4][i3] + y1[0][i3]) * (z1[1][i3] + z1[0][i3]) - (y1[1][i3] + y1[0][i3]) * (z1[4][i3] + z1[0][i3]) -
        (y1[6][i3] + y1[2][i3]) * (z1[1][i3] + z1[2][i3]) + (y1[1][i3] + y1[2][i3]) * (z1[6][i3] + z1[2][i3]);
        dvdy[5][i3] =
        - (x1[7][i3] + x1[6][i3]) * (z1[4][i3] + z1[7][i3]) + (x1[4][i3] + x1[7][i3]) * (z1[7][i3] + z1[6][i3]) -
        (x1[4][i3] + x1[0][i3]) * (z1[1][i3] + z1[0][i3]) + (x1[1][i3] + x1[0][i3]) * (z1[4][i3] + z1[0][i3]) +
        (x1[6][i3] + x1[2][i3]) * (z1[1][i3] + z1[2][i3]) - (x1[1][i3] + x1[2][i3]) * (z1[6][i3] + z1[2][i3]);
        
        dvdz[5][i3] =
        - (y1[7][i3] + y1[6][i3]) * (x1[4][i3] + x1[7][i3]) + (y1[4][i3] + y1[7][i3]) * (x1[7][i3] + x1[6][i3]) -
        (y1[4][i3] + y1[0][i3]) * (x1[1][i3] + x1[0][i3]) + (y1[1][i3] + y1[0][i3]) * (x1[4][i3] + x1[0][i3]) +
        (y1[6][i3] + y1[2][i3]) * (x1[1][i3] + x1[2][i3]) - (y1[1][i3] + y1[2][i3]) * (x1[6][i3] + x1[2][i3]);
        
        dvdx[5][i3] *= twelfth;
        dvdy[5][i3] *= twelfth;
        dvdz[5][i3] *= twelfth; 

/*	VoluDer(x[5], x[4], x[7], x[2], x[1], x[3],
			y[5], y[4], y[7], y[2], y[1], y[3],
			z[5], z[4], z[7], z[2], z[1], z[3],
			&dvdx[6], &dvdy[6], &dvdz[6]); */
        dvdx[6][i3] =
        (y1[4][i3] + y1[7][i3]) * (z1[5][i3] + z1[4][i3]) - (y1[5][i3] + y1[4][i3]) * (z1[4][i3] + z1[7][i3]) +
        (y1[5][i3] + y1[1][i3]) * (z1[2][i3] + z1[1][i3]) - (y1[2][i3] + y1[1][i3]) * (z1[5][i3] + z1[1][i3]) -
        (y1[7][i3] + y1[3][i3]) * (z1[2][i3] + z1[3][i3]) + (y1[2][i3] + y1[3][i3]) * (z1[7][i3] + z1[3][i3]);
        dvdy[6][i3] =
        - (x1[4][i3] + x1[7][i3]) * (z1[5][i3] + z1[4][i3]) + (x1[5][i3] + x1[4][i3]) * (z1[4][i3] + z1[7][i3]) -
        (x1[5][i3] + x1[1][i3]) * (z1[2][i3] + z1[1][i3]) + (x1[2][i3] + x1[1][i3]) * (z1[5][i3] + z1[1][i3]) +
        (x1[7][i3] + x1[3][i3]) * (z1[2][i3] + z1[3][i3]) - (x1[2][i3] + x1[3][i3]) * (z1[7][i3] + z1[3][i3]);
        
        dvdz[6][i3] =
        - (y1[4][i3] + y1[7][i3]) * (x1[5][i3] + x1[4][i3]) + (y1[5][i3] + y1[4][i3]) * (x1[4][i3] + x1[7][i3]) -
        (y1[5][i3] + y1[1][i3]) * (x1[2][i3] + x1[1][i3]) + (y1[2][i3] + y1[1][i3]) * (x1[5][i3] + x1[1][i3]) +
        (y1[7][i3] + y1[3][i3]) * (x1[2][i3] + x1[3][i3]) - (y1[2][i3] + y1[3][i3]) * (x1[7][i3] + x1[3][i3]);
        
        dvdx[6][i3] *= twelfth;
        dvdy[6][i3] *= twelfth;
        dvdz[6][i3] *= twelfth;

/*	VoluDer(x[6], x[5], x[4], x[3], x[2], x[0],
			y[6], y[5], y[4], y[3], y[2], y[0],
			z[6], z[5], z[4], z[3], z[2], z[0],
			&dvdx[7], &dvdy[7], &dvdz[7]); */
        dvdx[7][i3] =
        (y1[5][i3] + y1[4][i3]) * (z1[6][i3] + z1[5][i3]) - (y1[6][i3] + y1[5][i3]) * (z1[5][i3] + z1[4][i3]) +
        (y1[6][i3] + y1[2][i3]) * (z1[3][i3] + z1[2][i3]) - (y1[3][i3] + y1[2][i3]) * (z1[6][i3] + z1[2][i3]) -
        (y1[4][i3] + y1[0][i3]) * (z1[3][i3] + z1[0][i3]) + (y1[3][i3] + y1[0][i3]) * (z1[4][i3] + z1[0][i3]);
        dvdy[7][i3] =
        - (x1[5][i3] + x1[4][i3]) * (z1[6][i3] + z1[5][i3]) + (x1[6][i3] + x1[5][i3]) * (z1[5][i3] + z1[4][i3]) -
        (x1[6][i3] + x1[2][i3]) * (z1[3][i3] + z1[2][i3]) + (x1[3][i3] + x1[2][i3]) * (z1[6][i3] + z1[2][i3]) +
        (x1[4][i3] + x1[0][i3]) * (z1[3][i3] + z1[0][i3]) - (x1[3][i3] + x1[0][i3]) * (z1[4][i3] + z1[0][i3]);
        
        dvdz[7][i3] =
        - (y1[5][i3] + y1[4][i3]) * (x1[6][i3] + x1[5][i3]) + (y1[6][i3] + y1[5][i3]) * (x1[5][i3] + x1[4][i3]) -
        (y1[6][i3] + y1[2][i3]) * (x1[3][i3] + x1[2][i3]) + (y1[3][i3] + y1[2][i3]) * (x1[6][i3] + x1[2][i3]) +
        (y1[4][i3] + y1[0][i3]) * (x1[3][i3] + x1[0][i3]) - (y1[3][i3] + y1[0][i3]) * (x1[4][i3] + x1[0][i3]);
        
        dvdx[7][i3] *= twelfth;
        dvdy[7][i3] *= twelfth;
        dvdz[7][i3] *= twelfth;

		
	//}	
	  //for(Index_t i3 = 0; i3 < VEC_LEN; i3++) {
		determ[i3] = domain.volo(i2+i3) * domain.v(i2+i3);
		
		
		volinv[i3]=Real_t(1.0)/determ[i3];
  //}
//	  for(Index_t i3 = 0; i3 < VEC_LEN; i3++) {

		            hourmodx[0][i3] =
            x1[0][i3] * Gamma[0][0] + x1[1][i3] * Gamma[0][1] +
            x1[2][i3] * Gamma[0][2] + x1[3][i3] * Gamma[0][3] +
            x1[4][i3] * Gamma[0][4] + x1[5][i3] * Gamma[0][5] +
            x1[6][i3] * Gamma[0][6] + x1[7][i3] * Gamma[0][7];

                        hourmody[0][i3] =
            y1[0][i3] * Gamma[0][0] + y1[1][i3] * Gamma[0][1] +
            y1[2][i3] * Gamma[0][2] + y1[3][i3] * Gamma[0][3] +
            y1[4][i3] * Gamma[0][4] + y1[5][i3] * Gamma[0][5] +
            y1[6][i3] * Gamma[0][6] + y1[7][i3] * Gamma[0][7];

                        hourmodz[0][i3] =
            z1[0][i3] * Gamma[0][0] + z1[1][i3] * Gamma[0][1] +
            z1[2][i3] * Gamma[0][2] + z1[3][i3] * Gamma[0][3] +
            z1[4][i3] * Gamma[0][4] + z1[5][i3] * Gamma[0][5] +
            z1[6][i3] * Gamma[0][6] + z1[7][i3] * Gamma[0][7];

            		hourmodx[1][i3] =
            x1[0][i3] * Gamma[1][0] + x1[1][i3] * Gamma[1][1] +
            x1[2][i3] * Gamma[1][2] + x1[3][i3] * Gamma[1][3] +
            x1[4][i3] * Gamma[1][4] + x1[5][i3] * Gamma[1][5] +
            x1[6][i3] * Gamma[1][6] + x1[7][i3] * Gamma[1][7];

                        hourmody[1][i3] =
            y1[0][i3] * Gamma[1][0] + y1[1][i3] * Gamma[1][1] +
            y1[2][i3] * Gamma[1][2] + y1[3][i3] * Gamma[1][3] +
            y1[4][i3] * Gamma[1][4] + y1[5][i3] * Gamma[1][5] +
            y1[6][i3] * Gamma[1][6] + y1[7][i3] * Gamma[1][7];

                        hourmodz[1][i3] =
            z1[0][i3] * Gamma[1][0] + z1[1][i3] * Gamma[1][1] +
            z1[2][i3] * Gamma[1][2] + z1[3][i3] * Gamma[1][3] +
            z1[4][i3] * Gamma[1][4] + z1[5][i3] * Gamma[1][5] +
            z1[6][i3] * Gamma[1][6] + z1[7][i3] * Gamma[1][7];

            		hourmodx[2][i3] =
            x1[0][i3] * Gamma[2][0] + x1[1][i3] * Gamma[2][1] +
            x1[2][i3] * Gamma[2][2] + x1[3][i3] * Gamma[2][3] +
            x1[4][i3] * Gamma[2][4] + x1[5][i3] * Gamma[2][5] +
            x1[6][i3] * Gamma[2][6] + x1[7][i3] * Gamma[2][7];

                        hourmody[2][i3] =
            y1[0][i3] * Gamma[2][0] + y1[1][i3] * Gamma[2][1] +
            y1[2][i3] * Gamma[2][2] + y1[3][i3] * Gamma[2][3] +
            y1[4][i3] * Gamma[2][4] + y1[5][i3] * Gamma[2][5] +
            y1[6][i3] * Gamma[2][6] + y1[7][i3] * Gamma[2][7];

                        hourmodz[2][i3] =
            z1[0][i3] * Gamma[2][0] + z1[1][i3] * Gamma[2][1] +
            z1[2][i3] * Gamma[2][2] + z1[3][i3] * Gamma[2][3] +
            z1[4][i3] * Gamma[2][4] + z1[5][i3] * Gamma[2][5] +
            z1[6][i3] * Gamma[2][6] + z1[7][i3] * Gamma[2][7];

	
			hourmodx[3][i3] =
            x1[0][i3] * Gamma[3][0] + x1[1][i3] * Gamma[3][1] +
            x1[2][i3] * Gamma[3][2] + x1[3][i3] * Gamma[3][3] +
            x1[4][i3] * Gamma[3][4] + x1[5][i3] * Gamma[3][5] +
            x1[6][i3] * Gamma[3][6] + x1[7][i3] * Gamma[3][7];
			
			hourmody[3][i3] =
            y1[0][i3] * Gamma[3][0] + y1[1][i3] * Gamma[3][1] +
            y1[2][i3] * Gamma[3][2] + y1[3][i3] * Gamma[3][3] +
            y1[4][i3] * Gamma[3][4] + y1[5][i3] * Gamma[3][5] +
            y1[6][i3] * Gamma[3][6] + y1[7][i3] * Gamma[3][7];
			
			hourmodz[3][i3] =
            z1[0][i3] * Gamma[3][0] + z1[1][i3] * Gamma[3][1] +
            z1[2][i3] * Gamma[3][2] + z1[3][i3] * Gamma[3][3] +
            z1[4][i3] * Gamma[3][4] + z1[5][i3] * Gamma[3][5] +
            z1[6][i3] * Gamma[3][6] + z1[7][i3] * Gamma[3][7];
//}
//	  for(Index_t i3 = 0; i3 < VEC_LEN; i3++) {
			
			hourgam0[0][i3] = Gamma[0][0] -  volinv[i3]*(dvdx[0][i3] * hourmodx[0][i3] +
												   dvdy[0][i3] * hourmody[0][i3] +
												   dvdz[0][i3] * hourmodz[0][i3] );
			hourgam1[0][i3] = Gamma[0][1] -  volinv[i3]*(dvdx[1][i3] * hourmodx[0][i3] +
												   dvdy[1][i3] * hourmody[0][i3] +
												   dvdz[1][i3] * hourmodz[0][i3] );
			hourgam2[0][i3] = Gamma[0][2] -  volinv[i3]*(dvdx[2][i3] * hourmodx[0][i3] +
												   dvdy[2][i3] * hourmody[0][i3] +
												   dvdz[2][i3] * hourmodz[0][i3] );
			hourgam3[0][i3] = Gamma[0][3] -  volinv[i3]*(dvdx[3][i3] * hourmodx[0][i3] +
												   dvdy[3][i3] * hourmody[0][i3] +
												   dvdz[3][i3] * hourmodz[0][i3] );
			hourgam4[0][i3] = Gamma[0][4] -  volinv[i3]*(dvdx[4][i3] * hourmodx[0][i3] +
												   dvdy[4][i3] * hourmody[0][i3] +
												   dvdz[4][i3] * hourmodz[0][i3] );
			hourgam5[0][i3] = Gamma[0][5] -  volinv[i3]*(dvdx[5][i3] * hourmodx[0][i3] +
												   dvdy[5][i3] * hourmody[0][i3] +
												   dvdz[5][i3] * hourmodz[0][i3] );
			hourgam6[0][i3] = Gamma[0][6] -  volinv[i3]*(dvdx[6][i3] * hourmodx[0][i3] +
												   dvdy[6][i3] * hourmody[0][i3] +
												   dvdz[6][i3] * hourmodz[0][i3] );
			hourgam7[0][i3] = Gamma[0][7] -  volinv[i3]*(dvdx[7][i3] * hourmodx[0][i3] +
												   dvdy[7][i3] * hourmody[0][i3] +
												   dvdz[7][i3] * hourmodz[0][i3] );
			
			hourgam0[1][i3] = Gamma[1][0] -  volinv[i3]*(dvdx[0][i3] * hourmodx[1][i3] +
												   dvdy[0][i3] * hourmody[1][i3] +
												   dvdz[0][i3] * hourmodz[1][i3] );
			hourgam1[1][i3] = Gamma[1][1] -  volinv[i3]*(dvdx[1][i3] * hourmodx[1][i3] +
												   dvdy[1][i3] * hourmody[1][i3] +
												   dvdz[1][i3] * hourmodz[1][i3] );
			hourgam2[1][i3] = Gamma[1][2] -  volinv[i3]*(dvdx[2][i3] * hourmodx[1][i3] +
												   dvdy[2][i3] * hourmody[1][i3] +
												   dvdz[2][i3] * hourmodz[1][i3] );
			hourgam3[1][i3] = Gamma[1][3] -  volinv[i3]*(dvdx[3][i3] * hourmodx[1][i3] +
												   dvdy[3][i3] * hourmody[1][i3] +
												   dvdz[3][i3] * hourmodz[1][i3] );
			hourgam4[1][i3] = Gamma[1][4] -  volinv[i3]*(dvdx[4][i3] * hourmodx[1][i3] +
												   dvdy[4][i3] * hourmody[1][i3] +
												   dvdz[4][i3] * hourmodz[1][i3] );
			hourgam5[1][i3] = Gamma[1][5] -  volinv[i3]*(dvdx[5][i3] * hourmodx[1][i3] +
												   dvdy[5][i3] * hourmody[1][i3] +
												   dvdz[5][i3] * hourmodz[1][i3] );
			hourgam6[1][i3] = Gamma[1][6] -  volinv[i3]*(dvdx[6][i3] * hourmodx[1][i3] +
												   dvdy[6][i3] * hourmody[1][i3] +
												   dvdz[6][i3] * hourmodz[1][i3] );
			hourgam7[1][i3] = Gamma[1][7] -  volinv[i3]*(dvdx[7][i3] * hourmodx[1][i3] +
												   dvdy[7][i3] * hourmody[1][i3] +
												   dvdz[7][i3] * hourmodz[1][i3] );
			hourgam0[2][i3] = Gamma[2][0] -  volinv[i3]*(dvdx[0][i3] * hourmodx[2][i3] +
												   dvdy[0][i3] * hourmody[2][i3] +
												   dvdz[0][i3] * hourmodz[2][i3] );
			hourgam1[2][i3] = Gamma[2][1] -  volinv[i3]*(dvdx[1][i3] * hourmodx[2][i3] +
												   dvdy[1][i3] * hourmody[2][i3] +
												   dvdz[1][i3] * hourmodz[2][i3] );
			hourgam2[2][i3] = Gamma[2][2] -  volinv[i3]*(dvdx[2][i3] * hourmodx[2][i3] +
												   dvdy[2][i3] * hourmody[2][i3] +
												   dvdz[2][i3] * hourmodz[2][i3] );
			hourgam3[2][i3] = Gamma[2][3] -  volinv[i3]*(dvdx[3][i3] * hourmodx[2][i3] +
												   dvdy[3][i3] * hourmody[2][i3] +
												   dvdz[3][i3] * hourmodz[2][i3] );
			hourgam4[2][i3] = Gamma[2][4] -  volinv[i3]*(dvdx[4][i3] * hourmodx[2][i3] +
												   dvdy[4][i3] * hourmody[2][i3] +
												   dvdz[4][i3] * hourmodz[2][i3] );
			hourgam5[2][i3] = Gamma[2][5] -  volinv[i3]*(dvdx[5][i3] * hourmodx[2][i3] +
												   dvdy[5][i3] * hourmody[2][i3] +
												   dvdz[5][i3] * hourmodz[2][i3] );
			hourgam6[2][i3] = Gamma[2][6] -  volinv[i3]*(dvdx[6][i3] * hourmodx[2][i3] +
												   dvdy[6][i3] * hourmody[2][i3] +
												   dvdz[6][i3] * hourmodz[2][i3] );
			hourgam7[2][i3] = Gamma[2][7] -  volinv[i3]*(dvdx[7][i3] * hourmodx[2][i3] +
												   dvdy[7][i3] * hourmody[2][i3] +
												   dvdz[7][i3] * hourmodz[2][i3] );
			hourgam0[3][i3] = Gamma[3][0] -  volinv[i3]*(dvdx[0][i3] * hourmodx[3][i3] +
												   dvdy[0][i3] * hourmody[3][i3] +
												   dvdz[0][i3] * hourmodz[3][i3] );
			hourgam1[3][i3] = Gamma[3][1] -  volinv[i3]*(dvdx[1][i3] * hourmodx[3][i3] +
												   dvdy[1][i3] * hourmody[3][i3] +
												   dvdz[1][i3] * hourmodz[3][i3] );
			hourgam2[3][i3] = Gamma[3][2] -  volinv[i3]*(dvdx[2][i3] * hourmodx[3][i3] +
												   dvdy[2][i3] * hourmody[3][i3] +
												   dvdz[2][i3] * hourmodz[3][i3] );
			hourgam3[3][i3] = Gamma[3][3] -  volinv[i3]*(dvdx[3][i3] * hourmodx[3][i3] +
												   dvdy[3][i3] * hourmody[3][i3] +
												   dvdz[3][i3] * hourmodz[3][i3] );
			hourgam4[3][i3] = Gamma[3][4] -  volinv[i3]*(dvdx[4][i3] * hourmodx[3][i3] +
												   dvdy[4][i3] * hourmody[3][i3] +
												   dvdz[4][i3] * hourmodz[3][i3] );
			hourgam5[3][i3] = Gamma[3][5] -  volinv[i3]*(dvdx[5][i3] * hourmodx[3][i3] +
												   dvdy[5][i3] * hourmody[3][i3] +
												   dvdz[5][i3] * hourmodz[3][i3] );
			hourgam6[3][i3] = Gamma[3][6] -  volinv[i3]*(dvdx[6][i3] * hourmodx[3][i3] +
												   dvdy[6][i3] * hourmody[3][i3] +
												   dvdz[6][i3] * hourmodz[3][i3] );
			hourgam7[3][i3] = Gamma[3][7] -  volinv[i3]*(dvdx[7][i3] * hourmodx[3][i3] +
												   dvdy[7][i3] * hourmody[3][i3] +
												   dvdz[7][i3] * hourmodz[3][i3] );
//}
		/* compute forces */
		/* store forces into h arrays (force arrays) */
		
//	  for(Index_t i3 = 0; i3 < VEC_LEN; i3++) {
		ss1[i3]=domain.ss(i2+i3);
		mass1[i3]=domain.elemMass(i2+i3);
//}
//	  for(Index_t i3 = 0; i3 < VEC_LEN; i3++) {
		volume13[i3]=CBRT(determ[i3]);
//	   }
		
		
//	  for(Index_t i3 = 0; i3 < VEC_LEN; i3++) {
		coefficient[i3] = - hourg * Real_t(0.01) * ss1[i3] * mass1[i3] / volume13[i3];
//	    }
//	  for(Index_t i3 = 0; i3 < VEC_LEN; i3++) {
		
		//CalcElemFBHourglassForce(xd1[i3],yd1[i3],zd1[i3],
		//						 hourgam0[i3],hourgam1[i3],hourgam2[i3],hourgam3[i3],
		//						 hourgam4[i3],hourgam5[i3],hourgam6[i3],hourgam7[i3],
		//						 coefficient[i3], hgfx[i3], hgfy[i3], hgfz[i3]);
	Index_t i00=0;
	Index_t i01=1;
	Index_t i02=2;
	Index_t i03=3;
	
Real_t h00 =
	hourgam0[i00][i3] * xd1[0][i3] + hourgam1[i00][i3] * xd1[1][i3] +
	hourgam2[i00][i3] * xd1[2][i3] + hourgam3[i00][i3] * xd1[3][i3] +
	hourgam4[i00][i3] * xd1[4][i3] + hourgam5[i00][i3] * xd1[5][i3] +
	hourgam6[i00][i3] * xd1[6][i3] + hourgam7[i00][i3] * xd1[7][i3];
	
//	Real_t 
Real_t h01 =
	hourgam0[i01][i3] * xd1[0][i3] + hourgam1[i01][i3] * xd1[1][i3] +
	hourgam2[i01][i3] * xd1[2][i3] + hourgam3[i01][i3] * xd1[3][i3] +
	hourgam4[i01][i3] * xd1[4][i3] + hourgam5[i01][i3] * xd1[5][i3] +
	hourgam6[i01][i3] * xd1[6][i3] + hourgam7[i01][i3] * xd1[7][i3];
	
//	Real_t 
Real_t h02 =
	hourgam0[i02][i3] * xd1[0][i3] + hourgam1[i02][i3] * xd1[1][i3] +
	hourgam2[i02][i3] * xd1[2][i3] + hourgam3[i02][i3] * xd1[3][i3] +
	hourgam4[i02][i3] * xd1[4][i3] + hourgam5[i02][i3] * xd1[5][i3] +
	hourgam6[i02][i3] * xd1[6][i3] + hourgam7[i02][i3] * xd1[7][i3];
	
//	Real_t 
Real_t h03 =
	hourgam0[i03][i3] * xd1[0][i3] + hourgam1[i03][i3] * xd1[1][i3] +
	hourgam2[i03][i3] * xd1[2][i3] + hourgam3[i03][i3] * xd1[3][i3] +
	hourgam4[i03][i3] * xd1[4][i3] + hourgam5[i03][i3] * xd1[5][i3] +
	hourgam6[i03][i3] * xd1[6][i3] + hourgam7[i03][i3] * xd1[7][i3];
	
	
	hgfx[0][i3] = coefficient[i3] *
	(hourgam0[i00][i3] * h00 + hourgam0[i01][i3] * h01 +
	 hourgam0[i02][i3] * h02 + hourgam0[i03][i3] * h03);
	
	hgfx[1][i3] = coefficient[i3] *
	(hourgam1[i00][i3] * h00 + hourgam1[i01][i3] * h01 +
	 hourgam1[i02][i3] * h02 + hourgam1[i03][i3] * h03);
	
	hgfx[2][i3] = coefficient[i3] *
	(hourgam2[i00][i3] * h00 + hourgam2[i01][i3] * h01 +
	 hourgam2[i02][i3] * h02 + hourgam2[i03][i3] * h03);
	
	hgfx[3][i3] = coefficient[i3] *
	(hourgam3[i00][i3] * h00 + hourgam3[i01][i3] * h01 +
	 hourgam3[i02][i3] * h02 + hourgam3[i03][i3] * h03);
	
	hgfx[4][i3] = coefficient[i3] *
	(hourgam4[i00][i3] * h00 + hourgam4[i01][i3] * h01 +
	 hourgam4[i02][i3] * h02 + hourgam4[i03][i3] * h03);
	
	hgfx[5][i3] = coefficient[i3] *
	(hourgam5[i00][i3] * h00 + hourgam5[i01][i3] * h01 +
	 hourgam5[i02][i3] * h02 + hourgam5[i03][i3] * h03);
	
	hgfx[6][i3] = coefficient[i3] *
	(hourgam6[i00][i3] * h00 + hourgam6[i01][i3] * h01 +
	 hourgam6[i02][i3] * h02 + hourgam6[i03][i3] * h03);
	
	hgfx[7][i3] = coefficient[i3] *
	(hourgam7[i00][i3] * h00 + hourgam7[i01][i3] * h01 +
	 hourgam7[i02][i3] * h02 + hourgam7[i03][i3] * h03);
	
h00 =
	hourgam0[i00][i3] * yd1[0][i3] + hourgam1[i00][i3] * yd1[1][i3] +
	hourgam2[i00][i3] * yd1[2][i3] + hourgam3[i00][i3] * yd1[3][i3] +
	hourgam4[i00][i3] * yd1[4][i3] + hourgam5[i00][i3] * yd1[5][i3] +
	hourgam6[i00][i3] * yd1[6][i3] + hourgam7[i00][i3] * yd1[7][i3];
	
//	Real_t 
h01 =
	hourgam0[i01][i3] * yd1[0][i3] + hourgam1[i01][i3] * yd1[1][i3] +
	hourgam2[i01][i3] * yd1[2][i3] + hourgam3[i01][i3] * yd1[3][i3] +
	hourgam4[i01][i3] * yd1[4][i3] + hourgam5[i01][i3] * yd1[5][i3] +
	hourgam6[i01][i3] * yd1[6][i3] + hourgam7[i01][i3] * yd1[7][i3];
	
//	Real_t 
h02 =
	hourgam0[i02][i3] * yd1[0][i3] + hourgam1[i02][i3] * yd1[1][i3] +
	hourgam2[i02][i3] * yd1[2][i3] + hourgam3[i02][i3] * yd1[3][i3] +
	hourgam4[i02][i3] * yd1[4][i3] + hourgam5[i02][i3] * yd1[5][i3] +
	hourgam6[i02][i3] * yd1[6][i3] + hourgam7[i02][i3] * yd1[7][i3];
	
//	Real_t 
h03 =
	hourgam0[i03][i3] * yd1[0][i3] + hourgam1[i03][i3] * yd1[1][i3] +
	hourgam2[i03][i3] * yd1[2][i3] + hourgam3[i03][i3] * yd1[3][i3] +
	hourgam4[i03][i3] * yd1[4][i3] + hourgam5[i03][i3] * yd1[5][i3] +
	hourgam6[i03][i3] * yd1[6][i3] + hourgam7[i03][i3] * yd1[7][i3];
	
	
	hgfy[0][i3] = coefficient[i3] *
	(hourgam0[i00][i3] * h00 + hourgam0[i01][i3] * h01 +
	 hourgam0[i02][i3] * h02 + hourgam0[i03][i3] * h03);
	
	hgfy[1][i3] = coefficient[i3] *
	(hourgam1[i00][i3] * h00 + hourgam1[i01][i3] * h01 +
	 hourgam1[i02][i3] * h02 + hourgam1[i03][i3] * h03);
	
	hgfy[2][i3] = coefficient[i3] *
	(hourgam2[i00][i3] * h00 + hourgam2[i01][i3] * h01 +
	 hourgam2[i02][i3] * h02 + hourgam2[i03][i3] * h03);
	
	hgfy[3][i3] = coefficient[i3] *
	(hourgam3[i00][i3] * h00 + hourgam3[i01][i3] * h01 +
	 hourgam3[i02][i3] * h02 + hourgam3[i03][i3] * h03);
	
	hgfy[4][i3] = coefficient[i3] *
	(hourgam4[i00][i3] * h00 + hourgam4[i01][i3] * h01 +
	 hourgam4[i02][i3] * h02 + hourgam4[i03][i3] * h03);
	
	hgfy[5][i3] = coefficient[i3] *
	(hourgam5[i00][i3] * h00 + hourgam5[i01][i3] * h01 +
	 hourgam5[i02][i3] * h02 + hourgam5[i03][i3] * h03);
	
	hgfy[6][i3] = coefficient[i3] *
	(hourgam6[i00][i3] * h00 + hourgam6[i01][i3] * h01 +
	 hourgam6[i02][i3] * h02 + hourgam6[i03][i3] * h03);
	
	hgfy[7][i3] = coefficient[i3] *
	(hourgam7[i00][i3] * h00 + hourgam7[i01][i3] * h01 +
	 hourgam7[i02][i3] * h02 + hourgam7[i03][i3] * h03);
	
//	Real_t 
h00 =
	hourgam0[i00][i3] * zd1[0][i3] + hourgam1[i00][i3] * zd1[1][i3] +
	hourgam2[i00][i3] * zd1[2][i3] + hourgam3[i00][i3] * zd1[3][i3] +
	hourgam4[i00][i3] * zd1[4][i3] + hourgam5[i00][i3] * zd1[5][i3] +
	hourgam6[i00][i3] * zd1[6][i3] + hourgam7[i00][i3] * zd1[7][i3];
	
//	Real_t 
h01 =
	hourgam0[i01][i3] * zd1[0][i3] + hourgam1[i01][i3] * zd1[1][i3] +
	hourgam2[i01][i3] * zd1[2][i3] + hourgam3[i01][i3] * zd1[3][i3] +
	hourgam4[i01][i3] * zd1[4][i3] + hourgam5[i01][i3] * zd1[5][i3] +
	hourgam6[i01][i3] * zd1[6][i3] + hourgam7[i01][i3] * zd1[7][i3];
	
//	Real_t 
h02 =
	hourgam0[i02][i3] * zd1[0][i3] + hourgam1[i02][i3] * zd1[1][i3] +
	hourgam2[i02][i3] * zd1[2][i3] + hourgam3[i02][i3] * zd1[3][i3] +
	hourgam4[i02][i3] * zd1[4][i3] + hourgam5[i02][i3] * zd1[5][i3] +
	hourgam6[i02][i3] * zd1[6][i3] + hourgam7[i02][i3] * zd1[7][i3];
	
//	Real_t 
h03 =
	hourgam0[i03][i3] * zd1[0][i3] + hourgam1[i03][i3] * zd1[1][i3] +
	hourgam2[i03][i3] * zd1[2][i3] + hourgam3[i03][i3] * zd1[3][i3] +
	hourgam4[i03][i3] * zd1[4][i3] + hourgam5[i03][i3] * zd1[5][i3] +
	hourgam6[i03][i3] * zd1[6][i3] + hourgam7[i03][i3] * zd1[7][i3];
	
	
	hgfz[0][i3] = coefficient[i3] *
	(hourgam0[i00][i3] * h00 + hourgam0[i01][i3] * h01 +
	 hourgam0[i02][i3] * h02 + hourgam0[i03][i3] * h03);
	
	hgfz[1][i3] = coefficient[i3] *
	(hourgam1[i00][i3] * h00 + hourgam1[i01][i3] * h01 +
	 hourgam1[i02][i3] * h02 + hourgam1[i03][i3] * h03);
	
	hgfz[2][i3] = coefficient[i3] *
	(hourgam2[i00][i3] * h00 + hourgam2[i01][i3] * h01 +
	 hourgam2[i02][i3] * h02 + hourgam2[i03][i3] * h03);
	
	hgfz[3][i3] = coefficient[i3] *
	(hourgam3[i00][i3] * h00 + hourgam3[i01][i3] * h01 +
	 hourgam3[i02][i3] * h02 + hourgam3[i03][i3] * h03);
	
	hgfz[4][i3] = coefficient[i3] *
	(hourgam4[i00][i3] * h00 + hourgam4[i01][i3] * h01 +
	 hourgam4[i02][i3] * h02 + hourgam4[i03][i3] * h03);
	
	hgfz[5][i3] = coefficient[i3] *
	(hourgam5[i00][i3] * h00 + hourgam5[i01][i3] * h01 +
	 hourgam5[i02][i3] * h02 + hourgam5[i03][i3] * h03);
	
	hgfz[6][i3] = coefficient[i3] *
	(hourgam6[i00][i3] * h00 + hourgam6[i01][i3] * h01 +
	 hourgam6[i02][i3] * h02 + hourgam6[i03][i3] * h03);
	
	hgfz[7][i3] = coefficient[i3] *
	(hourgam7[i00][i3] * h00 + hourgam7[i01][i3] * h01 +
	 hourgam7[i02][i3] * h02 + hourgam7[i03][i3] * h03);
       }
	  for(Index_t i3 = 0; i3 < VEC_LEN; i3++) {
		
		domain.fx_elem((i2+i3)*8) = hgfx[0][i3];
		domain.fx_elem((i2+i3)*8+1) = hgfx[1][i3];
		domain.fx_elem((i2+i3)*8+2) = hgfx[2][i3];
		domain.fx_elem((i2+i3)*8+3) = hgfx[3][i3];
		domain.fx_elem((i2+i3)*8+4) = hgfx[4][i3];
		domain.fx_elem((i2+i3)*8+5) = hgfx[5][i3];
		domain.fx_elem((i2+i3)*8+6) = hgfx[6][i3];
		domain.fx_elem((i2+i3)*8+7) = hgfx[7][i3];
		
		domain.fy_elem((i2+i3)*8) = hgfy[0][i3];
		domain.fy_elem((i2+i3)*8+1) = hgfy[1][i3];
		domain.fy_elem((i2+i3)*8+2) = hgfy[2][i3];
		domain.fy_elem((i2+i3)*8+3) = hgfy[3][i3];
		domain.fy_elem((i2+i3)*8+4) = hgfy[4][i3];
		domain.fy_elem((i2+i3)*8+5) = hgfy[5][i3];
		domain.fy_elem((i2+i3)*8+6) = hgfy[6][i3];
		domain.fy_elem((i2+i3)*8+7) = hgfy[7][i3];
	
		domain.fz_elem((i2+i3)*8) = hgfz[0][i3];
		domain.fz_elem((i2+i3)*8+1) = hgfz[1][i3];
		domain.fz_elem((i2+i3)*8+2) = hgfz[2][i3];
		domain.fz_elem((i2+i3)*8+3) = hgfz[3][i3];
		domain.fz_elem((i2+i3)*8+4) = hgfz[4][i3];
		domain.fz_elem((i2+i3)*8+5) = hgfz[5][i3];
		domain.fz_elem((i2+i3)*8+6) = hgfz[6][i3];
		domain.fz_elem((i2+i3)*8+7) = hgfz[7][i3];
	   }
		
	}
#ifdef GATHER_MICRO_TIMING
	//gettimeofday(&end, NULL);
	//elapsed[2] += double(end.tv_sec - start.tv_sec) + double(end.tv_usec - start.tv_usec) *1e-6;
	t2=getticks();
	elapsed_time[2] += elapsed(t2, t1);
#endif
	
	{
		Index_t numNode = domain.numNode() ;
		
#ifdef GATHER_MICRO_TIMING
//	timeval start, end;
//	gettimeofday(&start, NULL);
	ticks t1, t2;
	t1=getticks();
#endif
#pragma omp parallel for firstprivate(numNode)
		for( Index_t gnode=0 ; gnode<numNode ; ++gnode )
		{
			Index_t count = domain.nodeElemCount(gnode) ;
			Index_t start = domain.nodeElemStart(gnode) ;
			Real_t fx = Real_t(0.0) ;
			Real_t fy = Real_t(0.0) ;
			Real_t fz = Real_t(0.0) ;
			for (Index_t i=0 ; i < count ; ++i) {
				Index_t elem = domain.nodeElemCornerList(start+i) ;
				fx += domain.fx_elem(elem) ;
				fy += domain.fy_elem(elem) ;
				fz += domain.fz_elem(elem) ;
			}
			domain.fx(gnode) += fx ;
			domain.fy(gnode) += fy ;
			domain.fz(gnode) += fz ;
		}
#ifdef GATHER_MICRO_TIMING
	t2=getticks();
	elapsed_time[3] += elapsed(t2, t1);
//	gettimeofday(&end, NULL);
//	elapsed[3] += double(end.tv_sec - start.tv_sec) + double(end.tv_usec - start.tv_usec) *1e-6;
#endif
	}
}


//  CalcHourglassControlForElems eliminated.
//     Pre-fetch of x1, y1, z1        moved to CalcFBHourglassForceForElems
//     Pre-calc  of dvdx, dvdy, dvdz  moved to CalcFBHourglassForceForElems



static inline
void CalcVolumeForceForElems()
{
	Index_t numElem = domain.numElem() ;
	if (numElem != 0) {
		Real_t  hgcoef = domain.hgcoef() ;
		
		// Sum contributions to total stress tensor moved into IntegrateStressForElems
		
		// Call elemlib stress integration loop to produce nodal forces from
		// material stresses.

		IntegrateStressForElems( numElem) ;
		
		// check for negative element volume moved to CalcKinematicsForElems
		
		if ( hgcoef > Real_t(0.) ) { CalcFBHourglassForceForElems(hgcoef) ; }
		
	}
}

//  CalcForceForNodes eliminated
//     Initialization of Force array to zero no longer needed.


static inline
void CalcAccelerationForNodes()
{
	Index_t numNode = domain.numNode() ;
#ifdef GATHER_MICRO_TIMING
	//timeval start, end;
	//gettimeofday(&start, NULL);
	ticks t1, t2;
	t1=getticks();
#endif
#pragma omp parallel for firstprivate(numNode)
	for (Index_t i = 0; i < numNode; ++i) {
		domain.xdd(i) = domain.fx(i) / domain.nodalMass(i);
		domain.ydd(i) = domain.fy(i) / domain.nodalMass(i);
		domain.zdd(i) = domain.fz(i) / domain.nodalMass(i);
	}
#ifdef GATHER_MICRO_TIMING
	//gettimeofday(&end, NULL);
	//elapsed[4] += double(end.tv_sec - start.tv_sec) + double(end.tv_usec - start.tv_usec) *1e-6;
	t2=getticks();
	elapsed_time[4] += elapsed(t2, t1);
#endif
}


static inline
void ApplyAccelerationBoundaryConditionsForNodes()
{
	Index_t numNodeBC = (domain.sizeX()+1)*(domain.sizeX()+1) ;
	
#ifdef GATHER_MICRO_TIMING
	//timeval start, end;
	//gettimeofday(&start, NULL);
	ticks t1, t2;
	t1=getticks();
#endif
#pragma omp parallel for firstprivate(numNodeBC)
	for(Index_t i=0 ; i<numNodeBC ; ++i){
		domain.xdd(domain.symmX(i)) = Real_t(0.0) ;
		domain.ydd(domain.symmY(i)) = Real_t(0.0) ;
		domain.zdd(domain.symmZ(i)) = Real_t(0.0) ;
		}
#ifdef GATHER_MICRO_TIMING
	//gettimeofday(&end, NULL);
	//elapsed[5] += double(end.tv_sec - start.tv_sec) + double(end.tv_usec - start.tv_usec) *1e-6;
	t2=getticks();
	elapsed_time[5] += elapsed(t2, t1);
#endif
}



static inline
void LagrangeNodal()
{
	const Real_t      dt  = domain.deltatime() ;
	const Real_t   u_cut  = domain.u_cut() ;

	Index_t numNode = domain.numNode() ;

	CalcVolumeForceForElems() ;

	/* Calculate Nodal Forces at domain boundaries */
	/* problem->commSBN->Transfer(CommSBN::forces); */
	
	CalcAccelerationForNodes();
	
	ApplyAccelerationBoundaryConditionsForNodes();
	
	
		
#ifdef GATHER_MICRO_TIMING
	ticks t1, t2;
	t1=getticks();
	//timeval start, end;
	//gettimeofday(&start, NULL);
#endif
#pragma omp parallel for firstprivate(numNode)
	for (Index_t NodeId=0; NodeId<numNode; ++NodeId) {
		
		
		// Calculate new Velocity for the Node
		
		Real_t xdtmp = domain.xd(NodeId) + domain.xdd(NodeId) * dt ;
		if( FABS(xdtmp) < u_cut ) xdtmp = Real_t(0.0);
		domain.xd(NodeId) = xdtmp ;
		
		Real_t ydtmp = domain.yd(NodeId) + domain.ydd(NodeId) * dt ;
		if( FABS(ydtmp) < u_cut ) ydtmp = Real_t(0.0);
		domain.yd(NodeId) = ydtmp ;
		
		Real_t zdtmp = domain.zd(NodeId) + domain.zdd(NodeId) * dt ;
		if( FABS(zdtmp) < u_cut ) zdtmp = Real_t(0.0);
		domain.zd(NodeId) = zdtmp ;
		
		//  Calculate new Postion for the Node
		
		domain.x(NodeId) += domain.xd(NodeId) * dt ;
		domain.y(NodeId) += domain.yd(NodeId) * dt ;
		domain.z(NodeId) += domain.zd(NodeId) * dt ;
		
	}
#ifdef GATHER_MICRO_TIMING
	//gettimeofday(&end, NULL);
	//elapsed[6] += double(end.tv_sec - start.tv_sec) + double(end.tv_usec - start.tv_usec) *1e-6;
	t2=getticks();
	elapsed_time[6] += elapsed(t2, t1);
#endif
	
	return;
}

static inline
Real_t CalcElemVolume( const Real_t Pos[8][3] )
{
	const int x = 0;
	const int y = 1;
	const int z = 2;
	Real_t twelveth = Real_t(1.0)/Real_t(12.0);
	
	
	Real_t dx61 = Pos[6][x] - Pos[1][x];
	Real_t dy61 = Pos[6][y] - Pos[1][y];
	Real_t dz61 = Pos[6][z] - Pos[1][z];
	
	Real_t dx70 = Pos[7][x] - Pos[0][x];
	Real_t dy70 = Pos[7][y] - Pos[0][y];
	Real_t dz70 = Pos[7][z] - Pos[0][z];
	
	Real_t dx63 = Pos[6][x] - Pos[3][x];
	Real_t dy63 = Pos[6][y] - Pos[3][y];
	Real_t dz63 = Pos[6][z] - Pos[3][z];
	
	Real_t dx20 = Pos[2][x] - Pos[0][x];
	Real_t dy20 = Pos[2][y] - Pos[0][y];
	Real_t dz20 = Pos[2][z] - Pos[0][z];
	
	Real_t dx50 = Pos[5][x] - Pos[0][x];
	Real_t dy50 = Pos[5][y] - Pos[0][y];
	Real_t dz50 = Pos[5][z] - Pos[0][z];
	
	Real_t dx64 = Pos[6][x] - Pos[4][x];
	Real_t dy64 = Pos[6][y] - Pos[4][y];
	Real_t dz64 = Pos[6][z] - Pos[4][z];
	
	Real_t dx31 = Pos[3][x] - Pos[1][x];
	Real_t dy31 = Pos[3][y] - Pos[1][y];
	Real_t dz31 = Pos[3][z] - Pos[1][z];
	
	Real_t dx72 = Pos[7][x] - Pos[2][x];
	Real_t dy72 = Pos[7][y] - Pos[2][y];
	Real_t dz72 = Pos[7][z] - Pos[2][z];
	
	Real_t dx43 = Pos[4][x] - Pos[3][x];
	Real_t dy43 = Pos[4][y] - Pos[3][y];
	Real_t dz43 = Pos[4][z] - Pos[3][z];
	
	Real_t dx57 = Pos[5][x] - Pos[7][x];
	Real_t dy57 = Pos[5][y] - Pos[7][y];
	Real_t dz57 = Pos[5][z] - Pos[7][z];
	
	Real_t dx14 = Pos[1][x] - Pos[4][x];
	Real_t dy14 = Pos[1][y] - Pos[4][y];
	Real_t dz14 = Pos[1][z] - Pos[4][z];
		
	Real_t dx25 = Pos[2][x] - Pos[5][x];
	Real_t dy25 = Pos[2][y] - Pos[5][y];
	Real_t dz25 = Pos[2][z] - Pos[5][z];
	
#define TRIPLE_PRODUCT(x1, y1, z1, x2, y2, z2, x3, y3, z3) \
((x1)*((y2)*(z3) - (z2)*(y3)) + (x2)*((z1)*(y3) - (y1)*(z3)) + (x3)*((y1)*(z2) - (z1)*(y2)))
	
	Real_t volume =
    TRIPLE_PRODUCT(dx31 + dx72, dx63, dx20,
				   dy31 + dy72, dy63, dy20,
				   dz31 + dz72, dz63, dz20) +
    TRIPLE_PRODUCT(dx43 + dx57, dx64, dx70,
				   dy43 + dy57, dy64, dy70,
				   dz43 + dz57, dz64, dz70) +
    TRIPLE_PRODUCT(dx14 + dx25, dx61, dx50,
				   dy14 + dy25, dy61, dy50,
				   dz14 + dz25, dz61, dz50);
	
#undef TRIPLE_PRODUCT
	
	volume *= twelveth;
	
	return volume ;
}


static inline
Real_t AreaFace( const Real_t Pos[8][3],
				 const int    c0,
				 const int    c1,
				 const int    c2,
				 const int    c3        )
{
	const int x = 0;
	const int y = 1;
	const int z = 2;

	Real_t fx = (Pos[c2][x] - Pos[c0][x]) - (Pos[c3][x] - Pos[c1][x]);
	Real_t fy = (Pos[c2][y] - Pos[c0][y]) - (Pos[c3][y] - Pos[c1][y]);
	Real_t fz = (Pos[c2][z] - Pos[c0][z]) - (Pos[c3][z] - Pos[c1][z]);
	
	Real_t gx = (Pos[c2][x] - Pos[c0][x]) + (Pos[c3][x] - Pos[c1][x]);
	Real_t gy = (Pos[c2][y] - Pos[c0][y]) + (Pos[c3][y] - Pos[c1][y]);
	Real_t gz = (Pos[c2][z] - Pos[c0][z]) + (Pos[c3][z] - Pos[c1][z]);
	
	Real_t area =	(fx * fx + fy * fy + fz * fz) *
					(gx * gx + gy * gy + gz * gz) -
					(fx * gx + fy * gy + fz * gz) *
					(fx * gx + fy * gy + fz * gz);
	return area ;
}

static inline
Real_t CalcElemCharacteristicLength( const Real_t Pos[8][3],
									 const Real_t volume    )
{
	Real_t a, charLength = Real_t(0.0);
	
	a = AreaFace(Pos, 0, 1, 2, 3); 
	charLength = std::max(a,charLength) ;
	
	a = AreaFace(Pos, 4, 5, 6, 7); 
	charLength = std::max(a,charLength) ;
	
	a = AreaFace(Pos, 0, 1, 5, 4); 
	charLength = std::max(a,charLength) ;
	
	a = AreaFace(Pos, 1, 2, 6, 5); 
	charLength = std::max(a,charLength) ;
	
	a = AreaFace(Pos, 2, 3, 7, 6); 
	charLength = std::max(a,charLength) ;
	
	a = AreaFace(Pos, 3, 0, 4, 7); 
	charLength = std::max(a,charLength) ;
	
	charLength = Real_t(4.0) * volume / SQRT(charLength);
	
	return charLength;
}

static inline
void CalcElemVelocityGrandient( const Real_t vel[8][3],
							    const Real_t b[][8],
							    const Real_t detJ,
							          Real_t* const d )
{	const int x = 0;
	const int y = 1;
	const int z = 2;
	
	const Real_t inv_detJ = Real_t(1.0) / detJ ;
	Real_t dyddx, dxddy, dzddx, dxddz, dzddy, dyddz;
	const Real_t* const pfx = b[0];
	const Real_t* const pfy = b[1];
	const Real_t* const pfz = b[2];
	
	d[0] =   inv_detJ * (  pfx[0] * (vel[0][x]-vel[6][x])
					     + pfx[1] * (vel[1][x]-vel[7][x])
					     + pfx[2] * (vel[2][x]-vel[4][x])
					     + pfx[3] * (vel[3][x]-vel[5][x]) );
	
	d[1] =   inv_detJ * (  pfy[0] * (vel[0][y]-vel[6][y])
					     + pfy[1] * (vel[1][y]-vel[7][y])
					     + pfy[2] * (vel[2][y]-vel[4][y])
					     + pfy[3] * (vel[3][y]-vel[5][y]) );
	
	d[2]   = inv_detJ * (  pfz[0] * (vel[0][z]-vel[6][z])
					     + pfz[1] * (vel[1][z]-vel[7][z])
					     + pfz[2] * (vel[2][z]-vel[4][z])
					     + pfz[3] * (vel[3][z]-vel[5][z]) );
	
	dyddx  = inv_detJ * (  pfx[0] * (vel[0][y]-vel[6][y])
						 + pfx[1] * (vel[1][y]-vel[7][y])
						 + pfx[2] * (vel[2][y]-vel[4][y])
						 + pfx[3] * (vel[3][y]-vel[5][y]) );
	
	dxddy  = inv_detJ * (  pfy[0] * (vel[0][x]-vel[6][x])
						 + pfy[1] * (vel[1][x]-vel[7][x])
						 + pfy[2] * (vel[2][x]-vel[4][x])
						 + pfy[3] * (vel[3][x]-vel[5][x]) );
	
	dzddx  = inv_detJ * (  pfx[0] * (vel[0][z]-vel[6][z])
						 + pfx[1] * (vel[1][z]-vel[7][z])
						 + pfx[2] * (vel[2][z]-vel[4][z])
						 + pfx[3] * (vel[3][z]-vel[5][z]) );
	
	dxddz  = inv_detJ * (  pfz[0] * (vel[0][x]-vel[6][x])
						 + pfz[1] * (vel[1][x]-vel[7][x])
						 + pfz[2] * (vel[2][x]-vel[4][x])
						 + pfz[3] * (vel[3][x]-vel[5][x]) );
	
	dzddy  = inv_detJ * (  pfy[0] * (vel[0][z]-vel[6][z])
						 + pfy[1] * (vel[1][z]-vel[7][z])
						 + pfy[2] * (vel[2][z]-vel[4][z])
						 + pfy[3] * (vel[3][z]-vel[5][z]) );
	
	dyddz  = inv_detJ * (  pfz[0] * (vel[0][y]-vel[6][y])
						 + pfz[1] * (vel[1][y]-vel[7][y])
						 + pfz[2] * (vel[2][y]-vel[4][y])
						 + pfz[3] * (vel[3][y]-vel[5][y]) );
	
	d[5]  = Real_t( .5) * ( dxddy + dyddx );
	d[4]  = Real_t( .5) * ( dxddz + dzddx );
	d[3]  = Real_t( .5) * ( dzddy + dyddz );
}



static inline
void CalcElemShapeFunctionDerivatives( const Real_t  Pos[8][3],
									  Real_t  b[][8],
									  Real_t* const volume )
{	const int x = 0;
	const int y = 1;
	const int z = 2;
	
	const Real_t x0 = Pos[0][x] ;   const Real_t x1 = Pos[1][x] ;
	const Real_t x2 = Pos[2][x] ;   const Real_t x3 = Pos[3][x] ;
	const Real_t x4 = Pos[4][x] ;   const Real_t x5 = Pos[5][x] ;
	const Real_t x6 = Pos[6][x] ;   const Real_t x7 = Pos[7][x] ;
	
	const Real_t y0 = Pos[0][y] ;   const Real_t y1 = Pos[1][y] ;
	const Real_t y2 = Pos[2][y] ;   const Real_t y3 = Pos[3][y] ;
	const Real_t y4 = Pos[4][y] ;   const Real_t y5 = Pos[5][y] ;
	const Real_t y6 = Pos[6][y] ;   const Real_t y7 = Pos[7][y] ;
	
	const Real_t z0 = Pos[0][z] ;   const Real_t z1 = Pos[1][z] ;
	const Real_t z2 = Pos[2][z] ;   const Real_t z3 = Pos[3][z] ;
	const Real_t z4 = Pos[4][z] ;   const Real_t z5 = Pos[5][z] ;
	const Real_t z6 = Pos[6][z] ;   const Real_t z7 = Pos[7][z] ;
	
	Real_t fjxxi, fjxet, fjxze;
	Real_t fjyxi, fjyet, fjyze;
	Real_t fjzxi, fjzet, fjzze;
	Real_t cjxxi, cjxet, cjxze;
	Real_t cjyxi, cjyet, cjyze;
	Real_t cjzxi, cjzet, cjzze;
	
	fjxxi = .125 * ( (x6-x0) + (x5-x3) - (x7-x1) - (x4-x2) );
	fjxet = .125 * ( (x6-x0) - (x5-x3) + (x7-x1) - (x4-x2) );
	fjxze = .125 * ( (x6-x0) + (x5-x3) + (x7-x1) + (x4-x2) );
	
	fjyxi = .125 * ( (y6-y0) + (y5-y3) - (y7-y1) - (y4-y2) );
	fjyet = .125 * ( (y6-y0) - (y5-y3) + (y7-y1) - (y4-y2) );
	fjyze = .125 * ( (y6-y0) + (y5-y3) + (y7-y1) + (y4-y2) );
	
	fjzxi = .125 * ( (z6-z0) + (z5-z3) - (z7-z1) - (z4-z2) );
	fjzet = .125 * ( (z6-z0) - (z5-z3) + (z7-z1) - (z4-z2) );
	fjzze = .125 * ( (z6-z0) + (z5-z3) + (z7-z1) + (z4-z2) );
	
	/* compute cofactors */
	cjxxi =    (fjyet * fjzze) - (fjzet * fjyze);
	cjxet =  - (fjyxi * fjzze) + (fjzxi * fjyze);
	cjxze =    (fjyxi * fjzet) - (fjzxi * fjyet);
	
	cjyxi =  - (fjxet * fjzze) + (fjzet * fjxze);
	cjyet =    (fjxxi * fjzze) - (fjzxi * fjxze);
	cjyze =  - (fjxxi * fjzet) + (fjzxi * fjxet);
	
	cjzxi =    (fjxet * fjyze) - (fjyet * fjxze);
	cjzet =  - (fjxxi * fjyze) + (fjyxi * fjxze);
	cjzze =    (fjxxi * fjyet) - (fjyxi * fjxet);
	
	/* calculate partials :
     this need only be done for l = 0,1,2,3   since , by symmetry ,
     (6,7,4,5) = - (0,1,2,3) .
	 */
	b[0][0] =   -  cjxxi  -  cjxet  -  cjxze;
	b[0][1] =      cjxxi  -  cjxet  -  cjxze;
	b[0][2] =      cjxxi  +  cjxet  -  cjxze;
	b[0][3] =   -  cjxxi  +  cjxet  -  cjxze;
	b[0][4] = -b[0][2];
	b[0][5] = -b[0][3];
	b[0][6] = -b[0][0];
	b[0][7] = -b[0][1];
	
	b[1][0] =   -  cjyxi  -  cjyet  -  cjyze;
	b[1][1] =      cjyxi  -  cjyet  -  cjyze;
	b[1][2] =      cjyxi  +  cjyet  -  cjyze;
	b[1][3] =   -  cjyxi  +  cjyet  -  cjyze;
	b[1][4] = -b[1][2];
	b[1][5] = -b[1][3];
	b[1][6] = -b[1][0];
	b[1][7] = -b[1][1];
	
	b[2][0] =   -  cjzxi  -  cjzet  -  cjzze;
	b[2][1] =      cjzxi  -  cjzet  -  cjzze;
	b[2][2] =      cjzxi  +  cjzet  -  cjzze;
	b[2][3] =   -  cjzxi  +  cjzet  -  cjzze;
	b[2][4] = -b[2][2];
	b[2][5] = -b[2][3];
	b[2][6] = -b[2][0];
	b[2][7] = -b[2][1];
	
	/* calculate jacobian determinant (volume) */
	*volume = Real_t(8.) * ( fjxet * cjxet + fjyet * cjyet + fjzet * cjzet);
}



static inline
void CalcKinematicsForElems( const Index_t ElemId,
							 const Real_t  Pos[8][3],
							 const Real_t  Vel[8][3],
							 const Real_t  dt          )
{
		Real_t B[3][8] ; /** shape function derivatives */
		Real_t D[6] ;
		Real_t Pos_local[8][3] ;
		Real_t detJ = Real_t(0.0) ;
		
		Real_t volume ;
		Real_t relativeVolume ;

		// volume calculations

		volume = CalcElemVolume(Pos);
		relativeVolume = volume / domain.volo(ElemId) ;
		domain.vnew(ElemId) = relativeVolume ;

		//  volume error check moved from Force Calculation to here.
	
		if (relativeVolume <= Real_t(0.0)) { exit(VolumeError) ; }
		
		domain.delv(ElemId) = relativeVolume - domain.v(ElemId) ;
		
		// set characteristic length
	
		domain.arealg(ElemId) = CalcElemCharacteristicLength(Pos, volume);
		
		Real_t dt2 = Real_t(0.5) * dt;
		for ( Index_t j=0 ; j<8 ; ++j )
		{
			Pos_local[j][0] = Pos[j][0] - dt2 * Vel[j][0];
			Pos_local[j][1] = Pos[j][1] - dt2 * Vel[j][1];
			Pos_local[j][2] = Pos[j][2] - dt2 * Vel[j][2];
		}
		
		CalcElemShapeFunctionDerivatives( Pos_local, B, &detJ );
		
		CalcElemVelocityGrandient( Vel, B, detJ, D );
		
		// put velocity gradient quantities into their global arrays.
		domain.dxx(ElemId) = D[0];
		domain.dyy(ElemId) = D[1];
		domain.dzz(ElemId) = D[2];
}

static inline
void CalcLagrangeElements(const Index_t ElemId,
						  const Real_t  Pos[8][3],
						  const Real_t  Vel[8][3],
						  const Real_t  deltatime  )
{
	CalcKinematicsForElems(ElemId, Pos, Vel, deltatime) ;
		
	// calc strain rate and apply as constraint (only done in FB element)
	
	Real_t vdov = domain.dxx(ElemId) + domain.dyy(ElemId) + domain.dzz(ElemId) ;
	Real_t vdovthird = vdov/Real_t(3.0) ;
			
	// make the rate of deformation tensor deviatoric
	domain.vdov(ElemId) = vdov ;
	domain.dxx(ElemId) -= vdovthird ;
	domain.dyy(ElemId) -= vdovthird ;
	domain.dzz(ElemId) -= vdovthird ;
}


static inline
void CalcMonotonicQGradientsForElems(const Index_t ElemId,
									 const Real_t  Pos[8][3],
									 const Real_t  Vel[8][3]   )
{
#define SUM4(a,b,c,d) (a + b + c + d)
	
	const Real_t ptiny = Real_t(1.e-36) ;
	Real_t ax,ay,az ;
	Real_t dxv,dyv,dzv ;

	const int x = 0;
	const int y = 1;
	const int z = 2;
		
	Real_t vol = domain.volo(ElemId)*domain.vnew(ElemId) ;
	Real_t norm = Real_t(1.0) / ( vol + ptiny ) ;
		
	Real_t dxj = Real_t(-0.25)*
					( SUM4( Pos[0][x], Pos[1][x], Pos[5][x], Pos[4][x] ) 
					- SUM4( Pos[3][x], Pos[2][x], Pos[6][x], Pos[7][x] )) ;
	Real_t dyj = Real_t(-0.25)*
					( SUM4( Pos[0][y], Pos[1][y], Pos[5][y], Pos[4][y] ) 
					- SUM4( Pos[3][y], Pos[2][y], Pos[6][y], Pos[7][y] )) ;
	Real_t dzj = Real_t(-0.25)*
					( SUM4( Pos[0][z], Pos[1][z], Pos[5][z], Pos[4][z] ) 
					- SUM4( Pos[3][z], Pos[2][z], Pos[6][z], Pos[7][z] )) ;
		
	Real_t dxi = Real_t(-0.25)*
					( SUM4( Pos[1][x], Pos[2][x], Pos[6][x], Pos[5][x] ) 
					- SUM4( Pos[0][x], Pos[3][x], Pos[7][x], Pos[4][x] )) ;
	Real_t dyi = Real_t(-0.25)*
					( SUM4( Pos[1][y], Pos[2][y], Pos[6][y], Pos[5][y] ) 
					- SUM4( Pos[0][y], Pos[3][y], Pos[7][y], Pos[4][y] )) ;
	Real_t dzi = Real_t(-0.25)*
					( SUM4( Pos[1][z], Pos[2][z], Pos[6][z], Pos[5][z] ) 
					- SUM4( Pos[0][z], Pos[3][z], Pos[7][z], Pos[4][z] )) ;
				
	Real_t dxk = Real_t(-0.25)*
					( SUM4( Pos[4][x], Pos[5][x], Pos[6][x], Pos[7][x] ) 
					- SUM4( Pos[0][x], Pos[1][x], Pos[2][x], Pos[3][x] )) ;
	Real_t dyk = Real_t(-0.25)*
					( SUM4( Pos[4][y], Pos[5][y], Pos[6][y], Pos[7][y] ) 
					- SUM4( Pos[0][y], Pos[1][y], Pos[2][y], Pos[3][y] )) ;
	Real_t dzk = Real_t(-0.25)*
					( SUM4( Pos[4][z], Pos[5][z], Pos[6][z], Pos[7][z] ) 
					- SUM4( Pos[0][z], Pos[1][z], Pos[2][z], Pos[3][z] )) ;
				
	/* find delvk and delxk ( i cross j ) */
		
	ax = dyi*dzj - dzi*dyj ;
	ay = dzi*dxj - dxi*dzj ;
	az = dxi*dyj - dyi*dxj ;
		
	domain.delx_zeta(ElemId) = vol / SQRT(ax*ax + ay*ay + az*az + ptiny) ;
		
	ax *= norm ;
	ay *= norm ;
	az *= norm ;
		
	dxv = Real_t(-0.25)*
					( SUM4( Vel[4][x], Vel[5][x], Vel[6][x], Vel[7][x] ) 
					- SUM4( Vel[0][x], Vel[1][x], Vel[2][x], Vel[3][x] )) ;
	dyv = Real_t(-0.25)*
					( SUM4( Vel[4][y], Vel[5][y], Vel[6][y], Vel[7][y] ) 
					- SUM4( Vel[0][y], Vel[1][y], Vel[2][y], Vel[3][y] )) ;
	dzv = Real_t(-0.25)*
					( SUM4( Vel[4][z], Vel[5][z], Vel[6][z], Vel[7][z] ) 
					- SUM4( Vel[0][z], Vel[1][z], Vel[2][z], Vel[3][z] )) ;
		
				
	domain.delv_zeta(ElemId) = ax*dxv + ay*dyv + az*dzv ;
		
	/* find delxi and delvi ( j cross k ) */
		
	ax = dyj*dzk - dzj*dyk ;
	ay = dzj*dxk - dxj*dzk ;
	az = dxj*dyk - dyj*dxk ;
		
	domain.delx_xi(ElemId) = vol / SQRT(ax*ax + ay*ay + az*az + ptiny) ;
		
	ax *= norm ;
	ay *= norm ;
	az *= norm ;
		
	dxv = Real_t(-0.25)*
				( SUM4( Vel[1][x], Vel[2][x], Vel[6][x], Vel[5][x] ) 
				- SUM4( Vel[0][x], Vel[3][x], Vel[7][x], Vel[4][x] )) ;
	dyv = Real_t(-0.25)*
				( SUM4( Vel[1][y], Vel[2][y], Vel[6][y], Vel[5][y] ) 
				- SUM4( Vel[0][y], Vel[3][y], Vel[7][y], Vel[4][y] )) ;
	dzv = Real_t(-0.25)*
				( SUM4( Vel[1][z], Vel[2][z], Vel[6][z], Vel[5][z] ) 
				- SUM4( Vel[0][z], Vel[3][z], Vel[7][z], Vel[4][z] )) ;
		
	domain.delv_xi(ElemId) = ax*dxv + ay*dyv + az*dzv ;
		
	/* find delxj and delvj ( k cross i ) */
		
	ax = dyk*dzi - dzk*dyi ;
	ay = dzk*dxi - dxk*dzi ;
	az = dxk*dyi - dyk*dxi ;
		
	domain.delx_eta(ElemId) = vol / SQRT(ax*ax + ay*ay + az*az + ptiny) ;
		
	ax *= norm ;
	ay *= norm ;
	az *= norm ;
		
	dxv = Real_t(-0.25)*
				( SUM4( Vel[0][x], Vel[1][x], Vel[5][x], Vel[4][x] ) 
				- SUM4( Vel[3][x], Vel[2][x], Vel[6][x], Vel[7][x] )) ;
	dyv = Real_t(-0.25)*
				( SUM4( Vel[0][y], Vel[1][y], Vel[5][y], Vel[4][y] ) 
				- SUM4( Vel[3][y], Vel[2][y], Vel[6][y], Vel[7][y] )) ;
	dzv = Real_t(-0.25)*
				( SUM4( Vel[0][z], Vel[1][z], Vel[5][z], Vel[4][z] ) 
				- SUM4( Vel[3][z], Vel[2][z], Vel[6][z], Vel[7][z] )) ;
		
	domain.delv_eta(ElemId) = ax*dxv + ay*dyv + az*dzv ;
	
#undef SUM4
}


static inline
void CalcMonotonicQRegionForElems(const Index_t ElemId,
								  const Real_t  qlc_monoq,
								  const Real_t  qqc_monoq,
								  const Real_t  monoq_limiter_mult,
								  const Real_t  monoq_max_slope,
								  const Real_t  ptiny,
								  const Real_t  qstop)
{
	Real_t qlin, qquad ;
	Real_t phixi, phieta, phizeta ;
	Real_t delvm, delvp ;

	Int_t bcMask = domain.elemBC(ElemId) ;
		
		
		/*  phixi     */
		Real_t norm = Real_t(1.) / ( domain.delv_xi(ElemId) + ptiny ) ;
		
		switch (bcMask & XI_M) {
			case 0:         delvm = domain.delv_xi(domain.lxim(ElemId)) ; break ;
			case XI_M_SYMM: delvm = domain.delv_xi(ElemId) ;              break ;
			case XI_M_FREE: delvm = Real_t(0.0) ;                         break ;
			default:        /* ERROR */ ;                                 break ;
		}
		switch (bcMask & XI_P) {
			case 0:         delvp = domain.delv_xi(domain.lxip(ElemId)) ; break ;
			case XI_P_SYMM: delvp = domain.delv_xi(ElemId) ;              break ;
			case XI_P_FREE: delvp = Real_t(0.0) ;                         break ;
			default:        /* ERROR */ ;                                 break ;
		}
		
		delvm = delvm * norm ;
		delvp = delvp * norm ;
		
		phixi = Real_t(.5) * ( delvm + delvp ) ;
		
		delvm *= monoq_limiter_mult ;
		delvp *= monoq_limiter_mult ;
		
		if ( delvm < phixi ) phixi = delvm ;
		if ( delvp < phixi ) phixi = delvp ;
		if ( phixi < Real_t(0.)) phixi = Real_t(0.) ;
		if ( phixi > monoq_max_slope) phixi = monoq_max_slope;
		
		
		/*  phieta     */
		norm = Real_t(1.) / ( domain.delv_eta(ElemId) + ptiny ) ;
		
		switch (bcMask & ETA_M) {
			case 0:          delvm = domain.delv_eta(domain.letam(ElemId)) ; break ;
			case ETA_M_SYMM: delvm = domain.delv_eta(ElemId) ;               break ;
			case ETA_M_FREE: delvm = Real_t(0.0) ;                           break ;
			default:         /* ERROR */ ;                                   break ;
		}
		switch (bcMask & ETA_P) {
			case 0:          delvp = domain.delv_eta(domain.letap(ElemId)) ; break ;
			case ETA_P_SYMM: delvp = domain.delv_eta(ElemId) ;               break ;
			case ETA_P_FREE: delvp = Real_t(0.0) ;                           break ;
			default:         /* ERROR */ ;                                   break ;
		}
		
		delvm = delvm * norm ;
		delvp = delvp * norm ;
		
		phieta = Real_t(.5) * ( delvm + delvp ) ;
		
		delvm *= monoq_limiter_mult ;
		delvp *= monoq_limiter_mult ;
		
		if ( delvm  < phieta ) phieta = delvm ;
		if ( delvp  < phieta ) phieta = delvp ;
		if ( phieta < Real_t(0.)) phieta = Real_t(0.) ;
		if ( phieta > monoq_max_slope)  phieta = monoq_max_slope;
		
		/*  phizeta     */
		norm = Real_t(1.) / ( domain.delv_zeta(ElemId) + ptiny ) ;
		
		switch (bcMask & ZETA_M) {
			case 0:           delvm = domain.delv_zeta(domain.lzetam(ElemId)) ; break ;
			case ZETA_M_SYMM: delvm = domain.delv_zeta(ElemId) ;                break ;
			case ZETA_M_FREE: delvm = Real_t(0.0) ;                             break ;
			default:          /* ERROR */ ;                                     break ;
		}
		switch (bcMask & ZETA_P) {
			case 0:           delvp = domain.delv_zeta(domain.lzetap(ElemId)) ; break ;
			case ZETA_P_SYMM: delvp = domain.delv_zeta(ElemId) ;                break ;
			case ZETA_P_FREE: delvp = Real_t(0.0) ;                             break ;
			default:          /* ERROR */ ;                                     break ;
		}
		
		delvm = delvm * norm ;
		delvp = delvp * norm ;
		
		phizeta = Real_t(.5) * ( delvm + delvp ) ;
		
		delvm *= monoq_limiter_mult ;
		delvp *= monoq_limiter_mult ;
		
		if ( delvm   < phizeta ) phizeta = delvm ;
		if ( delvp   < phizeta ) phizeta = delvp ;
		if ( phizeta < Real_t(0.)) phizeta = Real_t(0.);
		if ( phizeta > monoq_max_slope  ) phizeta = monoq_max_slope;
		
		/* Remove length scale */
		
		if ( domain.vdov(ElemId) > Real_t(0.) )  {
			qlin  = Real_t(0.) ;
			qquad = Real_t(0.) ;
		}
		else {
			Real_t delvxxi   = domain.delv_xi(ElemId)   * domain.delx_xi(ElemId)   ;
			Real_t delvxeta  = domain.delv_eta(ElemId)  * domain.delx_eta(ElemId)  ;
			Real_t delvxzeta = domain.delv_zeta(ElemId) * domain.delx_zeta(ElemId) ;
			
			if ( delvxxi   > Real_t(0.) ) delvxxi   = Real_t(0.) ;
			if ( delvxeta  > Real_t(0.) ) delvxeta  = Real_t(0.) ;
			if ( delvxzeta > Real_t(0.) ) delvxzeta = Real_t(0.) ;
			
			Real_t rho = domain.elemMass(ElemId) / (domain.volo(ElemId) * domain.vnew(ElemId)) ;
			
			qlin = -qlc_monoq * rho *
            (  delvxxi   * (Real_t(1.) - phixi) +
			 delvxeta  * (Real_t(1.) - phieta) +
			 delvxzeta * (Real_t(1.) - phizeta)  ) ;
			
			qquad = qqc_monoq * rho *
            (  delvxxi*delvxxi     * (Real_t(1.) - phixi*phixi) +
			 delvxeta*delvxeta   * (Real_t(1.) - phieta*phieta) +
			 delvxzeta*delvxzeta * (Real_t(1.) - phizeta*phizeta)  ) ;
		}
		
		domain.qq(ElemId) = qquad ;
		domain.ql(ElemId) = qlin  ;
		
		/* Don't allow excessive artificial viscosity */
		if ( qlin > qstop ) exit(QStopError);

}

static inline
void CalcPressureForElems(const Real_t e_old,
						  const Real_t compression, 
						  const Real_t vnewc, 
						  const Real_t pmin,
						  const Real_t p_cut, 
						  const Real_t eosvmax, 
								Real_t *p_new, 
								Real_t *bvc,
								Real_t *pbvc       ) 
{
		Real_t c1s = Real_t(2.0)/Real_t(3.0) ;
			  *bvc = c1s * (compression + Real_t(1.));
			 *pbvc = c1s;
			*p_new = *bvc * e_old ;
		
		if (FABS(*p_new) <  p_cut)  *p_new = Real_t(0.0) ;
		if ( vnewc    >= eosvmax )  *p_new = Real_t(0.0) ;
		if (*p_new       <  pmin )  *p_new = pmin ;
}

	
static inline
Real_t CalcSoundSpeedForElem( const Real_t  new_vol,     
							  const Real_t  enew,          
							  const Real_t  pnew,        
							  const Real_t  pbvc,
							  const Real_t  bvc,
							  const Real_t  rho0   )
	{
		Real_t  ss;
		ss = (   pbvc * enew + new_vol * new_vol * bvc * pnew) / rho0 ;
		ss = ( ss <= Real_t(.111111e-36) ) ? Real_t(.333333e-18) :  sqrt(ss)  ;
		return ss; 
	}

		
static inline
	void CalcEnergyForElems(const Real_t p_old, 
							const Real_t e_old, 
							const Real_t q_old,
							const Real_t compression, 
							const Real_t compHalfStep,
							const Real_t vnewc, 
							const Real_t work, 
							const Real_t delvc, 
							const Real_t pmin,
							const Real_t p_cut, 
							const Real_t  e_cut, 
							const Real_t q_cut, 
							const Real_t emin,
							const Real_t qq, 
							const Real_t ql,
							const Real_t rho0,
							const Real_t eosvmax,
								  Real_t *p_new, 
								  Real_t *e_new, 
								  Real_t *q_new,
								  Real_t *bvc, 
								  Real_t *pbvc   )						
{
	Real_t sixth = Real_t(1.0) / Real_t(6.0) ;
	Real_t pHalfStep ;
	Real_t vhalf;
	Real_t ssc ;
	Real_t q_tilde ;

	*e_new = e_old - Real_t(0.5) * delvc * (p_old + q_old) + Real_t(0.5) * work;

	if (*e_new  < emin )  *e_new = emin ;
	


	CalcPressureForElems(*e_new, compHalfStep, vnewc, pmin, p_cut, eosvmax, 
						 &pHalfStep, bvc, pbvc);
	
	vhalf = Real_t(1.) / (Real_t(1.) + compHalfStep) ;

	ssc = CalcSoundSpeedForElem(vhalf, *e_new, pHalfStep, *pbvc, *bvc, rho0);

	*q_new = ( delvc > Real_t(0.0)) ? Real_t(0.0) : ssc * ql + qq ;

	*e_new = *e_new + Real_t(0.5) * delvc * (  Real_t(3.0) * (p_old + q_old)
									         - Real_t(4.0) * (pHalfStep  + *q_new))
				    + Real_t(0.5) * work;

	if (FABS(*e_new) < e_cut)  *e_new = Real_t(0.)  ;
	if (     *e_new  < emin )  *e_new = emin ;
	

	
	CalcPressureForElems(*e_new, compression, vnewc, pmin, p_cut, eosvmax, 
						 p_new, bvc, pbvc );
	
	ssc = CalcSoundSpeedForElem(vnewc, *e_new, *p_new, *pbvc, *bvc, rho0);
	
	q_tilde = ( delvc > Real_t(0.0)) ? Real_t(0.0) : ssc * ql + qq ;
	
	*e_new = *e_new - (  Real_t(7.0) * (p_old     +  q_old)
                       - Real_t(8.0) * (pHalfStep + *q_new)
                       + (*p_new + q_tilde)) * delvc * sixth ;
		
	if (FABS(*e_new) < e_cut)   *e_new = Real_t(0.)  ;
	if (     *e_new  < emin )   *e_new = emin ;
	

		
	CalcPressureForElems(*e_new, compression, vnewc, pmin, p_cut, eosvmax,
						 p_new, bvc, pbvc );

	if ( delvc <= Real_t(0.) ) {
		ssc = CalcSoundSpeedForElem(vnewc, *e_new, *p_new, *pbvc, *bvc, rho0);
		*q_new = (ssc * ql + qq) ;
		if (FABS(*q_new) < q_cut) *q_new = Real_t(0.) ;
	}
	
	return ;
}

		
static inline
void EvalEOSForElems(const Index_t ElemId,
					 const Real_t  e_cut,
					 const Real_t  p_cut,
					 const Real_t  q_cut,
					 const Real_t  eosvmin,
					 const Real_t  eosvmax,
					 const Real_t  pmin,
					 const Real_t  emin,
					 const Real_t  rho0   )
{
	
	Real_t vnewc   = domain.vnew(ElemId);
	Real_t e_old   = domain.e   (ElemId);
	Real_t delvc   = domain.delv(ElemId);
	Real_t p_old   = domain.p   (ElemId);
	Real_t q_old   = domain.q   (ElemId);
	Real_t qq      = domain.qq  (ElemId);
	Real_t ql      = domain.ql  (ElemId);
	Real_t work    = Real_t(0.) ;
	
	Real_t compression  = Real_t(1.) / vnewc - Real_t(1.);
	Real_t vchalf       = vnewc - delvc * Real_t(.5);
	Real_t compHalfStep = Real_t(1.) / vchalf - Real_t(1.);
	
    if (   (eosvmin != Real_t(0.)) 
		&& (vnewc   <  eosvmin   ) ) compHalfStep = compression ;
	
    if (   (eosvmax != Real_t(0.)) 
		&& (vnewc   >  eosvmax   ) ) 
									{ /* impossible due to calling func? */
										p_old        = Real_t(0.) ;
										compression  = Real_t(0.) ;
										compHalfStep = Real_t(0.) ;
									}	
	Real_t p_new ;
	Real_t e_new ;
	Real_t q_new ;
	Real_t bvc   ;
	Real_t pbvc  ;
	Real_t ss    ;
	
	CalcEnergyForElems(p_old, e_old,  q_old, compression, compHalfStep,
					   vnewc, work,  delvc, pmin, p_cut, e_cut, q_cut, emin,
					   qq, ql, rho0, eosvmax, 
					   &p_new, &e_new, &q_new, &bvc, &pbvc);
	
	ss = CalcSoundSpeedForElem(vnewc, e_new, p_new, pbvc, bvc, rho0) ;
	
	domain.p (ElemId) = p_new ;
	domain.e (ElemId) = e_new ;
	domain.q (ElemId) = q_new ;
	domain.ss(ElemId) = ss    ;
}

		

//  ApplyMaterialPropertiesForElems removed from this version of LULESH
//       Extraction  of  vnew values moved to EvalEOSForElems
//       Range tests for vnew values moved to EvalEOSForElems		
//       Range tests for v    values removed as redundant


		
static inline
void UpdateVolumesForElems(const Index_t ElemId)
{
	Real_t v_cut = domain.v_cut();
	Real_t  tmpV = domain.vnew(ElemId) ;
	if ( FABS(tmpV - Real_t(1.0)) < v_cut )  tmpV = Real_t(1.0) ;

	domain.v(ElemId) = tmpV ;
	
	return ;
}

static inline
void LagrangeElements()
{
	const Real_t deltatime  = domain.deltatime() ;

	Index_t numElem = domain.numElem() ;

	// Compute for all elements:
	//	    in  CalcKinematicsForElems:  vnew, delv, dxx, dyy, dzz  
	//		in 	LagrangeElements:		 vdov, dxx, dyy, dzz 
	//      in  MonoQGradElements:       delv, delx          
	
#ifdef GATHER_MICRO_TIMING
	ticks t1, t2;
	t1=getticks();
	//timeval start, end;
	//gettimeofday(&start, NULL);
#endif
#pragma omp parallel for firstprivate(numElem)
	for (Index_t ElemId = 0 ; ElemId < numElem ; ElemId=ElemId+VEC_LEN) {

		Real_t Pos[8][3][VEC_LEN] ;
		Real_t Vel[8][3][VEC_LEN] ;
	for(int i = 0; i < VEC_LEN; i++) {	
		const Index_t* const elemToNode = domain.nodelist(ElemId+i) ;
		
		// get nodal coordinates and velocities from global arrays 
		// and copy into local arrays.
		//CollectElemPositions (elemToNode, Pos);
		for( Index_t lnode=0 ; lnode<8 ; ++lnode )
    		{
                   Index_t  gnode    = elemToNode[lnode];
                   Pos[lnode][0][i] = domain.x(gnode);
                   Pos[lnode][1][i] = domain.y(gnode);
                   Pos[lnode][2][i] = domain.z(gnode);
                }

		
		//CollectElemVelocities(elemToNode, Vel);		
		for( Index_t lnode=0 ; lnode<8 ; ++lnode )
    		{
                	Index_t  gnode    = elemToNode[lnode];
                	Vel[lnode][0][i] = domain.xd(gnode);
                	Vel[lnode][1][i] = domain.yd(gnode);
                	Vel[lnode][2][i] = domain.zd(gnode);
        	}
         }
	Real_t fjxxi[VEC_LEN], fjxet[VEC_LEN], fjxze[VEC_LEN];
	Real_t fjyxi[VEC_LEN], fjyet[VEC_LEN], fjyze[VEC_LEN];
	Real_t fjzxi[VEC_LEN], fjzet[VEC_LEN], fjzze[VEC_LEN];
	Real_t cjxxi[VEC_LEN], cjxet[VEC_LEN], cjxze[VEC_LEN];
	Real_t cjyxi[VEC_LEN], cjyet[VEC_LEN], cjyze[VEC_LEN];
	Real_t cjzxi[VEC_LEN], cjzet[VEC_LEN], cjzze[VEC_LEN];
	
	   Real_t vdov[VEC_LEN];
	   Real_t vdovthird[VEC_LEN];
	   Real_t vol[VEC_LEN];
	   Real_t norm[VEC_LEN];
	   Real_t ax[VEC_LEN],ay[VEC_LEN],az[VEC_LEN] ;
	   Real_t dxv[VEC_LEN],dyv[VEC_LEN],dzv[VEC_LEN] ;
	   Real_t dxj[VEC_LEN],dyj[VEC_LEN],dzj[VEC_LEN] ;
	   Real_t dxi[VEC_LEN],dyi[VEC_LEN],dzi[VEC_LEN] ;
	   Real_t dxk[VEC_LEN],dyk[VEC_LEN],dzk[VEC_LEN] ;
		Real_t B[3][8][VEC_LEN] ; /** shape function derivatives */
		Real_t D[6][VEC_LEN] ;
		Real_t Pos_local[8][3][VEC_LEN] ;
		Real_t detJ[VEC_LEN]; 
		
		Real_t volume[VEC_LEN] ;
		Real_t relativeVolume[VEC_LEN] ;
		Real_t dt2[VEC_LEN] ;
	Real_t twelveth = Real_t(1.0)/Real_t(12.0);

                Real_t dx61[VEC_LEN], dy61[VEC_LEN], dz61[VEC_LEN];
                Real_t dx70[VEC_LEN], dy70[VEC_LEN], dz70[VEC_LEN];
                Real_t dx63[VEC_LEN], dy63[VEC_LEN], dz63[VEC_LEN];
                Real_t dx20[VEC_LEN], dy20[VEC_LEN], dz20[VEC_LEN];
                Real_t dx50[VEC_LEN], dy50[VEC_LEN], dz50[VEC_LEN];
                Real_t dx64[VEC_LEN], dy64[VEC_LEN], dz64[VEC_LEN];
                Real_t dx31[VEC_LEN], dy31[VEC_LEN], dz31[VEC_LEN];
                Real_t dx72[VEC_LEN], dy72[VEC_LEN], dz72[VEC_LEN];
                Real_t dx43[VEC_LEN], dy43[VEC_LEN], dz43[VEC_LEN];
                Real_t dx57[VEC_LEN], dy57[VEC_LEN], dz57[VEC_LEN];
                Real_t dx14[VEC_LEN], dy14[VEC_LEN], dz14[VEC_LEN];
                Real_t dx25[VEC_LEN], dy25[VEC_LEN], dz25[VEC_LEN];
	Real_t a[VEC_LEN], charLength[VEC_LEN];
		Real_t fx[VEC_LEN], fy[VEC_LEN], fz[VEC_LEN];
		Real_t gx[VEC_LEN], gy[VEC_LEN], gz[VEC_LEN];
	Real_t dyddx[VEC_LEN], dxddy[VEC_LEN], dzddx[VEC_LEN], dxddz[VEC_LEN], dzddy[VEC_LEN], dyddz[VEC_LEN];
	Real_t inv_detJ[VEC_LEN];
	   const Real_t ptiny = Real_t(1.e-36) ;
		
		//CalcLagrangeElements(ElemId, Pos, Vel, deltatime) ;
/*void CalcLagrangeElements(const Index_t ElemId,
						  const Real_t  Pos[8][3],
						  const Real_t  Vel[8][3],
	}				  const Real_t  deltatime  )*/

	for(int i = 0; i < VEC_LEN; i++) {	
	   //CalcKinematicsForElems(ElemId, Pos, Vel, deltatime) ;
/*void CalcKinematicsForElems( const Index_t ElemId,
							 const Real_t  Pos[8][3],
							 const Real_t  Vel[8][3],
							 const Real_t  dt          )*/

		detJ[i] = Real_t(0.0) ;
		charLength[i] = Real_t(0.0);
		// volume calculations

	
	dx61[i] = Pos[6][0][i] - Pos[1][0][i];
	dy61[i] = Pos[6][1][i] - Pos[1][1][i];
	dz61[i] = Pos[6][2][i] - Pos[1][2][i];
	
	dx70[i] = Pos[7][0][i] - Pos[0][0][i];
	dy70[i] = Pos[7][1][i] - Pos[0][1][i];
	dz70[i] = Pos[7][2][i] - Pos[0][2][i];
	
	dx63[i] = Pos[6][0][i] - Pos[3][0][i];
	dy63[i] = Pos[6][1][i] - Pos[3][1][i];
	dz63[i] = Pos[6][2][i] - Pos[3][2][i];
	
	dx20[i] = Pos[2][0][i] - Pos[0][0][i];
	dy20[i] = Pos[2][1][i] - Pos[0][1][i];
	dz20[i] = Pos[2][2][i] - Pos[0][2][i];
	
	dx50[i] = Pos[5][0][i] - Pos[0][0][i];
	dy50[i] = Pos[5][1][i] - Pos[0][1][i];
	dz50[i] = Pos[5][2][i] - Pos[0][2][i];
	
	dx64[i] = Pos[6][0][i] - Pos[4][0][i];
	dy64[i] = Pos[6][1][i] - Pos[4][1][i];
	dz64[i] = Pos[6][2][i] - Pos[4][2][i];
	
	dx31[i] = Pos[3][0][i] - Pos[1][0][i];
	dy31[i] = Pos[3][1][i] - Pos[1][1][i];
	dz31[i] = Pos[3][2][i] - Pos[1][2][i];
	
	dx72[i] = Pos[7][0][i] - Pos[2][0][i];
	dy72[i] = Pos[7][1][i] - Pos[2][1][i];
	dz72[i] = Pos[7][2][i] - Pos[2][2][i];
	
	dx43[i] = Pos[4][0][i] - Pos[3][0][i];
	dy43[i] = Pos[4][1][i] - Pos[3][1][i];
 	dz43[i] = Pos[4][2][i] - Pos[3][2][i];
	
	dx57[i] = Pos[5][0][i] - Pos[7][0][i];
	dy57[i] = Pos[5][1][i] - Pos[7][1][i];
	dz57[i] = Pos[5][2][i] - Pos[7][2][i];
	
	dx14[i] = Pos[1][0][i] - Pos[4][0][i];
	dy14[i] = Pos[1][1][i] - Pos[4][1][i];
	dz14[i] = Pos[1][2][i] - Pos[4][2][i];
		
	dx25[i] = Pos[2][0][i] - Pos[5][0][i];
	dy25[i] = Pos[2][1][i] - Pos[5][1][i];
	dz25[i] = Pos[2][2][i] - Pos[5][2][i];
	
#define TRIPLE_PRODUCT(x1, y1, z1, x2, y2, z2, x3, y3, z3) \
((x1)*((y2)*(z3) - (z2)*(y3)) + (x2)*((z1)*(y3) - (y1)*(z3)) + (x3)*((y1)*(z2) - (z1)*(y2)))
	
	volume[i] =
    TRIPLE_PRODUCT(dx31[i] + dx72[i], dx63[i], dx20[i],
				   dy31[i] + dy72[i], dy63[i], dy20[i],
				   dz31[i] + dz72[i], dz63[i], dz20[i]) +
    TRIPLE_PRODUCT(dx43[i] + dx57[i], dx64[i], dx70[i],
				   dy43[i] + dy57[i], dy64[i], dy70[i],
				   dz43[i] + dz57[i], dz64[i], dz70[i]) +
    TRIPLE_PRODUCT(dx14[i] + dx25[i], dx61[i], dx50[i],
				   dy14[i] + dy25[i], dy61[i], dy50[i],
				   dz14[i] + dz25[i], dz61[i], dz50[i]);
	
#undef TRIPLE_PRODUCT
	
	volume[i] *= twelveth;
	
		relativeVolume[i] = volume[i] / domain.volo(ElemId+i) ;
}
	for(int i = 0; i < VEC_LEN; i++) {	
		domain.vnew(ElemId+i) = relativeVolume[i] ;

		//  volume error check moved from Force Calculation to here.
	
		if (relativeVolume[i] <= Real_t(0.0)) { exit(VolumeError) ; }
		
		domain.delv(ElemId+i) = relativeVolume[i] - domain.v(ElemId+i) ;
}
		
	for(int i = 0; i < VEC_LEN; i++) {	
		// set characteristic length
		//domain.arealg(ElemId+i) = CalcElemCharacteristicLength(Pos, volume);
	fx[i] = (Pos[2][0][i] - Pos[0][0][i]) - (Pos[3][0][i] - Pos[1][0][i]);
        fy[i] = (Pos[2][1][i] - Pos[0][1][i]) - (Pos[3][1][i] - Pos[1][1][i]);
        fz[i] = (Pos[2][2][i] - Pos[0][2][i]) - (Pos[3][2][i] - Pos[1][2][i]);

        gx[i] = (Pos[2][0][i] - Pos[0][0][i]) + (Pos[3][0][i] - Pos[1][0][i]);
        gy[i] = (Pos[2][1][i] - Pos[0][1][i]) + (Pos[3][1][i] - Pos[1][1][i]);
        gz[i] = (Pos[2][2][i] - Pos[0][2][i]) + (Pos[3][2][i] - Pos[1][2][i]);

        a[i] =   (fx[i] * fx[i] + fy[i] * fy[i] + fz[i] * fz[i]) *
                                        (gx[i] * gx[i] + gy[i] * gy[i] + gz[i] * gz[i]) -
                                        (fx[i] * gx[i] + fy[i] * gy[i] + fz[i] * gz[i]) *
                                        (fx[i] * gx[i] + fy[i] * gy[i] + fz[i] * gz[i]);

	charLength[i] = std::max(a[i],charLength[i]) ;

	
	fx[i] = (Pos[6][0][i] - Pos[4][0][i]) - (Pos[7][0][i] - Pos[5][0][i]);
        fy[i] = (Pos[6][1][i] - Pos[4][1][i]) - (Pos[7][1][i] - Pos[5][1][i]);
        fz[i] = (Pos[6][2][i] - Pos[4][2][i]) - (Pos[7][2][i] - Pos[5][2][i]);

        gx[i] = (Pos[6][0][i] - Pos[4][0][i]) + (Pos[7][0][i] - Pos[5][0][i]);
        gy[i] = (Pos[6][1][i] - Pos[4][1][i]) + (Pos[7][1][i] - Pos[5][1][i]);
        gz[i] = (Pos[6][2][i] - Pos[4][2][i]) + (Pos[7][2][i] - Pos[5][2][i]);

        a[i] =   (fx[i] * fx[i] + fy[i] * fy[i] + fz[i] * fz[i]) *
                                        (gx[i] * gx[i] + gy[i] * gy[i] + gz[i] * gz[i]) -
                                        (fx[i] * gx[i] + fy[i] * gy[i] + fz[i] * gz[i]) *
                                        (fx[i] * gx[i] + fy[i] * gy[i] + fz[i] * gz[i]);
	
//	a = AreaFace(Pos, 0, 1, 5, 4); 
	charLength[i] = std::max(a[i],charLength[i]) ;
	fx[i] = (Pos[5][0][i] - Pos[0][0][i]) - (Pos[4][0][i] - Pos[1][0][i]);
        fy[i] = (Pos[5][1][i] - Pos[0][1][i]) - (Pos[4][1][i] - Pos[1][1][i]);
        fz[i] = (Pos[5][2][i] - Pos[0][2][i]) - (Pos[4][2][i] - Pos[1][2][i]);

        gx[i] = (Pos[5][0][i] - Pos[0][0][i]) + (Pos[4][0][i] - Pos[1][0][i]);
        gy[i] = (Pos[5][1][i] - Pos[0][1][i]) + (Pos[4][1][i] - Pos[1][1][i]);
        gz[i] = (Pos[5][2][i] - Pos[0][2][i]) + (Pos[4][2][i] - Pos[1][2][i]);

        a[i] =   (fx[i] * fx[i] + fy[i] * fy[i] + fz[i] * fz[i]) *
                                        (gx[i] * gx[i] + gy[i] * gy[i] + gz[i] * gz[i]) -
                                        (fx[i] * gx[i] + fy[i] * gy[i] + fz[i] * gz[i]) *
                                        (fx[i] * gx[i] + fy[i] * gy[i] + fz[i] * gz[i]);
	
//	a = AreaFace(Pos, 1, 2, 6, 5); 
	charLength[i] = std::max(a[i],charLength[i]) ;
	fx[i] = (Pos[6][0][i] - Pos[1][0][i]) - (Pos[5][0][i] - Pos[2][0][i]);
        fy[i] = (Pos[6][1][i] - Pos[1][1][i]) - (Pos[5][1][i] - Pos[2][1][i]);
        fz[i] = (Pos[6][2][i] - Pos[1][2][i]) - (Pos[5][2][i] - Pos[2][2][i]);

        gx[i] = (Pos[6][0][i] - Pos[1][0][i]) + (Pos[5][0][i] - Pos[2][0][i]);
        gy[i] = (Pos[6][1][i] - Pos[1][1][i]) + (Pos[5][1][i] - Pos[2][1][i]);
        gz[i] = (Pos[6][2][i] - Pos[1][2][i]) + (Pos[5][2][i] - Pos[2][2][i]);

        a[i] =   (fx[i] * fx[i] + fy[i] * fy[i] + fz[i] * fz[i]) *
                                        (gx[i] * gx[i] + gy[i] * gy[i] + gz[i] * gz[i]) -
                                        (fx[i] * gx[i] + fy[i] * gy[i] + fz[i] * gz[i]) *
                                        (fx[i] * gx[i] + fy[i] * gy[i] + fz[i] * gz[i]);
	
//	a = AreaFace(Pos, 2, 3, 7, 6); 
	charLength[i] = std::max(a[i],charLength[i]) ;
	fx[i] = (Pos[7][0][i] - Pos[2][0][i]) - (Pos[6][0][i] - Pos[3][0][i]);
        fy[i] = (Pos[7][1][i] - Pos[2][1][i]) - (Pos[6][1][i] - Pos[3][1][i]);
        fz[i] = (Pos[7][2][i] - Pos[2][2][i]) - (Pos[6][2][i] - Pos[3][2][i]);

        gx[i] = (Pos[7][0][i] - Pos[2][0][i]) + (Pos[6][0][i] - Pos[3][0][i]);
        gy[i] = (Pos[7][1][i] - Pos[2][1][i]) + (Pos[6][1][i] - Pos[3][1][i]);
        gz[i] = (Pos[7][2][i] - Pos[2][2][i]) + (Pos[6][2][i] - Pos[3][2][i]);

        a[i] =   (fx[i] * fx[i] + fy[i] * fy[i] + fz[i] * fz[i]) *
                                        (gx[i] * gx[i] + gy[i] * gy[i] + gz[i] * gz[i]) -
                                        (fx[i] * gx[i] + fy[i] * gy[i] + fz[i] * gz[i]) *
                                        (fx[i] * gx[i] + fy[i] * gy[i] + fz[i] * gz[i]);
	
//	a = AreaFace(Pos, 3, 0, 4, 7); 
	charLength[i] = std::max(a[i],charLength[i]) ;
	fx[i] = (Pos[4][0][i] - Pos[3][0][i]) - (Pos[7][0][i] - Pos[0][0][i]);
        fy[i] = (Pos[4][1][i] - Pos[3][1][i]) - (Pos[7][1][i] - Pos[0][1][i]);
        fz[i] = (Pos[4][2][i] - Pos[3][2][i]) - (Pos[7][2][i] - Pos[0][2][i]);

        gx[i] = (Pos[4][0][i] - Pos[3][0][i]) + (Pos[7][0][i] - Pos[0][0][i]);
        gy[i] = (Pos[4][1][i] - Pos[3][1][i]) + (Pos[7][1][i] - Pos[0][1][i]);
        gz[i] = (Pos[4][2][i] - Pos[3][2][i]) + (Pos[7][2][i] - Pos[0][2][i]);

        a[i] =   (fx[i] * fx[i] + fy[i] * fy[i] + fz[i] * fz[i]) *
                                        (gx[i] * gx[i] + gy[i] * gy[i] + gz[i] * gz[i]) -
                                        (fx[i] * gx[i] + fy[i] * gy[i] + fz[i] * gz[i]) *
                                        (fx[i] * gx[i] + fy[i] * gy[i] + fz[i] * gz[i]);
	charLength[i] = std::max(a[i],charLength[i]) ;
	}
	for(int i = 0; i < VEC_LEN; i++) {	
	
	domain.arealg(ElemId + i) = Real_t(4.0) * volume[i] / SQRT(charLength[i]);
	}
	for(int i = 0; i < VEC_LEN; i++) {	
		
		        dt2[i] = Real_t(0.5) * deltatime;
			Pos_local[0][0][i] = Pos[0][0][i] - dt2[i] * Vel[0][0][i];
			Pos_local[0][1][i] = Pos[0][1][i] - dt2[i] * Vel[0][1][i];
			Pos_local[0][2][i] = Pos[0][2][i] - dt2[i] * Vel[0][2][i];
			Pos_local[1][0][i] = Pos[1][0][i] - dt2[i] * Vel[1][0][i];
			Pos_local[1][1][i] = Pos[1][1][i] - dt2[i] * Vel[1][1][i];
			Pos_local[1][2][i] = Pos[1][2][i] - dt2[i] * Vel[1][2][i];
			Pos_local[2][0][i] = Pos[2][0][i] - dt2[i] * Vel[2][0][i];
			Pos_local[2][1][i] = Pos[2][1][i] - dt2[i] * Vel[2][1][i];
			Pos_local[2][2][i] = Pos[2][2][i] - dt2[i] * Vel[2][2][i];
			Pos_local[3][0][i] = Pos[3][0][i] - dt2[i] * Vel[3][0][i];
			Pos_local[3][1][i] = Pos[3][1][i] - dt2[i] * Vel[3][1][i];
			Pos_local[3][2][i] = Pos[3][2][i] - dt2[i] * Vel[3][2][i];
			Pos_local[4][0][i] = Pos[4][0][i] - dt2[i] * Vel[4][0][i];
			Pos_local[4][1][i] = Pos[4][1][i] - dt2[i] * Vel[4][1][i];
			Pos_local[4][2][i] = Pos[4][2][i] - dt2[i] * Vel[4][2][i];
			Pos_local[5][0][i] = Pos[5][0][i] - dt2[i] * Vel[5][0][i];
			Pos_local[5][1][i] = Pos[5][1][i] - dt2[i] * Vel[5][1][i];
			Pos_local[5][2][i] = Pos[5][2][i] - dt2[i] * Vel[5][2][i];
			Pos_local[6][0][i] = Pos[6][0][i] - dt2[i] * Vel[6][0][i];
			Pos_local[6][1][i] = Pos[6][1][i] - dt2[i] * Vel[6][1][i];
			Pos_local[6][2][i] = Pos[6][2][i] - dt2[i] * Vel[6][2][i];
			Pos_local[7][0][i] = Pos[7][0][i] - dt2[i] * Vel[7][0][i];
			Pos_local[7][1][i] = Pos[7][1][i] - dt2[i] * Vel[7][1][i];
			Pos_local[7][2][i] = Pos[7][2][i] - dt2[i] * Vel[7][2][i];
		
//		CalcElemShapeFunctionDerivatives( Pos_local, B, &detJ );
	
	fjxxi[i] = .125 * ( (Pos_local[6][0][i]-Pos_local[0][0][i]) + (Pos_local[5][0][i]-Pos_local[3][0][i]) - (Pos_local[7][0][i]-Pos_local[1][0][i]) - (Pos_local[4][0][i]-Pos_local[2][0][i]) );
	fjxet[i] = .125 * ( (Pos_local[6][0][i]-Pos_local[0][0][i]) - (Pos_local[5][0][i]-Pos_local[3][0][i]) + (Pos_local[7][0][i]-Pos_local[1][0][i]) - (Pos_local[4][0][i]-Pos_local[2][0][i]) );
	fjxze[i] = .125 * ( (Pos_local[6][0][i]-Pos_local[0][0][i]) + (Pos_local[5][0][i]-Pos_local[3][0][i]) + (Pos_local[7][0][i]-Pos_local[1][0][i]) + (Pos_local[4][0][i]-Pos_local[2][0][i]) );
	
	fjyxi[i] = .125 * ( (Pos_local[6][1][i]-Pos_local[0][1][i]) + (Pos_local[5][1][i]-Pos_local[3][1][i]) - (Pos_local[7][1][i]-Pos_local[1][1][i]) - (Pos_local[4][1][i]-Pos_local[2][1][i]) );
	fjyet[i] = .125 * ( (Pos_local[6][1][i]-Pos_local[0][1][i]) - (Pos_local[5][1][i]-Pos_local[3][1][i]) + (Pos_local[7][1][i]-Pos_local[1][1][i]) - (Pos_local[4][1][i]-Pos_local[2][1][i]) );
	fjyze[i] = .125 * ( (Pos_local[6][1][i]-Pos_local[0][1][i]) + (Pos_local[5][1][i]-Pos_local[3][1][i]) + (Pos_local[7][1][i]-Pos_local[1][1][i]) + (Pos_local[4][1][i]-Pos_local[2][1][i]) );
	
	fjzxi[i] = .125 * ( (Pos_local[6][2][i]-Pos_local[0][2][i]) + (Pos_local[5][2][i]-Pos_local[3][2][i]) - (Pos_local[7][2][i]-Pos_local[1][2][i]) - (Pos_local[4][2][i]-Pos_local[2][2][i]) );
	fjzet[i] = .125 * ( (Pos_local[6][2][i]-Pos_local[0][2][i]) - (Pos_local[5][2][i]-Pos_local[3][2][i]) + (Pos_local[7][2][i]-Pos_local[1][2][i]) - (Pos_local[4][2][i]-Pos_local[2][2][i]) );
	fjzze[i] = .125 * ( (Pos_local[6][2][i]-Pos_local[0][2][i]) + (Pos_local[5][2][i]-Pos_local[3][2][i]) + (Pos_local[7][2][i]-Pos_local[1][2][i]) + (Pos_local[4][2][i]-Pos_local[2][2][i]) );
	
	/* compute cofactors */
	cjxxi[i] =    (fjyet[i] * fjzze[i]) - (fjzet[i] * fjyze[i]);
	cjxet[i] =  - (fjyxi[i] * fjzze[i]) + (fjzxi[i] * fjyze[i]);
	cjxze[i] =    (fjyxi[i] * fjzet[i]) - (fjzxi[i] * fjyet[i]);
	
	cjyxi[i] =  - (fjxet[i] * fjzze[i]) + (fjzet[i] * fjxze[i]);
	cjyet[i] =    (fjxxi[i] * fjzze[i]) - (fjzxi[i] * fjxze[i]);
	cjyze[i] =  - (fjxxi[i] * fjzet[i]) + (fjzxi[i] * fjxet[i]);
	
	cjzxi[i] =    (fjxet[i] * fjyze[i]) - (fjyet[i] * fjxze[i]);
	cjzet[i] =  - (fjxxi[i] * fjyze[i]) + (fjyxi[i] * fjxze[i]);
	cjzze[i] =    (fjxxi[i] * fjyet[i]) - (fjyxi[i] * fjxet[i]);
	
	/* calculate partials :
     this need only be done for l = 0,1,2,3   since , by symmetry ,
     (6,7,4,5) = - (0,1,2,3) .
	 */
	B[0][0][i] =   -  cjxxi[i]  -  cjxet[i]  -  cjxze[i];
	B[0][1][i] =      cjxxi[i]  -  cjxet[i]  -  cjxze[i];
	B[0][2][i] =      cjxxi[i]  +  cjxet[i]  -  cjxze[i];
	B[0][3][i] =   -  cjxxi[i]  +  cjxet[i]  -  cjxze[i];
	B[0][4][i] = -B[0][2][i];
	B[0][5][i] = -B[0][3][i];
	B[0][6][i] = -B[0][0][i];
	B[0][7][i] = -B[0][1][i];
	
	B[1][0][i] =   -  cjyxi[i]  -  cjyet[i]  -  cjyze[i];
	B[1][1][i] =      cjyxi[i]  -  cjyet[i]  -  cjyze[i];
	B[1][2][i] =      cjyxi[i]  +  cjyet[i]  -  cjyze[i];
	B[1][3][i] =   -  cjyxi[i]  +  cjyet[i]  -  cjyze[i];
	B[1][4][i] = -B[1][2][i];
	B[1][5][i] = -B[1][3][i];
	B[1][6][i] = -B[1][0][i];
	B[1][7][i] = -B[1][1][i];
	
	B[2][0][i] =   -  cjzxi[i]  -  cjzet[i]  -  cjzze[i];
	B[2][1][i] =      cjzxi[i]  -  cjzet[i]  -  cjzze[i];
	B[2][2][i] =      cjzxi[i]  +  cjzet[i]  -  cjzze[i];
	B[2][3][i] =   -  cjzxi[i]  +  cjzet[i]  -  cjzze[i];
	B[2][4][i] = -B[2][2][i];
	B[2][5][i] = -B[2][3][i];
	B[2][6][i] = -B[2][0][i];
	B[2][7][i] = -B[2][1][i];
	
	/* calculate jacobian determinant (volume) */
	detJ[i] = Real_t(8.) * ( fjxet[i] * cjxet[i] + fjyet[i] * cjyet[i] + fjzet[i] * cjzet[i]);
		
//		CalcElemVelocityGrandient( Vel, B, detJ, D );
	
	inv_detJ[i] = Real_t(1.0) / detJ[i] ;
	
	D[0][i] =   inv_detJ[i] * (            B[0][0][i] * (Vel[0][0][i]-Vel[6][0][i])
					     + B[0][1][i] * (Vel[1][0][i]-Vel[7][0][i])
					     + B[0][2][i] * (Vel[2][0][i]-Vel[4][0][i])
					     + B[0][3][i] * (Vel[3][0][i]-Vel[5][0][i]));

	
	D[1][i] =   inv_detJ[i] * (            B[1][0][i] * (Vel[0][1][i]-Vel[6][1][i])
					     + B[1][1][i] * (Vel[1][1][i]-Vel[7][1][i])
					     + B[1][2][i] * (Vel[2][1][i]-Vel[4][1][i])
					     + B[1][3][i] * (Vel[3][1][i]-Vel[5][1][i]) );
	
	D[2][i]   = inv_detJ[i] * (            B[2][0][i] * (Vel[0][2][i]-Vel[6][2][i])
					     + B[2][1][i] * (Vel[1][2][i]-Vel[7][2][i])
					     + B[2][2][i] * (Vel[2][2][i]-Vel[4][2][i])
					     + B[2][3][i] * (Vel[3][2][i]-Vel[5][2][i]) );
	
	dyddx[i]  = inv_detJ[i] * (                B[0][0][i] * (Vel[0][1][i]-Vel[6][1][i])
						 + B[0][1][i] * (Vel[1][1][i]-Vel[7][1][i])
						 + B[0][2][i] * (Vel[2][1][i]-Vel[4][1][i])
						 + B[0][3][i] * (Vel[3][1][i]-Vel[5][1][i]) );
	
	dxddy[i]  = inv_detJ[i] * (                B[1][0][i] * (Vel[0][0][i]-Vel[6][0][i])
						 + B[1][1][i] * (Vel[1][0][i]-Vel[7][0][i])
						 + B[1][2][i] * (Vel[2][0][i]-Vel[4][0][i])
						 + B[1][3][i] * (Vel[3][0][i]-Vel[5][0][i]) );
	
	dzddx[i]  = inv_detJ[i] * (                B[0][0][i] * (Vel[0][2][i]-Vel[6][2][i])
						 + B[0][1][i] * (Vel[1][2][i]-Vel[7][2][i])
						 + B[0][2][i] * (Vel[2][2][i]-Vel[4][2][i])
						 + B[0][3][i] * (Vel[3][2][i]-Vel[5][2][i]) );
	
	dxddz[i]  = inv_detJ[i] * (                B[2][0][i] * (Vel[0][0][i]-Vel[6][0][i])
						 + B[2][1][i] * (Vel[1][0][i]-Vel[7][0][i])
						 + B[2][2][i] * (Vel[2][0][i]-Vel[4][0][i])
						 + B[2][3][i] * (Vel[3][0][i]-Vel[5][0][i]) );
	
	dzddy[i]  = inv_detJ[i] * (                B[1][0][i] * (Vel[0][2][i]-Vel[6][2][i])
						 + B[1][1][i] * (Vel[1][2][i]-Vel[7][2][i])
						 + B[1][2][i] * (Vel[2][2][i]-Vel[4][2][i])
						 + B[1][3][i] * (Vel[3][2][i]-Vel[5][2][i]) );
	
	dyddz[i]  = inv_detJ[i] * (                B[2][0][i] * (Vel[0][1][i]-Vel[6][1][i])
						 + B[2][1][i] * (Vel[1][1][i]-Vel[7][1][i])
						 + B[2][2][i] * (Vel[2][1][i]-Vel[4][1][i])
						 + B[2][3][i] * (Vel[3][1][i]-Vel[5][1][i]) );
	
	D[5][i]  = Real_t( .5) * ( dxddy[i] + dyddx[i] );
	D[4][i]  = Real_t( .5) * ( dxddz[i] + dzddx[i] );
	D[3][i]  = Real_t( .5) * ( dzddy[i] + dyddz[i] );
}
	for(int i = 0; i < VEC_LEN; i++) {	
		
		// put velocity gradient quantities into their global arrays.
		domain.dxx(ElemId+i) = D[0][i];
		domain.dyy(ElemId+i) = D[1][i];
		domain.dzz(ElemId+i) = D[2][i];
		
	  // calc strain rate and apply as constraint (only done in FB element)
	
	vdov[i] = domain.dxx(ElemId+i) + domain.dyy(ElemId+i) + domain.dzz(ElemId+i) ;
	vdovthird[i] = vdov[i]/Real_t(3.0) ;
			
	// make the rate of deformation tensor deviatoric
	domain.vdov(ElemId+i) = vdov[i] ;
	domain.dxx(ElemId+i) -= vdovthird[i] ;
	domain.dyy(ElemId+i) -= vdovthird[i] ;
	domain.dzz(ElemId+i) -= vdovthird[i] ;
}
	for(int i = 0; i < VEC_LEN; i++) {	

	//	CalcMonotonicQGradientsForElems(ElemId, Pos_local, Vel_local) ;
#define SUM4(a,b,c,d) (a + b + c + d)
		
	   vol[i] = domain.volo(ElemId+i)*domain.vnew(ElemId+i) ;
	   norm[i] = Real_t(1.0) / ( vol[i] + ptiny ) ;
		
	   dxj[i] = Real_t(-0.25)*
					( SUM4( Pos[0][0][i], Pos[1][0][i], Pos[5][0][i], Pos[4][0][i] ) 
					- SUM4( Pos[3][0][i], Pos[2][0][i], Pos[6][0][i], Pos[7][0][i] )) ;
	   dyj[i] = Real_t(-0.25)*
					( SUM4( Pos[0][1][i], Pos[1][1][i], Pos[5][1][i], Pos[4][1][i] ) 
					- SUM4( Pos[3][1][i], Pos[2][1][i], Pos[6][1][i], Pos[7][1][i] )) ;
	   dzj[i] = Real_t(-0.25)*
					( SUM4( Pos[0][2][i], Pos[1][2][i], Pos[5][2][i], Pos[4][2][i] ) 
					- SUM4( Pos[3][2][i], Pos[2][2][i], Pos[6][2][i], Pos[7][2][i] )) ;
		
	   dxi[i] = Real_t(-0.25)*
					( SUM4( Pos[1][0][i], Pos[2][0][i], Pos[6][0][i], Pos[5][0][i] ) 
					- SUM4( Pos[0][0][i], Pos[3][0][i], Pos[7][0][i], Pos[4][0][i] )) ;
	   dyi[i] = Real_t(-0.25)*
					( SUM4( Pos[1][1][i], Pos[2][1][i], Pos[6][1][i], Pos[5][1][i] ) 
					- SUM4( Pos[0][1][i], Pos[3][1][i], Pos[7][1][i], Pos[4][1][i] )) ;
	   dzi[i] = Real_t(-0.25)*
					( SUM4( Pos[1][2][i], Pos[2][2][i], Pos[6][2][i], Pos[5][2][i] ) 
					- SUM4( Pos[0][2][i], Pos[3][2][i], Pos[7][2][i], Pos[4][2][i] )) ;
				
	   dxk[i] = Real_t(-0.25)*
					( SUM4( Pos[4][0][i], Pos[5][0][i], Pos[6][0][i], Pos[7][0][i] ) 
					- SUM4( Pos[0][0][i], Pos[1][0][i], Pos[2][0][i], Pos[3][0][i] )) ;
	   dyk[i] = Real_t(-0.25)*
					( SUM4( Pos[4][1][i], Pos[5][1][i], Pos[6][1][i], Pos[7][1][i] ) 
					- SUM4( Pos[0][1][i], Pos[1][1][i], Pos[2][1][i], Pos[3][1][i] )) ;
	   dzk[i] = Real_t(-0.25)*
					( SUM4( Pos[4][2][i], Pos[5][2][i], Pos[6][2][i], Pos[7][2][i] ) 
					- SUM4( Pos[0][2][i], Pos[1][2][i], Pos[2][2][i], Pos[3][2][i] )) ;
				
	/* find delvk and delxk ( i cross j ) */
		
	ax[i] = dyi[i]*dzj[i] - dzi[i]*dyj[i] ;
	ay[i] = dzi[i]*dxj[i] - dxi[i]*dzj[i] ;
	az[i] = dxi[i]*dyj[i] - dyi[i]*dxj[i] ;
}
	for(int i = 0; i < VEC_LEN; i++) {	
		
	domain.delx_zeta(ElemId+i) = vol[i] / SQRT(ax[i]*ax[i] + ay[i]*ay[i] + az[i]*az[i] + ptiny) ;
}
		
	for(int i = 0; i < VEC_LEN; i++) {	
	ax[i] *= norm[i] ;
	ay[i] *= norm[i] ;
	az[i] *= norm[i] ;
		
	dxv[i] = Real_t(-0.25)*
					( SUM4( Vel[4][0][i], Vel[5][0][i], Vel[6][0][i], Vel[7][0][i] ) 
					- SUM4( Vel[0][0][i], Vel[1][0][i], Vel[2][0][i], Vel[3][0][i] )) ;
	dyv[i] = Real_t(-0.25)*
					( SUM4( Vel[4][1][i], Vel[5][1][i], Vel[6][1][i], Vel[7][1][i] ) 
					- SUM4( Vel[0][1][i], Vel[1][1][i], Vel[2][1][i], Vel[3][1][i] )) ;
	dzv[i] = Real_t(-0.25)*
					( SUM4( Vel[4][2][i], Vel[5][2][i], Vel[6][2][i], Vel[7][2][i] ) 
					- SUM4( Vel[0][2][i], Vel[1][2][i], Vel[2][2][i], Vel[3][2][i] )) ;
		
	}			
	for(int i = 0; i < VEC_LEN; i++) {	
	domain.delv_zeta(ElemId+i) = ax[i]*dxv[i] + ay[i]*dyv[i] + az[i]*dzv[i] ;
	}	
	for(int i = 0; i < VEC_LEN; i++) {	
	/* find delxi and delvi ( j cross k ) */
		
	ax[i] = dyj[i]*dzk[i] - dzj[i]*dyk[i] ;
	ay[i] = dzj[i]*dxk[i] - dxj[i]*dzk[i] ;
	az[i] = dxj[i]*dyk[i] - dyj[i]*dxk[i] ;
	}
		
	for(int i = 0; i < VEC_LEN; i++) {	
	domain.delx_xi(ElemId+i) = vol[i] / SQRT(ax[i]*ax[i] + ay[i]*ay[i] + az[i]*az[i] + ptiny) ;
	}	
	for(int i = 0; i < VEC_LEN; i++) {	
	ax[i] *= norm[i] ;
	ay[i] *= norm[i] ;
	az[i] *= norm[i] ;
		
	dxv[i] = Real_t(-0.25)*
				( SUM4( Vel[1][0][i], Vel[2][0][i], Vel[6][0][i], Vel[5][0][i] ) 
				- SUM4( Vel[0][0][i], Vel[3][0][i], Vel[7][0][i], Vel[4][0][i] )) ;
	dyv[i] = Real_t(-0.25)*
				( SUM4( Vel[1][1][i], Vel[2][1][i], Vel[6][1][i], Vel[5][1][i] ) 
				- SUM4( Vel[0][1][i], Vel[3][1][i], Vel[7][1][i], Vel[4][1][i] )) ;
	dzv[i] = Real_t(-0.25)*
				( SUM4( Vel[1][2][i], Vel[2][2][i], Vel[6][2][i], Vel[5][2][i] ) 
				- SUM4( Vel[0][2][i], Vel[3][2][i], Vel[7][2][i], Vel[4][2][i] )) ;
	}	
	for(int i = 0; i < VEC_LEN; i++) {	
	domain.delv_xi(ElemId+i) = ax[i]*dxv[i] + ay[i]*dyv[i] + az[i]*dzv[i] ;
	}	
	/* find delxj and delvj ( k cross i ) */
	for(int i = 0; i < VEC_LEN; i++) {	
		
	ax[i] = dyk[i]*dzi[i] - dzk[i]*dyi[i] ;
	ay[i] = dzk[i]*dxi[i] - dxk[i]*dzi[i] ;
	az[i] = dxk[i]*dyi[i] - dyk[i]*dxi[i] ;
	}
	for(int i = 0; i < VEC_LEN; i++) {	
		
	domain.delx_eta(ElemId+i) = vol[i] / SQRT(ax[i]*ax[i] + ay[i]*ay[i] + az[i]*az[i] + ptiny) ;
	}
	for(int i = 0; i < VEC_LEN; i++) {	
		
	ax[i] *= norm[i] ;
	ay[i] *= norm[i] ;
	az[i] *= norm[i] ;
		
	dxv[i] = Real_t(-0.25)*
				( SUM4( Vel[0][0][i], Vel[1][0][i], Vel[5][0][i], Vel[4][0][i] ) 
				- SUM4( Vel[3][0][i], Vel[2][0][i], Vel[6][0][i], Vel[7][0][i] )) ;
	dyv[i] = Real_t(-0.25)*
				( SUM4( Vel[0][1][i], Vel[1][1][i], Vel[5][1][i], Vel[4][1][i] ) 
				- SUM4( Vel[3][1][i], Vel[2][1][i], Vel[6][1][i], Vel[7][1][i] )) ;
	dzv[i] = Real_t(-0.25)*
				( SUM4( Vel[0][2][i], Vel[1][2][i], Vel[5][2][i], Vel[4][2][i] ) 
				- SUM4( Vel[3][2][i], Vel[2][2][i], Vel[6][2][i], Vel[7][2][i] )) ;
	}
	for(int i = 0; i < VEC_LEN; i++) {	
		
	domain.delv_eta(ElemId+i) = ax[i]*dxv[i] + ay[i]*dyv[i] + az[i]*dzv[i] ;
	
#undef SUM4
		}
	}
#ifdef GATHER_MICRO_TIMING
	t2=getticks();
	elapsed_time[7] += elapsed(t2, t1);
	//gettimeofday(&end, NULL);
	//elapsed[7] += double(end.tv_sec - start.tv_sec) + double(end.tv_usec - start.tv_usec) *1e-6;
#endif
	
	
	// Compute for all elements in MaterialList:
	//	    in  CalcMonotonicQRegionForElems:  qq, ql  
	//		in 	EvalEOSForElems:			   p, e, q, ss 
	//
	//    In a code with multiple materials the following loop
	//    would go separately over all elemts with the same material.
	//    Hence this loop is not merged with the previous loop.
	
	const Real_t ptiny              = Real_t(1.e-36) ;
	const Real_t qstop              = domain.qstop() ;
	const Real_t monoq_max_slope    = domain.monoq_max_slope() ;
	const Real_t monoq_limiter_mult = domain.monoq_limiter_mult() ;
	const Real_t qlc_monoq          = domain.qlc_monoq();
	const Real_t qqc_monoq          = domain.qqc_monoq();
	const Real_t eosvmin	        = domain.eosvmin();
	const Real_t eosvmax	        = domain.eosvmax();

	const Real_t e_cut  = domain.e_cut();
	const Real_t p_cut  = domain.p_cut();
	const Real_t q_cut  = domain.q_cut();
	const Real_t pmin   = domain.pmin() ;
	const Real_t emin   = domain.emin() ;
	const Real_t rho0   = domain.refdens() ;
	
	// Calculate Q.  (Monotonic q option requires communication)
	//
	// Transfer veloctiy gradients in the first order elements 
	// problem->commElements->Transfer(CommElements::monoQ) ; 
	
	
#ifdef GATHER_MICRO_TIMING
	//ticks t1, t2;
	t1=getticks();
	//gettimeofday(&start, NULL);
#endif
#pragma omp parallel for firstprivate(numElem)
	for (Index_t ElemId = 0 ; ElemId < numElem ; ++ElemId ) {

		//
		// calculate the monotonic q for pure regions
		//
		CalcMonotonicQRegionForElems(ElemId, qlc_monoq, qqc_monoq,
									 monoq_limiter_mult, monoq_max_slope,
									 ptiny, qstop );
		
		EvalEOSForElems(ElemId, e_cut, p_cut, q_cut, 
						eosvmin, eosvmax, pmin, emin, rho0);
	}
#ifdef GATHER_MICRO_TIMING
	//gettimeofday(&end, NULL);
	//elapsed[8] += double(end.tv_sec - start.tv_sec) + double(end.tv_usec - start.tv_usec) *1e-6;
	t2=getticks();
	elapsed_time[8] += elapsed(t2, t1);
#endif
	
	
	// Computer for all elements:
	//      in UpdateVolumes:  v
	//
	//  This loop has too little work for current OpenMP overhead
	//  but it is kept here for now to maintain code correctness.
	//  An optimization we can consider is merging this work with the 
	//  Hydro and Courant constraint calculations that will be done next.
	
	
	
#ifdef GATHER_MICRO_TIMING
	//ticks t1, t2;
	t1=getticks();
	//gettimeofday(&start, NULL);
#endif
#pragma omp parallel for firstprivate(numElem)
	for (Index_t ElemId = 0 ; ElemId < numElem ; ++ElemId ) {
		
		UpdateVolumesForElems(ElemId) ;
	}
#ifdef GATHER_MICRO_TIMING
	//gettimeofday(&end, NULL);
	//elapsed[9] += double(end.tv_sec - start.tv_sec) + double(end.tv_usec - start.tv_usec) *1e-6;
	t2=getticks();
	elapsed_time[9] += elapsed(t2, t1);
#endif
}


static inline
void CalcCourantConstraintForElems()
{
	Real_t dtcourant = Real_t(1.0e+20) ;
	Index_t   courant_elem = -1 ;
	Real_t      qqc = domain.qqc() ;
	Index_t length = domain.numElem() ;
	
	Real_t  qqc2 = Real_t(64.0) * qqc * qqc ;
	
  	Index_t threads = omp_get_max_threads();

	//  For sequential run (non OpenMP, replace line above with next line.	
	//Index_t threads = Index_t (1);
	
	Index_t courant_elem_per_thread[threads];
	Real_t  dtcourant_per_thread[threads];

	for (Index_t i = 0; i < threads; i++) {
		courant_elem_per_thread[i] = -1;
		dtcourant_per_thread[i] =  Real_t(1.0e+20);
	}
	
#ifdef GATHER_MICRO_TIMING
	ticks t1, t2;
	t1=getticks();
	//timeval start, end;
	//gettimeofday(&start, NULL);
#endif
#pragma omp parallel for firstprivate(length,qqc2) shared(dtcourant,courant_elem)
	for (Index_t i = 0 ; i < length ; ++i) {
		Index_t indx = domain.matElemlist(i) ;
		
		Real_t dtf = domain.ss(indx) * domain.ss(indx) ;
		
		if ( domain.vdov(indx) < Real_t(0.) ) {
			
			dtf = dtf
            + qqc2 * domain.arealg(indx) * domain.arealg(indx)
            * domain.vdov(indx) * domain.vdov(indx) ;
		}
		
		dtf = SQRT(dtf) ;
		
		dtf = domain.arealg(indx) / dtf ;
		
		/* determine minimum timestep with its corresponding elem */
		if (domain.vdov(indx) != Real_t(0.)) {

  			Index_t thread_num = omp_get_thread_num();

			//  For sequential run (non OpenMP, replace line above with next line.	
			//Index_t thread_num = Index_t (0);
			
			
			if ( dtf < dtcourant_per_thread[thread_num] ) {
				{
					dtcourant_per_thread[thread_num] = dtf ;
					courant_elem_per_thread[thread_num] = indx ;
				}
			}
		}
	}
#ifdef GATHER_MICRO_TIMING
	//gettimeofday(&end, NULL);
	//elapsed[10] += double(end.tv_sec - start.tv_sec) + double(end.tv_usec - start.tv_usec) *1e-6;
	t2=getticks();
	elapsed_time[10] += elapsed(t2, t1);
#endif
	for (Index_t i = 0; i < threads; i++) {
		if(dtcourant_per_thread[i] < dtcourant) {
			dtcourant = dtcourant_per_thread[i];
			courant_elem =  courant_elem_per_thread[i];
		}
	}
	
	// Don't try to register a time constraint if none of the elements
	// were active 
	if (courant_elem != -1)   domain.dtcourant() = dtcourant ;
	return ;
}

static inline
void CalcHydroConstraintForElems()
{
	Real_t dthydro = Real_t(1.0e+20) ;
	Index_t hydro_elem = -1 ;
	Real_t dvovmax = domain.dvovmax() ;
	Index_t length = domain.numElem() ;
	
  	Index_t threads = omp_get_max_threads();

	//  For sequential run (non OpenMP, replace line above with next line.	
	//Index_t threads = Index_t (1);
	
	Real_t  dthydro_per_thread[threads];
	Index_t hydro_elem_per_thread[threads];

	for (Index_t i = 0; i < threads; i++) {
		hydro_elem_per_thread[i] = -1;
		dthydro_per_thread[i] =  Real_t(1.0e+20);
	}
	
	
#ifdef GATHER_MICRO_TIMING
	ticks t1, t2;
	t1=getticks();
	//timeval start, end;
	//gettimeofday(&start, NULL);
#endif
#pragma omp parallel for firstprivate(length) shared(dthydro,hydro_elem)
	for (Index_t i = 0 ; i < length ; ++i) {
		Index_t indx = domain.matElemlist(i) ;
		
		if (domain.vdov(indx) != Real_t(0.)) {
			Real_t dtdvov = dvovmax / (FABS(domain.vdov(indx))+Real_t(1.e-20)) ;

  			Index_t thread_num = omp_get_thread_num();

			//  For sequential run (non OpenMP, replace line above with next line.	
			//  Index_t thread_num = Index_t (0);
			
			if ( dthydro_per_thread[thread_num] > dtdvov ) {
				{
					dthydro_per_thread[thread_num] = dtdvov ;
					hydro_elem_per_thread[thread_num] = indx ;
				}
			}
		}
	}
#ifdef GATHER_MICRO_TIMING
	//gettimeofday(&end, NULL);
	//elapsed[11] += double(end.tv_sec - start.tv_sec) + double(end.tv_usec - start.tv_usec) *1e-6;
	t2=getticks();
	elapsed_time[11] += elapsed(t2, t1);
#endif
	
	for (Index_t i = 0; i < threads; i++) {
		if(dthydro_per_thread[i] < dthydro) {
			dthydro = dthydro_per_thread[i];
			hydro_elem =  hydro_elem_per_thread[i];
		}
	}
	// Don't try to register a time constraint if none of the elements
	// were active 
	if (hydro_elem != -1)   domain.dthydro() = dthydro ;
	return ;
}


static inline
void CalcTimeConstraintsForElems() {

	/* evaluate time constraint */
	CalcCourantConstraintForElems() ;
	
	/* check hydro constraint */
	CalcHydroConstraintForElems() ;
}


static inline
void LagrangeLeapFrog()
{
	/* calculate nodal forces, accelerations, velocities, positions, with
	 * applied boundary conditions and slide surface considerations */
	LagrangeNodal();
	
	/* calculate element quantities (i.e. velocity gradient & q), and update
	 * material states */
	LagrangeElements();
	
	CalcTimeConstraintsForElems();
	
	// LagrangeRelease() ;  Creation/destruction of temps may be important to capture 
}



#ifdef LULESH_VIZ_MESH

#ifdef __cplusplus
extern "C" {
#endif
#include "silo.h"
#ifdef __cplusplus
}
#endif

#define MAX_LEN_SAMI_HEADER  10

#define SAMI_HDR_NUMBRICK     0
#define SAMI_HDR_NUMNODES     3
#define SAMI_HDR_NUMMATERIAL  4
#define SAMI_HDR_INDEX_START  6
#define SAMI_HDR_MESHDIM      7

#define MAX_ADJACENCY  14  /* must be 14 or greater */

void DumpSAMI(Domain *domain, char *name)
{
	DBfile *fp ;
	int headerLen = MAX_LEN_SAMI_HEADER ;
	int headerInfo[MAX_LEN_SAMI_HEADER];
	char varName[] = "brick_nd0";
	char coordName[] = "x";
	char symmName[] = "symm_bcx";
	int version = 121 ;
	int numElem = int(domain->numElem()) ;
	int numNode = int(domain->numNode()) ;
	int count ;
	
	int *materialID ;
	int *nodeConnect ;
	double *nodeCoord ;
	
	if ((fp = DBCreate(name, DB_CLOBBER, DB_LOCAL,
					   NULL, DB_PDB)) == NULL)
	{
		printf("Couldn't create file %s\n", name) ;
		exit(-1) ;
	}
	
	for (int i=0; i<MAX_LEN_SAMI_HEADER; ++i) {
		headerInfo[i] = 0 ;
	}
	headerInfo[SAMI_HDR_NUMBRICK]    = numElem ;
	headerInfo[SAMI_HDR_NUMNODES]    = numNode ;
	headerInfo[SAMI_HDR_NUMMATERIAL] = 1 ;
	headerInfo[SAMI_HDR_INDEX_START] = 1 ;
	headerInfo[SAMI_HDR_MESHDIM]     = 3 ;
	
	DBWrite(fp, "mesh_data", headerInfo, &headerLen, 1, DB_INT) ;
	
	count = 1 ;
	DBWrite(fp, "version", &version, &count, 1, DB_INT) ;
	
	nodeConnect = new int[numElem] ;
	
	for (Index_t i=0; i<8; ++i)
	{
		for (Index_t j=0; j<numElem; ++j) {
			Index_t *nl = domain->nodelist(j) ;
			nodeConnect[j] = int(nl[i]) + 1 ;
		}
		varName[8] = '0' + i;
		DBWrite(fp, varName, nodeConnect, &numElem, 1, DB_INT) ;
	}
	
	delete [] nodeConnect ;
	
	nodeCoord = new double[numNode] ;
	
	for (Index_t i=0; i<3; ++i)
	{
		for (Index_t j=0; j<numNode; ++j) {
			Real_t coordVal ;
			switch(i) {
				case 0: coordVal = double(domain->x(j)) ; break ;
				case 1: coordVal = double(domain->y(j)) ; break ;
				case 2: coordVal = double(domain->z(j)) ; break ;
			}
			nodeCoord[j] = coordVal ;
		}
		coordName[0] = 'x' + i ;
		DBWrite(fp, coordName, nodeCoord, &numNode, 1, DB_DOUBLE) ;
	}
	
	delete [] nodeCoord ;
	
	materialID = new int[numElem] ;
	
	for (Index_t i=0; i<numElem; ++i)
		materialID[i] = 1 ;
	
	DBWrite(fp, "brick_material", materialID, &numElem, 1, DB_INT) ;
	
	delete [] materialID ;
	
	DBClose(fp);
}

void DumpDomain(Domain *domain, int myRank, int numProcs)
{
	char baseName[64] ;
	char meshName[64] ;
	sprintf(baseName, "sedov_%d.sami", int(domain->cycle())) ;
	
	if (myRank == 0) {
		sprintf(meshName, "sedov_%d.sami", int(domain->cycle())) ;
	}
	else {
		sprintf(meshName, "%s.%d", baseName, myRank) ;
	}
	
	DumpSAMI(domain, meshName) ;
	
	if ((myRank == 0) && (numProcs > 1)) {
		FILE *fp ;
		sprintf(meshName, "%s.visit", baseName) ;
		if ((fp = fopen(meshName, "w")) == NULL) {
			printf("Could not create file %s\n", meshName) ;
			exit(-10) ;
		}
		fprintf(fp, "!NBLOCKS %d\n%s\n", numProcs, baseName) ;
		for (int i=1; i<numProcs; ++i) {
			fprintf(fp, "%s.%d\n", baseName, i) ;
		}
		fclose(fp) ;
	}
}

#endif





int main(int argc, char *argv[])
{
	if(argc != 2) {
	    printf("Usage of program is ./a.out <even integer>.\n");
	    exit(1);
	}
	int x = strlen(argv[1]);
	for(int i = 0; i < x; i++) {
	   if(!isdigit(argv[1][i])) {
	     printf("Please enter an even size integer to run the program.\n");
	     exit(1);  
	   }
	}
	Index_t edgeElems = atoi(argv[1]) ;
	if(edgeElems % 2) {
	    printf("Please enter an even size integer to run the program.\n");
	    exit(1);
	}
	Index_t edgeNodes = edgeElems+1 ;
	// Real_t ds = Real_t(1.125)/Real_t(edgeElems) ; /* may accumulate roundoff */
	Real_t tx, ty, tz ;
	Index_t nidx, zidx ;
	Index_t domElems ;
	
	
	// Initialize constant array needed in HourGlass calc
	
	Gamma[0][0] = Real_t( 1.);
	Gamma[0][1] = Real_t( 1.);
	Gamma[0][2] = Real_t(-1.);
	Gamma[0][3] = Real_t(-1.);
	Gamma[0][4] = Real_t(-1.);
	Gamma[0][5] = Real_t(-1.);
	Gamma[0][6] = Real_t( 1.);
	Gamma[0][7] = Real_t( 1.);
	Gamma[1][0] = Real_t( 1.);
	Gamma[1][1] = Real_t(-1.);
	Gamma[1][2] = Real_t(-1.);
	Gamma[1][3] = Real_t( 1.);
	Gamma[1][4] = Real_t(-1.);
	Gamma[1][5] = Real_t( 1.);
	Gamma[1][6] = Real_t( 1.);
	Gamma[1][7] = Real_t(-1.);
	Gamma[2][0] = Real_t( 1.);
	Gamma[2][1] = Real_t(-1.);
	Gamma[2][2] = Real_t( 1.);
	Gamma[2][3] = Real_t(-1.);
	Gamma[2][4] = Real_t( 1.);
	Gamma[2][5] = Real_t(-1.);
	Gamma[2][6] = Real_t( 1.);
	Gamma[2][7] = Real_t(-1.);
	Gamma[3][0] = Real_t(-1.);
	Gamma[3][1] = Real_t( 1.);
	Gamma[3][2] = Real_t(-1.);
	Gamma[3][3] = Real_t( 1.);
	Gamma[3][4] = Real_t( 1.);
	Gamma[3][5] = Real_t(-1.);
	Gamma[3][6] = Real_t( 1.);
	Gamma[3][7] = Real_t(-1.);
	
	/* get run options to measure various metrics */
	
	/* ... */
	
	/****************************/
	/*   Initialize Sedov Mesh  */
	/****************************/
	
	/* construct a uniform box for this processor */
	
	domain.sizeX()   = edgeElems ;
	domain.sizeY()   = edgeElems ;
	domain.sizeZ()   = edgeElems ;
	domain.numElem() = edgeElems*edgeElems*edgeElems ;
	domain.numNode() = edgeNodes*edgeNodes*edgeNodes ;
	
	domElems = domain.numElem() ;
	
	
	/* allocate field memory */
	
	domain.AllocateElemPersistent(domain.numElem()) ;
	domain.AllocateElemTemporary (domain.numElem()) ;
	
	domain.AllocateNodalPersistent(domain.numNode()) ;
	domain.AllocateNodesets(edgeNodes*edgeNodes) ;
	
	/* initialize nodal coordinates */
	
	nidx = 0 ;
	tz  = Real_t(0.) ;
	for (Index_t plane=0; plane<edgeNodes; ++plane) {
		ty = Real_t(0.) ;
		for (Index_t row=0; row<edgeNodes; ++row) {
			tx = Real_t(0.) ;
			for (Index_t col=0; col<edgeNodes; ++col) {
				domain.x(nidx) = tx ;
				domain.y(nidx) = ty ;
				domain.z(nidx) = tz ;
				++nidx ;
				// tx += ds ; /* may accumulate roundoff... */
				tx = Real_t(1.125)*Real_t(col+1)/Real_t(edgeElems) ;
			}
			// ty += ds ;  /* may accumulate roundoff... */
			ty = Real_t(1.125)*Real_t(row+1)/Real_t(edgeElems) ;
		}
		// tz += ds ;  /* may accumulate roundoff... */
		tz = Real_t(1.125)*Real_t(plane+1)/Real_t(edgeElems) ;
	}
	
	
	/* embed hexehedral elements in nodal point lattice */
	
	nidx = 0 ;
	zidx = 0 ;
	for (Index_t plane=0; plane<edgeElems; ++plane) {
		for (Index_t row=0; row<edgeElems; ++row) {
			for (Index_t col=0; col<edgeElems; ++col) {
				Index_t *localNode = domain.nodelist(zidx) ;
				localNode[0] = nidx                                       ;
				localNode[1] = nidx                                   + 1 ;
				localNode[2] = nidx                       + edgeNodes + 1 ;
				localNode[3] = nidx                       + edgeNodes     ;
				localNode[4] = nidx + edgeNodes*edgeNodes                 ;
				localNode[5] = nidx + edgeNodes*edgeNodes             + 1 ;
				localNode[6] = nidx + edgeNodes*edgeNodes + edgeNodes + 1 ;
				localNode[7] = nidx + edgeNodes*edgeNodes + edgeNodes     ;
				++zidx ;
				++nidx ;
			}
			++nidx ;
		}
		nidx += edgeNodes ;
	}
	
	domain.AllocateNodeElemIndexes() ;
	
	/* Create a material IndexSet (entire domain same material for now) */
	for (Index_t i=0; i<domElems; ++i) {
		domain.matElemlist(i) = i ;
	}
	
	/* initialize material parameters */
	domain.dtfixed() = Real_t(-1.0e-7) ;
	domain.deltatime() = Real_t(1.0e-7) ;
	domain.deltatimemultlb() = Real_t(1.1) ;
	domain.deltatimemultub() = Real_t(1.2) ;
	domain.stoptime()  = Real_t(1.0e-2) ;
	domain.dtcourant() = Real_t(1.0e+20) ;
	domain.dthydro()   = Real_t(1.0e+20) ;
	domain.dtmax()     = Real_t(1.0e-2) ;
	domain.time()    = Real_t(0.) ;
	domain.cycle()   = 0 ;
	
	domain.e_cut() = Real_t(1.0e-7) ;
	domain.p_cut() = Real_t(1.0e-7) ;
	domain.q_cut() = Real_t(1.0e-7) ;
	domain.u_cut() = Real_t(1.0e-7) ;
	domain.v_cut() = Real_t(1.0e-10) ;
	
	domain.hgcoef()      = Real_t(3.0) ;
	domain.ss4o3()       = Real_t(4.0)/Real_t(3.0) ;
	
	domain.qstop()              =  Real_t(1.0e+12) ;
	domain.monoq_max_slope()    =  Real_t(1.0) ;
	domain.monoq_limiter_mult() =  Real_t(2.0) ;
	domain.qlc_monoq()          = Real_t(0.5) ;
	domain.qqc_monoq()          = Real_t(2.0)/Real_t(3.0) ;
	domain.qqc()                = Real_t(2.0) ;
	
	domain.pmin() =  Real_t(0.) ;
	domain.emin() = Real_t(-1.0e+15) ;
	
	domain.dvovmax() =  Real_t(0.1) ;
	
	domain.eosvmax() =  Real_t(1.0e+9) ;
	domain.eosvmin() =  Real_t(1.0e-9) ;
	
	domain.refdens() =  Real_t(1.0) ;
	
	/* initialize field data */
	for (Index_t i=0; i<domElems; ++i) {
		Real_t Pos_local[8][3];
		Index_t *elemToNode = domain.nodelist(i) ;
		CollectElemPositions (elemToNode, Pos_local);

		// volume calculations
		Real_t volume = CalcElemVolume(Pos_local);
		domain.volo(i) = volume ;
		domain.elemMass(i) = volume ;
		for (Index_t j=0; j<8; ++j) {
			Index_t idx = elemToNode[j] ;
			domain.nodalMass(idx) += volume / Real_t(8.0) ;
		}
	}
	
	/* deposit energy */
	domain.e(0) = Real_t(3.948746e+7) ;
	

	/* set up symmetry nodesets */
	nidx = 0 ;
	for (Index_t i=0; i<edgeNodes; ++i) {
		Index_t planeInc = i*edgeNodes*edgeNodes ;
		Index_t rowInc   = i*edgeNodes ;
		for (Index_t j=0; j<edgeNodes; ++j) {
			domain.symmX(nidx) = planeInc + j*edgeNodes ;
			domain.symmY(nidx) = planeInc + j ;
			domain.symmZ(nidx) = rowInc   + j ;
			++nidx ;
		}
	}
	
	/* set up element connectivity information */
	domain.lxim(0) = 0 ;
	for (Index_t i=1; i<domElems; ++i) {
		domain.lxim(i)   = i-1 ;
		domain.lxip(i-1) = i ;
	}
	domain.lxip(domElems-1) = domElems-1 ;
	
	for (Index_t i=0; i<edgeElems; ++i) {
		domain.letam(i) = i ; 
		domain.letap(domElems-edgeElems+i) = domElems-edgeElems+i ;
	}
	for (Index_t i=edgeElems; i<domElems; ++i) {
		domain.letam(i) = i-edgeElems ;
		domain.letap(i-edgeElems) = i ;
	}
	
	for (Index_t i=0; i<edgeElems*edgeElems; ++i) {
		domain.lzetam(i) = i ;
		domain.lzetap(domElems-edgeElems*edgeElems+i) = domElems-edgeElems*edgeElems+i ;
	}
	for (Index_t i=edgeElems*edgeElems; i<domElems; ++i) {
		domain.lzetam(i) = i - edgeElems*edgeElems ;
		domain.lzetap(i-edgeElems*edgeElems) = i ;
	}
	
	/* set up boundary condition information */
	for (Index_t i=0; i<domElems; ++i) {
		domain.elemBC(i) = 0 ;  /* clear BCs by default */
	}
	
	/* faces on "external" boundaries will be */
	/* symmetry plane or free surface BCs */
	for (Index_t i=0; i<edgeElems; ++i) {
		Index_t planeInc = i*edgeElems*edgeElems ;
		Index_t rowInc   = i*edgeElems ;
		for (Index_t j=0; j<edgeElems; ++j) {
			domain.elemBC(planeInc+j*edgeElems) |= XI_M_SYMM ;
			domain.elemBC(planeInc+j*edgeElems+edgeElems-1) |= XI_P_FREE ;
			domain.elemBC(planeInc+j) |= ETA_M_SYMM ;
			domain.elemBC(planeInc+j+edgeElems*edgeElems-edgeElems) |= ETA_P_FREE ;
			domain.elemBC(rowInc+j) |= ZETA_M_SYMM ;
			domain.elemBC(rowInc+j+domElems-edgeElems*edgeElems) |= ZETA_P_FREE ;
		}
	}

	
	/* timestep to solution */
	
#ifdef GATHER_MICRO_TIMING
	for(int i = 0; i < 12; i++)
          elapsed_time[i] = 0.0;
#endif
	timeval start, end;
	gettimeofday(&start, NULL);
	
  	while(domain.time() < domain.stoptime() ) {

	
//   	for (int step=0; step<5; ++step) {
		
		
#ifdef LULESH_VIZ_MESH
		char meshName[64] ;
		if (domain.cycle() % int(100) == 0) {
			DumpDomain(&domain, 0, 1) ;
		}
#endif
		
		TimeIncrement() ;
		LagrangeLeapFrog() ;
		/* problem->commNodes->Transfer(CommNodes::syncposvel) ; */

#ifdef LULESH_SHOW_PROGRESS
  		printf("iteration = %i,  time = %12.6e,  dthydro=%12.6e,  dtcourant=%12.6e\n", 
  			   domain.cycle(), domain.time(), domain.dthydro(), domain.dtcourant() ) ;
#endif
		
	}
	
	
	gettimeofday(&end, NULL);
	double elapsed_timer = double(end.tv_sec - start.tv_sec) + double(end.tv_usec - start.tv_usec) *1e-6;
	
	
#ifdef LULESH_VIZ_MESH
	if (domain.cycle() % int(100) != 0) {
		DumpDomain(&domain, 0, 1) ;
	}
#endif

	
	printf("\n\nElapsed time = %12.6e\n\n", elapsed_timer);

	printf("Run completed:  \n");
	printf("   Problem size        =  %i \n",    edgeElems);
	printf("   Iteration count     =  %i \n",    domain.cycle());	
	printf("   Final Origin Energy = %12.6e \n", domain.e(0));	

	Real_t   MaxAbsDiff = Real_t(0.0);
	Real_t TotalAbsDiff = Real_t(0.0);
	Real_t   MaxRelDiff = Real_t(0.0);
		
	for (Index_t j=0; j<edgeElems; ++j) {
		for (Index_t k=j+1; k<edgeElems; ++k) {
			Real_t AbsDiff = FABS(domain.e(j*edgeElems+k) - domain.e(k*edgeElems+j));
			TotalAbsDiff  += AbsDiff;
			
			if (MaxAbsDiff <AbsDiff) MaxAbsDiff = AbsDiff;
			
			Real_t RelDiff = AbsDiff / domain.e(k*edgeElems+j);
			
			if (MaxRelDiff <RelDiff)  MaxRelDiff = RelDiff;
		}		
	}	
		
	printf("   Testing Plane 0 of Energy Array:\n");
	printf("        MaxAbsDiff   = %12.6e\n",   MaxAbsDiff   );
	printf("        TotalAbsDiff = %12.6e\n",   TotalAbsDiff );
	printf("        MaxRelDiff   = %12.6e\n\n", MaxRelDiff   );

#ifdef GATHER_MICRO_TIMING
	for(int i = 0; i < 12; i++)
	printf("%12.6e\n", elapsed_time[i]);
#endif
	
}


