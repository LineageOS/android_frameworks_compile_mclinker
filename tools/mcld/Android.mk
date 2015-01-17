LOCAL_PATH:= $(call my-dir)

LOCAL_MODULE_TAGS := optional

# Set up common build variables
# =====================================================

MCLD_C_INCLUDES := $(LOCAL_PATH)/include

MCLD_SRC_FILES := \
  main.cpp \
  lib/DynamicSectionOptions.cpp \
  lib/OptimizationOptions.cpp \
  lib/OutputFormatOptions.cpp \
  lib/PositionalOptions.cpp \
  lib/PreferenceOptions.cpp \
  lib/ScriptOptions.cpp \
  lib/SearchPathOptions.cpp \
  lib/SymbolOptions.cpp \
  lib/TargetControlOptions.cpp \
  lib/TripleOptions.cpp


MCLD_WHOLE_STATIC_LIBRARIES := \
  libmcldADT \
  libmcldCore \
  libmcldFragment \
  libmcldLD \
  libmcldLDVariant \
  libmcldMC \
  libmcldObject \
  libmcldScript \
  libmcldSupport \
  libmcldTarget

MCLD_SHARED_LIBRARIES := libLLVM

# Collect target specific code generation libraries
MCLD_ARM_LIBS := libmcldARMTarget libmcldARMInfo
MCLD_AARCH64_LIBS := libmcldAArch64Target libmcldAArch64Info
MCLD_MIPS_LIBS := libmcldMipsTarget libmcldMipsInfo
MCLD_X86_LIBS := libmcldX86Target libmcldX86Info

MCLD_MODULE:= ld.mc

# Executable the device
# =====================================================
include $(CLEAR_VARS)

LOCAL_C_INCLUDES := $(MCLD_C_INCLUDES)
LOCAL_SRC_FILES := $(MCLD_SRC_FILES)
LOCAL_WHOLE_STATIC_LIBRARIES := $(MCLD_WHOLE_STATIC_LIBRARIES)

# Add target specific code generation libraries
ifeq ($(TARGET_ARCH), arm)
  LOCAL_WHOLE_STATIC_LIBRARIES += $(MCLD_ARM_LIBS)
endif

# Include ARM libs to enable 32-bit linking on AARCH64 targets
ifeq ($(TARGET_ARCH), arm64)
  LOCAL_WHOLE_STATIC_LIBRARIES += $(MCLD_AARCH64_LIBS) \
                                  $(MCLD_ARM_LIBS)
endif

ifneq (, $(findstring mips,$(TARGET_ARCH)))
  LOCAL_WHOLE_STATIC_LIBRARIES += $(MCLD_MIPS_LIBS)
endif

# Add x86 libraries for both x86 and x86_64 targets
ifneq (, $(findstring x86,$(TARGET_ARCH)))
  LOCAL_WHOLE_STATIC_LIBRARIES += $(MCLD_X86_LIBS)
endif


# zlib's libnames are different for the host and target.
# For the target, it is the standard libz
LOCAL_SHARED_LIBRARIES := $(MCLD_SHARED_LIBRARIES) libz

LOCAL_MODULE := $(MCLD_MODULE)
include $(MCLD_DEVICE_BUILD_MK)
include $(BUILD_EXECUTABLE)

# Executable the host
# =====================================================
include $(CLEAR_VARS)

LOCAL_C_INCLUDES := $(MCLD_C_INCLUDES)
LOCAL_SRC_FILES := $(MCLD_SRC_FILES)

LOCAL_WHOLE_STATIC_LIBRARIES := $(MCLD_WHOLE_STATIC_LIBRARIES)
LOCAL_WHOLE_STATIC_LIBRARIES += $(MCLD_ARM_LIBS) \
                                $(MCLD_AARCH64_LIBS) \
                                $(MCLD_MIPS_LIBS) \
                                $(MCLD_X86_LIBS)

# zlib's libnames are different for the host and target.
# For the host, it is libz-host
LOCAL_SHARED_LIBRARIES := $(MCLD_SHARED_LIBRARIES) libz-host

LOCAL_MODULE := $(MCLD_MODULE)
include $(MCLD_HOST_BUILD_MK)
include $(BUILD_HOST_EXECUTABLE)
