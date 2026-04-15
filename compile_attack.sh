
# here, "unoptim_clang12" is the CLANG compiler executable with standard SoftboundCETS protection; unoptimized by my analyses
./build/bin/unoptim_clang12 -g -O3 -c attack/uninstr.c -o attack/uninstr.o

./build/bin/unoptim_clang12 -g -O0 -fuse-ld=$(pwd)/build/bin/ld.lld -flto -Wl,-mllvm=-load=$(pwd)/build/lib/LLVMSoftBoundCETSLTO.so,--whole-archive,-L$(pwd)/build/lib/clang/12.0.1/lib/linux,-Bstatic,-lclang_rt.softboundcets-x86_64,-Bdynamic,--no-whole-archive -c attack/main.c -o attack/main.o

./build/bin/unoptim_clang12 -O0 -fuse-ld=$(pwd)/build/bin/ld.lld -flto -Wl,-mllvm=-load=$(pwd)/build/lib/LLVMSoftBoundCETSLTO.so,--whole-archive,-L$(pwd)/build/lib/clang/12.0.1/lib/linux,-Bstatic,-lclang_rt.softboundcets-x86_64,-Bdynamic,--no-whole-archive attack/uninstr.o attack/main.o -o attack/attack.exe


# $(pwd)/build/bin/clang