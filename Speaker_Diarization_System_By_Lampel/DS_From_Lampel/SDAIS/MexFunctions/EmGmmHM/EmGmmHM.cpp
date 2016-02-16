// USAGE: [PriorO MeanO CovO] = EMGMM(Data, PriorI, MeanI, CovI, Mode, MaxIter, ...
//                  Thresh)
// Generic EM-GMM algorithm
//
// INPUTS:
//     Data - D x N matrix of N data points of dimension D
//     PriorI - 1 x K vector of priors
//     MeanI - D x K matrix of means
//     CovI - D x D x K matrix of covariances
//     MinDur - minimum duration coefficient
//     Mode - full (0), diagonal(1), map(2) (when in map PriorI, MeanI and CovI 
//            contains the values from the ubm)
//     MaxIter - maximum number of iterations
//     Thresh - threshold termination condition
//
// OUTPUTS:
//     PriorO - K x 1 vector of priors
//     MeanO - K x D matrix of means
//     CovO - D x D x K array of covariance matrices


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
	printf("USAGE: [PriorO MeanO CovO] = EMGMM(Data, PriorI, MeanI, CovI, Mode, MaxIter, ...\n"
			"           Thresh)\n"
			"Generic EM-GMM algorithm\n"
			"\n"
			"INPUTS:\n"
			"   Data - \tD x N matrix of N data points of dimension D\n"
			"   PriorI - \t1 x K vector of priors\n"
			"   MeanI - \tD x K matrix of means\n"
			"   CovI - \tD x D x K matrix of covariances\n"
			"   MinDur - \tminimum duration coefficient\n"
			"   Mode - \tfull (0), diagonal(1), map(2) (when in map, PriorI, MeanI and CovI\n"
			"	       \tcontains the model for adaptation)\n"
			"   MaxIter - \tmaximum number of iterations\n"
			"   Thresh - \tthreshold termination condition\n"
			"\n"
			"OUTPUTS:\n"
			"   PriorO - \tK x 1 vector of priors\n"
			"   MeanO - \tK x D matrix of means\n"
			"   CovO - \tD x D x K array of covariance matrices\n");

}

/*
 * Print 2D matrices
 * iMat is a pointer to matrix
 * iRows and iCols are the number of rows and columns of iMat
 */
void print2DMat(const double *iMat, const int iRows, const int iCols){
	for(int i = 0; i < iRows; i++){
		for(int j = 0; j < iCols; j++){
			printf("%3.4f\t",iMat[i*iCols+j]);
		}
		printf("\n");
	}
	printf("\n\n");
};

/*
 * Convert a column major matrix into row major
 * iMat is a pointer to matrix
 * iRows and iCols are the number of rows and columns of iMat
 */
void ConvertToRowMajor( double *iMat, const int iRows, const int iCols){

	double *Temp; Temp = new double[iRows*iCols];
	memcpy(Temp,iMat,iRows*iCols*sizeof(double));

	for(int i = 0; i < iRows; i++)
		for(int j = 0; j < iCols; j++)
			iMat[j*iRows+i] = Temp[i*iCols+j];

	delete [] Temp;

}

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
 * Matrix in-place transposition
 * iMat is a pointer to an array of iRows rows and iCols columns
 */
void *MatTrans(void *iMat, int iRows, int iCols, size_t item_size)
{
#define ALIGNMENT 16    /* power of 2 >= minimum array boundary alignment; maybe unnecessary but machine dependent */

	char *cursor;
	char carry[ALIGNMENT];
	size_t block_size, remaining_size;
	int nadir, lag, orbit, ents;

	if (iRows == 1 || iCols == 1)
		return iMat;
	ents = iRows * iCols;
	cursor = (char *) iMat;
	remaining_size = item_size;
	while ((block_size = ALIGNMENT < remaining_size ? ALIGNMENT : remaining_size))
	{
		nadir = 1;                          /* first and last entries are always fixed points so aren't visited */
		while (nadir + 1 < ents)
		{
			memcpy(carry, &cursor[(lag = nadir) * item_size], block_size);
			while ((orbit = lag / iRows + iCols * (lag % iRows)) > nadir)             /* follow a complete cycle */
			{
				memcpy(&cursor[lag * item_size], &cursor[orbit * item_size], block_size);
				lag = orbit;
			}
			memcpy(&cursor[lag * item_size], carry, block_size);
			orbit = nadir++;
			while (orbit < nadir && nadir + 1 < ents)  /* find the next unvisited index by an exhaustive search */
			{
				orbit = nadir;
				while ((orbit = orbit / iRows + iCols * (orbit % iRows)) > nadir);
				if (orbit < nadir) nadir++;
			}
		}
		cursor += block_size;
		remaining_size -= block_size;
	}
	return iMat;
}

