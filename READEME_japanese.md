# MCDLのWRF環境をまとめたDOCKER
このディレクトリに存在するDockerfileは[WRF_DOCKER](https://github.com/NCAR/WRF_DOCKER)に私が普段使用している環境を模すために修正を加えたものです。詳細はリンク先を確認してください。

## DOCKERでWRFシミュレーションを回すまで、
```
docker   build   -t   wrf_tutorial  .
```
でイメージを作成して、
```
mkdir OUTPUT
```
でコンテナを建てるディレクトリを用意したうえで、
```
docker   run   -it   --name   teachme   -v   `pwd`/OUTPUT:/wrf/wrfoutput   wrf_tutorial   /bin/tcsh
```
で実行する。