// USAGE: [PriorO MeanO CovO] = EmGmm(Data, PriorI, MeanI, CovI, Mode, MAP, MaxIter, ...
//                  Thresh, Verbose)
//
// Generic EM-GMM algorithm
//
// INPUTS:
//     Data - D x N, matrix of N data points of dimension D
//     PriorI - 1 x K, vector of priors
//     MeanI - D x K, matrix of means
//     CovI - D x (D) x K, matrix of covariances
//     Mode - 1 x 1, full covariance (0), diagonal covariance (1)
//     MAP - 1 x 1(3), apply full training (0), apply MAP adaptation [r r r] (when in MAP : PriorI, MeanI and CovI
//            contains the the model for adaptation, r is the adaptation coefficient)
//     MaxIter - 1 x 1, maximum number of iterations
//     Thresh - 1 x 1, threshold termination condition
//	   Verbose - (0,1) verbosity
//
// OUTPUTS:
//     PriorO - 1 x K, vector of priors
//     MeanO - D x K, matrix of means
//     CovO - D x D x K, array of covariance matrices


#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include <string.h>
#include <float.h>
#include <omp.h>

#include "mex.h"
#include "mkl.h"

// -------------------------------  Utility Function   --------------------------------//

// Usage
void Usage(){
	printf("USAGE: [PriorO MeanO CovO] = EmGmm(Data, PriorI, MeanI, CovI, Mode, MAP, MaxIter, Thresh, Verbose)\n"
			"Generic EM-GMM algorithm\n"
			"\n"
			"INPUTS:\n"
			"   Data - \tD x N matrix of N data points of dimension D\n"
			"   PriorI - \t1 x K vector of priors\n"
			"   MeanI - \tD x K matrix of means\n"
			"   CovI - \tD x (D) x K matrix of covariances\n"
			"   Mode - full covariance (0), diagonal covariance (1)\n"
			"   MAP - apply full training (0), apply MAP adaptation (1) (when in MAP "
			"	       \t: PriorI, MeanI and CovI contains the model for adaptation)\n"
			"   MaxIter - \tmaximum number of iterations\n"
			"   Thresh - \tthreshold termination condition\n"
			"\n"
			"OUTPUTS:\n"
			"   PriorO - \t1 x K vector of priors\n"
			"   MeanO - \tD x K matrix of means\n"
			"   CovO - \tD x D x K array of covariance matrices\n");

}

/*
 * Print 2D matrices
 * iMat is a pointer to matrix
 * iRows and iCols are the number of rows and columns of iMat
 */
void Print2DMat(const double *iMat, const int iRows, const int iCols){
	for(int i = 0; i < iRows; i++){
		for(int j = 0; j < iCols; j++){
			printf("%3.4f\t",iMat[i*iCols+j]);
		}
		printf("\n");
	}
	printf("\n\n");
};

/*
 * Inverse GMM covariance matrices
 * Cov is a pointer to an iDim x iDim x iNME covariace matrices
 * InvCov is a pointer to the output matrix, should be of compatible size
 */
void invertCovMat( const double *Cov, double *InvCov, const int iDim,
		const int iNME){

	// MKL variables for matrix inversion
	char uplo = 'U';
	int n = iDim;
	int lda = iDim;
	int lwork = n;
	double *work; work = new double[iDim];
	int *ipiv; ipiv = new int[iDim];
	int info = 0;
	int Index = 0;

	// Copy data to InvCov
	memcpy(InvCov, Cov, iDim*iDim*iNME*sizeof(double));

	for(int i = 0; i < iNME; i++){

		Index = iDim*iDim*i;
		// Compute the Bunch-Kaufman factorization
		dsytrf( &uplo, &n, &InvCov[Index], &lda, ipiv, work, &lwork,
				&info );

		// Invert the matrix
		dsytri( &uplo, &n, &InvCov[Index], &lda, ipiv, work, &info );

		// Complete the lower diagonal
		for(int j = 1; j < iDim; j++)
			for(int k = 0; k < j; k++)
				InvCov[Index+k*iDim+j] = InvCov[Index+j*iDim+k];

	}

	delete [] work;
	delete [] ipiv;
}

