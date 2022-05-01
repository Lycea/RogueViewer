# RogueViewer

This is a simple viewer to view game saves of project rogue.

How to use it ?

- clone this repository
- git submodule init
- git submodule update
- (install love2d if not existent)
- love .
- drop a saved .json file on the  programm


Supported features:
- loading up a save file of version 1.1.0.0
- seeing the following things
    - Items
    - Entities(right now all in red)
    - walls
    - floors
- selecting view of:
    - items
    - entities


TODOS:
- catch errors on json load
- show names of items/elements
- show information of tile
- add simple editing