After installing the .otf file, apps will need to support 'discretionary ligatures' to work with the word-blocking (an option may be tucked away somewhere).

When using the .woff file in a web page, these ligatures can be enabled with
text-rendering: optimizeLegibility;
-webkit-font-variant-ligatures: discretionary-ligatures;
font-variant-ligatures: discretionary-ligatures;

Scunthorpe Sans is based on Aileron https://dotcolon.net/font/aileron/ and released under a CC0/public domain license https://creativecommons.org/publicdomain/zero/1.0/