/*
 * Matrix and vector product
 * oVec = iAlpha * trans(iMat) * iVec + iBeta * oVec
 * trans is 'N' or 'T' for normal and transpose
 */
void MatVecProd(const char trans, const double *iMat, const double *iVec, double *oVec,
		const double iAlpha, const double iBeta, const int iMatRows, const
		int iMatCols){

	// MKL variables required for multiplication
	const double    alpha = iAlpha,
			beta = iBeta;
	const int inc = 1;

	dgemv(&trans, &iMatRows, &iMatCols, &alpha, iMat, &iMatRows,
			iVec, &inc, &beta, oVec, &inc);

}

/*
 * Matrix and matrix product
 * oVec = iAlpha * trans(iMatA) * trans(iMatB) + iBeta * oMat
 * transa and transb are 'N' or 'T' for normal and transpose
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
 * EM - E_Step
 * Calculates the likelihood of the data given the model and
 * generates the posterior probability
 */
void E_Step(const double *Data, const double* Prior,
		const double* Mean, const double* Cov, const double* InvCov,
		const double* DetCov, double *GMMP, double *GMME, const int Dim,
		const int ND, const int NME, double &NLL){

	const double *Vec = NULL;
	double VM[Dim];
	double TM[Dim];
	double QM[Dim];
	int i,j,k,index;
	double piconst = pow(6.2832,Dim),
			Norm = 0;
	int inc = 1;

	memset(GMMP, 0, ND*NME*sizeof(double));

#pragma omp parallel for shared(Data, Prior, Cov, Mean, InvCov, DetCov) private(i,j,k,VM,TM,QM, Vec, index)
	for(i = 0; i < ND; i++){
		for(j = 0; j < NME; j++){

			// Get data vector
			Vec = &Data[i*Dim];

			// Subtract mean from vector
			vdSub( Dim, Vec, &Mean[j*Dim], VM );

			// Multiply vector by inverse covariance
			MatVecProd('N',&InvCov[j*Dim*Dim], VM, TM, 1.0, 0.0, Dim, Dim);

			// Multiply vector by vector and sum
			vdMul( Dim, TM, VM, QM );

			// Sum result
			index = i*NME+j;
			for(k = 0; k < Dim; k++)
				GMMP[index]+=QM[k];

			// Exponentiate and multiply by prior
			GMMP[index] = Prior[j]*exp(-0.5*GMMP[index])/
					sqrt((piconst*(fabs(DetCov[j])+DBL_MIN)));

		}
	}

	// Normalize GMMP and calculate GMME
	NLL = 0;
	memset(GMME, 0, NME*sizeof(double));
	for(i = 0; i < ND; i++){
		index = i*NME;
		Norm = dasum(&NME, &GMMP[index], &inc);

		for(k = 0; k < NME; k++){
			if(GMMP[index+k] < DBL_MIN)
				GMMP[index+k] = DBL_MIN;
			NLL-=log(GMMP[index+k])/ND;
			GMMP[index+k]/=Norm;
			GMME[k]+=GMMP[index+k];
		}
	}
}

/*
 * EM - E_Step for diagonal covariance matrices
 * Calculates the likelihood of the data given the model and
 * generates the posterior probability
 */
