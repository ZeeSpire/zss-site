---
layout: post-style-1
type: post
title: Hexagonal Architecture
published: 26 Oct 2019
last_modified_at: 16 November 2021
author: Gabriel Voicu
keywords: java, spring-boot, architecture 
description: 
categories: java spring-boot architecture
featured-image: "/assets/images/posts/0004/hexa-header.png" # full size
featured-image-top: "/assets/images/posts/0004/hexa-header.png" # width - 1200 (you can add the same URL as for featured-image) 
featured-image-home: "/assets/images/posts/0004/hexa-header.png" # width - 600 (you can add the same URL as for featured-image) [use ~square images for homepage-style-1]
featured-image-style: centered # can be centered or full-width
hidden: true # true if hidden from homepage list
---
#### 1. Overview
**Hexagonal Architecture is an architectural design pattern** that makes the application highly maintainable and fully testable.

It keeps the important parts of the application isolated from outer components.

**We integrate components into the core through ports and adapters.**

The core comprises business logic, and domain layers.

Also known as Ports and Adapters Pattern, it has a lot of benefits visible in the long term.

**Above all, testing and changing the application are easy and cost-effective.**

<div class="row mb-4">
    <div class="col-sm-12 col-lg-12 text-center">
        <img src="/assets/images/posts/0004/hexagonal-architecture-1.png" class="img-fluid img-thumbnail img-600" alt="Hexagonal architecture 1" />
        <br />
        <a href="https://jmgarridopaz.github.io/" target="_blank">https://jmgarridopaz.github.io/</a>
    </div>
</div>

#### 2. Principles
The principles of Hexagonal Architecture are:
- Application, domain, and infrastructure are separate
- Outer components depend on the domain and service layer, not vice versa
- Isolate the core through ports and adapters
<br />
<br />

#### 3. Hexagon Implementation

<div class="row mb-4">
    <div class="col-sm-12 col-lg-12 text-center">
        <img src="/assets/images/posts/0004/hexagonal-architecture.png" class="img-fluid img-thumbnail img-600" alt="Hexagonal architecture 2" />
    </div>
</div>

**Domain**
```java
public class Book {
    private Long id;
    private String name;
    //constructors //getters and setters 
}
```

**Driven Ports**

A driven port is an interface for a functionality, needed by the application for implementing the business logic. Such functionality is provided by a driven actor. So driven ports are the SPI (Service Provider Interface) required by the application.

```java
public interface BookRepository {
    Book findById(Long id);
}
```

**Driver Ports**

The Driver Ports offer the application functionality to drivers of the outside world. Thus, driver ports are said to be the **use case boundary** of the application. They are **the API** of the application.

```java
public interface BookService {
    Book getBook(Long id);
}
```

Driver Ports also have an implementation in the core.

```java
public class BookServiceImpl implements BookService {

    private BookRepositoryPort bookRepositoryPort;

    public BookServiceImpl(BookRepositoryPort bookRepositoryPort) {
        this.bookRepositoryPort = bookRepositoryPort;
    }

    public Book getBook(Long id) {
        return bookRepositoryPort.findById(id);
    }
}
```

Now we can decide on the details of the application. Until now, we could defer the decisions regarding what technologies and libraries we will use to implement outer components. Therefore, we implement the adapters for the database and REST UI.
<br />
<br />
#### 4. Adapters Implementation

**DB Driven Adapter**

A driven adapter **implements a driven port interface**, converting the technology agnostic methods of the port into specific technology methods.

```java
@Component
public class JpaBookRepositoryAdapter implements BookRepositoryPort {

    @Autowired
    private HAAJpaRepository haaJpaRepository;

    @Override
    public Book findById(Long id) {
        Optional<BookEntity> bookEntityOptional = haaJpaRepository.findById(id);
        BookEntity bookEntity = bookEntityOptional.orElseThrow(BookDoesNotExistException::new);
        return bookEntity.toBook();
    }
}
```
```java
public interface HAAJpaRepository extends JpaRepository<BookEntity, Long> {}
```
```java
@Entity
public class BookEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @Column(name = "name")
    private String name;

    //constructors //getters and setters 

    public Book toBook(){
        return new Book(this.id, this.name);
    }
}
```

**UI Driver Adapter**

A driver adapter **uses a driver port interface**, converting a specific technology request into a technology agnostic request to a driver port.

```java
@RestController
public class BookControllerControllerAdapter implements BookControllerPort {

    @Autowired
    private BookService bookService;

    @GetMapping("/books")
    public ResponseEntity getBook(@RequestParam Long id) {
        try {
            return ResponseEntity.ok(bookService.getBook(id));
        } catch (BookDoesNotExistException e){
            return ResponseEntity.ok("We don't have this book!");
        } catch (Exception e){
            return ResponseEntity.badRequest().build();
        }
    }
}
```

#### 5. Configuration
We can also use Dependency Injection in our core by adding an external configuration.

```java
@Configuration
public class SpringBeans {
        @Bean
        BookService bookService(final BookRepositoryPort bookRepositoryPort) {
            return new BookServiceImpl(bookRepositoryPort);

    }
}
```

Book endpoint is accessible here: http://host:8080/books?id=1
<br />
<br />
#### 6. Conclusion
In conclusion, Hexagonal Architecture lets us plug or unplug components as we see fit without major costs.

The UI, database and other components are plugins. We can easily change or swap the plugins.

We achieve all this through Dependency Inversion and Dependency Injection.

The code is available over [GitHub](https://github.com/WeInspireTech/websitetutorials).

You can read more about Hexagonal Architecture on [https://jmgarridopaz.github.io](https://jmgarridopaz.github.io)