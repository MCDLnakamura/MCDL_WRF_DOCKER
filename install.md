## CentOS 7にdockerをインストールする

参考URL
- https://docs.docker.jp/engine/installation/linux/docker-ce/centos.html

古いdockerの削除
```
sudo yum remove docker docker-common docker-selinux docker-engine
```
リポジトリのセットアップ
```
sudo yum install -y yum-utils device-mapper-persistent-data lvm2
```
安定版(stable)リポジトリをセットアップ
```
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```
テスト版 リポジトリを無効にする
```
sudo yum-config-manager --disable docker-ce-edge
```
Docker CE の最新版をインストール
```
sudo yum install docker-ce
```
インストールが出来ていれば、
```
docker
```
と打てば、helpの説明が出てくる。<br>
この状態でDockerはインストールされるが、まだ起動はしていない。
起動及び実行だけであれば、
```
sudo systemctl start docker
```
ですることが出来る。
グループにdockerが追加されていますが、このグループにはまだユーザが存在していない状態であり、実行にはsudoもしくはこのグループに追加したメンバーがsgコマンドを使って実行しなければならない。<br>


## その他
イメージの保管場所を自分のディレクトリに変更
- https://vasteelab.com/2019/06/12/2019-06-12-143104/

現時点では導入していないが、一般ユーザーで実行する方法もあるらしい
- https://e-penguiner.com/rootless-docker-for-nonroot/