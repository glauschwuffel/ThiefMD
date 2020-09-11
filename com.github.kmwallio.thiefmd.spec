Name: com.github.kmwallio.thiefmd
Version: 0.0.6
Release: 1%{?dist}
Summary: The markdown editor worth stealing.
License: GPL-3.0+

Source0: com.github.kmwallio.thiefmd-0.0.6.tar.xz

BuildRequires: meson
BuildRequires: vala
BuildRequires: gcc
BuildRequires: pkgconfig(libmarkdown)
BuildRequires: pkgconfig(libxml-2.0)
BuildRequires: pkgconfig(gio-2.0)
BuildRequires: pkgconfig(gee-0.8)
BuildRequires: pkgconfig(glib-2.0)
BuildRequires: pkgconfig(gobject-2.0)
BuildRequires: pkgconfig(libarchive)
BuildRequires: pkgconfig(clutter-1.0)
BuildRequires: pkgconfig(granite)
BuildRequires: pkgconfig(gtksourceview-3.0)
BuildRequires: pkgconfig(gtk+-3.0)
BuildRequires: pkgconfig(gtkspell3-3.0)
BuildRequires: pkgconfig(webkit2gtk-4.0)

%description

%package devel
Summary: Development files for %{name}
Requires: %{name}%{?_isa} = %{?epoch:%{epoch}:}{version}-%{release}

%description devel
Development files for %{name}.

%prep
%autosetup

%build
%meson
%meson_build

%install
%meson_install
rm -vf %{buildroot}%{_libdir}/libultheme.a

%check
%meson_test

