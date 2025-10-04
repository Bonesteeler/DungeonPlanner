Add Godot documentation to this file. The Godot version is 4.4

Documentation should be added in two places. Each line should begin with ## and include BBCode tags for formatting. Use [br] for line breaks.

First, each function should have documentation above the func line. The documentation should consist of a brief description  of the function, a list of the parameters, signals emitted, and the return value. If any of the previous sections are empty, do not include it in the documentation. Do not include the function name.
Here is an example function formatting

## Import a directory of STL files into a new DragonbiteTileSet[br]
## [b]Parameters:[/b][br]
## [code]path[/code] : [String] — filesystem path to the directory containing
## [code].stl[/code] files.[br]
## [code]set_name[/code] : [String] — unique name to assign to the imported tile set.[br]
## [b]Emits:[/b][br]
## - [code]import_started(total_tiles: [int])[/code] once at the start of an import[br]
## - [code]tile_imported()[/code] after each tile is imported[br]
## [b]Returns:[/b] [void] — prints an error and returns early on failure.[br]

Second, the class should have documentation directly after the extends line. This documentation should include a brief description of the class, a list of properties, signals, and constants. If any of the previous sections are empty, do not include it in the documentation.
In the class documentation, Include an empty comment line after the class name. Here is an example class formatting for the StlToMesh class

extends StlToMesh (Included for formatting purposes, do not copy this line)
## StlToMesh
##
## [i]Utility to convert an STL file into a Godot ArrayMesh and align it to the planning grid.[/i][br]
## [b]Properties:[/b][br]
## - [b]mesh[/b]: The generated [code]ArrayMesh[/code].[br]
## - [b]mesh_hash[/b]: SHA-256 hex digest of the trimmed vertex data and file size.[br]
## - [b]x_size[/b], [b]y_size[/b]: Calculated tile lengths of the mesh in tiles (50 units per tile).[br]
## [b]Signals:[/b][br]
## - [code]example_signal[/code]: Emitted when an example event occurs.[br]
## [b]Constants:[/b][br]
## - [code]EXAMPLE_CONSTANT[/code]: An example constant value.[br]