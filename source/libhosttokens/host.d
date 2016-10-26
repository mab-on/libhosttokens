/**
* Copyright:
* (C) 2016 Martin Brzenska
*
* License:
* Distributed under the terms of the MIT license.
* Consult the provided LICENSE.md file for details
*/
module libhosttokens.host;

auto parseHost(string host) {
  import std.array : split;
  import std.algorithm.searching : find;
  import std.algorithm.mutation : reverse;
  import std.socket : parseAddress , Address , SocketException;

  import libhosttokens.ccSLD : ccSLDs;

  struct Host {
    string host;
    string[] subdomains;
    string lowlevelDomain;
    string[] reglevels = [];
    bool isIP;

    string toString() {
      return this.host;
    }

    @property tld() {
      import std.array : join;
      return this.reglevels.join(".");
    }

    @property paylevelDomain() {
      return (this.lowlevelDomain.length ? this.lowlevelDomain ~ ( this.isIP ? "" : ".") : "") ~ this.tld;
    }

    @property subdomain() {
      import std.array : join;
      return this.subdomains.join(".");
    }

  }

  Host sHost;
  bool isIPaddr = true;
  Address addr;
  try
  {
    addr = parseAddress(host);
  }
  catch(SocketException e) {
    isIPaddr = false;
  }

  sHost.host = host;
  if(isIPaddr) {
    sHost.isIP = true;
    sHost.lowlevelDomain = addr.toAddrString();
    return sHost;
  }

  auto arrHost = split(host , ".");
  arrHost.reverse();

  //Parse TLD/ccSLD
  string ccSLD;
  size_t lastLevel;
  foreach(size_t level , string domain ; arrHost) {
    lastLevel = level;
    if( level == 0 && domain !in ccSLDs) {
      sHost.reglevels ~= domain;
      break;
    }
    else if( level == 0 && domain in ccSLDs) {
      ccSLD = domain;
      sHost.reglevels ~= ccSLD;
    }
    else if( level == 1 && ccSLDs[ccSLD].find(domain)) {
      sHost.reglevels ~= domain;
      break;
    }
  }
  sHost.reglevels.reverse();

  //Paydomain
  sHost.lowlevelDomain = arrHost[++lastLevel];

  //Subdomains
  for(size_t i = ++lastLevel ; i < arrHost.length ; i++) {
    sHost.subdomains ~= arrHost[i];
  }
  sHost.subdomains.reverse();

  return sHost;
}

unittest {

  auto host = parseHost("profil.mab-on.net");
  assert(host.lowlevelDomain == "mab-on");
  assert(host.tld == "net");
  assert(host.subdomain == "profil");
  assert(host.paylevelDomain == "mab-on.net");

  host = parseHost("www.amazon.co.uk");
  assert(host.lowlevelDomain == "amazon");
  assert(host.tld == "co.uk");
  assert(host.subdomain == "www");
  assert(host.paylevelDomain == "amazon.co.uk");

  host = parseHost("www.herts.police.uk");
  assert(host.lowlevelDomain == "herts");
  assert(host.tld == "police.uk");
  assert(host.subdomain == "www");
  assert(host.paylevelDomain == "herts.police.uk");

  host = parseHost("www.ub.uni-koeln.de");
  assert(host.lowlevelDomain == "uni-koeln");
  assert(host.tld == "de");
  assert(host.subdomain == "www.ub");
  assert(host.paylevelDomain == "uni-koeln.de");

  host = parseHost("127.0.0.1");
  assert(host.lowlevelDomain == "127.0.0.1" , host.lowlevelDomain);
  assert(host.tld == "");
  assert(host.subdomain == "");
  assert(host.paylevelDomain == "127.0.0.1");

  import std.format : format;
  host = parseHost("2001:0db8:85a3:08d3:1319:8a2e:0370:7344");
  assert(host.lowlevelDomain == "2001:db8:85a3:8d3:1319:8a2e:370:7344" , host.lowlevelDomain);
  //Note, that Host.host is the original IPv6 String - other properties shortens the address.
  assert(format("%s",host) == "2001:0db8:85a3:08d3:1319:8a2e:0370:7344");
  assert(host.tld == "");
  assert(host.subdomain == "");
  assert(host.paylevelDomain == "2001:db8:85a3:8d3:1319:8a2e:370:7344");
}