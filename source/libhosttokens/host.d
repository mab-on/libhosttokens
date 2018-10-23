/**
* Parses the URL-host (not the url)
* e.g. www.github.com , lb1.www.some-cool-domain.co.uk , 127.0.0.1 , 2001:0db8:0:0:0:0:1428:57ab
*
* Copyright:
* (C) 2016 Martin Brzenska
*
* License:
* Distributed under the terms of the MIT license.
* Consult the provided LICENSE.md file for details
*/
module libhosttokens.host;


/**
* A parsed hostname.
*/
struct Host
{
  ///The original hostname.
  string host;
  ///A list of subdomains.
  string[] subdomains;
  ///The part of the domain between the subdomain and tld/ccSLD.
  string lowlevelDomain;
  ///A list of TLD or ccSLD and TLD.
  string[] reglevels = [];
  ///True if the hostname is a IP (IPv4 or IPv6).
  bool isIP;


  string toString() {
    return this.host;
  }

  ///The TLD or ccSLD.TLD.
  @property tld() {
    import std.array : join;
    return this.reglevels.join(".");
  }

  ///The part of a hostname, that is before (right of) the subdomains.
  @property paylevelDomain() {
    return (this.lowlevelDomain.length ? this.lowlevelDomain ~ ( this.isIP ? "" : ".") : "") ~ this.tld;
  }

  ///The part of a hostname, that is after (left of) the paylevelDomain.
  @property subdomain() {
    import std.array : join;
    return this.subdomains.join(".");
  }

}

/**
* Parses a hostname
* Params:
*   host = the Hostname to be parsed
*
* Returns: A Host struct containing the the hostname elements (subdomain , paylevelDomain , tld ...).
*/
immutable(Host) parseHost(string host) {
  import std.array : split;
  import std.algorithm.searching : find;
  import std.algorithm.mutation : reverse;
  import std.socket : parseAddress , Address , SocketException;

  import libhosttokens.ccSLD : ccSLDs;
  
  string[] sHost_subdomains;
  string sHost_lowlevelDomain;
  string[] sHost_reglevels;
  bool sHost_isIP;

  bool isIPaddr = true;
  Address addr;
  try
  {
    addr = parseAddress(host);
  }
  catch(SocketException e) {
    isIPaddr = false;
  }

  if(isIPaddr) {
    sHost_isIP = true;
    sHost_lowlevelDomain = addr.toAddrString();
    return immutable(Host)(
      host,
      [],
      sHost_lowlevelDomain,
      [],
      sHost_isIP
    );
  }

  auto arrHost = split(host , ".");
  arrHost.reverse();

  //Parse TLD/ccSLD
  string ccSLD;
  size_t lastLevel;
  foreach(size_t level , string domain ; arrHost) {
    lastLevel = level;
    if( level == 0 && domain !in ccSLDs) {
      sHost_reglevels ~= domain;
      break;
    }
    else if( level == 0 && domain in ccSLDs) {
      ccSLD = domain;
      sHost_reglevels ~= ccSLD;
    }
    else if( level == 1 && ccSLDs[ccSLD].find(domain)) {
      sHost_reglevels ~= domain;
      break;
    }
  }
  sHost_reglevels.reverse();

  //Paydomain
  sHost_lowlevelDomain = arrHost[++lastLevel];

  //Subdomains
  for(size_t i = ++lastLevel ; i < arrHost.length ; i++) {
    sHost_subdomains ~= arrHost[i];
  }
  sHost_subdomains.reverse();

  return immutable(Host)(
    host,
    sHost_subdomains.idup,
    sHost_lowlevelDomain,
    sHost_reglevels.idup,
    sHost_isIP
  );
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