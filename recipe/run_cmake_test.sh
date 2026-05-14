#!/bin/bash

set -euxo pipefail

test -f "${PREFIX}"/lib/cmake/Dispenso-*/DispensoConfig.cmake

cmake tests \
  ${CMAKE_ARGS:-} \
  -G Ninja \
  -B tests/build \
  -DCMAKE_BUILD_TYPE=Release

cmake --build tests/build --parallel

./tests/build/dispenso_consumer_test
