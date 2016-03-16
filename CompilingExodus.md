# Compiling Exodus from Source #

  1. Install [Borland Developer Studio 2006](http://www.borland.com/delphi).
  1. Install the Jedi Code Library from [here](http://sourceforge.net/project/showfiles.php?group_id=47514). Use at least release 1.97 for BDS2006.
  1. Install and setup [Subversion](http://subversion.tigris.org/).
  1. Checkout the Exodus source code
> > svn checkout http://exodus.googlecode.com/svn/trunk/ exodus
  1. Unzip tntUnicode.zip from the Exodus\Exodus\Components directory.
  1. Open Exodus\Exodus\Components\tntUnicode\Packages\BDS4\TntUnicodeVCL\_Design.bdsproj
  1. From the Project Manager, Right click, and select Install.
  1. Open Exodus\Exodus\Components\ExComponents.dpk
  1. From the Project Manager, Right click, and select Install.
  1. Open Exodus\Exodus.dpr
  1. Click "Build Exodus"