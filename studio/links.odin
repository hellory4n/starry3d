package studio

import st "../starrylib"

URL_THIRDPARTY_LICENSES ::
	"https://github.com/hellory4n/starry3d/blob/dev/COPYRIGHT.md" when st.VERSION_PRERELEASE else "https://github.com/hellory4n/starry3d/blob/COPYRIGHT.md"
URL_SOURCE_CODE ::
	"https://github.com/hellory4n/starry3d" when st.VERSION_PRERELEASE else "https://github.com/hellory4n/starry3d/tree/dev"
URL_DOCUMENTATION ::
	"https://github.com/hellory4n/starry3d/tree/dev/docs" when st.VERSION_PRERELEASE else "https://github.com/hellory4n/starry3d/tree/main/docs"
