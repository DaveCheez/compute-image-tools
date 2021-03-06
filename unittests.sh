#!/usr/bin/env bash
# Copyright 2017 Google Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

GOCOVPATH=./artifacts/test-report.out
RET=0
go get -t ./...
for d in $(go list ./... | grep -v vendor); do
  echo "Running tests on ${d}."
  mkdir -p artifacts
  go test ${d} -race -coverprofile=profile.out -covermode=atomic -v 2>&1 > test.out
  PARTRET=$?
  echo "${d} test returned ${PARTRET}."
  if [ ${PARTRET} -ne 0 ]; then
    RET=${PARTRET}
  fi

  # Output test report.
  cat test.out | go-junit-report > artifacts/${d//\//_}_report.xml

  # Output coverage data.
  if [ -f profile.out ]; then
    cat profile.out >> $GOCOVPATH
    rm profile.out
  fi
done
exit $RET
