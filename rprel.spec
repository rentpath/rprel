Summary: rprel
Name: rprel
Version: 2.2.6
Release: 1%{?dist}
License: MIT
Group: Development/Tools
Packager: IDG Engineering Operations <idg.engops@rentpath.com>
URL: https://github.com/rentpath/rprel
Source0:  https://github.com/rentpath/rprel/archive/v%{version}.tar.gz
BuildRoot:  %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
Requires: erlang >= 20
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
* Wed Jun 20 2018 - Pasha Lifshiz <plifshiz@rentpath.com> - 2.2.5
* Tue Jun 19 2018 - Pasha Lifshiz <plifshiz@rentpath.com> - 2.2.4
- Updated most dependencies
* Tue Jun 12 2018 - Brad Anderson <banderson@rentpath.com> - 2.2.3
- updating version
* Tue Jan 17 2017 - Pasha Lifshiz <plifshiz@rentpath.com> - 2.2.1
- Set `target_commitish` to full commit sha for a release
* Fri Jan 13 2017 - Pasha Lifshiz <plifshiz@rentpath.com> - 2.2.0
- Create annotated tag before making a release
* Fri Jan 13 2017 - Tyler Long <tlong@rentpath.com> - 2.1.2
- Update mix version
* Fri Jan 13 2017 - Tyler Long <tlong@rentpath.com> - 2.1.1
- Fix errors in Koji build
* Thu Jan 12 2017 - Tyler Long <tlong@rentpath.com> - 2.1.0
- Update elixir to version 1.4.0
* Tue Dec 20 2016 - Tyler Long <tlong@rentpath.com> - 2.0.1
- Increase timeout
* Mon Dec 19 2016 - Tyler Long <tlong@rentpath.com> - 2.0.0
- Add branch argument to `Release` step
* Thu Sep 1 2016 - Eric Himmelreich <ehimmelreich@rentpath.com> - 1.1.6
- Updated rpm file to v1.1.6
* Thu Sep 1 2016 - Eric Himmelreich <ehimmelreich@rentpath.com> - 1.1.5
- Updated rpm file to v1.1.5
* Mon Jun 06 2016 - Colin Rymer <crymer@rentpath.com> - 1.0.0-1
- Initial release.
