---
layout: post-style-1
type: post
title: Testing Spring Boot applications
published: 26 Oct 2019
last_modified_at: 16 November 2021
author: Gabriel Voicu
keywords: java, spring, boot, test, unit 
description: 
categories: java spring-boot test
featured-image: "/assets/images/posts/0001/full/spring-logo.png" # full size
featured-image-top: "/assets/images/posts/0001/full/spring-logo.png" # width - 1200 (you can add the same URL as for featured-image)
featured-image-home: "/assets/images/posts/0001/full/spring-logo.png" # width - 600 (you can add the same URL as for featured-image) [use ~square images for homepage-style-1]
featured-image-style: centered # can be centered or full-width
hidden: false # true if hidden from homepage list
---
In this article, we will create and test using both unit and integration tests a small Spring Boot application with a REST API. If you don’t have any experience with JUnit5 and Mockito, you can start with [this](/jumpstart-testing-with-mockito-and-junit5/) article.

Tools used: Spring Boot 2, Spring Data JPA, H2 as an in-memory database, Spring Test, Mockito and JUnit5.

Spring Boot’s starter dependency named Test comes with a lot of functionality and libraries such as JUnit5, Mockito, Hamcrest, AssertJ, JSONAssert, JSONPath that help us write great tests.

This example does not focus on [code coverage](/what-is-and-how-do-we-measure-code-coverage/).

**ProductController.java**
```java
@RestController
public class ProductController {
    @Autowired
    private ProductService productService;

    @GetMapping(value = "/status")
    public String checkStatus(){
        return "Live!";
    }

    @GetMapping("/products")
    public Product getProduct(@RequestParam Long id){
        boolean discount = true;
        return productService.getProductById(id, discount);
    }
}
```

**ProductService.java**
```java
public interface ProductService {
    Product getProductById(Long id, boolean hasDiscount);
}
```

**ProductServiceImpl.java**
```java
@Service
public class ProductServiceImpl implements ProductService {
    @Autowired
    private ProductRepository productRepository;

    public Product getProductById(Long id, boolean hasDiscount) {
        Product product = productRepository.getProductById(id);
        if (product != null) {
            if (hasDiscount) {
                product.setPrice(product.getPrice() - 10);
            }
            return product;
        } else {
            throw new ProductNotFoundException();
        }
    }
}
```

**ProductRepository.java**
```java
@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    Product getProductById(Long id);
}
```

**Product.java**
```java
@Entity
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;
    private String name;
    private Double price;
    private Long quantity;
    private String storeName;
    //constructors, getters and setters
}
```

#### Controller Unit tests
REST Controllers are a key part of a Spring Boot REST application and Spring Boot comes with utility objects to help us unit test them in isolation from the rest of the application.

In this test, we will use @ExtendWIth(SpringExtension.class) annotation to register the test class as a Spring Unit Test and @WebMvcTest(ProductController.class) annotation that will enable us to write a Spring MVC test that focuses only on Spring MVC components.

@WebMvcTest(ProductController.class) will also disable full auto-configuration and instead apply only configuration relevant to MVC tests. Without other components like Services or Repositories in ApplicationContext, we will test the controller in isolation.

MockMvc component is provided by Spring to make calls to the Spring MVC API and assert different properties like status code and received response.

