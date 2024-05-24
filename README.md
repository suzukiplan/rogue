# Rogue Like A.RPG Prototype (仮)

- VGS-Zero ソフト第2段
- ローグライク ARPG
- オールマシン語（Z80 アセンブリ言語）で VGS-Zero のゲームを開発したい方向けに知見共有する目的で OSS にしておきます

## How to Execute

### on the Steam

売れる水準のゲームが完成した場合は Steam で販売するかもしれません（未定）

### on the RaspberryPi Zero 2W

1. [./image](./image) ディレクトリ以下を micro SD カードへコピー
2. micro SD カードを RaspberryPi Zero 2W へ挿入
3. RaspberryPi Zero 2W へ USB ゲームパッドと電源を接続して起動

## How to Build

ビルドをすれば Linux (Ubuntu) のパソコン上で本ゲームを動かすことができます。

> - 本ゲームのビルド & テスト実行は __Linux (Ubuntu) で行うこと__ を前提としています。
> - macOS でのビルドであれば可能かもしれませんが、Windows でのビルドは大変かもしれません。

### Pre-requests

Linux での環境構築方法を記します。

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
