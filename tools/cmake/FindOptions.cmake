macro(append var string)
  set(${var} "${${var}} ${string}")
endmacro(append)

set(SANITIZE_FLAGS "")

if(ROARING_SANITIZE)
  set(ROARING_SANITIZE_FLAGS "-fsanitize=address -fno-omit-frame-pointer -fsanitize=undefined -fno-sanitize-recover=all")
  if (CMAKE_COMPILER_IS_GNUCC)
    # Ubuntu bug for GCC 5.0+ (safe for all versions)
    append(CMAKE_EXE_LINKER_FLAGS "-fuse-ld=gold")
    append(CMAKE_SHARED_LINKER_FLAGS "-fuse-ld=gold")
  endif()
endif()

if((NOT MSVC) AND ROARING_ARCH)
set(OPT_FLAGS "-march=${ROARING_ARCH}")
endif()
if(ROARING_DISABLE_X64)
  # we can manually disable any optimization for x64
  set (OPT_FLAGS "${OPT_FLAGS} -DROARING_DISABLE_X64" )
endif()
if(ROARING_DISABLE_AVX)
   # we can manually disable AVX by defining DISABLEAVX
   set (OPT_FLAGS "${OPT_FLAGS} -DROARING_DISABLE_AVX" )
 endif()
if(ROARING_DISABLE_NEON)
  set (OPT_FLAGS "${OPT_FLAGS} -DDISABLENEON" )
endif()

if(FORCE_AVX) # some compilers like clang do not automagically define __AVX2__ and __BMI2__ even when the hardware supports it
if(NOT MSVC)
   set (OPT_FLAGS "${OPT_FLAGS} -mavx2 -mbmi2")
else()
   set (OPT_FLAGS "${OPT_FLAGS} /arch:AVX2")
endif()
endif()

if(FORCE_AVX512) # some compilers like clang do not automagically define __AVX512__ even when the hardware supports it
if(NOT MSVC)
   set (OPT_FLAGS "${OPT_FLAGS} -mbmi2 -mavx512f -mavx512bw -mavx512dq")
else()
   set (OPT_FLAGS "${OPT_FLAGS} /arch:AVX512")
endif()
endif()

if(NOT MSVC)
set(STD_FLAGS "-std=c11 -fPIC")
set(CXXSTD_FLAGS "-std=c++11 -fPIC")
endif()

set(WARNING_FLAGS "-Wall")
if(NOT MSVC)
set(WARNING_FLAGS "${WARNING_FLAGS} -Wextra -Wsign-compare -Wshadow -Wwrite-strings -Wpointer-arith -Winit-self")
endif()

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${STD_FLAGS} ${OPT_FLAGS} ${INCLUDE_FLAGS} ${WARNING_FLAGS} ${ROARING_SANITIZE_FLAGS} ")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CXXSTD_FLAGS} ${OPT_FLAGS} ${INCLUDE_FLAGS} ${WARNING_FLAGS} ${ROARING_SANITIZE_FLAGS} ")

if(MSVC)
add_definitions( "/W3 /D_CRT_SECURE_NO_WARNINGS /wd4005 /wd4996 /wd4267 /wd4244  /wd4113 /nologo")
endif()
if(MSVC_VERSION GREATER 1910)
  add_definitions("/permissive-")
endif()
if(ROARING_LINK_STATIC)
  if(NOT MSVC)
    set(CMAKE_EXE_LINKER_FLAGS "-static")
  else()
    MESSAGE(WARNING "Option ROARING_LINK_STATIC is not supported with MSVC and was ignored")
  endif()
endif()
