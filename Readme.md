# Wihajseter

Wihajster is a Ruby library for generating GCode and controlling the
3D printer.

## 

## Instalation 

### QT4

Debian / Ubuntu / Mint + Ruby 1.9.3

```
sudo aptitude install cmake libqt4-core libqt4-dev libqimageblitz-dev libqscintilla2-dev libqwt5-qt4-dev libqwtplot3d-qt4-dev smoke-dev-tools

wget http://rubyforge.org/frs/download.php/75633/qt4-qtruby-2.2.0.tar.gz
tar -xvzf qt4-qtruby-*.tar.gz
rm qt4-qtruby-*.tar.gz
cd qt4-qtruby-*

# Install newest version of smokegen to get macros
# It's needed to compile other packages
cd smokegen
cmake . && make && sudo make install
cd ..

# Copy extra cmake finders
cp /usr/share/smoke/cmake/FindPhonon.cmake cmake/modules/
cat /usr/share/smoke/cmake/FindQImageBlitz.cmake |grep -v FindLibraryWithDebug | sed 's/find_library_with_debug/find_library/' > cmake/modules/FindQImageBlitz.cmake 

cmake . && make && sudo make install

sudo ldconfig
```

### Instalation - SDL/Rubygame

`https://github.com/rubygame/rubygame/wiki/Install`

For debian:

```
sudo apt-get install ruby ruby-dev irb ri rubygems # Ruby installation

sudo apt-get install libsdl1.2-dev libsdl-gfx1.2-dev libsdl-image1.2-dev libsdl-mixer1.2-dev libsdl-ttf2.0-dev
```

## Alternatives and Inspirations

- https://github.com/D1plo1d/Replicate.rb/blob/master/ReprapDriver.rb
- https://github.com/kliment/Printrun/blob/master/printcore.py

