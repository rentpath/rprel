%define version-number %(grep version %{sourcedir}/mix.exs | sed -e 's/version: "\(.*\)",/\1/' | tr -s " ")
Summary: rprel
Name: Rprel
Version: %{version-number}
Release: 1%{?dist}
License: MIT
Group: Development/Tools
Packager: IDG Engineering Operations <idg.engops@rentpath.com>
Source0: https://github.com/rentpath/rprel/archive/v${version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
BuildRequires: elixir, erlang, make
Requires: erlang
Provides: Rprel
%description
Rprel (arr-pee-rell) is a tool for creating GitHub releases from a build artifact.
%prep
%setup
%build
%{__make}
%install
%{__rm} -rf %{buildroot}
%{__install} -Dp -m0755 rprel %{buildroot}/usr/bin/rprel
%clean
%{__rm} -rf %{buildroot}
%files
%attr(0755,root,root) /usr/bin/rprel
%changelog
* Mon Jun 06 2016 - Colin Rymer <crymer@rentpath.com> - 1.0.0-1
- Initial release.
