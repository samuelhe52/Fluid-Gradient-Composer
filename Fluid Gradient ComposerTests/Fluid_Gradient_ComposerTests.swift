//
//  Fluid_Gradient_ComposerTests.swift
//  Fluid Gradient ComposerTests
//
//  Created by Samuel He on 2024/9/8.
//

import Testing
@testable import Fluid_Gradient_Composer

struct Fluid_Gradient_ComposerTests {
    @Test func example() async throws {
        let version1 = Config.Version(string: "1.0.0")!
        let version2 = Config.Version(string: "1.0.1")!
        let version3 = Config.Version(string: "1.2.2")!
        let version4 = Config.Version(string: "0.1.1")!
        let version5 = Config.Version(string: "0.1.1")!
        #expect(version1 < version2)
        #expect(version2 < version3)
        #expect(version3 >= version4)
        #expect(version4 == version5)
    }

}
