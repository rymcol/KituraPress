import Kitura

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

// All Web apps need a router to define routes
let router = Router()

router.get("/") { _, response, next in
     response.headers["Content-Type"] = "text/html; charset=utf-8"
     try response.send(fileName: "views/header.mustache")
     try response.send(IndexHander().generateContent())
     try response.send(fileName: "views/footer.mustache").end()
}

router.get("/blog") { _, response, next in
     response.headers["Content-Type"] = "text/html; charset=utf-8"
     try response.send(fileName: "views/header.mustache")
     try response.send(fileName: "views/blog.mustache")
     try response.send(fileName: "views/footer.mustache").end()
}

router.get(middleware: StaticFileServer(path: "./public"))

// Handles any errors that get set
router.error { request, response, next in
    response.headers["Content-Type"] = "text/plain; charset=utf-8"
    let errorDescription: String
    if let error = response.error {
        errorDescription = "\(error)"
    } else {
        errorDescription = "Unknown error"
    }
    try response.send("Caught the error: \(errorDescription)").end()
}

// A custom Not found handler
router.all { request, response, next in
    if  response.statusCode == .unknown  {
        // Remove this wrapping if statement, if you want to handle requests to / as well
        if  request.originalURL != "/"  &&  request.originalURL != ""  {
            try response.status(.notFound).send("404! - This page does not exits!").end()
        }
    }
    next()
}

// Add HTTP Server to listen on port 8090
Kitura.addHTTPServer(onPort: 8090, with: router)

// start the framework - the servers added until now will start listening
Kitura.run()
