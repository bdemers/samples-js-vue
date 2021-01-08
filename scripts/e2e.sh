#!/bin/bash -x

source ${OKTA_HOME}/${REPO}/scripts/setup.sh

setup_service xvfb start
setup_service java 1.8.222
setup_service google-chrome-stable 85.0.4183.102-1

yum -y install lsof

export TRAVIS=true
export DBUS_SESSION_BUS_ADDRESS=/dev/null

export TEST_SUITE_TYPE="junit"
export TEST_RESULT_FILE_DIR="${REPO}/build2/reports/junit"

export ISSUER=https://samples-javascript.okta.com/oauth2/default
export CLIENT_ID=0oapmwm72082GXal14x6
export USERNAME=george@acme.com
get_secret prod/okta-sdk-vars/password PASSWORD

cd ${OKTA_HOME}/${REPO}

function run_tests() {
  npm run pretest
  npm run test:okta-hosted-login
  kill -s TERM $(lsof -t -i:8080 -sTCP:LISTEN)
  kill -s TERM $(lsof -t -i:8000 -sTCP:LISTEN)
  npm run test:custom-login
}

if ! run_tests; then
  echo "e2e tests failed! Exiting..."
  report_results FAILURE publish_type_and_result_dir_but_always_fail
  exit 1
fi

echo ${TEST_SUITE_TYPE} > ${TEST_SUITE_TYPE_FILE}
echo ${TEST_RESULT_FILE_DIR} > ${TEST_RESULT_FILE_DIR_FILE}
exit ${PUBLISH_TYPE_AND_RESULT_DIR}
