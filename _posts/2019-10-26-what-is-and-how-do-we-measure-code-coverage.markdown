---
layout: post-style-1
type: post
title: What is and how do we measure code coverage
published: 26 Oct 2019
last_modified_at: 16 November 2021
author: Gabriel Voicu
keywords: java, spring, boot, test, unit, code, coverage
description: 
categories: java spring-boot test
featured-image: # full size 
featured-image-top: # width - 1200 (you can add the same URL as for featured-image)
featured-image-home: # width - 600  (you can add the same URL as for featured-image) [use ~square images for homepage-style-1]
featured-image-style: centered # can be centered or full-width
hidden: true # true if hidden from homepage list
---
Test quality is very important and one of the most important things in building quality tests is to cover all production code lines with tests.
<div class="row mb-4">
    <div class="col-sm-12 col-lg-6">
        Code coverage is a metric that shows us the percentage of code that is covered by tests. Using test coverage we can also identify the lines of code that we missed.
    </div>
    <div class="col-sm-12 col-lg-6">
        <img src="/assets/images/posts/0002/coverage1.png" class="img-fluid img-thumbnail" alt="Coverage 1" />
        Using IntelliJ Idea to check for code coverage.
    </div>
</div>
<div class="row mb-4">
    <div class="col-sm-12 col-lg-6">
        All modern IDEs have a tool that allows us to run tests with code coverage. This way we will be able to see what methods and lines of production code we didn’t cover and write more tests before pushing the code into a repository.
        Another great way to check code coverage is to use a tool like SonarQube.
    </div>
    <div class="col-sm-12 col-lg-6">
        <img src="/assets/images/posts/0002/coverage2.png" class="img-fluid img-thumbnail" alt="Coverage 2" />
        Covered lines are green and uncovered are red.
    </div>
</div>