---
layout: post-style-1
type: post
title: MapStruct for automated DTO to Entity mapping and vice-versa
published: 08 Oct 2019
last_modified_at: 16 November 2021
author: Gabriel Voicu
keywords: java, spring, boot, test, unit 
description: 
categories: java spring boot test unit 
featured-image: "/assets/images/posts/0006/project_structure_v01.png" # full size
featured-image-top: "/assets/images/posts/0006/project_structure_v01.png" # width - 1200 (you can add the same URL as for featured-image)
featured-image-home: "/assets/images/posts/0006/project_structure_v01.png" # width - 600 (you can add the same URL as for featured-image) [use ~square images for homepage-style-1]
featured-image-style: centered # can be centered or full-width
hidden: false # true if hidden from homepage list
---
This code example demonstrates the use of MapStruct when we need to convert basic objects into DTOs.

We start by adding the MapStruct dependencies to a Spring project. Here we use a new project but the procedure is the same for mature projects as well.

pom.xml
```xml
<dependencies>
    <dependency>
        <groupId>org.mapstruct</groupId>
        <artifactId>mapstruct-jdk8</artifactId>
        <version>1.2.0.Final</version>
    </dependency>
</dependencies>
<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-compiler-plugin</artifactId>
            <version>3.5.1</version>
            <configuration>
                <source>1.8</source>
                <target>1.8</target>
                <annotationProcessorPaths>
                    <path>
                        <groupId>org.mapstruct</groupId>
                        <artifactId>mapstruct-processor</artifactId>
                        <version>1.2.0.Final</version>
                    </path>
                </annotationProcessorPaths>
            </configuration>
        </plugin>
    </plugins>
</build>
```

For each entity we need a Mapper interface:

UtilizatorUtilizatorDTOMapper Interface
```java
@Mapper
public interface UtilizatorUtilizatorDTOMapper {
    UtilizatorUtilizatorDTOMapper INSTANCE = Mappers.getMapper(UtilizatorUtilizatorDTOMapper.class);
    UtilizatorDTO objToDto(Utilizator utilizator);
    Utilizator dtoToObj(UtilizatorDTO destination);
}
```

Now we can build the entity and DTO:

Utilizator Entity
```java
public class Utilizator {
    private String name;
    private String address;
    public Utilizator() {
    }
    public Utilizator(String name, String address) {
        this.name = name;
        this.address = address;
    }
    //getters & setters
}
```

UtilizatorDTO
```java
public class UtilizatorDTO {
    private String name;
    public UtilizatorDTO() {
    }
    public UtilizatorDTO(String name) {
        this.name = name;
    }
    //getters & setters
}
```

For demonstration purpose we are going to use a Controller class to test our Mapper.

Controller class
```java
@RestController
class Controller {
    @GetMapping(value = "/mapstruct_simple_obj_to_dto.action")
    public UtilizatorDTO mapstructSimpleObjToDto() {
        Utilizator utilizator = new Utilizator("Gabi", "Krakovia 9A");
        UtilizatorDTO utilizatorDTO = UtilizatorUtilizatorDTOMapper.INSTANCE.objToDto(utilizator);
        return utilizatorDTO;
    }

    @GetMapping(value = "/mapstruct_simple_dto_to_obj.action")
    public Utilizator mapstructSimpleDtoToObj() {
        UtilizatorDTO utilizatorDTO = new UtilizatorDTO("Gabi");
        Utilizator utilizator = UtilizatorUtilizatorDTOMapper.INSTANCE.dtoToObj(utilizatorDTO);
        return utilizator;
    }
}
```
