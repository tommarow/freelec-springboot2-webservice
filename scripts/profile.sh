#!/usr/bin/env bash

# 쉬고 있는 profile 찾기: real1이 사용중이면 real2가 쉬고있고, 반대면 real1이 쉬고 있음.
function find_idle_profile()
{
  # 현재 nginx가 바라보고 있는 springboot가 정상적으로 수행중인지 확인
  # 응답값을 HttpStatus로 받음
  # 정상이면 200, 오류가 발생한다면 400~503 사이로 발생, 400 이상은 모두 예외로 판단, real2을 현재 profile로 사용

  RESPONSE_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/profile) #

  if [ ${RESPONSE_CODE} -ge 400 ] # 400 보다 크면(즉, 40x/50x 에러 모두 포함)
  then
    CURRENT_PROFILE=real2
  else
    CURRENT_PROFILE=$(curl -s http://localhost/profile)
  fi

  if [ ${CURRENT_PROFILE} == real1 ] # 400 보다 크면(즉, 40x/50x 에러 모두 포함)
    then
      IDLE_PROFILE=real2 # nginx와 연결되지 않은 profile, springboot 프로젝트를 이 profile로 연결하기 위해 반환
    else
      IDLE_PROFILE=real1
    fi

    # bash 스크립트에서는 값을 반환하지 않은, 마지막 결과를 echo로 출력, 클라이언트에서는 그 값을 잡아서 ($(find_idle_profile)) 사용
    # 따라서 중간에 echo를 사용하면 안됨.
    echo "${IDLE_PROFILE}"
}

# 쉬고 있는 profile의 port 찾기
function find_idle_port()
{
  IDLE_PROFILE=$(find_idle_profile)

  if [ ${IDLE_PROFILE} == real1 ]
  then
    echo "8081"
  else
    echo "8082"
  fi
}