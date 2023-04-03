# MCDLのWRF環境をまとめたDOCKER
このディレクトリに存在するDockerfileは[WRF_DOCKER](https://github.com/NCAR/WRF_DOCKER)に私が普段使用している環境を模すために修正を加えたものです。<br>
詳細はリンク先を確認してください。

## DOCKERでWRFシミュレーションを回すまで、
このディレクトリにおいて、
```
docker   build   -t   wrf  .
```
でイメージを作成して、
```
mkdir OUTPUT
```
でコンテナを建てるディレクトリを用意したうえで、
```
docker run -it --name="wrf" --mount type=bind,source="$(pwd)"/work/,target=/wrf/work wrf /bin/bash
```
で実行する。実行するときに-mountオプションをつけることで、dockerの内外でのファイルのやり取りを容易にする。


## そのほかメモ 
1. wrfをconfigureするときの数字は34と1
2. sudoかできるようにしてある。また、パスワードはwrfuserである。

## 元祖WRF_DOCKERからの変更点
1. tcshではなくbashをターミナルに
2. centosはlatestではなく、7を指定
3. リンク切れのファイルを変更(複数)
4. チュートリアルデータの変更
5. docker runのオプションを-vではなく、-mountに変更
