# Creating a Branded version of Exodus #

  1. The easiest way to do these is to check out from Subversion.
  1. Get or build a copy of these files:
    * Exodus.exe
    * IdleHooks.dll
    * [exodus.ico](http://exodus.googlecode.com/svn/trunk/exodus/exodus.ico)
    * [exodus-installer.bmp](http://exodus.googlecode.com/svn/trunk/exodus/exodus-installer.bmp)
    * [GPL-LICENSE.TXT](http://exodus.googlecode.com/svn/trunk/exodus/GPL-LICENSE.TXT)
    * [ZipDLL.dll](http://exodus.googlecode.com/svn/trunk/redist/ZipDLL.dll)
    * [exodus-new.nsi](http://exodus.googlecode.com/svn/trunk/exodus/exodus-new.nsi)
    * [version.nsi](http://exodus.googlecode.com/svn/trunk/exodus/version.nsi)
    * [example-plugin-i18n-new.nsi](http://exodus.googlecode.com/svn/trunk/exodus/plugins/example-plugin-i18n-new.nsi)
    * [NSIS 2](http://sourceforge.net/project/showfiles.php?group_id=22049)
  1. These files you might want to host on your own web server:
    * indy\_openssl096k.zip
    * richupd.exe
    * branding.xml
  1. Create a branding.xml file.  [Here](http://exodus.googlecode.com/svn/trunk/exodus/branding_defaults.xml) is a template, with the defaults.  Any preference you set in this file will become the default.  You can set other preferences in here as well, such as [these](http://exodus.googlecode.com/svn/trunk/exodus/defaults.xml), or things that you find in your exodus.xml file.  Good candidates are fonts and colors.
  1. Move ZipDll.dll to $NSIS\_HOME\Plugins.
  1. Read the [NSIS docs](http://nsis.sourceforge.net/Docs/), to find out how to customize exodus.nsi.  I'd suggest removing the "Bleeding-edge updates" section, and adding branding.xml to the !Exodus section. Search for the word **BRANDING** for hints.
  1. If you want your branding.xml file to auto-update (seperately from your setup.exe file), put your branding.xml file on a web server, and set the 

<branding\_url/>

 option in the branding.xml that you distribute in your setup.exe. When your uses start up exodus, it will check to see if there is a later branding.xml file at the specified URL.
  1. Build your setup.exe file.  I use: "c:\program files\nsis\makensis.exe" /v2 exodus.nsi
  1. Distribute your new setup.exe.