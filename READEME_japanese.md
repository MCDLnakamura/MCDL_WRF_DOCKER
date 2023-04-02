# MCDLのWRF環境をまとめたDOCKER
このディレクトリに存在するDockerfileは[WRF_DOCKER](https://github.com/NCAR/WRF_DOCKER)に私が普段使用している環境を模すために修正を加えたものです。詳細はリンク先を確認してください。

## DOCKERでWRFシミュレーションを回すまで、
```
docker   build   -t   wrf  .
```
でイメージを作成して、
```
mkdir OUTPUT
```
でコンテナを建てるディレクトリを用意したうえで、
```
docker   run \
    -it \
    --name="wrf" \
    --mount type=bind,source="$(pwd)"/OUTPUT/,target=/wrf/wrfout/ 
    wrf \
    /bin/bash
```
で実行する。

wrfをconfigureするときの数字は34と1

## 元祖WRF_DOCKERからの変更点
1. tcshではなくbashをターミナルに
2. centosはlatestではなく、7を指定
3. リンク切れのファイルを変更(複数)
4. チュートリアルデータの変更
