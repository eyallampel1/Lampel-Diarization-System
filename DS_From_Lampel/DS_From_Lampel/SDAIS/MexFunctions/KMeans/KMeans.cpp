// USAGE: [AssignO MeanO PriorO CovO] = KMeans(Data, MeanI, MaxIter, Thresh, Verbose)
// Generic K-Means algorithm
//
// INPUTS:
//     Data - D x N matrix of N data points of dimension D
//     MeanI - D x K matrix of means
//     MaxIter - maximum number of iterations
//     Thresh - threshold termination condition
//	   Verbose - (0,1) verbosity
//
// OUTPUTS:
//	   AssignO - 1 x N vector of assignment
//     MeanO - K x D matrix of means
//     PriorO - K x 1 vector of priors
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
	printf("USAGE: [PriorO MeanO CovO] = EMGMM(Data, PriorI, MeanI, CovI, Mode, MaxIter, Thresh)\n"
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
			"   Verbose - \t(0,1) verbosity\n"
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
void Print2DMat(const double *iMat, const int iRows, const int iCols){
	for(int i = 0; i < iRows; i++){
		for(int j = 0; j < iCols; j++){
			printf("%3.4f\t",iMat[i*iCols+j]);
		}
		printf("\n");
	}
	printf("\n\n");
};

// -------------------------------  mexFunction ---------------------------------------//
void mexFunction( int nlhs, mxArray *plhs[],
		int nrhs, const mxArray *prhs[]) {

	/* Check for proper number of arguments */
	if(nrhs!=5) {
		Usage();
		mexErrMsgIdAndTxt("MyToolbox:arrayProduct:nrhs",
				"Five inputs required.");
	}
	if(nlhs!=4) {
		Usage();
		mexErrMsgIdAndTxt("MyToolbox:arrayProduct:nlhs",
				"Four output required.");
	}

	// Input argument and dimensions
	const mwSize 	DataR = mxGetM(prhs[0]),
					DataC = mxGetN(prhs[0]),
					MeanIR = mxGetM(prhs[1]),
					MeanIC = mxGetN(prhs[1]);
	const double 	*Data = mxGetPr(prhs[0]),
					*MeanI = mxGetPr(prhs[1]);
	const double 	MaxIter = mxGetScalar(prhs[2]),
					Thresh = mxGetScalar(prhs[3]);
	const int 		Verbose = (int) mxGetScalar(prhs[4]);


	// Set the number of means elements, dimension and number of data points
	int 	NM = MeanIC,
			ND = DataC,
			Dim = DataR;

	// Check appropriate sizes and modes
	if( Dim != MeanIR ) {
		Usage();
		mexErrMsgIdAndTxt("KMeans:Means","Means matrix dimension");
	}

	// Data elements
	double 	*Prior = NULL,
			*Mean = NULL,
			*Cov = NULL,
			*Assign;

	// ** KM parameters
	double	*SqrTemp = new double[Dim];
	double  *DistTemp = new double[NM];
	double	alpha = 1,
			beta = 1,
			Scale = 0;
	double  Term, TermP = 0;
	int     AssignTemp;
	int		*AssignNum; AssignNum = new int[NM];
	mwSize	CSize[] = {Dim,Dim,NM};
	int     CNumSize = 3;
	int 	i,k,j;
	int		inc = 1;
	int 	index = 0;

	Assign = new double[ND];
	Prior = new double[NM];
	Mean = new double[Dim*NM];
	Cov = new double[Dim*Dim*NM];

	memcpy(Mean, MeanI, Dim*NM*sizeof(double));

	for(int E = 0; E < MaxIter; E++){

		// ** Assign features to each center
#pragma omp parallel for shared(Data, Mean, Dim, inc, Assign) private(i,j, SqrTemp, DistTemp, AssignTemp)
		for(i = 0; i < ND; i++){
			for(j = 0; j < NM; j++){

				// Calculate elements of Data-Mean
				vdSub( Dim, &Data[i*Dim], &Mean[j*Dim], SqrTemp );

				// Square elements
				vdSqr( Dim, SqrTemp, SqrTemp );

				// Sum distances
				DistTemp[j] = dasum( &Dim, SqrTemp, &inc);
			}

			// Find minimum distance index
			AssignTemp = idamin(&NM, DistTemp, &inc);

			Assign[i] = double(AssignTemp-1);
		}

		// ** Calculate new center values
		// Zero out centers
		memset(Mean, 0, Dim*NM*sizeof(double));
		memset(AssignNum, 0, NM*sizeof(int));

		for(i = 0; i < ND; i++){
			index = Assign[i];
			daxpy(&Dim, &alpha, &Data[i*Dim], &inc, &Mean[index*Dim], &inc);
			AssignNum[index] = AssignNum[index] + 1;
		}

		for(i = 0; i < NM; i++){

			// If no point was assigned to an average, assign a different point
			if(AssignNum[i] == 0){
				memcpy(&Mean[i*Dim], &Data[(rand()%ND)*Dim], Dim*sizeof(double));
				Scale = 1;
				dscal(&Dim, &Scale, &Mean[i*Dim], &inc);
			}
			else{
				Scale = 1 / double(AssignNum[i]);
				dscal(&Dim, &Scale, &Mean[i*Dim], &inc);
			}
		}

		// Termination conditions
		k = Dim*NM;
		Term = dasum(&k, Mean, &inc);

		if(Verbose == 1){
			printf("Iteration %d - Shift %3.9f\n",E, fabs(Term-TermP));
			mexEvalString("pause(.000001);");
		}

		if(fabs(Term-TermP) <= Thresh)
			break;

		TermP = Term;
	}


	// ** Create and assign output variables
	double *Out;
	plhs[0] = mxCreateDoubleMatrix(1, ND ,mxREAL );
	plhs[1] = mxCreateDoubleMatrix(Dim, NM, mxREAL );
	plhs[2] = mxCreateDoubleMatrix(1, NM, mxREAL );
	plhs[3] = mxCreateNumericArray( CNumSize, CSize,
			mxDOUBLE_CLASS, mxREAL);

	// Priors
	k = 0;
	for(i = 0; i < NM; i++ )
		k = k + AssignNum[i];

	for(i = 0; i < NM; i++){
		Prior[i] = double(AssignNum[i])/k;
	}

	// Covariances
	memset(Cov, 0, Dim*Dim*NM*sizeof(double));
	char trans = 'N';
	k = 1;
	for(i = 0; i < ND; i++){

		index = Assign[i];
		Scale = 1/(Prior[index]*ND);

		// Calculate elements of Data-Mean
		vdSub( Dim, &Data[i*Dim], &Mean[index*Dim], SqrTemp );

		// covariance
		dgemm(&trans, &trans, &Dim, &Dim, &k, &Scale, SqrTemp, &Dim, SqrTemp,
				&k, &beta, &Cov[index*Dim*Dim], &Dim);

	}

	Out = mxGetPr(plhs[0]);
	memcpy(Out, Assign, ND*sizeof(double));
	Out = mxGetPr(plhs[1]);
	memcpy(Out, Mean, Dim*NM*sizeof(double));
	Out = mxGetPr(plhs[2]);
	memcpy(Out, Prior, NM*sizeof(double));
	Out = mxGetPr(plhs[3]);
	memcpy(Out, Cov, Dim*Dim*NM*sizeof(double));

	//** Delete dynamic variables
	delete [] Prior;
	delete [] Mean;
	delete [] Cov;
	delete [] Assign;
	delete [] AssignNum;

}

