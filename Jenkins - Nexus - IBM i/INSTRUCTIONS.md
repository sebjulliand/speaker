# Jenkins

## Docker image
jenkins/jenkins:alpine

```bash
create -p 8080:8080 -v jenkins_home:/var/jenkins_home --name jenkins -d jenkins/jenkins:alpine
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
- Maven 3.9 installation

## Managed file
### maven-settings
#### Server credentials
- nexus-repository (using `jenkins` Nexus credentials)
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
### Build project
#### Parameters
- Branch
- Version

#### Script
```groovy
node {
    stage('Prepare') {
        dir('company_system') {
            git branch: params.Branch, url: 'git@github.com:sebjulliand/company_system.git'
        }
    }
    
    stage('Build') {
        onIBMi(server:'RDMER01') {
            def buildLibrary = "COMPANYSYS";
            def projectDirectory = "/home/sjulliand/builds/company_system";
            ibmiCommand command: "RMDIR DIR('$projectDirectory') SUBTREE(*ALL)", failOnError: false
            ibmiPutIFS from: 'company_system', to: projectDirectory
            ibmiCommand command: "DLTLIB LIB($buildLibrary)"
            ibmiCommand command: "CRTLIB LIB($buildLibrary)"
            ibmiCommand command: "QSH CMD('ADDENVVAR ENVVAR(QIBM_QSH_CMD_ESCAPE_MSG) VALUE(''Y'') LEVEL(*JOB) REPLACE(*YES)')"
            ibmiCommand command: "QSH CMD('chmod +x $projectDirectory/build.sh')"
            ibmiCommand command: "QSH CMD('$projectDirectory/build.sh $buildLibrary')"
            
            ibmiCommand "CRTSAVF QTEMP/COMPANYSYS"
            ibmiCommand "SAVLIB LIB($buildLibrary) DEV(*SAVF) SAVF(QTEMP/COMPANYSYS)"
            def saveFileContent = ibmiGetSAVF library: "QTEMP", name: "COMPANYSYS", toFile: 'CompanySystem.savf'
            writeFile encoding: "UTF-8", file: "CompanySystem.json", text: saveFileContent.toJSON()
        }
    }
    
    stage('Publish') {
        withMaven(maven: 'Maven399', mavenSettingsConfig: 'maven-settings') {
            def isSnapshot = params.Version.endsWith("-SNAPSHOT");
            sh "mvn deploy:deploy-file -Dfile=CompanySystem.savf -Dfiles=CompanySystem.json -Dtypes=json -Dclassifiers=metadata -DgroupId=com.powerup -DartifactId=company-system -Dversion=${params.Version} -Durl=http://host.docker.internal:8081/repository/ibmi-${isSnapshot ? 'snapshots' : 'releases'} -DrepositoryId=nexus-repository"
        }
    }
}
```

### Deploy project
#### Parameters
- Version

#### Script
```groovy
node {
    stage('Retrieve') {
        def artifactId = "com.powerup:company-system:${params.Version}";
		withMaven(maven: 'Maven399', mavenSettingsConfig: 'maven-settings') {
            def isSnapshot = params.Version.endsWith("-SNAPSHOT");
            //Get company-system.savf
            sh "mvn dependency:copy -Dartifact=$artifactId:savf -DoutputDirectory=. -Dmdep.stripClassifier=true -Dmdep.stripVersion=true";
            //Get company-system.json
            sh "mvn dependency:copy -Dartifact=$artifactId:json:metadata -DoutputDirectory=. -Dmdep.stripClassifier=true -Dmdep.stripVersion=true";
		}
    }
    
    stage('Deploy') {
        onIBMi(server:'RDMER01') {
            def content = ibmiPutSAVF(fromFile: "company-system.savf", library: "QTEMP", name: "COMPANYSYS")
            ibmiCommand "RSTLIB SAVLIB(${content.savedLibrary}) DEV(*SAVF) SAVF(QTEMP/COMPANYSYS) RSTLIB(NEWCMPSYS)"
        }
    }
}
```

# Sonatype Nexus

## Docker image
sonatype/nexus3:3.76.0-java17-alpine

```bash
create -p 8081:8081 -v /Users/sebjulliand/volumes/nexus-data:/nexus-data --name nexus -m 3G -d -e NEXUS_CONTEXT=/  sonatype/nexus3:3.86.0-alpine
```

## Configuration
- Dedicated IBM i repositories (maven2 format)
  - ibmi-releases
  - ibmi-snapshots
- Dedicated `jenkins` user