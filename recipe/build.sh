#!/usr/bin/env bash
set -ex

if [ "${mpi}" != "nompi" ]; then
  MPI=ON
  cmake_mpi_options=(
    "-DWITH_ELSI=ON"
    "-DWITH_ARPACK=OFF"
  )
else
  MPI=OFF
  cmake_mpi_options=(
    "-DWITH_ELSI=OFF"
    "-DWITH_ARPACK=ON"
  )
fi

cmake_options=(
   ${CMAKE_ARGS}
   "-DLAPACK_LIBRARY='lapack;blas'"
   "-DSCALAPACK_LIBRARY='scalapack'"
   "-DHYBRID_CONFIG_METHODS='Find;PkgConf'"
   "-DBUILD_SHARED_LIBS=ON"
   "-DWITH_PYTHON=OFF"
   "-DWITH_API=ON"
   "-DWITH_SOCKETS=ON"
   "-DWITH_OMP=ON"
   "-DWITH_MPI=${MPI}"
   "-DWITH_TRANSPORT=ON"
   "-DWITH_TBLITE=OFF"
   "-DWITH_SDFTD3=ON"
   "-DWITH_MBD=ON"
   "-DWITH_PLUMED=ON"
   "-DWITH_CHIMES=OFF"
   "-GNinja"
   ${cmake_mpi_options}
   ..
)

mkdir -p _build
pushd _build

FFLAGS="-fno-backtrace" cmake "${cmake_options[@]}"
ninja all install

popd
