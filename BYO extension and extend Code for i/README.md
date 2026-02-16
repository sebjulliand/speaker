# Build Your Own VS Code extension and extend Code for i
## Prerequisites
### Tools
- VS Code
- node.js
- git

### Get the [boilerplate](https://github.com/sebjulliand/vscode-extension-template/tree/code4i)
- [Download the code4i template branch](https://github.com/sebjulliand/vscode-extension-template/archive/refs/heads/code4i.zip)
- Extract the zip file
- Rename the `vscode-extension-template-code4i` folder it contains to something that fits your project

### Initialize the project
- Open a terminal into the folder extracted above
- Run the following commands
```bash
git init --initial-branch=main
```
```bash
npm i
```

### Open the project in VS Code
- Press F5 to start a debug session
- In the debug window, press F1 and look for the Hello World command
![](images/helloworld.png)
- Press Enter
- A notification shows up and says Hello: success!

## Step 1: implement a simple "Run CL Command" command that can be run from the command palette
- Declare the command in `package.json`
- Add its label in `package.nls.json`
- Implement the command's logic and register it using `vscode.commands.registerCommand`

## Step 2: add an action in the Object Browser and use CustomUI to display the description of a file
- Follow the instructions from Step 1 to create, declare, register and implement the command
- Use `code4i.customUI()` to display the file description
- Add an entry in the manifest to hide the command from the palette; for example:
  ```json
  {
    "command": "byoe.displayFileDescription",
    "when": "never"
  }
  ```
- Add an entry in the manifest to show that command in Code for i Object Browser on the relevent view items
  ```json
  "view/item/context": [
    {
      "command": "byoe.displayFileDescription",
      "when": "view === objectBrowser && (viewItem =~ /^object\\.file/ || viewItem =~ /^SPF/)"
    }
  ]
  ```

## Step 3: add another actionto display the columns of a file in the Object Browser and create a submenu
- Instructions are the same as Step 2
- Declare a new submenu in the manifest
  ```json
  "submenus": [
    {
      "id": "byoe.objects",
      "label": "%Build Your Own Extension%"
    }
  ]
  ```
- Add an entry in the manifest to put the commands from this step and step 2 into that submenu
- Attach that submenu to Code for i Object Browser view
  ```json
  "view/item/context": [
    {
      "submenu": "byoe.objects",
      "when": "view === objectBrowser"
    }
  ]
  ``` 

## Step 4: create a simple spooled files browser using `vscode.window` and `vscode.workspace` APIs
- Create a new command that implements the logic (`QSYS2.SPOOLED_FILE_INFO` and `SYSTOOLS.SPOOLED_FILE_DATA` are your friends here)
- Use `vscode.window.showQuickPick` to let the user select the spooled file to open
- Use `vscode.workspace.openTextDocument` to display the selected spooled file

## Step 5: create a Job browser using VS Code Tree View API
- Declare a new view whose icon will be visible in the Activity Bar
  ```json
  "viewsContainers": {
    "activitybar": [
      {
        "id": "byoe-container",
        "icon": "$(vr)",
        "title": "B.Y.O.E."
      }
    ]
  },
  "views": {
    "byoe-container": [
      {
        "id": "byoe.jobBrowser",
        "name": "%IBM i Job Browser%",
        "icon": "",
        "when": "code-for-ibmi:connected"
      }
    ]
  }
  ```
- Declare a refresh action that will be used in the Job Browser - the action should be put in the navigation area
  ```json
  "view/title": [
      {
        "command": "jobBrowser.refresh",
        "group": "navigation@99",
        "when": "view === byoe.jobBrowser"
      }
    ],
  ```
- Extend the `TreeNodeDataProvider` class from the boilerplate to implement the Job Browser tree view

## Final result
Check out my [BYOE](https://github.com/sebjulliand/BYOE) repository that implements steps 1 to 5.
Each tag in the repository matches the final result from a step.