#!/usr/bin/env bash

ABSPATH=$(readlink -f $0)
ABSDIR=$(dirname $ABSPATH) # 현재 stop.sh가 속해있는 경로를 찾음, profile.sh의 경로를 찾기 위해 사용됨.
source ${ABSDIR}/profile.sh # 자바의 import 개념임, 해당 코드로 stop.sh에서도 profile.sh의 funciton 사용 가능
source ${ABSDIR}/switch.sh

IDLE_PORT=$(find_idle_port)

echo "> Health Check Start!"
echo "> IDLE_PORT: $IDLE_PORT"
echo "> curl -s http://localhost:$IDLE_PORT/profile"
sleep 10

for RETRY_COUNT in {1..10}
do
  RESPONSE=$(curl -s http://localhost:${IDLE_PORT}/profile)
  UP_COUNT=$(echo ${RESPONSE} | grep 'real' | wc -l)

  # nginx와 연결되지 않은 포트로 springboot가 잘 수행되었는지 체크
  if [ ${UP_COUNT} -ge 1 ]
  then # $UP_COUNT >= 1 ("real" 문자열이 있는지 검증)
    echo "> Health check 성공"
    switch_proxy # 성공시 nginx 프록시 설정을 변경함.
    break
  else
    echo "> Health check의 응답을 알 수 없거나 혹은 실행 상태가 아닙니다."
    echo "> Health check: ${RESPONSE}"
  fi

  if [ ${RETRY_COUNT} -eq 10 ]
  then #
    echo "> Health check 실패"
    echo "> nginx에 연결하지 않고 배포를 종료합니다."
    exit 1
  fi

  echo "> Health check 연결 실패. 재시도..."
  sleep 10
done