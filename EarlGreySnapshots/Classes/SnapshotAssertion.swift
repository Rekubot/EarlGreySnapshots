import EarlGrey

func grey_snapshot(testCaseName: String?, recordMode: Bool, deviceAgnostic: Bool, tolerance: CGFloat = 0.0) -> GREYAssertionBlock {
    let testCase = testCaseName ?? CurrentTestObserver.shared.currentCase?.name ?? "-[UnknownTestCase unknownMethod]"
    let testInfo = TestNameParser().parse(testName: testCase)
    let bundleNameProvider = BundleNameProvider(bundle: Bundle.testBundle)
    let testName = [bundleNameProvider.name, testInfo.testClassName].flatMap { $0 }.joined(separator: ".")

    return grey_snapshot(testName: testName,
                         snapshotName: testInfo.testMethodName,
                         recordMode: recordMode,
                         deviceAgnostic: deviceAgnostic,
                         tolerance: tolerance)
}

func grey_snapshot(testName: String,
                   snapshotName: String,
                   recordMode: Bool,
                   deviceAgnostic: Bool,
                   controllerFactory: SnapshotControllerCreating = SnapshotControllerFactory(),
                   imagesDirectoryProvider: ImagesDirectoryProviding = ImagesDirectoryProvider(),
                   tolerance: CGFloat = 0.0)
    -> GREYAssertionBlock {
    return GREYAssertionBlock(name: "snapshot") { element, errorOrNil -> Bool in
        guard let view = element as? UIView else {
            return false
        }

        let snapshotInfo = SnapshotControllerInfo(testName: testName,
                                                  deviceAgnostic: deviceAgnostic,
                                                  recordMode: recordMode,
                                                  imagesDirectory: imagesDirectoryProvider.directory)
        let testController = controllerFactory.makeSnapshotController(withInfo: snapshotInfo)

        do {
            try testController.compare(viewOrLayer: view, selector: snapshotName, identifier: nil, tolerance: tolerance)
        } catch let error as NSError {
            errorOrNil?.pointee = error
        }

        if errorOrNil?.pointee == nil && recordMode {
            errorOrNil?.pointee = EarlGreySnapshotError.recording(deviceAgnostic: deviceAgnostic) as NSError
        }

        return errorOrNil?.pointee == nil
    }
}
