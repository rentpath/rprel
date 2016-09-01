Summary: rprel
Name: rprel
Version: 1.1.5
Release: 1%{?dist}
License: MIT
Group: Development/Tools
Packager: IDG Engineering Operations <idg.engops@rentpath.com>
URL: https://github.com/rentpath/rprel
Source0:  https://github.com/rentpath/rprel/archive/v%{version}.tar.gz
BuildRoot:  %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
Requires: erlang >= 18.3
Provides: Rprel

%description
Rprel (arr-pee-rell) is a tool for creating GitHub releases from a build artifact.

%prep
mkdir %{_sourcedir}/%{name}-%{version}
tar xzf %{SOURCE0} -C %{_sourcedir}


%install
%{__rm} -rf %{buildroot}
mkdir -p %{buildroot}%{appdir}/
%{__install} -D -m 0655 %{_sourcedir}/%{name}-%{version}/rel/rprel %{buildroot}%{_bindir}/rprel


%clean
%{__rm} -rf %{buildroot}


%files
%defattr(-,root,root,-)
%{_bindir}/%{name}


%changelog
* Thu Sep 1 2016 - Eric Himmelreich <ehimmelreich@rentpath.com> - 1.1.5
- Updated rpm file to v1.1.5
* Mon Jun 06 2016 - Colin Rymer <crymer@rentpath.com> - 1.0.0-1
- Initial release.
