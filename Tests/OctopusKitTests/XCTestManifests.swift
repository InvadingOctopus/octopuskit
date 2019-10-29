import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(OctopusKitTests.allTests),
        textCase(OctopusLogTests.allTests)
    ]
}
#endif
