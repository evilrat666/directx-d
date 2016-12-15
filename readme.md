#DirectX bindings for D language.

___
##Running samples:

open sample folder in terminal *(a quick way is to shift-RMB in that folder in explorer and choose open command window)* 
and symply type :
__`dub run --build=x86_64` __
or for x86
__`dub run` __

Some samples requires using Windows8 config if you use win8 or win10, if you see linker errors just specify that config in build
__`dub run --build=x86_64 --config=Windows8`__

since DMD 2.067 it is now possible to use COFF .lib files, to do so add dflags -m32mscoff to your dub package
__`"dflags" : ["-m32mscoff"]`__
however at this moment something broken so you need to call dub with `--combined` flag
__`dub build --combined`__

___
###Disclaimer:
*Keep in mind that this bindings is still far from ideal, any changes may broke API, it requires a lot of commitment to be finally finished, and one can find something that is not there yet from C++.*

Any questions on D forum thread here: http://forum.dlang.org/thread/cbjjmigmqpfxbmxwrmru@forum.dlang.org

___
####License:
*MIT License*