```java
@ExtendWith(SpringExtension.class)
@WebMvcTest(ProductController.class)
class ProductControllerTest {

   @Autowired
   private MockMvc mockMvc;

   @MockBean
   private ProductService productServiceImpl; // This will mock a Spring Bean and Inject it where is needed

   // This test uses assertEquals to check the validity of the response
   @Test
   void checkStatus_Should_ReturnLive_When_StatusPathIsCalled_AssertUsingAssertEquals() throws Exception {
       //build request, execute GET to /status
       MvcResult mvcResult = mockMvc
               .perform(MockMvcRequestBuilders.get("/status").accept(MediaType.APPLICATION_JSON))
               .andReturn();
       assertEquals("Live!", mvcResult.getResponse().getContentAsString());
   }

   // This test uses ResultMatchers to check the validity of the response
   @Test
   void checkStatus_Should_ReturnLive_When_StatusPathIsCalled_AssertUsingResultMatchers() throws Exception {
       //build request, execute GET to /status and assert result using Response Matchers
       mockMvc.perform(MockMvcRequestBuilders.get("/status").accept(MediaType.APPLICATION_JSON))
               .andExpect(status().isOk()) //check is response status is 200
               .andExpect(content().string("Live!"))
               .andReturn();
   }

   // This test uses ResultMatchers with JSONAssert to check the validity of the response
   @Test
   void getProduct_Should_ReturnString_When_ProductsPathIsCalled_AssertUsingResultMatchers() throws Exception {
       String expectedResult = "{\"id\":1,\"name\":\"Cheese\",\"price\":10.0,\"quantity\":100}";
       String expectedResultWithoutSomePropertiesAndEscapeChars = "{id: 1, name: Cheese, price: 10.0}";

       when(productServiceImpl.getProductById(1L, true))
               .thenReturn(new Product(1L, "Cheese", 10.0, 100L));

       // build request, execute GET to /product and assert result using Response Matchers with JSONAssert
       mockMvc.perform(MockMvcRequestBuilders.get("/products?id=1").accept(MediaType.APPLICATION_JSON))
               .andExpect(status().isOk()) //check is response status is 200
               .andExpect(content().json(expectedResult)) //it will succeed even if a property will be missing
               .andExpect(content().json(expectedResultWithoutSomePropertiesAndEscapeChars))
               .andReturn();
       // behind the scene .andExpect(content().json(...)) uses JSONAssert calling assertEquals
       // with strict mode deactivated

       verify(productServiceImpl, times(1)).getProductById(1L, true);
   }

   // This test shows some of the capabilities of JSONAssert to check the validity of the response
   @Test
   void getProduct_Should_ReturnString_When_ProductsPathIsCalled_AssertUsingJSONAssert() throws Exception {
       String expectedResult = "{\"id\":1,\"name\":\"Cheese\",\"price\":10.0,\"quantity\":100,\"storeName\":null}";
       String expectedResultWithoutSomePropertiesAndEscapeChars = "{id:1,name:Cheese,price:10.0}";

       when(productServiceImpl.getProductById(anyLong(), anyBoolean()))
               .thenReturn(new Product(1L, "Cheese", 10.0, 100L));

       // build request, execute GET to /products
       MvcResult mvcResult = mockMvc
               .perform(MockMvcRequestBuilders.get("/products?id=1").accept(MediaType.APPLICATION_JSON))
               .andReturn();

       // strict mode, everything should match, the structure should be the same
       JSONAssert.assertEquals(expectedResult, mvcResult.getResponse().getContentAsString(), true);

       // strict mode off, properties may be missing, escape characters can be missing too
       JSONAssert.assertEquals(expectedResultWithoutSomePropertiesAndEscapeChars,
               mvcResult.getResponse().getContentAsString(), false);

       verify(productServiceImpl, times(1)).getProductById(anyLong(), anyBoolean());
   }
}
```

#### Service Unit tests
Services are the most important layer of our application because they encapsulate the whole business logic. Tests for services should be concise, should cover all situations, therefore, they should have the coverage as close as possible to 100%.

We can test services outside Spring Context, mocking every dependency and testing them like regular Java classes rather than Spring Beans.

```java
@ExtendWith(MockitoExtension.class)
public class ProductSeviceTest {

   @InjectMocks
   private ProductService productService = new ProductServiceImpl();

   @Mock
   private ProductRepository productRepository;

   @Test
   void getProductById_Should_ReturnProduct_When_ParametersAreValidAndDiscountIsApplied(){
       when(productRepository.getProductById(any())).thenReturn(new Product(1L, "Beer", 100.0, 100L));

       Product product = productService.getProductById(1L, true);

       assertEquals("Beer", product.getName());
       assertEquals(90.0, product.getPrice());
       verify(productRepository, times(1)).getProductById(any());
   }

   @Test
   void getProductById_Should_ReturnProduct_When_ParametersAreValidAndDiscountIsNotApplied(){
       when(productRepository.getProductById(any())).thenReturn(new Product(1L, "Beer", 100.0, 100L));

       Product product = productService.getProductById(1L, false);

       assertEquals("Beer", product.getName());
       assertEquals(100.0, product.getPrice());
       verify(productRepository, times(1)).getProductById(any());
   }

   @Test
   void getProductById_Should_ThrowException_When_ProductIsNotFound(){
       assertThrows(ProductNotFoundException.class, () -> {
           when(productRepository.getProductById(any())).thenReturn(null);

           Product product = productService.getProductById(1L, true);
       });
   }
}
```

