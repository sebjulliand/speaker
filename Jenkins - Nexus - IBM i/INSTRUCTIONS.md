# Sample project
[Company System](https://github.com/sebjulliand/company_system)

# Sonatype Nexus

## Docker image
sonatype/nexus3:3.76.0-java17-alpine

```bash
docker/podman/container create -p 8081:8081 -v /Users/sebjulliand/volumes/nexus-data:/nexus-data --name nexus -m 3G -d -e NEXUS_CONTEXT=/ sonatype/nexus3:3.86.0-alpine
```

## Configuration
- Dedicated IBM i repositories (maven2 format)
  - ibmi-releases
  - ibmi-snapshots
- Dedicated `jenkins` user

# Jenkins

## Docker image
jenkins/jenkins:alpine

```bash
docker/podman/container create -p 8080:8080 -v jenkins_home:/var/jenkins_home --name jenkins -d jenkins/jenkins:alpine
```

## Plugins
- [Git plugin](https://plugins.jenkins.io/git)
- [IBM i Pipeline Steps](https://plugins.jenkins.io/github)
- [Pipeline Maven Integration Plugin](https://plugins.jenkins.io/pipeline-maven)
- [Pipeline Utility Steps](https://plugins.jenkins.io/pipeline-utility-steps)

## System
### IBM i servers
- 1 Build IBM i
- `n` IBM i deployment targets

## Tools
- Default Git installation
- Maven 3.9.x installation

## Managed file
### maven-settings
#### Server credentials
- nexus-repository (using `jenkins` Nexus credentials) : will be used in the pipelines
- nexus-snapshots (using `jenkins` Nexus credentials)
- nexus-releases (using `jenkins` Nexus credentials)
#### Content
```xml
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
    <profiles>
        <profile>
            <activation>
                <activeByDefault>true</activeByDefault>
            </activation>

            <repositories>
                <repository>
                    <id>nexus-snapshots</id>
                    <url>http://host.docker.internal:8081/repository/ibmi-snapshots/</url>
                    <releases>
                        <enabled>false</enabled>
                    </releases>
                    <snapshots>
                        <enabled>true</enabled>
                        <updatePolicy>always</updatePolicy>
                    </snapshots>
                </repository>
                <repository>
                    <id>nexus-releases</id>
                    <url>http://host.docker.internal:8081/repository/ibmi-releases/</url>
                    <releases>
                        <enabled>true</enabled>
                    </releases>
                    <snapshots>
                        <enabled>false</enabled>
                    </snapshots>
                </repository>
            </repositories>
        </profile>
    </profiles>
</settings>
```

## Pipelines
Two possible types of jobs

### Build project (multibranch pipeline)
Add Git source: `git@gitlab.com:SebJulliand/company_system.git`

Jenkins will scan the repository and find the Jenkinsfile on each branch.

### Build project (pipeline job)
#### Parameters
- Branch (string)
- Version (string)

#### Script
```groovy
node {
    stage('Prepare') {
        dir('company_system') {
            git credentialsId: 'sebjulliand', branch: params.Branch, url: 'git@gitlab.com:SebJulliand/company_system.git'
        }
    }
    
    stage('Build') {
        onIBMi(server:'PUB400') {
            def buildLibrary = "SEBJUB"; //change it
            def projectDirectory = "/home/sebju/builds/company_system"; //change it
            ibmiCommand command: "RMDIR DIR('$projectDirectory') SUBTREE(*ALL)", failOnError: false
            ibmiPutIFS from: 'company_system', to: projectDirectory
            ibmiCommand command: "CLRLIB LIB($buildLibrary)"
            
            def build = ibmiShellExec "cd $projectDirectory; chmod +x ./build.sh; ./build.sh $buildLibrary"
            writeFile encoding: "UTF-8", file: "build.txt", text: build.output()

            ibmiCommand "CRTSAVF QTEMP/COMPANYSYS"
            ibmiCommand "SAVLIB LIB($buildLibrary) DEV(*SAVF) SAVF(QTEMP/COMPANYSYS) TGTRLS(V7R4M0)"
            def saveFileContent = ibmiGetSAVF library: "QTEMP", name: "COMPANYSYS", toFile: 'CompanySystem.savf'
            writeFile encoding: "UTF-8", file: "CompanySystem.json", text: saveFileContent.toJSON()
        
            archiveArtifacts artifacts: 'build.txt,CompanySystem.json', followSymlinks: false
        }
    }
    
    stage('Publish') {
        withMaven(maven: 'maven39', mavenSettingsConfig: 'nexus-maven') {
            def isSnapshot = params.Version.endsWith("-SNAPSHOT");
            sh "mvn deploy:deploy-file -Dfile=CompanySystem.savf -Dfiles=CompanySystem.json -Dtypes=json -Dclassifiers=metadata -DgroupId=com.sebjulliand -DartifactId=company-system -Dversion=${params.Version} -Durl=http://localhost:8081/repository/ibmi-${isSnapshot ? 'snapshots' : 'releases'} -DrepositoryId=nexus-repository"
        }
    }
}
```

### Deploy project
#### Parameters
- Version (string)

#### Script
```groovy
node {
    stage('Retrieve') {
        def artifactId = "com.sebjulliand:company-system:${params.Version}";
		withMaven(maven: 'Maven399', mavenSettingsConfig: 'maven-settings') {
            def isSnapshot = params.Version.endsWith("-SNAPSHOT");
            //Get company-system.savf
            sh "mvn dependency:copy -Dartifact=$artifactId:savf -DoutputDirectory=. -Dmdep.stripClassifier=true -Dmdep.stripVersion=true";
            //Get company-system.json
            sh "mvn dependency:copy -Dartifact=$artifactId:json:metadata -DoutputDirectory=. -Dmdep.stripClassifier=true -Dmdep.stripVersion=true";
		}
    }
    
    stage('Deploy') {
        onIBMi(server:'TEST') {
            def content = ibmiPutSAVF(fromFile: "company-system.savf", library: "QTEMP", name: "COMPANYSYS")
            ibmiCommand "RSTLIB SAVLIB(${content.savedLibrary}) DEV(*SAVF) SAVF(QTEMP/COMPANYSYS) RSTLIB(NEWCMPSYS)"
        }
    }
}
```