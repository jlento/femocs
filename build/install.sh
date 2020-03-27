#!/bin/bash
# Compile Femocs compilation and linking flags under different machines

source ./build/makefile.defs

## Optimization and warnings
OPT="-O3 -w"
OPT_DBG="-g -Og -Wall -Wpedantic -Wno-unused-local-typedefs"

## Paths to headers
HEADPATH_ALL="-Iinclude -Ilib -Idealii/include -IGETELEC/modules -std=c++11"
HEADPATH_UBUNTU=""
HEADPATH_PUHTI=""
HEADPATH_ALCYONE="-I/share/intel/composer_xe_2013.1.117/tbb/include"
HEADPATH_CGAL="-DUSE_CGAL=true -Icgal/include"

## Paths to incorporated libraries
LIBPATH_ALL="-Llib -LGETELEC/lib -Ldealii/lib"
LIBPATH_CGAL="-Lcgal/lib/x86_64-linux-gnu -Lcgal/lib64"

## Incorporated libraries
LIB_ALL="-ltet -ldeal_II -lgetelec -lslatec -fopenmp"
LIB_UBUNTU="-ltbb -llapack -lz -lm -lstdc++ -lgfortran"
LIB_PUHTI="-lz -lm -lstdc++ -lgfortran"
LIB_ALCYONE="-llapack -lz -lm -lstdc++ -lgfortran"
LIB_CGAL="-lCGAL"

## Name of Femocs library
LIB_FEMOCS="-lfemocs"

## Flags for Tetgen
TETGEN_FLAGS="-DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX\
 -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY=../../lib"

## Flags for Deal.II
DEALII_FLAGS="-DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX\
 -DDEAL_II_WITH_NETCDF=OFF -DDEAL_II_STATIC_EXECUTABLE=ON\
 -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=../.."

DEALII_FLAGS_PUHTI="-DDEAL_II_WITH_THREADS=OFF"

## Flags for CGAL
CGAL_FLAGS="-DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX\
 -DBUILD_SHARED_LIBS=FALSE -DCMAKE_INSTALL_PREFIX=../.."

CGAL_FLAGS_PUHTI="\
 -DBoost_NO_BOOST_CMAKE=TRUE\
 -DBOOST_ROOT=$BOOST_INSTALL_ROOT\
 -DGMP_LIBRARIES_DIR=/appl/spack/install-tree/gcc-9.1.0/gmp-6.1.2-wiqe4d/lib\
 -DGMP_INCLUDE_DIR=/appl/spack/install-tree/gcc-9.1.0/gmp-6.1.2-wiqe4d/include\
 -DMPFR_LIBRARIES_DIR=/appl/spack/install-tree/gcc-9.1.0/mpfr-4.0.1-px7373/lib\
 -DMPFR_INCLUDE_DIR=/appl/spack/install-tree/gcc-9.1.0/mpfr-4.0.1-px7373/include\
 -DGMP_LIBRARIES=/appl/spack/install-tree/gcc-9.1.0/gmp-6.1.2-wiqe4d/lib/libgmp.so\
 -DMPFR_LIBRARIES=/appl/spack/install-tree/gcc-9.1.0/mpfr-4.0.1-px7373/lib/libmpfr.so"


mode=$1

write_initial_flags () {
    rm -rf share/makefile.femocs
    cp build/makefile.empty share/makefile.femocs

    sed -i "/^FEMOCS_OPT=/ s|$|$OPT |" share/makefile.femocs
    sed -i "/^FEMOCS_DOPT=/ s|$|$OPT_DBG |" share/makefile.femocs

    sed -i "/^FEMOCS_HEADPATH=/ s|$|$HEADPATH_ALL |" share/makefile.femocs
    sed -i "/^FEMOCS_LIBPATH=/ s|$|$LIBPATH_ALL |" share/makefile.femocs

    sed -i "/^FEMOCS_LIB=/ s|$|$LIB_FEMOCS |" share/makefile.femocs
    sed -i "/^FEMOCS_LIB=/ s|$|$LIB_ALL |" share/makefile.femocs

    sed -i "/^FEMOCS_DLIB=/ s|$|$LIB_FEMOCS |" share/makefile.femocs
    sed -i "/^FEMOCS_DLIB=/ s|$|$LIB_ALL |" share/makefile.femocs

    sed -i "/^TETGEN_FLAGS=/ s|$|$TETGEN_FLAGS |" share/makefile.femocs
    sed -i "/^DEALII_FLAGS=/ s|$|$DEALII_FLAGS |" share/makefile.femocs
    sed -i "/^CGAL_FLAGS=/ s|$|$CGAL_FLAGS |" share/makefile.femocs
}

