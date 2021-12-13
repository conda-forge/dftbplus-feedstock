#!/usr/bin/env bash
set -ex

if [ "${mpi}" != "nompi" ]; then
  MPI=ON
else
  MPI=OFF
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
   "-DWITH_MBD=ON"
   "-GNinja"
   ..
)

mkdir -p _build
pushd _build

cmake "${cmake_options[@]}"
ninja all install

popd
