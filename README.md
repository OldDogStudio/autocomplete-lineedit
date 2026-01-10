# LineEdit AutoCompletion
Custom Node to implement an auto-complete menu for one or more LineEdit Nodes.  
This is a forked project from the repo https://github.com/Lenrow/line-edit-complete-godot .  
  
![Plugin Example](doc-files/line-edit-complete-preview.gif)  
(animation from Lenrow's plugin, credit to him)  
  
## How to Use
1. Scene Setup  
	1. Set 'Menu Location Node' to boundary object for the AutoComplete menu options.  
	2. Optionally disable directions for menu growth.  
	3. Optionally set minimum character requirment.  
2. Script Use  
	1. Add the LineEdit AutoComplete Assistant node to your scene.  
	2. Assign a Node to "Menu Location Node" which the AutoCompletion Options will be contained within.  
	3. Use linedit_autocomplete_assistant.add_lineedit() to assign a LineEdit Node and a list of terms 
		to the assistant script.  
The list of terms can be a passed as Array, or sourced from a file. Both can be passed and they will be combined.  
The file can be .json (Array or Dictionary with key "terms") or a simple txt file with a term on each line.  
  
  
## Contrast to Original Source 
I made multiple functional changes--here's a list. Perhaps Lenrow's addon would suit your needs better.  
* Lenrow's addon uses a single list of terms for 1+ LineEdits; this addon allows assigning each LineEdit its own list.  
* Lenrow's addon checks each word, treating the text like a sentence being written; this addon checks the entire LineEdit.text, treating the LineEdit as a user-input field with expected choices.  
* This addon has a minimum character feature. If that is the only positive to using this addon, Lamelynx has a fork of Lenrow's addon with the minimum character feature.  
* This addon has a strict string feature. With this the LineEdit behaves similar to an OptionButton. This is an easy way to have both functionalities without UI differences.  
* Lenrow's addon can only read json files; this addon will also read txt files.  
  
  
## Feedback  
If you have any feedback or found bugs please contact me via:  
* github: OldDogStudio  
* Redot discord: OldDogStudio  
* X:  @OldDog_GameDev
