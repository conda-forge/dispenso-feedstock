#!/bin/bash

set -euxo pipefail

if [[ "${target_platform}" == osx-* ]]; then
  # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
  CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

if [[ "$(uname -a)" == *"Ubuntu"* ]]; then
  git apply ubuntu-prevent-double-free.patch
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
  ctest --test-dir build --output-on-failure -LE flaky
fi

cmake --build build --target install