void E_Step_Diag(const double *Data, const double* Prior,
		const double* Mean, const double* Cov, const double* InvCov,
		const double* DetCov, double *GMMP, double *GMME, const int Dim,
		const int ND, const int NME, double &NLL){

	const double *Vec = NULL;
	double VM[Dim];
	double TM[Dim];
	double QM[Dim];
	int i,j,k,index;
	double piconst = pow(6.2832,Dim),
			Norm = 0;
	int inc = 1;

	memset(GMMP, 0, ND*NME*sizeof(double));

	#pragma omp parallel for shared(Data, Prior, Cov, Mean, InvCov, DetCov) private(i,j,k,VM,TM,QM, Vec, index)
	for(i = 0; i < ND; i++){
		for(j = 0; j < NME; j++){

			// Get data vector
			Vec = &Data[i*Dim];

			// Subtract mean from vector
			vdSub( Dim, Vec, &Mean[j*Dim], VM );

			// Dot product VM and inverse covariance
			vdMul(Dim, &InvCov[j*Dim], VM, TM);

			// Multiply vector by vector and sum
			vdMul( Dim, TM, VM, QM );

			// Sum result
			index = i*NME+j;
			for(k = 0; k < Dim; k++)
				GMMP[index]+=QM[k];

			// Exponentiate and multiply by prior
			GMMP[index] = Prior[j]*exp(-0.5*GMMP[index])/
					sqrt((piconst*(fabs(DetCov[j])+DBL_MIN)));

		}
	}

	// Normalize GMMP and calculate GMME
	NLL = 0;
	memset(GMME, 0, NME*sizeof(double));
	for(i = 0; i < ND; i++){
		index = i*NME;
		Norm = dasum(&NME, &GMMP[index], &inc);

		for(k = 0; k < NME; k++){
			if(GMMP[index+k] < DBL_MIN)
				GMMP[index+k] = DBL_MIN;
			NLL-=log(GMMP[index+k])/ND;
			GMMP[index+k]/=Norm;
			GMME[k]+=GMMP[index+k];
		}
	}
}

/*
 * EM - M_Step
 * Optimizes model parameters
 */
void M_Step(const double *Data, double* Prior,
		double* Mean, double* Cov,
		double *GMMP, const double *GMME, const int Dim,
		const int ND, const int NME){

	// Update values
	int i,j,
		CInd = 0,
		Inc = 1,
		CDim = Dim*Dim;

	double 	TScale,
			Beta = 1,
			TempC[Dim];

#pragma omp parallel for shared(Data, Prior, Cov, Mean, GMMP, GMME, CDim) private(i,j, TScale, TempC, CInd)
	for(i = 0; i < NME; i++){

		TScale = 1/GMME[i];

		// Priors
		Prior[i] = GMME[i]/ND;

		// Means
		memset(&Mean[i*Dim], 0, Dim*sizeof(double));
		for(j = 0; j < ND; j++){
			daxpy(&Dim, &GMMP[j*NME+i], &Data[j*Dim], &Inc, &Mean[i*Dim], &Inc);
		}
		dscal(&Dim, &TScale, &Mean[i*Dim], &Inc);

		// Covariances
		CInd = i*Dim*Dim;
		memset(&Cov[CInd], 0, Dim*Dim*sizeof(double));
		for(j = 0; j < ND; j++){
			vdSub( Dim, &Data[j*Dim], &Mean[i*Dim], TempC );
			MatMatProd('N', 'N', GMMP[j*NME+i], Beta, TempC,
					TempC, &Cov[CInd], Dim, 1, 1, Dim,
					Dim, Dim);
		}
		dscal(&CDim, &TScale, &Cov[CInd], &Inc);

		// Add small value to covariance diagonal
		for(j = 1; j < Dim; j++)
			Cov[CInd+j*Dim+j] = Cov[CInd+j*Dim+j] + 1e-5;
	}

}


/*
 * EM - M_Step for diagonal covariances
 * Optimizes model parameters
 */
void M_Step_Diag(const double *Data, double* Prior,
		double* Mean, double* Cov,
		double *GMMP, const double *GMME, const int Dim,
		const int ND, const int NME){

	// Update values
	int i,j,
		Inc = 1;

	double 	TScale,
			TempC[Dim];

	#pragma omp parallel for shared(Data, Prior, Cov, Mean, GMMP, GMME ) private(i,j, TScale, TempC)
	for(i = 0; i < NME; i++){

		TScale = 1/GMME[i];

		// Priors
		Prior[i] = GMME[i]/ND;

		// Means
		memset(&Mean[i*Dim], 0, Dim*sizeof(double));
		for(j = 0; j < ND; j++){
			daxpy(&Dim, &GMMP[j*NME+i], &Data[j*Dim], &Inc, &Mean[i*Dim], &Inc);
		}
		dscal(&Dim, &TScale, &Mean[i*Dim], &Inc);

		// Covariances
		memset(&Cov[i*Dim], 0, Dim*sizeof(double));
		for(j = 0; j < ND; j++){
			vdSub( Dim, &Data[j*Dim], &Mean[i*Dim], TempC );

			// Square elements
			vdSqr(Dim, TempC, TempC);

			// Multiply by posterior and sum
			daxpy(&Dim, &GMMP[j*NME+i], TempC, &Inc, &Cov[i*Dim], &Inc );

		}
		dscal(&Dim, &TScale, &Cov[i*Dim], &Inc);

		// Add small value to covariance diagonal
		for(j = 1; j < Dim; j++)
			Cov[i*Dim+j] = Cov[i*Dim+j] + 1e-5;
	}

}



