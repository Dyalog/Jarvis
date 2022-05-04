## Terminology
### Endpoint 
In the context of ***Jarvis***, an endpoint is the last segment of a URL up to the query string, if any.  When using ***Jarvis***' JSON paradigm, the endpoint represents the name of the APL function used to service that endpoint.  When using ***Jarvis***' REST paradigm, the endpoint identifies the resource to acted upon by the request.

### HTTP method
The HTTP protocol defines several request "methods" that a client may use to request the server to perform different operations. When you open a web browser on a URL, the browser is typically using the **GET** HTTP method to retrieve the requested content. Other HTTP methods include POST, PUT, DELETE, PATCH, and HEAD; each one designed to indicate the operation the server should perform.

### JSON
JSON stands for **J**ava**S**cript **O**bject **N**otation and is a flexible notation for representing data arrays and objects. Dyalog APL has a system function, `⎕JSON`, which easily converts between JSON and APL arrays/namespaces.

### REST
REST stands for **RE**presentational **S**tate **T**ransfer and is a design pattern for APIs. An API that follows this design pattern is termed "RESTful". When a RESTful API is called, the server will transfer to the client a representation of the state of the requested resource.

## Paradigms
***Jarvis*** supports two operational paradigms that we term **JSON** and **REST**. A ***Jarvis*** server can run only one paradigm at a time. One of the first decisions you'll need to make when using ***Jarvis*** is which web service paradigm to use. The paradigm will determine protocol for how a client will interact with ***Jarvis***. This section provides information to help you decide which paradigm is most appropriate for your application.

### The JSON paradigm
The JSON paradigm may seem quite natural to the APLer in that the endpoints (functions) take a data argument and return a data result. The argument and result can be as complex as you like, provided that they can be represented using JSON.

-	The endpoints are the actual APL functions that are called.  You can specify which functions you want to expose as endpoints for your service to the client.
-	The client uses the HTTP POST method and passes the parameters for the request as JSON in the request body.
-	The payload (body) of the request is automatically converted by ***Jarvis*** from JSON to an APL array and passed as the right argument to your function.
-	Your function should return an APL array which ***Jarvis*** then converts to JSON and returns to the client in the response.
-	Your application needs to know nothing about JSON, HTTP or web services.

### The REST paradigm
One common feature of RESTful web services is that they tend to use standard HTTP methods to perform operations on resources.  A resource is specified by the URL of the request.  The resource could be a physical resource like a file or a virtual resource that is constructed dynamically by your code. There are several other ["RESTful  design"](https://en.wikipedia.org/wiki/Representational_state_transfer) principles or constraints, but they are beyond the scope of this document.

- Operations are typically implemented corresponding to standard HTTP methods:
    - GET – read a resource
    - POST – create a resource
    - PUT – update/replace a resource
    - PATCH – update/modify a resource
    - DELETE – delete a resource
- With ***Jarvis***, you specify which methods you want your service to support. (***Jarvis*** even allows you to create your own method names as well.)
- You then implement an APL function with the same name as each method.
- Resources are specified in the request URL.  
- Depending on how you design the service API, parameters, if any, can be passed in the URL,  the query string, the body of the request, or some combination thereof.
- The function you write is passed the request object and it's up to you to parse the URL, payload, headers, and query parameters to determine what to do and what the arguments are.
- You decide on the content type and format of the payload of the response.  Common response content types for RESTful web services are JSON, XML or HTML.
- In general, the **JSON** paradigm is quicker and easier to implement, but a properly implemented **REST** paradigm 

### JSON contrasted with REST
In many cases, the same functionality can be implemented using either paradigm.

With **JSON**, endpoints are the names of APL functions that you want to expose with your web service.  You write one APL function per operation you want to perform.

With **REST**, endpoints identify resources and the HTTP method determines the operation to perform on the resource. You write one APL function for each HTTP method your web service will support.

To compare the two paradigms, let's imagine you want to retrieve the total of invoice 45 for customer 231.

#### JSON Example
One way to implement this using the JSON paradigm might be to:

- specify that the client should provide the arguments as a JSON object with a "customer" element and an "invoicenum" element. For this example, it might look like 
      {"customer":231,"invoice":45} 
- write an APL function called `GetInvoiceTotal` which would take a namespace as its argument.  The namespace will contain elements named "customer" and "invoice"
```
       ∇ namespace← GetInvoiceTotal namespace;costs
    [1]   ⍝ the namespace argument was created by Jarvis from the JSON object in the request
    [2]    costs←ns.customer GetInvoiceItems ns.invoice ⍝ retrieve the invoice item costs pseudo-code
    [3]    namespace.total←+/costs ⍝ insert a total element into the namespace  
       ∇
```
- ***Jarvis*** will then convert the result, in this case the updated namespace, to JSON `{"customer":231,"invoicenum":45,"total":654.32}` and return it to the client

#### REST Example

Using the REST paradigm, you might specify a resource like `/customer/231/invoice/45/total`. Since this is a "read" operation, you would use the HTTP GET method to retrieve it.  
- You would write a function named `GET` (the same as the HTTP method) which would be passed the HTTP request object. The `Endpoint` element of the request object will be `'/customer/231/invoice/45/total'`. 
- Your function would need to parse the endpoint to determine what is being requested and then retrieve the information.
- Your function would set the content-type for the response payload as well as format the retrieved information and assign it to the payload.





