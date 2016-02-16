// USAGE: SOM = KohonenSR(Data, SOMI, LDU, Iters, EtaS ,EtaF , SigmaS , SigmaF )
// This function trains a Kohonen SOM using the training algorithm.
// At each iteration, a random datapoint is chosen, the closest unit
// is selected, and all of the units are moved toward the datapoint in
// proportion to their distance from the winner (in the low-dimensional
// space).  The 'proportion' is eta*exp(-d/2sigma^2).
//
// INPUTS:
//     Data - d x N matrix of input vectors
//     SOMI - d x M matrix of neural units' preferred inputs
//     LDU - m x M matrix of neural units' low-dimensional coordinates
//     Iters - the number of iterations
//     EtaS & EtaF - the start & final values of eta
//     SigmaS & SigmaF - the start & final values of sigma
//
// OUTPUTS:
//     SOM - A matrix of neurons describing the data

#include <stdio.h>
#include <time.h>
#include <math.h>
#include <string.h>

#include "mex.h"

void mexFunction( int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[]) {
    
    /* Initialize random seed */
    srand(time(NULL));
    
    /* Check for proper number of arguments */
    if(nrhs!=8) {
        mexErrMsgIdAndTxt("MyToolbox:arrayProduct:nrhs",
                "Eight inputs required.");
    }
    if(nlhs!=1) {
        mexErrMsgIdAndTxt("MyToolbox:arrayProduct:nlhs",
                "One output required.");
    }
    
    /* Set parameters */
    int d = mxGetM(prhs[0]),
        N = mxGetN(prhs[0]),
        M = mxGetN(prhs[1]),
        m = mxGetM(prhs[2]),
        RandS = 0,
        i, j, k, l,
        TI1, TI2;
    
    int  Iters = (int) mxGetScalar(prhs[3]);
    
    double  EtaS = mxGetScalar(prhs[4]),
            EtaF = mxGetScalar(prhs[5]),
            SigmaS = mxGetScalar(prhs[6]),
            SigmaF = mxGetScalar(prhs[7]),
            DEta = (EtaS - EtaF)/Iters,
            DSigma = (SigmaS - SigmaF)/Iters,
            Sigma = SigmaS,
            SigmaSquared = 0,
            Eta = EtaS;
    
    /* Memory allocation */
    double  *Data,
            *SOMI,
            *SOM,
            *dSOM,
            *dSOMDist,
            *LDU,
            *dLDU,
            *dLDUDist;
    
    Data = mxGetPr(prhs[0]);
    SOMI = mxGetPr(prhs[1]);
    LDU = mxGetPr(prhs[2]);
            
    SOM = new double[d*M];
    memcpy(SOM, SOMI, d*M*sizeof(double));
    dSOM = new double[d*M];
    dSOMDist = new double [M];
    dLDU = new double [m*M];
    dLDUDist = new double [M];
    
    /* Variables for the winner neuron */
    double Min;
    int MinI;
    
    /* Training loop */
    for(int iter = 0; iter < Iters; iter++){
        /* Select random sample */
        RandS = rand() % N;
        
        /* Compute model to sample diff */
        for(i = 0; i < d; i++){
            for(j = 0; j < M; j++){
                TI1 = j*d+i;
                dSOM[TI1] = Data[RandS*d+i] - SOM[TI1];
            }
        }
        
        /* Compute distance vector */
        for(j = 0; j < M; j++){
            dSOMDist[j] = 0;
        }
        
        for(i = 0; i < d; i++){
            for(j = 0; j < M; j++){
                TI1 = j*d+i;
                dSOMDist[j] += (dSOM[TI1] * dSOM[TI1]);
            }
        }
        
        for(j = 0; j < M; j++){
            dSOMDist[j] = sqrt(dSOMDist[j]);
        }
        
        /* Find the winner neuron */
        Min = dSOMDist[0];
        MinI = 0;
        
        for(j = 1; j < M; j++){
            if(dSOMDist[j] < Min){
                Min = dSOMDist[j];
                MinI = j;
            }
        }
        
        /* Compute low-dim vector from winner */
        for(i = 0; i < m; i++){
            for(j = 0; j < M; j++){
                TI1 = j*m+i;
                dLDU[TI1] = LDU[TI1] - LDU[MinI*m+i];
            }
        }
        
        /* Compute distance vector */
        for(j = 0; j < M; j++){
            dLDUDist[j] = 0;
        }
        
        for(i = 0; i < m; i++){
            for(j = 0; j < M; j++){
                TI1 = j*m+i;
                dLDUDist[j] += (dLDU[TI1] * dLDU[TI1]);
            }
        }
        
        SigmaSquared = 2*Sigma*Sigma;
        for(j = 0; j < M; j++){
            dLDUDist[j] = exp(-dLDUDist[j]/(SigmaSquared));
        }
        
        /* Update SOM */
        for(i = 0; i < d; i++){
            for(j = 0; j < M; j++){
                TI1 = j*d+i;
                SOM[TI1] += Eta * dLDUDist[j] * dSOM[TI1];
            }
        }
        
        /* Update learning coefficients */
        Eta = Eta - DEta;
        Sigma = Sigma - DSigma;

    }
      
    /* Copy to output */   
    double *Out;
    plhs[0] = mxCreateDoubleMatrix(d,M,mxREAL);
    Out = mxGetPr(plhs[0]);
    for(i = 0; i < d; i++){
        for(j = 0; j < M; j++){
            Out[j*d+i] = SOM[j*d+i];
        }
    }
    
    /* Delete dynamic memory */
    delete [] SOM;
    delete [] dSOM;
    delete [] dSOMDist;
    delete [] dLDU;
    delete [] dLDUDist;
    
}