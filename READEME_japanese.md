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
<!-- docker run -it -privileged -p 2222:22  --name="wrf" --mount type=bind,source="$(pwd)"/work/,target=/wrf/work  wrf /bin/bash -->
```
docker run -d -it --name="wrf" --mount type=bind,source="$(pwd)"/work/,target=/wrf/work wrf /bin/bash 
```
で実行する。<br>
-mountオプションをつけることで、dockerの内外でのファイルのやり取りを容易にする。<br>
-dオプションをつけるとバックグラウンドで実行する。
<!-- dockerのコンテナから抜けるときは
```
Ctrl+P ⇒ Ctrl ＋Q
```
である。 -->
コンテナに入るには
```
docker exec -it wrf /bin/bash
```
でログインする。この場合にシェルを抜けるだけなら、exitでよい。

### 参考
- https://qiita.com/TakahiroSakoda/items/5180ff9762ebddb0bd4d

## そのほかメモ 
1. wrfをconfigureするときの数字は34と1
2. sudoかできるようにしてある。また、パスワードはwrfuserである。


- sshでホストからログインする方法もファイルのやり取りには良さそう

## 元祖WRF_DOCKERからの変更点
1. tcshではなくbashをターミナルに
2. centosはlatestではなく、7を指定
3. リンク切れのファイルを変更(複数)
4. チュートリアルデータの変更
5. docker runのオプションを-vではなく、-mountに変更