/*
 * Determinant for GMM covariance matrices
 * Cov is a pointer to an iDim x iDim x iNME covariace matrices
 * DetCov is a pointer to the output vector, should be of compatible size
 */
void detCovMat( double *Cov, double *DetCov, const int iDim, 
		const int iNME){

	// MKL matrix determinant variables
	char uplo = 'U';
	char jobz = 'N';
	double *w; w = new double[iDim];
	int lda = iDim;
	int lwork = 2*iDim+1;
	int liwork = 1;
	double *work; work = new double[lwork];
	int *iwork; iwork = new int[liwork];
	int info = 0;
	int Index = 0;

	for(int i = 0; i < iNME; i++){

		Index = iDim*iDim*i;
		dsyevd(&jobz, &uplo, &lda, &Cov[Index], &lda, w, work, &lwork,
				iwork, &liwork, &info);
		DetCov[i] = 1;
		for(int j = 0; j < iDim; j++)
			DetCov[i]*=w[j];
	}

	delete [] work;
	delete [] iwork;
	delete [] w;
}

/*
 * Matrix and matrix product
 * oVec - a and transb are 'N' or 'T' for normal and transpose
 */
void MatMatProd(const char transa, const char transb,
		double alpha, double beta, const double *iMatA,
		const double *iMatB, double *oMat, const int iMatARows,
		const int iMatACols, const int iMatBRows, const int iMatBCols,
		const int oMatRows, const int oMatCols){

	// MKL variables
	int 	m = 0,
			n = 0,
			k = 0;

	// Set dimenstions
	switch(transa){
	case 'N':
		m = iMatARows;
		k = iMatACols;
		break;
	case 'T':
		m = iMatACols;
		k = iMatARows;
		break;
	}
	switch(transb){
	case 'N':
		n = iMatBCols;
		break;
	case 'T':
		n = iMatBRows;
		break;
	}

	// Check dimenstions match
	if((m != oMatRows) | (n != oMatCols)){
		mexErrMsgIdAndTxt("EMGMM:MatMatProd",
				"Matrix dimensions must agree.");
	}

	dgemm(&transa, &transb, &m, &n, &k, &alpha, iMatA, &iMatARows,
			iMatB, &iMatBRows, &beta, oMat, &oMatRows);

}

/*
 * Gaussian density function using scaling (prior)
 * iVec - 1 x D vector of data
 * iGConst - 1 x 1 Gaussian constant
 * iGPri - 1 x 1 scaling (prior)
 * iGMean - 1 x D mean vector
 * iGInvCov - D x D inverse covariance matrix
 * iGDetCov - 1 x 1 determinant of the covariance matrix
 * Dim - 1 x 1 number of dimensions
 *
 * work - 2 x D matrix for work storage
 * oPro - 1 x 1 probability value
 *
 */
void GaussPDFFC(const double *iVec, const double *iGConst, const double *iGPri,
		const double *iGMean, const double *iGInvCov, const double *iGDetCov,
		const int *Dim, double *work, double *oPro){

	const char 	uplo = 'U';
	const int 	inc = 1;
	const double alpha = -0.5;
	const double beta = 0;


	// Generate Work[0] = iVec - Mean
	vdSub(*Dim, iVec, iGMean, work);

	// Multiply by inverse covariance
	dsymv(&uplo, Dim, &alpha, iGInvCov, Dim, work, &inc, &beta, &work[*Dim], &inc);

	// Dot product
	*oPro = ddot(Dim, work, &inc, &work[(*Dim)], &inc);

	// Mutiply by constants
	*oPro = exp((*oPro))*(*iGPri)/sqrt((*iGConst)*(fabs(*iGDetCov)+DBL_MIN));

}

/*
 * Gaussian density function using scaling (prior) diagonal covariance
 * iVec - 1 x D vector of data
 * iGConst - 1 x 1 Gaussian constant
 * iGPri - 1 x 1 scaling (prior)
 * iGMean - 1 x D mean vector
 * iGInvCov - 1 x D inverse covariance matrix
 * iGDetCov - 1 x 1 determinant of the covariance matrix
 * Dim - 1 x 1 number of dimensions
 *
 * work - 2 x D matrix for work storage
 * oPro - 1 x 1 probability value
 *
 */