// -------------------------------  mexFunction ---------------------------------------//
void mexFunction( int nlhs, mxArray *plhs[],
		int nrhs, const mxArray *prhs[]) {

	/* Check for proper number of arguments */
	if(nrhs!=7) {
		Usage();
		mexErrMsgIdAndTxt("MyToolbox:arrayProduct:nrhs",
				"Seven inputs required.");
	}
	if(nlhs!=3) {
		Usage();
		mexErrMsgIdAndTxt("MyToolbox:arrayProduct:nlhs",
				"Three output required.");
	}

	// Input argument dimensions
	const mwSize 	DataR = mxGetM(prhs[0]),
					DataC = mxGetN(prhs[0]),
					PriorIR = mxGetM(prhs[1]),
					PriorIC = mxGetN(prhs[1]),
					MeanIR = mxGetM(prhs[2]),
					MeanIC = mxGetN(prhs[2]),
					*CovIDim = mxGetDimensions(prhs[3]),
					CovINumDim = mxGetNumberOfDimensions(prhs[3]);

	// Get data and dimensions
	const double 	*Data = mxGetPr(prhs[0]),
					*PriorI = mxGetPr(prhs[1]),
					*MeanI = mxGetPr(prhs[2]),
					*CovI = mxGetPr(prhs[3]);

	// Get parameters
	const double 	Mode = mxGetScalar(prhs[4]),
					MaxIter = mxGetScalar(prhs[5]),
					Thresh = mxGetScalar(prhs[6]);


	// Set the number of mixture elements, dimension and number of data points
	unsigned int 	NME = MeanIC	,
					ND = DataC,
					Dim = DataR;

	// Check appropriate sizes and modes
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

	// Data elements
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

	// ** EM parameters
	double 	*GMMP; GMMP = new double[ND*NME];
	double 	*GMME; GMME = new double[NME];
	double 	PLL = 0,
			NLL = 0;

	memcpy(Prior, PriorI, NME*sizeof(double));
	memcpy(Mean, MeanI, Dim*NME*sizeof(double));


	// ** Switch operation mode
	switch(int(Mode)){
	// Full covariance
	case 0:
		// ** Initialize EM algorithm
		for(int EIter = 0; EIter < MaxIter; EIter++){
			// Compute inverse and determinants of the covariance matrices
			invertCovMat( Cov, InvCov, Dim, NME );
			detCovMat( Cov, DetCov, Dim, NME );

			// E-step
			E_Step(Data, Prior, Mean, Cov, InvCov, DetCov, GMMP, GMME,
					Dim, ND, NME, NLL);

			// M-step
			M_Step(Data, Prior, Mean, Cov, GMMP, GMME, Dim, ND, NME);

			// Termination
			printf("Iter %d, -LogLik: %3.8f\n",EIter+1,NLL);
			mexEvalString("pause(.000001);");
			if(fabs(NLL-PLL) <= Thresh)
				break;
			PLL = NLL;
		}
		break;

		// Diagonal covariance
	case 1:
		// ** Initialize EM algorithm
		for(int EIter = 0; EIter < MaxIter; EIter++){

			// Compute inverse and determinants of the covariance matrices
			memset(InvCov, 0, Dim*NME*sizeof(double));
			for(unsigned int j = 0; j < NME; j++)
				DetCov[j] = 1;

			for(unsigned int i = 0; i < Dim; i++){
				for(unsigned int j = 0; j < NME; j++){
					DetCov[j] = DetCov[j] * Cov[j*Dim+i];
					InvCov[i*NME+j] = 1/Cov[i*NME+j];
				}
			}

			// E-step for diagonal covariance
			E_Step_Diag(Data, Prior, Mean, Cov, InvCov, DetCov, GMMP, GMME,
					Dim, ND, NME, NLL);

			// M-step for diagonal covariance
			M_Step_Diag(Data, Prior, Mean, Cov, GMMP, GMME, Dim, ND, NME);

			// Termination
			printf("Iter %d : LL %3.8f\n",EIter+1,NLL);
			mexEvalString("pause(.000001);");
			if(fabs(NLL-PLL) <= Thresh)
				break;
			PLL = NLL;
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
	delete [] GMME;
}

