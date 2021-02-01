# AdoptOpenJDK for Synology

---

### Usages

Can be used with:
  - `java -version` - path executable
  - `JAVA_HOME` - env variable
  - `/var/packages/adoptopenjdk/target/bin/java` - absolute path
  - spk-packager-plugin (maven) - https://github.com/lost-carrier/spk-packager-plugin

SPK Packager maven plugin example:
```xml
            <plugin>
                <groupId>com.losty.maven.synology</groupId>
                <artifactId>spk-packager</artifactId>
                <version>0.1.3</version>
                <configuration>
                    <!-- Old official Java 8 Synology package -->
                    <!--<installDepPackages>Java8</installDepPackages>-->
                    <installDepPackages>adoptopenjdk</installDepPackages>
                    <java>/var/packages/adoptopenjdk/target/bin/java</java>
                </configuration>
                <executions>
                    <execution>
                        <id>package</id>
                        <phase>package</phase>
                        <goals>
                            <goal>package</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
```

---

### AdoptOpenJDK support

#### Tested on: 
- DS918+ (DSM 6.2.3) - Intel J3455 (x86_64)
- DS218play (DSM 6.2.3) - Realtek RTD1296 (aarch64)

#### Package is not installable on:
- DS415Play - has x86 32bit cpu which AdoptOpenJDK does not support.

#### Java versions:
- Dynamically changing based on API response from AdoptOpenJDK.net
- Installer will show:
  - All LTS releases (8, 11)
  - Latest feature release (15)

#### Installable on architectures:
- x64
- aarch64
- arm (arm32)

---

### Platform support

#### DSM
- **supported 6.0+**
    - This version can be lowered however someone will have to test it.
- not supported yet 7.0 (requires different package structure)

#### SRM
- **not supported yet**
- This build should support SRM arm devices by default, however the support is not enabled since SPK package version can be set only for one OS platform. And someone will have to test it.
- If needed separate package can be build with:
    - edit INFO: `arch="dakota ipq806x northstarplus"`
    - edit INFO: `firmware="1.2"`

Platform support was configured according to:
- https://gist.github.com/SpiReCZ/64bbeb66f782096cab32af8e501d9f48
- https://adoptopenjdk.net/

---

Inspiration taken from: https://pcloadletter.co.uk/2011/08/23/java-package-for-synology/