%files
%{_bindir}/com.github.kmwallio.thiefmd
%{_libdir}/libgxml-0.20.so.2
%{_libdir}/libgxml-0.20.so.2.0.2
/usr/include/gxml-0.20/gxml/gxml.h
/usr/include/ultheme.h
/usr/lib64/girepository-1.0/GXml-0.20.typelib
/usr/lib64/pkgconfig/gxml-0.20.pc
/usr/lib64/pkgconfig/ultheme.pc
/usr/share/applications/com.github.kmwallio.thiefmd.desktop
/usr/share/com.github.kmwallio.thiefmd/scripts/auto-render.min.js
/usr/share/com.github.kmwallio.thiefmd/scripts/highlight.js
/usr/share/com.github.kmwallio.thiefmd/scripts/katex.min.js
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_AMS-Regular.ttf
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_AMS-Regular.woff
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_AMS-Regular.woff2
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Caligraphic-Bold.ttf
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Caligraphic-Bold.woff
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Caligraphic-Bold.woff2
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Caligraphic-Regular.ttf
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Caligraphic-Regular.woff
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Caligraphic-Regular.woff2
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Fraktur-Bold.ttf
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Fraktur-Bold.woff
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Fraktur-Bold.woff2
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Fraktur-Regular.ttf
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Fraktur-Regular.woff
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Fraktur-Regular.woff2
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Main-Bold.ttf
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Main-Bold.woff
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Main-Bold.woff2
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Main-BoldItalic.ttf
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Main-BoldItalic.woff
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Main-BoldItalic.woff2
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Main-Italic.ttf
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Main-Italic.woff
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Main-Italic.woff2
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Main-Regular.ttf
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Main-Regular.woff
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Main-Regular.woff2
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Math-BoldItalic.ttf
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Math-BoldItalic.woff
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Math-BoldItalic.woff2
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Math-Italic.ttf
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Math-Italic.woff
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Math-Italic.woff2
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_SansSerif-Bold.ttf
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_SansSerif-Bold.woff
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_SansSerif-Bold.woff2
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_SansSerif-Italic.ttf
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_SansSerif-Italic.woff
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_SansSerif-Italic.woff2
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_SansSerif-Regular.ttf
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_SansSerif-Regular.woff
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_SansSerif-Regular.woff2
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Script-Regular.ttf
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Script-Regular.woff
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Script-Regular.woff2
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Size1-Regular.ttf
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Size1-Regular.woff
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Size1-Regular.woff2
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Size2-Regular.ttf
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Size2-Regular.woff
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Size2-Regular.woff2
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Size3-Regular.ttf
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Size3-Regular.woff
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Size3-Regular.woff2
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Size4-Regular.ttf
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Size4-Regular.woff
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Size4-Regular.woff2
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Typewriter-Regular.ttf
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Typewriter-Regular.woff
/usr/share/com.github.kmwallio.thiefmd/styles/fonts/KaTeX_Typewriter-Regular.woff2
/usr/share/com.github.kmwallio.thiefmd/styles/highlight.css
/usr/share/com.github.kmwallio.thiefmd/styles/katex.min.css
/usr/share/com.github.kmwallio.thiefmd/styles/preview.css
/usr/share/fonts/truetype/thiefmd/iAWriterDuospace-Regular.ttf
/usr/share/gir-1.0/GXml-0.20.gir
/usr/share/glib-2.0/schemas/com.github.kmwallio.thiefmd.gschema.xml
/usr/share/gtksourceview-3.0/styles/thiefmd.xml
/usr/share/icons/hicolor/128x128/apps/com.github.kmwallio.thiefmd.svg
/usr/share/icons/hicolor/48x48/apps/com.github.kmwallio.thiefmd.svg
/usr/share/icons/hicolor/64x64/apps/com.github.kmwallio.thiefmd.svg
/usr/share/icons/hicolor/symbolicxsymbolic/apps/com.github.kmwallio.thiefmd.svg
/usr/share/locale/ca/LC_MESSAGES/GXml-0.20.mo
/usr/share/locale/cs/LC_MESSAGES/GXml-0.20.mo
/usr/share/locale/da/LC_MESSAGES/GXml-0.20.mo
/usr/share/locale/de/LC_MESSAGES/GXml-0.20.mo
/usr/share/locale/el/LC_MESSAGES/GXml-0.20.mo
/usr/share/locale/en_GB/LC_MESSAGES/GXml-0.20.mo
/usr/share/locale/es/LC_MESSAGES/GXml-0.20.mo
/usr/share/locale/eu/LC_MESSAGES/GXml-0.20.mo
/usr/share/locale/fr/LC_MESSAGES/GXml-0.20.mo
/usr/share/locale/hu/LC_MESSAGES/GXml-0.20.mo
/usr/share/locale/id/LC_MESSAGES/GXml-0.20.mo
/usr/share/locale/pl/LC_MESSAGES/GXml-0.20.mo
/usr/share/locale/pt/LC_MESSAGES/GXml-0.20.mo
/usr/share/locale/pt_BR/LC_MESSAGES/GXml-0.20.mo
/usr/share/locale/ro/LC_MESSAGES/GXml-0.20.mo
/usr/share/locale/sl/LC_MESSAGES/GXml-0.20.mo
/usr/share/locale/sr/LC_MESSAGES/GXml-0.20.mo
/usr/share/locale/sr@latin/LC_MESSAGES/GXml-0.20.mo
/usr/share/locale/sv/LC_MESSAGES/GXml-0.20.mo
/usr/share/locale/uk/LC_MESSAGES/GXml-0.20.mo
/usr/share/locale/zh_CN/LC_MESSAGES/GXml-0.20.mo
/usr/share/metainfo/com.github.kmwallio.thiefmd.appdata.xml
/usr/share/vala/vapi/gxml-0.20.deps
/usr/share/vala/vapi/gxml-0.20.vapi
/usr/share/vala/vapi/ultheme.vapi

%files devel
%{_libdir}/libgxml-0.20.so

%post -p /sbin/ldconfig
%postun -p /sbin/ldconfig

%changelog
* Wed Sep 09 2020 kmwallio <mwallio@gmail.com> - 
- Add theme support