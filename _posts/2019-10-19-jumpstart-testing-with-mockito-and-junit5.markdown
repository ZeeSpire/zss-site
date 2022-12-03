---
layout: post-style-1
type: post
title: Jumpstart Testing with Mockito and JUnit5
published: 19 Oct 2019
last_modified_at: 16 November 2021
author: Gabriel Voicu
keywords: java, spring, boot, test, unit 
description: 
categories: java spring-boot test 
featured-image: "/assets/images/posts/0003/600/header.jpg" # full size
featured-image-top: "/assets/images/posts/0003/600/header.jpg" # width - 1200 (you can add the same URL as for featured-image) 
featured-image-home: "/assets/images/posts/0003/600/header.jpg" # width - 600 (you can add the same URL as for featured-image) [use ~square images for homepage-style-1]
featured-image-style: centered # can be centered or full-width
hidden: false # true if hidden from homepage list
---
In this article, we will see JUnit and Mockito in action using 2 Java components, a service class, and a repository class.

We will start by creating the classes and then write tests in different ways to use concepts like, assert, verify, check for thrown exception, ArgumentMatcher and ArgumentCaptor. At last, we will create cleaner tests by extracting the duplicated code and even use Mockito annotations. We will not focus on having 100% [code coverage](/what-is-and-how-do-we-measure-code-coverage/).

#### Code under test
**DataRepository.java**
```java
public interface DataRepository {
    int[] retrieveAllData();
    int getStoredSumById(int id);
    void save(Object o);
}
```

**DataService.java**
```java
public interface DataService {
    int calculateSum();
    void setDataRepository(DataRepository dataRepository);
    int calculateNewSum(int id);
    void save(Data o);
}
```

**DataServiceImpl.java**
```java
public class DataServiceImpl implements DataService {

    private DataRepository dataRepository;

    public void setDataRepository(DataRepository dataRepository) {
        this.dataRepository = dataRepository;
    }

    public int calculateSum(){
        int sum = 0;
        for(int value : dataRepository.retrieveAllData()){
            sum += value;
        }
        return sum;
    }

    public int calculateNewSum(int id){
        int sum = dataRepository.getStoredSumById(id);
        return sum + sum;
    }

    public void save(Data o){
        o = new Data(o.getName().toUpperCase());
        dataRepository.save(o);
    }
}
```

**Data.java**
```java
public class Data {
    private String name;
    // constructors, getters and setters
}
```

#### Unit tests without Mockito annotations
Test for calculateSum() method from service class, mocking repository. In this test, we are assuming that the retrieveAllData() mocked method from the repository returns an array with data.

```java
@Test
public void calculateSum_Should_ReturnResult_When_DataIsProvided() {
    //create service under test
    DataService ms = new DataServiceImpl();

    //mock repository to test service in isolation
    DataRepository dataRepositoryMock = mock(DataRepository.class);
    when(dataRepositoryMock.retrieveAllData()).thenReturn(new int[]{1, 2, 3});

    //set mock to service
    ms.setDataRepository(dataRepositoryMock);

    //call method under test
    int result = ms.calculateSum();

    //verify if method on the mock is called by service under test
    //it is mostly used when a method that is called on a mock does not have a return
    verify(dataRepositoryMock, times(1)).retrieveAllData();

    //assert result
    assertEquals(6, result);
}
```

Test for calculateSum() method from service class, mocking repository. We are assuming that the retrieveAllData() mocked method from the repository returns an array without data.

```java
@Test
public void calculateSum_Should_ReturnZero_When_DataIsEmpty() {
    //create service under test
    DataService ms = new DataServiceImpl();

    //mock repository to test service in isolation
    DataRepository dataRepositoryMock = mock(DataRepository.class);
    when(dataRepositoryMock.retrieveAllData()).thenReturn(new int[]{});

    //set mock to service
    ms.setDataRepository(dataRepositoryMock);

    //call method under test
    int result = ms.calculateSum();

    //verify if method on the mock is called by service under test
    verify(dataRepositoryMock, times(1)).retrieveAllData();

    //assert result
    assertEquals(0, result);
}
```

Test for calculateSum() method from service class, mocking repository. Assuming that retrieveAllData() mocked method from the repository returns null, causing the calculateSum() method from service class to throw a NullPointerException.