print_all() { 
    grep "FEMOCS_OPT=" share/makefile.femocs
    grep "FEMOCS_DOPT=" share/makefile.femocs
    grep "FEMOCS_HEADPATH=" share/makefile.femocs
    grep "FEMOCS_LIBPATH=" share/makefile.femocs
    grep "FEMOCS_LIB=" share/makefile.femocs
    grep "FEMOCS_DLIB=" share/makefile.femocs
    grep "TETGEN_FLAGS=" share/makefile.femocs
    grep "DEALII_FLAGS=" share/makefile.femocs
    grep "CGAL_FLAGS=" share/makefile.femocs
    grep "MACHINE=" share/makefile.femocs
}

if (test $mode = ubuntu) then
    if [ ! -f share/makefile.femocs ]; then
        echo "Checking Ubuntu dependencies"
        mkdir -p share/.build && rm -rf share/.build/*
        cd share/.build && cmake .. -Dmachine=ubuntu && cd ../..
        echo "All Femocs external dependencies found"
    fi

    echo -e "\nWriting Ubuntu flags"
    write_initial_flags
    
    sed -i "/^FEMOCS_HEADPATH=/ s|=|=$HEADPATH_UBUNTU |" share/makefile.femocs
    sed -i "/^FEMOCS_LIB=/ s|$|$LIB_UBUNTU |" share/makefile.femocs
    sed -i "/^FEMOCS_DLIB=/ s|$|$LIB_UBUNTU |" share/makefile.femocs
    
    sed -i "/MACHINE=/c\MACHINE=ubuntu" share/makefile.femocs
        
    print_all
    
    echo -e "\nInstalling Femocs dependencies"
    make -f build/makefile.install
fi

if (test $mode = puhti) then
    echo "Loading Puhti modules"
    module load gcc/9.1.0 hpcx-mpi/2.4.0 intel-mkl/2019.0.4 boost/1.68.0

    echo -e "\nWriting Puhti flags"
    write_initial_flags

    sed -i "/^FEMOCS_HEADPATH=/ s|=|=$HEADPATH_PUHTI |" share/makefile.femocs
    sed -i "/^FEMOCS_LIB=/ s|$|$LIB_PUHTI |" share/makefile.femocs
    sed -i "/^FEMOCS_DLIB=/ s|$|$LIB_PUHTI |" share/makefile.femocs

    sed -i "/^DEALII_FLAGS=/ s|=|=$DEALII_FLAGS_PUHTI |" share/makefile.femocs
    sed -i "/^CGAL_FLAGS=/ s|=|=$CGAL_FLAGS_PUHTI |" share/makefile.femocs

    sed -i "/MACHINE=/c\MACHINE=puhti" share/makefile.femocs

    print_all

    echo -e "\nInstalling Femocs dependencies"
    make -f build/makefile.install
fi

if (test $mode = alcyone) then
    echo "Loading Alcyone modules"
    module load PrgEnv-gnu gcc/5.1.0

    echo -e "\nWriting Alcyone flags"
    write_initial_flags

    sed -i "/^FEMOCS_HEADPATH=/ s|=|=$HEADPATH_ALCYONE |" share/makefile.femocs
    sed -i "/^FEMOCS_LIB=/ s|$|$LIB_ALCYONE |" share/makefile.femocs
    sed -i "/^FEMOCS_DLIB=/ s|$|$LIB_ALCYONE |" share/makefile.femocs

    sed -i "/MACHINE=/c\MACHINE=alcyone" share/makefile.femocs

    print_all

    echo -e "\nInstalling Femocs dependencies"
    make -f build/makefile.install
fi

if (test $mode = cgal) then
    echo "Adding CGAL flags"

    sed -i "/^FEMOCS_HEADPATH=/ s|=|=$HEADPATH_CGAL |" share/makefile.femocs
    sed -i "/^FEMOCS_LIBPATH=/ s|$|$LIBPATH_CGAL |" share/makefile.femocs
    sed -i "/^FEMOCS_LIB=/ s|=|=$LIB_CGAL |" share/makefile.femocs
    sed -i "/^FEMOCS_DLIB=/ s|=|=$LIB_CGAL |" share/makefile.femocs

    sed -i "/LIBCGAL=/c\LIBCGAL=1" share/makefile.femocs

    print_all
    grep "LIBCGAL=" share/makefile.femocs
    
    machine=$( grep "MACHINE=" share/makefile.femocs | sed "s|MACHINE=||" )       
    echo -e "\nInstalling CGAL in "$machine
    if (test $machine = puhti) then
        make -s -f build/makefile.cgal puhti
    else
        make -f build/makefile.cgal
    fi
fi

if (test $mode = no-cgal) then
    echo "Removing CGAL flags"

    sed -i -- "s|$HEADPATH_CGAL ||g" share/makefile.femocs
    sed -i -- "s|$LIBPATH_CGAL ||g" share/makefile.femocs
    sed -i -- "s|$LIB_CGAL ||g" share/makefile.femocs

    sed -i "/LIBCGAL=/c\LIBCGAL=" share/makefile.femocs

    print_all
    grep "LIBCGAL=" share/makefile.femocs
fi
