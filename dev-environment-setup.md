# Eclipse:

* Checkout code to *${HOME}/workspace-eclipse/kamehouse*
* Follow instructions in *eclipse/eclipse-configurations.md* (in programming private repo)
* Follow instructions in *eclipse/workspace-tomcat-setup.md* (in programming private repo)

# IntelliJ:

* Checkout code to *${HOME}/workspace-intellij/kamehouse*
* Follow instructions in *intellij/workspace-tomcat-setup.md* (in programming private repo)

# VS Code:

* Import workspace from *${HOME}/home-synced/workspace-vs-code* (backed up in private repo)
* To debug the frontend in vscode, use the chrome debugger launch configurations in .vscode/lauch.json
* There's 2 debugger launch configurations there, one for /kame-house-groot app and the other for /kame-house to debug the frontend in vscode and the backend in intellij: Run > Start Debugging or open the debugger tab to select which debugger to launch
* Create a symlink in kamehouse-ui/src/main: `mklink /D "kame-house" "webapp"` so that the vscode debugger picks up the files for /kame-house
* When setting the breakpoints to debug /kame-house, open the js files by browsing through kamehouse/kamehouse-ui/src/main/kame-house (through the symlink). Not by browsing through kamehouse/kamehouse-ui/src/main/webapp or they won't be bound
* When setting the breakpoints to debug /kame-house-groot, open the js files by browsing through kamehouse/kamehouse-groot/public/kame-house-groot

# Apache Httpd:

## Windows:

* Download a precompiled version of apache httpd (Currently using https://www.apachehaus.com/)
* Replace all the configuration with the settings I have for httpd in my private server backup repo
* Follow *apache-httpd/httpd-setup.md* (in programming private repo)

## Linux:

* Install apache httpd from the package manager
* Replace all the configuration with the settings I have for httpd in my private server backup repo
* Follow *apache-httpd/httpd-setup.md* (in programming private repo)
