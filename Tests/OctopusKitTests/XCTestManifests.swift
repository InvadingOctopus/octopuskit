import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(OctopusKitLaunchTests.allTests),
        testCase(OctopusLogTests.allTests),
        testCase(ECSTests.allTests),
        testCase(AppleAPIExtensionsTests.allTests),
        testCase(ContiguousArray2DTests.allTests)
    ]
}
#endif
