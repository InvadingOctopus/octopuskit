import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(NumericsTests.allTests),
        testCase(CGPointTests.allTests),
        testCase(StringTests.allTests),
        
        testCase(OctopusKitLaunchTests.allTests),
        testCase(OKLogTests.allTests),
        testCase(ECSTests.allTests),
        
        testCase(ContiguousArray2DTests.allTests)
    ]
}
#endif
