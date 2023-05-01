# MCDLのWRF環境をまとめたDOCKER
このディレクトリに存在するDockerfileは[WRF_DOCKER](https://github.com/NCAR/WRF_DOCKER)に私が普段使用している環境を模すために修正を加えたものです。<br>
詳細はリンク先を確認してください。

## 1. コンテナの作成から起動まで
このディレクトリにおいて、
```
docker build -t wrf .
```
でイメージを作成して、
```
mkdir work
```
でファイルのやり取りをするディレクトリを用意したうえで、
```
docker run -itd --privileged -p 2222:22 --name wrf --mount type=bind,source="$(pwd)"/work/,target=/wrf/work wrf /sbin/init 
```
で実行する。<br>
-mountオプションをつけることで、dockerの内外でのファイルのやり取りを容易にする。<br>
-dオプションをつけるとバックグラウンドで実行する。

コンテナに入るには
```
docker exec -it wrf /bin/bash
```
でログインする。この場合にシェルを抜けるだけなら、exitでよい。

## 2. SSH接続の設定
現在の設定では最初のログインは`root`でするようにしてある。
`root`のパスワードは設定していないので、`passwd`コマンドを使って設定すること。
また、`wrfuser`において`sudo`でほぼ全てのコマンドが使えるので、SSH接続が必要ない場合は、作業自体はログイン後に`su wrfuser`で切り替える方法で良い。その場合この節は飛ばして構わない。<br>
SSH接続を使う場合はSSHサーバーを立ち上げる必要があるが、これが`root`でないと出来ない。SSHサーバーは
```
systemctl start sshd.service
```
で立ち上げることが出来る。これを行った場合、この後ホスト側のマシンから、
```
ssh -p 2222 wrfuser@localhost
```
でログインできるはずである。
また、`wrfuser`のパスワードも同様に`passed`コマンドを使って設定すること。<br>
今回はローカルの2222のポートを仮想環境の22のポートにポートフォワードしている。しかしながら、ホストマシンの2222のポートは恐らくデフォルトでは閉じているので、必要に応じてホストの2222のポートを開放する。

## 3. WRF, WRFDA, WPSのコンパイル
基本的に木下さんのマニュアルを参考にしてある。<br>
GUIにはまだ対応していないので、DomainWizardは別の場所で行うことを想定している。

コンテナにログインしたら、
```
cd /wrf/WRF
./configure
```
選択肢は、34と1を選択する。
```
./compile em_real 2>&1 |tee  compile.log
```
でコンパイルを行う。20分程かかる。

また、WRFDAについても同様に
```
cd /wrf/WRFDA
./configure wrfda
```
選択肢は、34を選択
```
./compile all_wrfvar 2>&1 |tee  compile.log
```
でコンパイルを行う。20分程かかる。<br>
```
ls -l var/build/*exe var/obsproc/src/obsproc.exe| wc -l
```
で44と出ればコンパイル成功である。

WPSのコンパイルも同様に
```
cd /wrf/WPS
./clean
./configure
```
選択肢は、4を選択する。<br>
この後、`vi /wrf/WPS/configure.wps`で
```
-L$(NETCDF)/lib  -lnetcdf
```
とある行を
```
-L$(NETCDF)/lib  -lnetcdff -lnetcdf
```
に変える。その後、
```
./compile 2>&1 | tee compile.log
```
でコンパイルを行う。2分ほどで終わる。<br>
`ls -ls *.exe`で`ungrib.exe`と`metgrid.exe`と`geogrid.exe`のリンクが見えれば成功である。


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
6. その他も多分あります
