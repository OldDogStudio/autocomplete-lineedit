# LineEdit AutoCompletion
Custom Node to implement an auto-complete menu for one or more LineEdit Nodes.  
This is a forked project from the repo https://github.com/Lenrow/line-edit-complete-godot .  
If the intended use is multiple LineEdit nodes using the same list of terms, I suggest using
Lenrow's plugin.  

![Plugin Example](doc-files/line-edit-complete-preview.gif)  
(animation from Lenrow's plugin, credit to him)

## How to Use
1. Add the LineEdit AutoComplete Assistant node to your scene.  
2. Assign a Node to "Menu Location Node" which the AutoCompletion Options will be contained within.  
3. Use linedit_autocomplete_assistant.add_lineedit() to assign a LineEdit Node and a list of terms 
		to the assistant script.  
	-- the list of terms can be a passed Array, or sourced from a json file (Array or Dictionary),  
		or a simple txt file with a term on each line. A passed Array may be used in conjuntion with  
		a file.  
  
If you have any feedback or found bugs please contact me via github, the Redot discord  
server(OldDogStudio), or my X (@OldDog_GameDev).
