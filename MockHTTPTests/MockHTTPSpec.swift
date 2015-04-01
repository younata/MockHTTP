import Quick
import Nimble
import MockHTTP

class MockHTTPSpec: QuickSpec {
    override func spec() {
        let url = NSURL(string: "http://example.com/foo")!
        var configuration: NSURLSessionConfiguration! = nil
        beforeEach {
            configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            MockHTTP.startMocking(configuration)
        }

        describe("mocking http requests") {
            let data = NSString(string: "hello").dataUsingEncoding(NSUTF8StringEncoding)!
            let headers : [NSObject: AnyObject] = ["foo": "bar"]
            let response = MockHTTP.URLResponse(statusCode: 200, headers: headers, body: data)

            var session : NSURLSession! = nil
            var request : NSURLRequest! = nil
            var responseData : NSData? = nil
            var httpResponse : NSHTTPURLResponse? = nil

            beforeEach {
                MockHTTP.registerURL(url, withResponse: response)

                request = NSURLRequest(URL: url)

                session = NSURLSession(configuration: configuration)
            }

            it("should return the registered response") {
                let expectation = self.expectationWithDescription("registered")
                session.dataTaskWithRequest(request, completionHandler: { (body, urlResponse, error) -> Void in
                    httpResponse = urlResponse as? NSHTTPURLResponse
                    expect(body).to(equal(data))
                    expect(httpResponse?.statusCode).to(equal(200))
                    expect(MockHTTP.requests().count).to(equal(1))
                    expect(MockHTTP.requests().last?.URL?.absoluteString).to(equal("http://example.com/foo"))
                    expectation.fulfill()
                }).resume()

                self.waitForExpectationsWithTimeout(1, handler: { (error) in
                    expect(error).to(beNil())
                })
            }
        }

        describe("making a request that is not registered") {
            it("should fail") {
                let request = NSURLRequest(URL: url)
                var responseError : NSError? = nil

                let expectation = self.expectationWithDescription("failure")

                let session = NSURLSession(configuration: configuration)
                session.dataTaskWithRequest(request, completionHandler: { (body, urlResponse, error) in
                    expectation.fulfill()
                }).resume()

                self.waitForExpectationsWithTimeout(1, handler: { (error) in
                    expect(error).toNot(beNil())
                })
            }
        }
    }
}