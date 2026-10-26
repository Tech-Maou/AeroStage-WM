public let stableAeroSpaceAppId: String = "io.github.tech-maou.AeroStageWM"
#if DEBUG
    public let aeroSpaceAppId: String = "io.github.tech-maou.AeroStageWM.debug"
    public let aeroSpaceAppName: String = "AeroStage WM-Debug"
#else
    public let aeroSpaceAppId: String = stableAeroSpaceAppId
    public let aeroSpaceAppName: String = "AeroStage WM"
#endif
