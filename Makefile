SOURCE = src/*.asm
MAKEROM = ./vgszero/tools/makerom/makerom
MAKEPKG = ./vgszero/tools/makepkg/makepkg
BMP2CHR = ./vgszero/tools/bmp2chr/bmp2chr
EMU = ./vgszero/src/sdl2/vgs0

all: tools_build image/game.pkg ${EMU}
	${EMU} image/game.pkg

clean:
	rm -f *.tmp
	rm -f *.bin
	rm -f *.chr
	rm -f *.rom

tools_build:
	cd ./vgszero/tools/makerom && make
	cd ./vgszero/tools/makepkg && make
	cd ./vgszero/tools/bmp2chr && make
	cd tools && make

image/game.pkg: program.rom
	${MAKEPKG} -o $@ -r program.rom

program.rom: font.chr player.chr actbl.bin program.bin
	${MAKEROM} program.rom program.bin actbl.bin palette.bin font.chr player.chr

program.bin: ${SOURCE}
	z80asm -b src/main.asm -oprogram.bin.tmp
	dd bs=32768 conv=sync if=program.bin.tmp of=program.bin

actbl.bin: src/actbl.asm
	z80asm -b src/actbl.asm -oactbl.bin.tmp
	dd bs=8192 conv=sync if=actbl.bin.tmp of=actbl.bin
	tools/actbl actbl.bin >src/actbl_define.asm

font.chr: ./graphic/font.bmp
	${BMP2CHR} $< $@ palette.bin

player.chr: ./graphic/player.bmp
	${BMP2CHR} $< $@

${EMU}:
	cd vgszero/src/sdl2 && make