#### Repository Unit tests
It’s not always needed to write unit tests for repository methods. There are cases when you only use methods that code from JPA like findAll() and it would be useless to test them. 

We want to write tests only for custom queries.

Repository tests are a special category, Spring gives us some tools to help us write them. First, we can mark a test as a Spring Unit test with @ExtendWith(SpringExtension.class) and after we can use @DataJpaTest annotation to tell Spring to create an in-memory database for us just for the purpose of testing the repository.

```java
@ExtendWith(SpringExtension.class)
@DataJpaTest
class ProductRepositoryTest {

   @Autowired
   private ProductRepository productRepository;

   @Test
   void getProductById_Should_ReturnProduct_When_ProperIdIsProvided() {
       productRepository.save(new Product(1L, "Beer", 100.0, 100L));
       productRepository.save(new Product(2L, "Cheese", 200.0, 200L));

       Product cheese = productRepository.getProductById(2L);

       assertEquals(200L, cheese.getQuantity());
   }

   @Test
   void getProductById_Should_ReturnNull_When_ProductIsMissing() {
       Product cheese = productRepository.getProductById(2L);
       assertEquals(null, cheese);
   }
}
```

#### Integration tests
Unlike unit tests, integration tests check more components of our application working together.

We tested the Controller, Service and Repository, all in one test, mocking nothing.

Again Spring comes to our rescue and gives us some tools to use. We will use @ExtendWith(SpringExtension.class) annotation to register the test as a Spring Unit test, @SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT) annotation to lunch the entire Spring Boot application on a random port. All components within the application will be instantiated in ApplicationContext simulating the application running, unlike unit tests which test just individual components.

@SpringBootTest annotation will also lunch the in-memory database and query it just like in a real scenario.

Another great tool that Spring provides is the TestRestTemplate object that helps us make API calls to our REST endpoints.

```java
@ExtendWith(SpringExtension.class)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class ProductIntegrationTest {

   @Autowired
   private TestRestTemplate testRestTemplate;

   @Autowired
   private ProductRepository productRepository; // just to add data in db

   @Test
   void checkStatusApi_Should_ReturnString_When_Called() {
       String response = testRestTemplate.getForObject("/status", String.class);
       assertEquals(response, "Live!");
   }

   @Test
   @DirtiesContext //@DirtiesContext will rollback database changes after test is done
   void getProductApi_Should_ReturnProduct_When_Called() {
       addSomeDataToDb();

       ResponseEntity<Product> response = testRestTemplate
               .getForEntity("/products?id=1", Product.class, new HashMap<String, String>());

       assertEquals(HttpStatus.OK, response.getStatusCode());

       assertEquals("Beer", response.getBody().getName());
       assertEquals(10L, response.getBody().getQuantity());
       assertEquals(100, response.getBody().getPrice());
   }

   private void addSomeDataToDb() {
       Product p1 = new Product("Beer", 110.0, 10L);
       Product p2 = new Product("Cheese", 100.0, 9L);
       Product p3 = new Product("WIne", 110.0, 10L);
       productRepository.save(p1);
       productRepository.save(p2);
       productRepository.save(p3);
   }
}
```

In integration tests, we could mock some components and just inject the mocks in the components we test.

```java
@MockBean
private ProductRepository productRepositoryMock;
```

Then we can use when() in our tests:

```java
when(productRepositoryMock.method(..)).thenReturn(...)
```

#### Conclusion
Writing Spring Boot tests is fast and easy and keeps unwanted bugs away. The framework offers great tools to help us, and we don’t need to add any other dependencies to the project for most of the cases.

The code is available over [GitHub](https://github.com/WeInspireTech/websitetutorials).