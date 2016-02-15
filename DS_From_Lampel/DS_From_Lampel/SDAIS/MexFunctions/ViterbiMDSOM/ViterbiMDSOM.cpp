// USAGE: [VQT VDMin] = ViterbiMDSOM(TransMat, Features, Models, MinDur)
// This function calculates the Viterbi decoding of Features given Models,
// it solves the second problem of HMM giving the optimal state transition
// path
//
// INPUTS:
//     TransMat - S x S matrix of transition probabilities
//     Features - d x N matrix of observations
//     Models - d x M x S matrix of models
//     MinDur - minimum duration coefficient
//
// OUTPUTS:
//     VQT - 1 x N vector of states
//     VDMin - 1 x N vector of minimum distances

#include <stdio.h>
#include <time.h>
#include <math.h>
#include <string.h>
#include <limits.h>

#include "mex.h"

void mexFunction( int nlhs, mxArray *plhs[],
        int nrhs, const mxArray *prhs[]) {
    
    /* Check for proper number of arguments */
    if(nrhs!=5) {
        mexErrMsgIdAndTxt("MyToolbox:arrayProduct:nrhs",
                "Five inputs required.");
    }
    if(nlhs!=3) {
        mexErrMsgIdAndTxt("MyToolbox:arrayProduct:nlhs",
                "Three outputs required.");
    }
    
    /*Added code For recompiling in windows (Oren)*/
    const double DBL_MIN=1e-130;
	
    /* Get dimenstions */
    int     N = mxGetN(prhs[1]);
    const int *Dims;
    Dims = mxGetDimensions(prhs[2]);
    
    int     d = Dims[0],
            M = Dims[1],
            S = Dims[2];
    
    /* Get and set data and parameters */
    int     MinDur = mxGetScalar(prhs[3]),
            Counter = 0,
            i, j, k, l, MinI;
    double  *VAB,
            *VABB,
            *Features,
            *Models,
            *VQT,
            *VDMin,
            *Delta,
            *Zeta,
            *VPI,
            *VAA,
            *VB,
            *VTr,
            *DistMat,
            *DistVec,
            *VR,
            *VRM,
            *VRMI,
            *VPIP,
            Dist,
            Min;
    
    /* Inputs */
    VABB = mxGetPr(prhs[0]);
    Features = mxGetPr(prhs[1]);
    Models = mxGetPr(prhs[2]);
    VPIP = mxGetPr(prhs[3]);
    
    /* Outputs */
    plhs[0] = mxCreateDoubleMatrix(1, N, mxREAL);
    VQT = mxGetPr(plhs[0]);
    plhs[1] = mxCreateDoubleMatrix(1, N, mxREAL);
    VDMin = mxGetPr(plhs[1]);
    plhs[2] = mxCreateDoubleMatrix(S, N, mxREAL);
    VB = mxGetPr(plhs[2]);
    
    /* Dynamic memory */
    VPI = new double[S];
    VAA = new double[S*S];
    DistMat = new double[d*M];
    DistVec = new double[M];
    Delta = new double[S*N];
    Zeta = new double[S*N];
    VR = new double[S*S];
    VRM = new double[S];
    VRMI = new double[S];
    VAB = new double[S*S];
    
    /* Initialize initial state matrix */
    for( i = 0; i < S; i++ ){
        VPI[i] = VPIP[i];
    }
    
    /* Initialize default transition matrix */
    for(i = 0; i < S; i++){
        for(j = 0; j < S; j++){
            VAB[j*S+i] = log(VABB[j*S+i]);
            if(i == j){
                VAA[j*S+i] = log(1.0);
            }
            else{
                VAA[j*S+i] = log(DBL_MIN);
            }
        }
    }
    
    /* Initialize observation likelihood matrix */
    for(i = 0; i < S; i++){
        for(j = 0; j < N; j++){
            for(k = 0; k < d; k++){
                for(l = 0; l < M; l++){
                    DistMat[l*d+k] = Models[i*(d*M)+l*d+k] - Features[j*d+k];
                    DistVec[l] = 0;
                }
            }
            for(k = 0; k < d; k++){
                for(l = 0; l < M; l++){
                    DistVec[l] += DistMat[l*d+k]*DistMat[l*d+k];
                }
            }
            Min = DistVec[0];
            MinI = 0;
            for(l = 1; l < M; l++){
                if(DistVec[l] < Min){
                    Min = DistVec[l];
                    MinI = l;
                }
            }
            VB[j*S+i] = Min;
        }
    }
    
    /* Initialization */
    for(i = 0; i < S; i++){
        Delta[i] = VB[i] - log(VPI[i]);
    }
    
    /* Set transition matrix and counter */
    VTr = VAA;
    Counter = 1;
    
    /* Find Delta minimum */
    Min = Delta[0];
    MinI = 0;
    for(i = 1; i < S; i++){
        if(Delta[i] < Min){
            Min = Delta[i];
            MinI = i;
        }
    }
    
    for(i = 1; i <N; i++){
        /* Calculate Delta minus transmat log */
        for(j = 0; j < S; j++){
            for(k = 0; k < S; k++){
                VR[k*S+j] = Delta[(i-1)*S+j] - VTr[k*S+j];
            }
        }
        
        /* Find columns minimum */
        for(k = 0; k < S; k++){
            Min = VR[k*S];
            MinI = 0;
            for(j = 1; j < S; j++){
                if(VR[k*S+j] < Min){
                    Min = VR[k*S+j];
                    MinI = j;
                }
                VRM[k] = Min;
                VRMI[k] = (double)MinI;
            }
        }
        
        /* Assign Delta and Zeta */
        for( k = 0; k < S; k++){
            Delta[i*S+k] = VRM[k] + VB[i*S+k];
            Zeta[i*S+k] = VRMI[k];
        }
        
        
        if( Counter > MinDur){
            VTr = VAB;
            Counter = 1;
        }
        else{
            VTr = VAA;
            Counter++;
        }
    }
    
    

    /* Termination */
    Min = Delta[(N-1)*S];
    MinI = 0;
    for(k = 1; k < S; k++){
        if(Delta[(N-1)*S+k] < Min){
            Min = Delta[(N-1)*S+k];
            MinI = k;
        }
    }
    
    VQT[N-1] = (double)MinI;
    VDMin[N-1] = Min;
    
    /* Backtracking */
    for( k = N-2; k >=0; k--){
        j = (int) floor(VQT[k+1]);
        VQT[k] = Zeta[(k+1)*S+j];
    }
    
    /* Add one for MatLab interface */
    for( k = 0; k < N; k++){
        VQT[k]++;
    }
    
    
    /* Delete dynamic memory */
    delete [] VPI;
    delete [] VAA;
    delete [] Delta;
    delete [] Zeta;
    delete [] DistMat;
    delete [] DistVec;
    delete [] VR;
    delete [] VRM;
    delete [] VRMI;
    delete [] VAB;
    
}