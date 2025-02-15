extension PictureDefinition: CustomDebugStringConvertible {
  var debugDescription: String {
    let huesList = hues.map { "Hue(num: \($0.num), r: \($0.r), g: \($0.g), b: \($0.b))" }.joined(separator: ", ")

    return """
    PictureDefinition(
        id: \(id),
        hues: [\(huesList)],
        leftNumber: \(leftNumber),
        mandColor: Hue(num: \(mandColor.num), r: \(mandColor.r), g: \(mandColor.g), b: \(mandColor.b)),
        scale: \(scale),
        theta: \(theta),
        iterationsMax: \(iterationsMax),
        xCenter: \(xCenter),
        yCenter: \(yCenter),
        rSqLimit: \(rSqLimit),
        imageWidth: \(imageWidth),
        imageHeight: \(imageHeight),
        nBlocks: \(nBlocks),
        spacingColorFar: \(spacingColorFar),
        spacingColorNear: \(spacingColorNear),
        yY: \(yY),
        nImage: \(nImage),
        dFIterMin: \(dFIterMin),
        mandPowerReal: \(mandPowerReal)
    )
    """
  }
}
