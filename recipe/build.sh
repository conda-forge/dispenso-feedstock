#!/bin/bash

set -euxo pipefail

if [[ "${target_platform}" == osx-* ]]; then
  # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
  CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
  # Suppress C++20 extension warning for variadic macros in GoogleTest's TYPED_TEST_SUITE
  # when compiling with C++14. The macro requires a third argument but tests omit it.
  CXXFLAGS="${CXXFLAGS} -Wno-c++20-extensions"
fi

# Set the DISPENSO_BUILD_TESTS option based on the cross-compilation status.
# Dispenso uses gtest_discover_tests(), which invokes running tests during building.
# This can lead to segfaults when running osx-arm64 targets on osx during cross-compilation.
# Therefore, disable tests when cross-compilation is detected.
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" ]]; then
  DISPENSO_BUILD_TESTS=ON
else
  DISPENSO_BUILD_TESTS=OFF
fi

cmake $SRC_DIR \
  ${CMAKE_ARGS} \
  -G Ninja \
  -B build \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DDISPENSO_BUILD_TESTS=$DISPENSO_BUILD_TESTS

cmake --build build --parallel

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" ]]; then
  CTEST_ARGS=(--test-dir build --output-on-failure -LE flaky)
  if [[ "${target_platform}" == "osx-64" ]]; then
    CTEST_ARGS+=(-E "Timing\\.(StatisticalAccuracy|LongerDurationAccuracy)")
  fi
  ctest "${CTEST_ARGS[@]}"
fi

cmake --install build
