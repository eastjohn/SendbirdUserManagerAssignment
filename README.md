# How to use this repository
This document is a project to measure the programming skills of interview candidates in the Client iOS team. Please refer to the explanation below for the background of the assignment. Through this project, candidates will receive assignments. 
**Running `build_assignment.sh` in the parent directory creates a `zip` file for assignment to pass to a candidate.**
# Objective
Leverage the Sendbird platform API to construct an SDK that effectively manages user data
# Assignment Document
Please refers to [the shared assignment document (KOR version) here](https://docs.google.com/document/d/1FfzpF9TbH1mOkzCh31-FjQu9pVYOQbfFRC1SMLvaF3M/edit#heading=h.9xj3n33q7vja)

This document contains the below,
* Goal
* Environment & Instrument
* Assignment Description
* Expectation
* Review Criteria
* Point to note
* Scalability
# Criteria
## Skills that ***should*** be used:
- Async Programming
- Networking
- Database
- JSON parsing
- Thread-safety
## Skills that ***can*** be used: 
* Timers
- Unit Testing
- Memory management
# Follow-up Questions 
## Additional Features
* Upload binary
* Delete a user
* Get Users pagination
## Advanced Features
* Implement Local-DB with something like UserDefaults
- Rate limiting all requests
	- Only sending the last request if same requests
- Request Timeout handling
