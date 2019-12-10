import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(OctopusKitLaunchTests.allTests),
        testCase(OctopusLogTests.allTests),
        testCase(ECSTests.allTests),
        testCase(StringTests.allTests),
        testCase(CGPointTests.allTests),
        testCase(ContiguousArray2DTests.allTests)
    ]
}
#endif
