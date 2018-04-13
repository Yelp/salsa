BUILD_TOOL?=xcodebuild
XCODEFLAGS=-project 'SalsaCompiler/SalsaCompiler.xcodeproj'

.PHONY binary:
binary:
	$(BUILD_TOOL) $(XCODEFLAGS) build