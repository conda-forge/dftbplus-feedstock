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
   #"-DWITH_TBLITE=ON"
   #"-DWITH_SDFTD3=ON"
   "-DWITH_MBD=ON"
   "-DWITH_PLUMED=ON"
   "-DWITH_CHIMES=ON"
   "-GNinja"
   ${cmake_mpi_options[@]}
   ..
)

mkdir -p _build
pushd _build

FFLAGS="-fno-backtrace" cmake "${cmake_options[@]}"
ninja all install

popd


if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == "1" ]]; then
  exit 0
fi

#
# Very quick test (< 10s) to check build sanity (checking most important components)
#

if [ "${mpi}" == "nompi" ]; then
  ctest_mpi_regexps=(
    'timedep/N2_onsite$'               # WITH_ARPACK
  )
else
  ctest_mpi_regexps=(
    'helical/C6H6_stack_ELPA$'         # WITH_ELSI
  )
  if [ "${mpi}" = "openmpi" ]; then
    export OMPI_MCA_plm=isolated
    export OMPI_MCA_btl_vader_single_copy_mechanism=none
    export OMPI_MCA_rmaps_base_oversubscribe=yes
  fi
fi

ctest_regexps=(
  'non-scc/Si_2$'
  'transport/CH4$'                     # WITH_TRANSPORT
  'xtb/gfn1_h2$'                       # WITH_TBLITE
  'dispersion/2H2O_dftd3_zero$'        # WITH_SDFTD3
  'dispersion/2C6H6_TS$'               # WITH_MBD
  'md/H3-plumed$'                      # WITH_PLUMED
  'chimes/CNOH$'                       # WITH_CHIMES
  ${ctest_mpi_regexps[@]}
)

./utils/get_opt_externals slakos
pushd _build
for ctest_regexp in ${ctest_regexps[@]}; do
  ctest -R "${ctest_regexp}"
done
popd
