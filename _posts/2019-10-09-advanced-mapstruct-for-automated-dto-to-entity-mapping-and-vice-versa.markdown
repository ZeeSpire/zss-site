---
layout: post-style-1
type: post
title: Advanced MapStruct for automated DTO to Entity mapping and vice versa
published: 09 Oct 2019
last_modified_at: 16 November 2021
author: Gabriel Voicu
keywords: java, spring, boot, test, unit 
description: 
categories: java spring boot test unit 
featured-image: "/assets/images/posts/0005/Dn4uZqMI_400x400.png" # full size
featured-image-top: "/assets/images/posts/0005/Dn4uZqMI_400x400.png" # width - 1200 (you can add the same URL as for featured-image)
featured-image-home: "/assets/images/posts/0005/Dn4uZqMI_400x400.png" # width - 600 (you can add the same URL as for featured-image) [use ~square images for homepage-style-1]
featured-image-style: centered # can be centered or full-width
hidden: false # true if hidden from homepage list
---
Start this tutorial about MapStruct with [the introduction](/mapstruct-for-automated-dto-to-entity-mapping-and-vice-versa.html).

MapStruct tries to map the field from one object to another automatically but when the objects are different you can map the object’s fields explicitly.

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

Animal class
```java
public class Animal {
    private Breed breed;
    private Owner owner;
    //getters & setters
}
```

Breed class
```java
public class Breed {
    private String name;
    private String country;
    private Integer height;
    //getters & setters
}
```

Owner class
```java
public class Owner {
    private String name;
    private String address;
    //getters & setters
}
```

AnimalDTO class
```java
public class AnimalDTO {
    private String xName;
    private String zName;
    //getters & setters
}
```
<br />

#### The Mapper

AnimalAnimalDTOMapper Interface
```java
@Mapper
public interface AnimalAnimalDTOMapper {
    AnimalAnimalDTOMapper INSTANCE = Mappers.getMapper(AnimalAnimalDTOMapper.class);

    @Mappings({
            @Mapping(source = "breed.name", target = "xName"),
            @Mapping(source = "owner.name", target = "zName")}
    )
    AnimalDTO objToDto(Animal animal);

    Animal dtoToObj(AnimalDTO animalDTO);
}
```
<br />

#### And the action begins

```java
@GetMapping(value = "/mapstruct_adv_obj_to_dto.action")
public AnimalDTO mapstructAdvObjToDto() {
    Animal animal = new Animal(
            new Breed("Boxer", "Germany", 120),
            new Owner("Gabriel Voicu", "Krakovia 10A")
    );
    AnimalDTO animalDTO = AnimalAnimalDTOMapper.INSTANCE.objToDto(animal);
    return animalDTO;
}
```