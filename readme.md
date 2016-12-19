# DirectX bindings for D language.

___
## Running samples:

Open sample folder in terminal *(a quick way is to shift-RMB in that folder in explorer and choose open command window)* 
and simply type :

__`dub run --arch=x86_64`__

or for x86

__`dub run`__

&nbsp;

Some samples requires using Windows8 config if you are on Windows 8 or Windows 10, if you see linker errors just specify that config in build:

__`dub run --arch=x86_64 --config=Windows8`__



&nbsp;


Since DMD 2.067 it is now possible to use COFF .lib files for x86 builds, to do so add dflags -m32mscoff to your dub package

__`"dflags" : ["-m32mscoff"]`__

however at this moment something broken so one may need to call dub with `--combined` flag

__`dub build --combined`__


&nbsp;


___
### Disclaimer:

*Keep in mind that this bindings is still far from ideal, any changes may broke API. It requires a lot of commitment to be finally finished, and one can find something that is not there yet from C++.*

Any questions on [dlang.org forum thread](http://forum.dlang.org/thread/cbjjmigmqpfxbmxwrmru@forum.dlang.org)


&nbsp;


___
### How to contribute:

Found an error? Got "access violation"? Simply open an issue!

There is also a lot of broken things around in code, just search the sources for `"FIXME:"` and `"TODO:"`

&nbsp;


Pull requests are welcome!

&nbsp;


___
#### License:
*MIT License*

