################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
CPP_SRCS += \
../EmGmm.cpp 

OBJS += \
./EmGmm.o 

CPP_DEPS += \
./EmGmm.d 


# Each subdirectory must supply rules for building sources it contributes
%.o: ../%.cpp
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ -DMATLAB_MEX_FILE -I/opt/matlab_2009b/extern/include -I/opt/intel/mkl/10.2.4.032/include -O3 -Wall -c -fmessage-length=0 -fPIC -fopenmp -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o"$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


