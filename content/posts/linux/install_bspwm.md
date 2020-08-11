+++
title = "Archlinux에 bspwm 설치하기"
description = "Archlinux 설치후 Tiling window manager인 bspwm을 설정하는 방법을 알아봅시다"
date = "2020-08-11" 
author = "Gangjun"
tags = ["linux", "bspwm", "arch"]
+++

> 아직 작성중인 글입니다

아치리눅스는 기본적으로 GUI가 깔려있지 않습니다.
따라서 사용자가 직접 원하는 환경을 설정해주어야 합니다.
일반적으로 많이 쓰는 데스크톱 환경은 xfce, kde, gnome 등이 있습니다
하지만 이 글에서는 데스크톱 환경이 아닌 윈도우 매니저인 Bspwm 을 설치하는 방법을 알려드리도록 하겠습니다

# 목차

1. [Bspwm을 왜 써야할까?](#Bspwm을-왜-써야할까?)
2. [설치하기](#설치하기)
3. [꾸미기](#꾸미기)

# Bspwm을 왜 써야할까?

# 설치하기

## 패키지 설치하기

다음 패키지들을 설치합니다
(aur도 섞여 있으므로 [yay](https://github.com/Jguer/yay)등을 설치하여 사용하는것을 추천드립니다)

```
# gui 환경을 키기위해 필요한것들
xorg-server
xorg-xinit
xdg-utils
xterm

bspwm
sxhkd (키보드 단축키 프로그램, bspwm과 같이 깔아야함)
rofi (프로그램 실행기)
polybar (상단바)
termite (추천하는 터미널)
feh (이미지뷰어, 배경화면 설정위해 필요)
xorg-xsetroot
nemo (파일 브라우저)

# 한글 폰트/입력기
ttf-unfonts-core-ibx
ibus (bspwm 설치후 ibus-setup 실행하여 한글폰트 설정할것)
ibus-hangul
```
다음 명령어로 한번에 설치할 수 있습니다
```bash
yay -S xorg-server xorg-xinit xterm bspwm sxhkd rofi termite feh xorg-xsetroot ttf-unfonts-core-ibx ibus ibus-hangul
```

## bspwm 설정파일

bspwm의 default설정파일을 .config폴더 아래로 가져옵니다

```bash
cp /usr/share/doc/bspwm/examples/bspwmrc ~/.config/bspwm/bspwmrc
cp /usr/share/doc/bspwm/examples/sxhkdrc ~/.config/sxhkd/sxhkdrc
```

sxhkd의 터미널실행, 프로그램 실행기를 변경합니다

~/.config/sxhkd/sxhkdrc
```
다음 향목들을 변경
super + enter
    urxvt -> termite
super + @space
    dmenu_run -> rofi -show drun
```

## xinit설정

startx로 gui를 실행하였을때 bspwm이 실행될 수 있도록 .xinitrc를 변경해줍니다

~/.xinitrc
```
맨 아래 if문 밑에 있는 내용들 다 지우기,
다음과 같이 입력

...
sxhkd &
ibus-daemon &
xsetroot -cursor_name left_ptr
exec bspwm
```

자 이제 기본적인 설정이 끝났습니다!
터미널에서 아래의 명령어를 쳐서 GUI환경을 띄울 수 있습니다

```bash
xstart
```

아무것도 안뜬다고 걱정하지 마세요! `super+enter` 을 쳐서 터미널을 열고
`super+space`를 쳐서 앱 메뉴를 열 수 있습니다. 만약 열리지 않는다면 어딘가 설정을 잘못하였을 가능성이 높습니다.

제대로 설정되었다면 `super+alt+q`를 눌러 다시 쉘로 돌아갈 수 있습니다

## 배경화면 설정
아까 받은 feh라는 프로그램을 통하여 배경화면을 설정할 수 있습니다
설정파일 상단에 다음과 같은 명령어를 넣습니다

~/.config/bspwm/bspwmrc
```
feh --bg-fill <이미지 경로>
```

## polybar 설정
