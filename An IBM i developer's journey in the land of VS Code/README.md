# An IBM i developer's journey in the land of VS Code
This is the landing page that will help you get started with IBM i development within VS Code.

# Prerequisites
- VS Code must be installed: [get it here!](https://code.visualstudio.com/download)
- You must have a PUB400 profile: [signup here](https://pub400.com/cgi/signup.nd/start)

# Get started
Open VS Code and follow each steps carefully.

# 1. Install the IBM i Development pack
![](assets/ibmidevpack.png)

This is a set of extensions to get you started with IBM i development within VS Code. It includes Code for IBM i, DB2 for IBM i, RPG/CL/COBOL highlighting and a few other features.

[Click here to install it](vscode:extension/HalcyonTechLtd.ibm-i-development-pack)

# 2. Open the walkthroughs
There are 6 walkthroughs that are provided by Code for IBM i to help you get started with IBM i development within VS Code.

To open a walkthrough, follow these steps
1. Press F1
2. In the command palette, type `open walkthrough` and click on Welcome: `Open Walkthrough...`
![](assets/openwalkthrough.png)
3. Filter out the walkthrough by typing `code for ibm i`.
![](assets/filterwalkthroughs.png)
4. Click on a walkthrough to open it and get started

The walkthroughs should be taken in the following order:
## Getting Started with Code for IBM i
Through this walkthrough, you'll learn how to:
- Create a connection
- Connect to an IBM i
- Define an Object Browser filter ([documentation](https://codefori.github.io/docs/browsers/object-browser/))
- Edit source code ([documentation](https://codefori.github.io/docs/developing/editing-compiling/))


## Code for IBM i IFS Browser 
## Code for IBM i Actions
Actions in Code for IBM i is a highly customizable feature. It lets you define and run 5250 or shell commands on various items.

Through this walkthrough, you'll learn how to:
- Access the actions
- Create or edit actions
- Run the actions

### Dive deeper!
[Click here](https://codefori.github.io/docs/developing/actions/) to check out the related documentation section.

- Each command line starting with `?` will open an input to let you change the command before it gets executed
- You can define you own action prompt, using text fields and dropdown lists!

#### Text field example
Syntax: `PARM(${id|Label})`
```
OUTFILE(${outfile|Output file})
```
![](assets/textfield.png)

#### Dropdown list example
Syntax: `PARM(${id|Label|VALUE1,VALUE2,...})`
```
OUTPUT(${output|Output|*PRINT,*OUTFILE})
```
![](assets/dropdown.png)

## RPGLE language tools & linting
## Local development with ILE
## Code for IBM i Tips