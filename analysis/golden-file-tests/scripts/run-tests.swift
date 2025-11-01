#!/usr/bin/env swift
// Golden File Test Runner
// Usage: swift run-tests.swift [implementation-name]
// Example: swift run-tests.swift cmark-gfm

import Foundation

// MARK: - Configuration

let implementation = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "cmark-gfm"

let scriptURL = URL(fileURLWithPath: #file)
let scriptsDir = scriptURL.deletingLastPathComponent()
let testDir = scriptsDir.deletingLastPathComponent()
let projectRoot = testDir.deletingPathComponent().deletingPathComponent()

let testcasesDir = testDir.appendingPathComponent("testcases")
let expectedDir = testDir.appendingPathComponent("expected").appendingPathComponent(implementation)

// MARK: - Helper Functions

func printHeader(_ title: String) {
    print("==========================================")
    print(title)
    print("==========================================")
}

func printSeparator() {
    print("==========================================")
}

func runCommand(_ command: String, arguments: [String]) -> (output: String, exitCode: Int32) {
    let task = Process()
    task.launchPath = "/usr/bin/env"
    task.arguments = [command] + arguments

    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe

    task.launch()
    task.waitUntilExit()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8) ?? ""

    return (output, task.terminationStatus)
}

// MARK: - Test Runner

struct TestResult {
    let name: String
    let passed: Bool
    let diff: String?
}

class TestRunner {
    var results: [TestResult] = []

    func run() {
        printHeader("Golden File Test Runner")
        print("Implementation: \(implementation)")
        print("Test cases: \(testcasesDir.path)")
        print("Expected: \(expectedDir.path)")
        printSeparator()
        print()

        // Check if expected directory exists
        guard FileManager.default.fileExists(atPath: expectedDir.path) else {
            print("❌ ERROR: Expected output directory not found:")
            print("   \(expectedDir.path)")
            print()
            print("Generate baseline first:")
            print("   ./generate-baseline.sh \(implementation)")
            exit(1)
        }

        // Find CLI tool
        let cliPath = projectRoot
            .appendingPathComponent("build/Debug/TextDown.app")
            .appendingPathComponent("Contents/Resources/qlmarkdown_cli")

        guard FileManager.default.fileExists(atPath: cliPath.path) else {
            print("❌ ERROR: qlmarkdown_cli not found at:")
            print("   \(cliPath.path)")
            print()
            print("Build the project first:")
            print("   cd \(projectRoot.path)")
            print("   xcodebuild -scheme TextDown -configuration Debug")
            exit(1)
        }

        // Get test files
        let testFiles = getTestFiles()
        print("Found \(testFiles.count) test cases")
        print()

        // Run each test
        for testFile in testFiles {
            runTest(testFile, cliPath: cliPath.path)
        }

        // Print summary
        printSummary()
    }

    func getTestFiles() -> [URL] {
        guard let enumerator = FileManager.default.enumerator(
            at: testcasesDir,
            includingPropertiesForKeys: [.nameKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        return enumerator.compactMap { element in
            guard let url = element as? URL,
                  url.pathExtension == "md" else {
                return nil
            }
            return url
        }.sorted { $0.lastPathComponent < $1.lastPathComponent }
    }

    func runTest(_ testFile: URL, cliPath: String) {
        let filename = testFile.lastPathComponent
        let basename = testFile.deletingPathExtension().lastPathComponent

        let expectedFile = expectedDir.appendingPathComponent("\(basename).html")

        print("Testing: \(filename) ... ", terminator: "")

        // Generate current output
        let result = runCommand(cliPath, arguments: [testFile.path])
        let currentOutput = result.output

        // Read expected output
        guard let expectedOutput = try? String(contentsOf: expectedFile, encoding: .utf8) else {
            print("❌ FAILED (expected file not found)")
            results.append(TestResult(name: filename, passed: false, diff: "Expected file not found"))
            return
        }

        // Compare
        if currentOutput == expectedOutput {
            print("✅ PASS")
            results.append(TestResult(name: filename, passed: true, diff: nil))
        } else {
            print("❌ FAIL")

            // Generate diff
            let diff = generateDiff(expected: expectedOutput, current: currentOutput)
            results.append(TestResult(name: filename, passed: false, diff: diff))

            // Print diff preview (first 10 lines)
            let diffLines = diff.components(separatedBy: "\n")
            let preview = diffLines.prefix(10).joined(separator: "\n")
            print("   Diff preview:")
            preview.components(separatedBy: "\n").forEach { line in
                print("   \(line)")
            }
            if diffLines.count > 10 {
                print("   ... (\(diffLines.count - 10) more lines)")
            }
            print()
        }
    }

    func generateDiff(expected: String, current: String) -> String {
        // Simple line-by-line diff
        let expectedLines = expected.components(separatedBy: "\n")
        let currentLines = current.components(separatedBy: "\n")

        var diff = ""
        let maxLines = max(expectedLines.count, currentLines.count)

        for i in 0..<maxLines {
            let expectedLine = i < expectedLines.count ? expectedLines[i] : ""
            let currentLine = i < currentLines.count ? currentLines[i] : ""

            if expectedLine != currentLine {
                diff += "Line \(i + 1):\n"
                diff += "  Expected: \(expectedLine)\n"
                diff += "  Current:  \(currentLine)\n"
            }
        }

        return diff.isEmpty ? "No differences found (whitespace?)" : diff
    }

    func printSummary() {
        print()
        printSeparator()

        let passed = results.filter { $0.passed }.count
        let failed = results.filter { !$0.passed }.count
        let total = results.count

        print("Results:")
        print("  Passed: \(passed) / \(total)")
        print("  Failed: \(failed) / \(total)")

        if failed > 0 {
            print()
            print("Failed tests:")
            for result in results where !result.passed {
                print("  - \(result.name)")
            }
        }

        printSeparator()

        if failed > 0 {
            exit(1)
        } else {
            print()
            print("✅ All tests passed!")
        }
    }
}

// MARK: - Main

let runner = TestRunner()
runner.run()
