import PackageDescription

let package = Package(
  name: "CPU6502Swift",
  targets: [
    Target(
      name: "CPU6502Tests",
      dependencies: [
        
      ])
  ],
  dependencies: [
    .Package(url: "https://github.com/Quick/Nimble.git", Version(4,1,0))
  ]
)