void GaussPDFDC(const double *iVec, const double *iGConst, const double *iGPri,
		const double *iGMean, const double *iGInvCov, const double *iGDetCov,
		const int *Dim, double *work, double *oPro){

	const char 	uplo = 'U';
	const int 	inc = 1;
	const double alpha = -0.5;
	const double beta = 0;


	// Generate Work[0] = iVec - Mean
	vdSub(*Dim, iVec, iGMean, work);

	// Multiply by inverse covariance
	vdMul( *Dim, work, iGInvCov, &work[*Dim] );

	// Dot product
	*oPro = ddot(Dim, work, &inc, &work[(*Dim)], &inc);

	// Mutiply by constants
	*oPro = exp((-0.5*(*oPro)))*(*iGPri)/sqrt((*iGConst)*(fabs(*iGDetCov)+DBL_MIN));

}



// -------------------------------  mexFunction ---------------------------------------//
void mexFunction( int nlhs, mxArray *plhs[],
		int nrhs, const mxArray *prhs[]) {

	/* Check for proper number of arguments */
	if(nrhs!=9) {
		Usage();
		mexErrMsgIdAndTxt("MyToolbox:arrayProduct:nrhs",
				"Nine inputs required.");
	}
	if(nlhs!=3) {
		Usage();
		mexErrMsgIdAndTxt("MyToolbox:arrayProduct:nlhs",
				"Three output required.");
	}

	/************************ Input argument and dimensions ****************************/
	const mwSize 	DataR = mxGetM(prhs[0]),
					DataC = mxGetN(prhs[0]),
					PriorIR = mxGetM(prhs[1]),
					PriorIC = mxGetN(prhs[1]),
					MeanIR = mxGetM(prhs[2]),
					MeanIC = mxGetN(prhs[2]),
					MAPC = mxGetN(prhs[5]),
					*CovIDim = mxGetDimensions(prhs[3]),
					CovINumDim = mxGetNumberOfDimensions(prhs[3]);
	const double 	*Data = mxGetPr(prhs[0]),
					*PriorI = mxGetPr(prhs[1]),
					*MeanI = mxGetPr(prhs[2]),
					*CovI = mxGetPr(prhs[3]),
					*MAP = mxGetPr(prhs[5]);
	const double 	Mode = mxGetScalar(prhs[4]),
					MaxIter = mxGetScalar(prhs[6]),
					Thresh = mxGetScalar(prhs[7]);
	const int 		Verbose = mxGetScalar(prhs[8]);


	// Set the number of mixture elements, dimension and number of data points
	int 	NME = MeanIC,
			ND = DataC,
			Dim = DataR;


	/************************ Check appropriate sizes and modes ************************/
	if( (Mode != 0) & (Mode != 1) & (Mode != 2) ){
		Usage();
		mexErrMsgIdAndTxt("EMGMM:CovMat","Wrong mode");
	}

	if( (NME == 1) & (Mode == 0) ){
		if( (CovINumDim != 2) | (CovIDim[0] != Dim) | (CovIDim[1] != Dim) ){
			Usage();
			mexErrMsgIdAndTxt("EMGMM:CovMat","Covariance matrix dimension");
		}
		if( (MeanIR != Dim) | (MeanIC != NME) ){
			Usage();
			mexErrMsgIdAndTxt("EMGMM:CovMat","Mean matrix dimension");
		}
		if( (PriorIR != 1) | (PriorIC != NME) ){
			Usage();
			mexErrMsgIdAndTxt("EMGMM:CovMat","Prior vector dimension");
		}
	}
	if( (NME > 1) & (Mode == 0) ){
		if( (CovINumDim != 3) | (CovIDim[0] != Dim) | (CovIDim[1] != Dim) | (CovIDim[2] != NME) ){
			Usage();
			mexErrMsgIdAndTxt("EMGMM:CovMat","Covariance matrix dimension");
		}
		if( (MeanIR != Dim) | (MeanIC != NME) ){
			Usage();
			mexErrMsgIdAndTxt("EMGMM:CovMat","Mean matrix dimension");
		}
		if( (PriorIR != 1) | (PriorIC != NME) ){
			Usage();
			mexErrMsgIdAndTxt("EMGMM:CovMat","Prior vector dimension");
		}
	}
	if( (NME == 1) & (Mode == 1) ){
		if( (CovINumDim != 2) | (CovIDim[0] != Dim) | (CovIDim[1] != NME) ){
			Usage();
			mexErrMsgIdAndTxt("EMGMM:CovMat","Covariance matrix dimension");
		}
		if( (MeanIR != Dim) | (MeanIC != NME) ){
			Usage();
			mexErrMsgIdAndTxt("EMGMM:CovMat","Mean matrix dimension");
		}
		if( (PriorIR != 1) | (PriorIC != NME) ){
			Usage();
			mexErrMsgIdAndTxt("EMGMM:CovMat","Prior vector dimension");
		}
	}

	if( (NME > 1) & (Mode == 1) ){
		if( (CovINumDim != 2) | (CovIDim[0] != Dim) | (CovIDim[1] != NME)){
			Usage();
			mexErrMsgIdAndTxt("EMGMM:CovMat","Covariance matrix dimension");
		}
		if( (MeanIR != Dim) | (MeanIC != NME) ){
			Usage();
			mexErrMsgIdAndTxt("EMGMM:CovMat","Mean matrix dimension");
		}
		if( (PriorIR != 1) | (PriorIC != NME) ){
			Usage();
			mexErrMsgIdAndTxt("EMGMM:CovMat","Prior vector dimension");
		}
	}

	/************************ Model elements *******************************************/
	double 	*Prior = NULL,
			*Mean = NULL,
			*Cov = NULL,
			*InvCov = NULL,
			*DetCov = NULL;

	Prior = new double[NME];
	Mean = new double[Dim*NME];
	if(Mode == 0){
		Cov = new double[Dim*Dim*NME];
		InvCov = new double[Dim*Dim*NME];
		memcpy(Cov, CovI, Dim*Dim*NME*sizeof(double));
	}
	else if(Mode == 1){
		Cov = new double[Dim*NME];
		InvCov = new double[Dim*Dim*NME];
		memcpy(Cov, CovI, Dim*NME*sizeof(double));
	}
	DetCov = new double[NME];

	memcpy(Prior, PriorI, NME*sizeof(double));
	memcpy(Mean, MeanI, Dim*NME*sizeof(double));

	/************************ Function parameters **************************************/
	double 	*GMMP; GMMP = new double[ND];
	double 	*GMMPost;
	double	*Work;
	Work = 	new double[2*Dim];
	double  GTemp = 0;
	double	NLL = 0,
			PLL = 0;
	const double GConst = pow(6.2832,Dim);
	int 	CDim = Dim*Dim;
	int 	i,k;
	int		inc = 1;


	/************************ Switch operation mode ************************************/
	switch(int(Mode)){

	// Full covariance
	case 0:

		// MAP adaptation switch
		if(MAPC == 3){
			Usage();
			mexErrMsgIdAndTxt("EMGMM:MAP","Full covariance MAP is not yet implemented");
		}
		else{
			// Full covariance EM-GMM algorithm
			for(int EIter = 0; EIter < MaxIter; EIter++){

				// Compute inverse and determinants of the covariance matrices
				invertCovMat( Cov, InvCov, Dim, NME );
				detCovMat( Cov, DetCov, Dim, NME );

				// Reset values
				memset(GMMP, 0, ND*sizeof(double));
				NLL = 0;

				// Compute prior normalization coefficients
#pragma omp parallel for shared(Data, Prior, Mean, InvCov, DetCov, Dim, GMMP) private(i,k, Work, GTemp)
				for(i = 0; i < ND; i++){
					for(k = 0; k < NME; k++){
						GaussPDFFC(&Data[i*Dim], &GConst, &Prior[k],
								&Mean[k*Dim], &InvCov[k*Dim*Dim], &DetCov[k],
								&Dim, Work, &GTemp);
						GMMP[i] = GMMP[i] + GTemp;
					}
				}

				for(i = 0; i < ND; i++){
					if(GMMP[i] < DBL_MIN)
						NLL = NLL + log(DBL_MIN)/ND;
					else
						NLL = NLL + log(GMMP[i])/ND;
				}

				// Go over all components
#pragma omp parallel for shared(Data, Prior, Mean, InvCov, DetCov, Dim, GMMP, inc) private(i,k, Work, GMMPost, GTemp)
				for(k = 0; k < NME; k++){

					// Allocate dynamic space
					GMMPost = new double[ND];
					memset(GMMPost, 0, ND*sizeof(double));

					//Calculate posterior probabilities
					for(i = 0; i < ND; i++){
						GaussPDFFC(&Data[i*Dim], &GConst, &Prior[k],
								&Mean[k*Dim], &InvCov[k*Dim*Dim], &DetCov[k],
								&Dim, Work, &GMMPost[i]);
						GMMPost[i] = GMMPost[i] / GMMP[i];
					}

					// ** Calculate Prior
					Prior[k] = dasum(&ND, GMMPost, &inc);

					// Calculate scaling coefficient
					GTemp = 1/Prior[k];
					Prior[k] = Prior[k]/ND;

					// ** Caculate mean
					// Zero out mean vector
					memset(&Mean[k*Dim], 0, Dim*sizeof(double));


					for(i = 0; i < ND; i++){
						daxpy(&Dim, &GMMPost[i], &Data[i*Dim], &inc, &Mean[k*Dim], &inc);
					}

					// Divide by the posterior
					dscal(&Dim, &GTemp, &Mean[k*Dim], &inc);

					// Calculate covariances
					// Zero out covariance matrix
					memset(&Cov[k*Dim*Dim], 0 ,Dim*Dim*sizeof(double));


					for(i = 0; i < ND; i++){
						// Generate Data - Mean
						vdSub( Dim, &Data[i*Dim], &Mean[k*Dim], Work );

						// Generate matrix product
						MatMatProd('N', 'N', GMMPost[i], 1, Work, Work, &Cov[k*Dim*Dim], Dim,
								1, 1, Dim, Dim, Dim);
					}

					dscal(&CDim, &GTemp, &Cov[k*Dim*Dim], &inc);

					// Add small value to the diagonal
					for(i = 0; i < Dim; i++)
						Cov[k*Dim*Dim+i*Dim+i] = Cov[k*Dim*Dim+i*Dim+i] + 1e-5;

					delete [] GMMPost;

				}

				// Termination
				if(Verbose == 1){
					printf("Iter %d, Averaged -LogLik: %3.8f\n",EIter+1,NLL);
					mexEvalString("pause(.000001);");
				}

				if(fabs(NLL-PLL) <= Thresh)
					break;
				PLL = NLL;
			}
		}
		break;

		// Diagonal covariance
	case 1:

		// MAP adaptation switch
		if(MAPC == 3){

			// Diagonal covariance MAP adaptation

			// Compute inverse and determinants of the covariance matrices
			memset(InvCov, 0, Dim*NME*sizeof(double));
			for( int j = 0; j < NME; j++)
				DetCov[j] = 1;

			for( i = 0; i < Dim; i++){
				for( int j = 0; j < NME; j++){
					DetCov[j] = DetCov[j] * Cov[j*Dim+i];
					InvCov[i*NME+j] = 1/Cov[i*NME+j];
				}
			}

			// Reset values
			memset(GMMP, 0, ND*sizeof(double));
			NLL = 0;

			// Compute prior normalization coefficients
#pragma omp parallel for shared(Data, Prior, Mean, InvCov, DetCov, Dim, GMMP) private(i,k, Work, GTemp)
			for(i = 0; i < ND; i++){
				for(k = 0; k < NME; k++){
					GaussPDFDC(&Data[i*Dim], &GConst, &Prior[k],
							&Mean[k*Dim], &InvCov[k*Dim], &DetCov[k],
							&Dim, Work, &GTemp);
					GMMP[i] = GMMP[i] + GTemp;
				}
			}

			// Go over all components
//#pragma omp parallel for shared(Data, Prior, Mean, InvCov, DetCov, Dim, GMMP, inc) private(i,j,k, Work, GMMPost, GTemp)
			for(k = 0; k < NME; k++){

				// Allocate dynamic space
				GMMPost = new double[ND];
				memset(GMMPost, 0, ND*sizeof(double));

				//Calculate ni
				for(i = 0; i < ND; i++){
					GaussPDFDC(&Data[i*Dim], &GConst, &Prior[k],
							&Mean[k*Dim], &InvCov[k*Dim], &DetCov[k],
							&Dim, Work, &GMMPost[i]);
					GMMPost[i] = GMMPost[i] / GMMP[i];
				}

				// ** Calculate ni
				Prior[k] = dasum(&ND, GMMPost, &inc);

				// Calculate scaling coefficient, replace 0 with a small number
				// to avoid NaN
				if(Prior[k] == 0)
					GTemp = DBL_MIN;
				else
					GTemp = 1/Prior[k];

				// ** Caculate Eix
				// Zero out mean vector
				memset(&Mean[k*Dim], 0, Dim*sizeof(double));

				for(i = 0; i < ND; i++){
					daxpy(&Dim, &GMMPost[i], &Data[i*Dim], &inc, &Mean[k*Dim], &inc);
				}

				// Divide by the posterior
				dscal(&Dim, &GTemp, &Mean[k*Dim], &inc);

				// Calculate Eix^2
				// Zero out covariance matrix
				memset(&Cov[k*Dim], 0 ,Dim*sizeof(double));


				for(i = 0; i < ND; i++){
					// Generate element by element square
					vdSqr( Dim, &Data[i*Dim], Work );

					daxpy( &Dim, &GMMPost[i], Work, &inc, &Cov[k*Dim], &inc);
				}

				dscal(&Dim, &GTemp, &Cov[k*Dim], &inc);

				delete [] GMMPost;

			}

			// Update components

			// Set adaptation coefficients
			double  *ScaleP; ScaleP = new double[NME];
			double  *ScaleM; ScaleM = new double[NME];
			double  *ScaleC; ScaleC = new double[NME];
			for(i = 0; i < NME; i++){
				ScaleP[i] = Prior[i]/(Prior[i]+MAP[0]);
				ScaleM[i] = Prior[i]/(Prior[i]+MAP[1]);
				ScaleC[i] = Prior[i]/(Prior[i]+MAP[2]);
			}
			// Update priors
			GTemp = 0;
			for(i = 0; i < NME; i++){
				Prior[i] = (ScaleP[i]*Prior[i]/ND+(1-ScaleP[i])*PriorI[i]);
				GTemp = GTemp + Prior[i];
			}
			GTemp = 1/GTemp;
			dscal(&NME, &GTemp, Prior, &inc);

			// Update means
			for(i = 0; i < NME; i++){
				// Scale Eix by MAP adaptation coefficient
				dscal(&Dim, &ScaleM[i], &Mean[i*Dim], &inc);

				// Add UBM mean
				GTemp = 1 - ScaleM[i];
				daxpy(&Dim, &GTemp, &MeanI[i*Dim], &inc, &Mean[i*Dim], &inc);
			}

			// Update covariances
			for(i = 0; i < NME; i++){

				// Scale Eix^2 by MAP adaptation coefficient
				dscal(&Dim, &ScaleC[i], &Cov[i*Dim], &inc);

				// Square UBM mean vector
				vdSqr( Dim, &MeanI[i*Dim], Work );

				// Sum UBM squared mean and covariance
				vdAdd( Dim, Work, &CovI[i*Dim], &Work[Dim] );

				// Add Cov and work
				GTemp = 1 - ScaleC[i];
				daxpy(&Dim, &GTemp, &Work[Dim], &inc, &Cov[i*Dim], &inc);

				// Square appropriate mean element
				vdSqr( Dim, &Mean[i*Dim], Work );

				// subtract squared mean
				GTemp = -1;
				daxpy(&Dim, &GTemp, Work, &inc, &Cov[i*Dim], &inc);
			}

		}
		else{

			// Diagonal covariance EM-GMM algorithm
			for(int EIter = 0; EIter < MaxIter; EIter++){


				// Compute inverse and determinants of the covariance matrices
				memset(InvCov, 0, Dim*NME*sizeof(double));
				for( int j = 0; j < NME; j++)
					DetCov[j] = 1;

				for( i = 0; i < Dim; i++){
					for( int j = 0; j < NME; j++){
						DetCov[j] = DetCov[j] * Cov[j*Dim+i];
						InvCov[i*NME+j] = 1/Cov[i*NME+j];
					}
				}

				// Reset values
				memset(GMMP, 0, ND*sizeof(double));
				NLL = 0;

				// Compute prior normalization coefficients
#pragma omp parallel for shared(Data, Prior, Mean, InvCov, DetCov, Dim, GMMP) private(i,k, Work, GTemp)
				for(i = 0; i < ND; i++){
					for(k = 0; k < NME; k++){
						GaussPDFDC(&Data[i*Dim], &GConst, &Prior[k],
								&Mean[k*Dim], &InvCov[k*Dim], &DetCov[k],
								&Dim, Work, &GTemp);
						GMMP[i] = GMMP[i] + GTemp;
					}
				}

				for(i = 0; i < ND; i++){
					if(GMMP[i] < DBL_MIN)
						NLL = NLL + log(DBL_MIN)/ND;
					else
						NLL = NLL + log(GMMP[i])/ND;
				}

				// Go over all components
#pragma omp parallel for shared(Data, Prior, Mean, InvCov, DetCov, Dim, GMMP, inc) private(i,j,k, Work, GMMPost, GTemp)
				for(k = 0; k < NME; k++){

					// Allocate dynamic space
					GMMPost = new double[ND];
					memset(GMMPost, 0, ND*sizeof(double));

					//Calculate posterior probabilities
					for(i = 0; i < ND; i++){
						GaussPDFDC(&Data[i*Dim], &GConst, &Prior[k],
								&Mean[k*Dim], &InvCov[k*Dim], &DetCov[k],
								&Dim, Work, &GMMPost[i]);
						GMMPost[i] = GMMPost[i] / GMMP[i];
					}

					// ** Calculate Prior
					Prior[k] = dasum(&ND, GMMPost, &inc);

					// Calculate scaling coefficient
					GTemp = 1/Prior[k];
					Prior[k] = Prior[k]/ND;

					// ** Caculate mean
					// Zero out mean vector
					memset(&Mean[k*Dim], 0, Dim*sizeof(double));


					for(i = 0; i < ND; i++){
						daxpy(&Dim, &GMMPost[i], &Data[i*Dim], &inc, &Mean[k*Dim], &inc);
					}

					// Divide by the posterior
					dscal(&Dim, &GTemp, &Mean[k*Dim], &inc);

					// Calculate covariances
					// Zero out covariance matrix
					memset(&Cov[k*Dim], 0 ,Dim*sizeof(double));


					for(i = 0; i < ND; i++){
						// Generate Data - Mean
						vdSub( Dim, &Data[i*Dim], &Mean[k*Dim], Work );

						// Generate element by element square
						vdSqr( Dim, Work, &Work[Dim] );

						daxpy( &Dim, &GMMPost[i], &Work[Dim], &inc, &Cov[k*Dim], &inc);
					}

					dscal(&Dim, &GTemp, &Cov[k*Dim], &inc);

					// Add small value to the diagonal
					for(i = 0; i < Dim; i++)
						Cov[k*Dim+i] = Cov[k*Dim+i] + 1e-5;

					delete [] GMMPost;

				}

				// Termination
				printf("Iter %d, Averaged -LogLik: %3.8f\n",EIter+1,NLL);
				mexEvalString("pause(.000001);");
				if(fabs(NLL-PLL) <= Thresh)
					break;
				PLL = NLL;
			}
		}
		break;
	}

	// ** Create and assign output variables
	double *Out;
	plhs[0] = mxCreateDoubleMatrix(1, NME ,mxREAL );
	plhs[1] = mxCreateDoubleMatrix(Dim, NME, mxREAL );
	plhs[2] = mxCreateNumericArray( CovINumDim, CovIDim,
			mxDOUBLE_CLASS, mxREAL);
	Out = mxGetPr(plhs[0]);
	memcpy(Out, Prior, NME*sizeof(double));
	Out = mxGetPr(plhs[1]);
	memcpy(Out, Mean, Dim*NME*sizeof(double));
	Out = mxGetPr(plhs[2]);
	if(Mode == 0)
		memcpy(Out, Cov, Dim*Dim*NME*sizeof(double));
	else if(Mode == 1)
		memcpy(Out, Cov, Dim*NME*sizeof(double));

	//** Delete dynamic variables
	delete [] Prior;
	delete [] Mean;
	delete [] Cov;
	delete [] InvCov;
	delete [] DetCov;
	delete [] GMMP;
	delete [] Work;
}

