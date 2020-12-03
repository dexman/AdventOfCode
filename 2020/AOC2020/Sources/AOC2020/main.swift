import Foundation

let startDate = Date()
do {
    try day01part01()
    try day01part02()
    try day02part01()
    try day02part02()
    try day03part01()
    try day03part02()
} catch {
    print("Failed: \(error)")
}
let endDate = Date()
let duration = (floor(endDate.timeIntervalSince(startDate) * 1000) / 1000)
print("Completed in \(duration) seconds.")
