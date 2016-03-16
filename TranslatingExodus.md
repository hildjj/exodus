# Translating Exodus #

## Current Translations ##

To view the currently supported languages, you view the various lang files [here](http://exodus.googlecode.com/svn/trunk/exodus/locale/).

## Translation HOWTO ##

As of Exodus 0.8.5.0, Exodus supports language files use the [GNU GetText](http://www.gnu.org/software/gettext/gettext.html) project. Currently, the number of language files that have been created is small. We NEED MORE HELP :).

If you are willing to translate Exodus to your language, please subscribe to the [Exodus-Dev](http://groups.google.com/group/exodus-dev?hl=en) mailing list. Please post to the Exodus-dev list at least and advertise your intentions to translate. Somebody may be doing it already.

Once you have done that, you can continue with the following steps:

  1. [Download the template file](http://exodus.googlecode.com/svn/trunk/exodus/default.po) from the Exodus subversion repository. You may want to check the file out of Subversion yourself, if so take a look at the [README file for source code.](http://exodus.googlecode.com/svn/trunk/exodus/README.txt)
  1. Get a PO file editor, like poEdit (Win32), KBabel (Linux, KDE), or a similar PO File editor. This step isn't all necessary as PO files are just text, but it will help you a lot in managing the translation.
  1. Translate to your language. PO file editors are more or less intuitive and the task is not that complicated. Please try to make a good translation. It is a good idea to have someone review it, as that person may find some things that you have missed.
  1. If you are not using an editor, you need to compile your default.po file into default.mo. You can do this by using the tools from the dxGetText suite. Go [Download the latest Delphi toolkit](http://dybdahl.dk/dxgettext/download/) (should be the first link) and install it. Inside the directory, you'll find the msgfmt.exe console utility which can be used to compile PO files into binary MO files. Exodus requires the langauage files to be binary MO files before it will use them. **If you are using poEdit**, the editor will automatically compile PO files into MO files, so you don't need any additional tools.
  1. Try it. (You will need at least Exodus 0.8.5.0 installed). You can just drop the **default.mo** file in the **locale/XX/LC\_MESSAGES** directory. The local directory is located inside the main directory where you installed Exodus. Start Exodus, and goto Tools | Options | System, and select your language from the drop down list.
  1. If everything is correct, submit the file to the Exodus-Dev mailing list.