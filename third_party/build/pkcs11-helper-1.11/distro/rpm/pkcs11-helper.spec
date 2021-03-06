# doc support
%bcond_with doc

%define		name		pkcs11-helper
%define		version		1.11
%define		release		2
%define		prefix		/usr

Summary:	pkcs11-helper is a helper library for the use with smart cards and the PKCS#11 API
Name:		%{name}
Version:	%{version}
Release:	%{release}
License:	GPL-2/BSD
Vendor:		The OpenSC Project, http://www.opensc-project.org
Packager:	Alon Bar-Lev <alon.barlev@gmail.com>
Group:		System/Crypto
Url:		http://www.opensc-project.org/pkcs11-helper
Source:		http://www.opensc-project.org/files/pkcs11-helper/%{name}-%{version}.tar.bz2
BuildRoot:	/var/tmp/%{name}-%{version}-%{release}
%if %{with doc}
BuildRequires:	doxygen
%endif
BuildRequires:	openssl-devel >= 0.9.7a
Requires:	openssl >= 0.9.7a
Provides:	%{name} = %{version}
%description
pkcs11-helper allows using multiple PKCS#11 providers at the same 
time, selecting keys by id, label or certificate subject, handling 
card removal and card insert events, handling card re-insert to a 
different slot, supporting session expiration serialization and much 
more, all using a simple API.

%package devel
Summary:	pkcs11-helper development files
Group:		Development/Libraries
Requires:	%{name} >= %{version}
Requires:	pkgconfig
%description devel
pkcs11-helper development files.

%prep
rm -rf "${RPM_BUILD_ROOT}"
%setup -q

%build
%configure -q \
	--disable-rpath \
%if %{with doc}
	--enable-doc
%endif

make %{?_smp_mflags}

%install
rm -rf "${RPM_BUILD_ROOT}"
%makeinstall 

%clean
rm -rf "${RPM_BUILD_ROOT}"

%files
%defattr(-,root,root)
%{_libdir}/libpkcs11-helper.*
%{_mandir}/*
%{_docdir}/%{name}/COPYING*
%{_docdir}/%{name}/README

%files devel
%defattr(-,root,root,-)
%{_includedir}/*
%{_libdir}/pkgconfig/*
%{_datadir}/aclocal/*
%if %{with doc}
%{_docdir}/%{name}/api/*
%endif

%changelog
* Fri Nov 11 2011 Aon Bar-Lev <alon.barlev@gmail.com>
- Cleanups.

* Mon Feb 15 2007 Aon Bar-Lev <alon.barlev@gmail.com>
- Modify docs location.

* Mon Jan 15 2007 Eddy Nigg <eddy_nigg@startcom.org>
- Make doxygen dependency only for doc builds 

* Tue Jan 9 2007 Eddy Nigg <eddy_nigg@startcom.org>
- Build new version 1.03

* Sun Jan 7 2007 Eddy Nigg <eddy_nigg@startcom.org>
- Fix for pkgconfig.

* Mon Nov 27 2006 Eddy Nigg <eddy_nigg@startcom.org>
- Fix documentation.

* Sun Nov 26 2006 Eddy Nigg <eddy_nigg@startcom.org>
- Initial build for StartCom Linux 5.0.x
