#!/usr/bin/env bash

ABSPATH=$(readlink -f $0)
ABSDIR=$(dirname $ABSPATH) # 현재 stop.sh가 속해있는 경로를 찾음, profile.sh의 경로를 찾기 위해 사용됨.
source ${ABSDIR}/profile.sh # 자바의 import 개념임, 해당 코드로 stop.sh에서도 profile.sh의 funciton 사용 가능

function switch_proxy()
{
  IDLE_PORT=$(find_idle_port)

  echo "> 전환할 Port: $IDLE_PORT"
  echo "> Port 전환"
  # echo "set \$service_url http://127.0.0.1:${IDLE_PORT};" - 하나의 문장을 만들어 파이프라인(|)로 넘겨주기 위해 echo 사용
  # nginx가 변경할 프록시 주소 생성
  # 쌍따옴표(")를 사용해야하며, 그렇지 않은 경우 $service_url을 인식하지 못함.
  # | sudo tee /etc/nginx/conf.d/service-url.inc - 앞에서 넘겨준 문장을 service-url.inc에 덮어씀
  echo "set \$service_url http://127.0.0.1:${IDLE_PORT};" | sudo tee /etc/nginx/conf.d/service-url.inc
  echo "> nginx Reload"
  # nginx 설정을 다시 불러온다.
  # restart와 다르며, 잠시 끊기는 현상 발생, reload의 경우 끊김없이 다시 불러오지만 중요한 설정이 반영되지 않기때문에 restart 사용
  # 외부 설정 파일인 service-url.inc 파일을 다시 불러오는 것으로 reload 사용 가능함.
  sudo service nginx reload
}