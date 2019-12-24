import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(NumericsTests.allTests),
        testCase(CGPointTests.allTests),
        testCase(StringTests.allTests),
        
        testCase(OctopusKitLaunchTests.allTests),
        testCase(OctopusLogTests.allTests),
        testCase(ECSTests.allTests),
        
        testCase(ContiguousArray2DTests.allTests)
    ]
}
#endif
