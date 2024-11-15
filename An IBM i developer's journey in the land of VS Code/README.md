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

# 2. Open the Code for IBM i walkthroughs
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

### Dive deeper!
- Remote pase Terminal and 5250 emulator can be opened from the bottom status bar

![](assets/terminals.png)

- 

## Code for IBM i IFS Browser
Through this walkthrough, you'll learn how to:
- Browse the IFS
- Open streamfiles
- Change the working directory

### Dive deeper!
Aside from the usual streamfile actions (create/move/copy/delete), the IFS browser offers some useful features:
- Download multiple files or folder (select and right-click)
- Upload from your local file explorer using drag'n'drop
- Move/copy using drag'n'drop
- Compare with various items

## Code for IBM i Actions
Actions in Code for IBM i is a highly customizable feature. It lets you define and run 5250 or shell commands on various items.

Through this walkthrough, you'll learn how to:
- Access the actions
- Create or edit actions
- Run the actions

### Dive deeper!
[Click here](https://codefori.github.io/docs/developing/actions/) to check out the related documentation section.

- Define [command profiles](https://codefori.github.io/docs/settings/profiles) to customize actions execution context
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
Through this walkthrough, you'll learn how to:
- Bring the `Outline` view to focus
- Use content assist
- Configure the linter
- Fix errors reported by the linter

### Dive deeper!
- [Click here](https://codefori.github.io/docs/extensions/rpgle/) to check out the RPG documentation section.
- [Click here](https://codefori.github.io/docs/extensions/rpgle/linter/) to check out the linter documentation.

## Local development with ILE
Through this walkthrough, you'll learn how to:
- Work on a locally hosted IBM i project
- Create local actions set tied to this project
- Use git to manage the project lifecycle

### Dive deeper!
[Click here](https://codefori.github.io/docs/developing/local/getting-started/) to learn more about local IBM i development.

## Code for IBM i Tips
Through this walkthrough, you'll learn how to:
- Compare source editors
- Run SQL using the Db2 for i extension
- Search for source members

### Dive deeper!
[Check out this section](https://codefori.github.io/docs/tips/protect/) to learn more about preventing source code from being modified, using protected modes.

# 3. Dive into the Db2 for i extension
## Get started
The `Db2 for i` extension allows you to run SQL queries right from VS Code. It also includes Visual Explain and supports Notebook.

Open the [Db2 for i guide](https://codefori.github.io/docs/extensions/db2i/#executing-statements) and follow each steps starting from the **Executing statements** chapter.

## Try the examples
The extension comes with a set of SQL examples. To browse the examples, open the Db2 for i view container and then expand the `Examples` view.

![](assets/db2examples.png)

## Notebooks
Db2 Notebooks are documents that contain a mix of rich Markdown and executable code snippets (SQL, CL and shell), and accompanying rich output. These are all separated into distinct cells and can be interleaved in any order.

The Db2 for i extension comes with its own set of sample Notebooks.

![](assets/sameplnotebooks.png)

You can run several types of queries in a Notebook. Try these few examples:
### SQL
List the total size of each object types in a library.
```sql
Select objtype || ' (' || count(objtype) || ')' as label, Sum(OBJSIZE) / 1024 as "Size" FROM TABLE(QSYS2.OBJECT_STATISTICS('QGPL', '*ALL')) Group By objtype Order by "Size" Desc
```
Turn it into a bar chart!
```sql
-- chart: bar
-- title: QGPL objects size
-- y: Kilobytes
-- hideStatement: true
Select objtype || ' (' || count(objtype) || ')' as label, Sum(OBJSIZE) / 1024 as "Size" FROM TABLE(QSYS2.OBJECT_STATISTICS('QGPL', '*ALL')) Group By objtype Order by "Size" Desc
```

Fetch a dad joke! 😂
```sql
select json_value(response_message, '$.joke' returning varchar(5000)) as joke from table ( qsys2.http_get_verbose('https://icanhazdadjoke.com', json_object( 'headers': json_object('accept': 'application/json' ))));
```

Open a fortune cookie 🤔
```sql
select trim(replace(replace(RESPONSE_MESSAGE, '\n',' '), '\t', ' ')) fortune from table ( qsys2.http_get_verbose('https://api.justyy.workers.dev/api/fortune'));
```

### Shell
Fetch a dad joke again! (requires `curl` and `jq` to be installed)
```shell
curl -H "Accept: application/json" https://icanhazdadjoke.com | jq ".joke"
```  

### CL
Display the current library list
```
DSPLIBL
```
