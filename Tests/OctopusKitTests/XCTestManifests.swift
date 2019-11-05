import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(OctopusKitLaunchTests.allTests),
        textCase(OctopusLogTests.allTests)
    ]
}
#endif
