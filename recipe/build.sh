#!/usr/bin/env bash
set -ex

if [ "${mpi}" != "nompi" ]; then
  MPI=ON
else
  MPI=OFF
fi

cmake_options=(
   "-GNinja"
   "-DCMAKE_BUILD_TYPE=Release"
   "-DCMAKE_INSTALL_PREFIX=${PREFIX}"
   "-DBUILD_SHARED_LIBS=ON"
   "-DLAPACK_LIBRARIES='lapack;blas'"
   "-DSCALAPACK_LIBRARIES='scalapack'"
   "-DWITH_API=ON"
   "-DWITH_SOCKETS=ON"
   "-DWITH_OMP=ON"
   "-DWITH_MPI=${MPI}"
   ".."
)

mkdir -p _build
pushd _build

cmake "${cmake_options[@]}"
ninja all install
