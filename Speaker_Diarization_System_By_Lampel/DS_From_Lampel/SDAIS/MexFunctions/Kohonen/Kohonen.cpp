// USAGE: [SOM WN]= Kohonen(Data, SOMI, LDU, Iters, EtaS ,EtaF, SigmaS , SigmaF )
// SOM training using the Kohonen algorithm
// At each iteration, a random data point is chosen, the closest unit
// is selected, and all of the units are moved toward the datapoint in
// proportion to their distance from the winner (in the low-dimensional
// space).  The 'proportion' is eta*exp(-d/2sigma^2).
//
// INPUTS:
//     Data - D x N matrix of N input vectors
//     SOMI - D x M matrix of neural units' preferred inputs
//     LDU - m x M matrix of neural units' low-dimensional coordinates
//     Iters - the number of iterations
//     EtaS & EtaF - the start & final values of eta
//     SigmaS & SigmaF - the start & final values of sigma
//
// OUTPUTS:
//     SOM - D x M A matrix of aligned neurons
//	   WN - 1 x M The number of times a neuron has won

#include <stdio.h>
#include <time.h>
#include <math.h>
#include <string.h>

#include "mex.h"
#include "mkl.h"

// Usage function
void Usage(){

	printf("USAGE: [SOM WN] = Kohonen(Data, SOMI, LDU, Iters, EtaS ,EtaF, SigmaS , SigmaF\n"
			"SOM training using the Kohonen algorithm\n"
			"At each iteration, a random data point is chosen, the closest unit\n"
			"is selected, and all of the units are moved toward the datapoint in\n"
			"proportion to their distance from the winner (in the low-dimensional\n"
			"space).  The 'proportion' is eta*exp(-d/2sigma^2).\n"
			"\n"
			"INPUTS:\n"
			"	Data - d x N matrix of N input vectors\n"
			"	SOMI - d x M matrix of neural units' preferred inputs\n"
			"   LDU - m x M matrix of neural units' low-dimensional coordinates\n"
			"   Iters - the number of iterations\n"
			"   EtaS & EtaF - the start & final values of eta\n"
			"	SigmaS & SigmaF - the start & final values of sigma\n"
			"\n"
			"OUTPUTS:\n"
			"   SOM - D x M A matrix of aligned neurons"
			"   WN - 1 x M The number of times a neuron has won");
}

void mexFunction( int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[]) {
    
    /* Initialize random seed */
    srand(time(NULL));
    
    /* Check for proper number of arguments */
    if(nrhs!=8) {
        mexErrMsgIdAndTxt("MyToolbox:arrayProduct:nrhs",
                "Eight inputs required.");
    }
    if(nlhs!=2) {
        mexErrMsgIdAndTxt("MyToolbox:arrayProduct:nlhs",
                "Two output required.");
    }
    
    /* Set parameters */
    int D = mxGetM(prhs[0]),
        N = mxGetN(prhs[0]),
        M = mxGetN(prhs[1]),
        m = mxGetM(prhs[2]),
        RandS = 0,
        j,
        inc = 1;
    
    int  Iters = (int) mxGetScalar(prhs[3]);
    
    double  EtaS = mxGetScalar(prhs[4]),
            EtaF = mxGetScalar(prhs[5]),
            SigmaS = mxGetScalar(prhs[6]),
            SigmaF = mxGetScalar(prhs[7]),
            DEta = (EtaS - EtaF)/Iters,
            DSigma = (SigmaS - SigmaF)/Iters,
            Sigma = SigmaS,
            Scale = 0,
            Eta = EtaS;
    
    /* Memory allocation */
    double  *Data,
            *SOMI,
            *SOM,
            *WN,
            *dSOM,
            *dSOMDist,
            *LDU,
            *dLDU,
            *dLDUDist,
            *Work = new double[D];
    
    Data = mxGetPr(prhs[0]);
    SOMI = mxGetPr(prhs[1]);
    LDU = mxGetPr(prhs[2]);
            
    SOM = new double[M*D];
    memcpy(SOM, SOMI, M*D*sizeof(double));
    WN = new double [M];
    memset(WN, 0, M*sizeof(double));
    dSOM = new double[M*D];
    dSOMDist = new double[M];
    dLDU = new double[M*m];
    dLDUDist = new double[M];
    

    /* Variables for the winner neuron */
    int MinI;
    
    /* Training loop */
    for(int iter = 0; iter < Iters; iter++){

        /* Select random sample */
        RandS = rand() % N;


        /* Compute model to sample diff */
        for(j = 0; j < M; j++){
        	vdSub( D, &Data[RandS*D], &SOM[j*D], &dSOM[j*D] );
        	vdSqr( D, &dSOM[j*D], Work );
        	dSOMDist[j] = dasum(&D, Work, &inc);
        }

        /* Find the winner neuron */
        MinI = idamin(&M, dSOMDist, &inc);

        /* Update the winner neuron count */
        WN[(MinI-1)]++;

        /* Compute low-dim vector from winner */
        for(j = 0; j < M; j++){

        	vdSub(m, &LDU[j*m], &LDU[(MinI-1)*m], &dLDU[j*m]);
        	vdSqr( m, &dLDU[j*m], &dLDU[j*m] );
        	dLDUDist[j] = dasum(&m, &dLDU[j*m], &inc);
        }

        /* Scale distance */
        Scale = -1/(2*Sigma*Sigma);
        dscal(&M, &Scale, dLDUDist, &inc);
        vdExp( M, dLDUDist, dLDUDist );

        /* Update SOM */
        for(j = 0; j < M; j++){
        	Scale = Eta*dLDUDist[j];
        	daxpy(&D, &Scale, &dSOM[j*D], &inc, &SOM[j*D], &inc);
        }


        /* Update learning coefficients */
        Eta = Eta - DEta;
        Sigma = Sigma - DSigma;
    }

    /* Copy to output */
    double *Out;
    plhs[0] = mxCreateDoubleMatrix(D,M,mxREAL);
    Out = mxGetPr(plhs[0]);
    memcpy(Out, SOM, D*M*sizeof(double));
    plhs[1] = mxCreateDoubleMatrix(1,M,mxREAL);
    Out = mxGetPr(plhs[1]);
    memcpy(Out, WN, M*sizeof(double));

    
    /* Delete dynamic memory */
    delete [] SOM;
    delete [] dSOM;
    delete [] dSOMDist;
    delete [] dLDU;
    delete [] dLDUDist;
    delete [] WN;
    delete [] Work;
    
}
