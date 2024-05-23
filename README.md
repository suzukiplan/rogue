# Rogue Police (仮)

- VGS-Zero ソフト第2段
- ローグライク ARPG
- オールマシン語（Z80 アセンブリ言語）で VGS-Zero のゲームを開発したい方向けに知見共有する目的で OSS にしておきます

## How to Build

### Pre-requests

Linux でビルドする場合の環境構築方法を記します

```
# apt をアップデート
sudo apt update

# ビルドツールをインストール
sudp apt install build-essential

# snapd をインストール (z88dk のインストールに必要)
sudo apt install snapd

# snap で z88dk をインストール
sudo snap install z88dk --beta
```

### Build and Execute

```
git clone git@github.com:suzukiplan/rogue.git
cd rogue
make
```

## License

- プログラム（[src](./src)）の部分流用などはご自由にどうぞ
- 本ゲーム（改造したゲームを含む）をそのまま再配布することはご遠慮ください
- 本プログラムの利用により発生したいかなる問題についても作者に責任を負う義務は無いものとします