```java
@Test
public void calculateSum_Should_ThrowException_When_DataIsNull() {
    assertThrows(NullPointerException.class, () -> {
        //create service under test
        DataService ms = new DataServiceImpl();

        //mock repository to test service in isolation
        DataRepository dataRepositoryMock = mock(DataRepository.class);
        when(dataRepositoryMock.retrieveAllData()).thenReturn(null);

        //set mock to service
        ms.setDataRepository(dataRepositoryMock);

        //call method under test
        ms.calculateSum();
    });
}
```

Test for calculateNewSum() method from service class, mocking repository using ArgumentMatchers. In this test, we are assuming that getStoredSumById `(<called with any Integer>)` mocked method from the repository returns 2. The new topic introduced here are **ArgumentMatchers** like any(), anyInt(), etc. that can be used to replace an actual argument to make tests more generic.

```java
@Test
void calculateNewSum_Should_ReturnResult_When_DataIsProvided() {
    //create service under test
    DataService ms = new DataServiceImpl();

    //mock repository to test service in isolation
    DataRepository dataRepositoryMock = mock(DataRepository.class);

    //return 2 when method is called with any int value
    when(dataRepositoryMock.getStoredSumById(anyInt())).thenReturn(2);

    //set mock to service
    ms.setDataRepository(dataRepositoryMock);

    //call method under test
    int result = ms.calculateNewSum(1);

    //verify if method on the mock is called by service under test with any argument
    verify(dataRepositoryMock, times(1)).getStoredSumById(anyInt());

    //assert result
    assertEquals(4, result);
}
```

Test for save() method from service class, mocking repository. In this case, the save() method from the service class doesn’t return anything to be asserted. We can use an **ArgumentCaptor** to check if the save() method from the repository class is called with expected arguments.

```java
@Test
void save_ShouldCallRepository_With_GivenParam() {
    // create service under test
    DataService ms = new DataServiceImpl();

    // mock repository to test service in isolation
    DataRepository dataRepositoryMock = mock(DataRepository.class);

    // set mock to service
    ms.setDataRepository(dataRepositoryMock);

    // call method under test
    Data o = new Data("MockitoObject");
    ms.save(o);

    //create expected object
    Data expected = new Data("MOCKITOOBJECT");

    // because the method does not return anything we can check
    // if mock method was called with an expected parameter
    ArgumentCaptor<Data> captor = ArgumentCaptor.forClass(Data.class);
    verify(dataRepositoryMock, times(1)).save(captor.capture());

    //assert captured argument
    assertEquals(expected, captor.getValue());
}
```

#### Cleaner unit tests without Mockito annotations
We could extract duplicated code from every test into external methods like in the example below, to make our code cleaner.

```java
public class DataServiceTest_Clean {
    //create service under test
    DataService ms = new DataServiceImpl();

    //mock repository to test service in isolation
    DataRepository dataRepositoryMock = mock(DataRepository.class);

    @BeforeEach
    public void beforeEach(){
        //set mock to service
        ms.setDataRepository(dataRepositoryMock);
    }

    @Test
    public void calculateSum_Should_ReturnResult_When_DataIsProvided() {
        //mock repository to test service in isolation
        when(dataRepositoryMock.retrieveAllData()).thenReturn(new int[]{1, 2, 3});

        //call method under test
        int result = ms.calculateSum();

        //verify if method on the mock is called by service under test
        //it is mostly used when a method that is called on a mock does not have a return
        verify(dataRepositoryMock, times(1)).retrieveAllData();

        //assert result
        assertEquals(6, result);
    }
}
```

#### Unit tests with Mockito annotations
In the example above we demonstrated how we can remove duplicated code from our test but we can go a step forward and use Mockito annotations to create mocks and inject them using annotations.

```java
@ExtendWith(MockitoExtension.class)
public class DataServiceTest_Clean_WithAnnotations {
    //create service under test and inject all mocks needed
    //there is no need to manually inject mockitoRepositoryMock, just create it with @Mock
    @InjectMocks
    DataServiceImpl ms;

    //mock repository to test service in isolation
    @Mock
    DataRepository dataRepositoryMock;

    @Test
    void calculateSum_Should_ReturnResult_When_DataIsProvided() {
        //mock repository to test service in isolation
        when(dataRepositoryMock.retrieveAllData()).thenReturn(new int[]{1, 2, 3});

        //call method under test
        int result = ms.calculateSum();

        //verify if method on the mock is called by service under test
        //it is mostly used when a method that is called on a mock does not have a return
        verify(dataRepositoryMock, times(1)).retrieveAllData();

        //assert result
        assertEquals(6, result);
    }
}
```

The code is available over [GitHub](https://github.com/WeInspireTech/websitetutorials).